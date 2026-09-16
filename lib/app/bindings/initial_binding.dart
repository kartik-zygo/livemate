import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../core/network/dio_client.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/enquiry_badge_service.dart';
import '../../core/services/onboarding_service.dart';
import '../../core/services/reference_service.dart';
import '../../core/services/shortlist_service.dart';
import '../../data/providers/auth_api_provider.dart';
import '../../data/providers/enquiry_api_provider.dart';
import '../../data/providers/finder_post_api_provider.dart';
import '../../data/providers/reference_api_provider.dart';
import '../../data/providers/saved_api_provider.dart';
import '../../data/providers/search_api_provider.dart';
import '../../data/providers/tenant_listing_api_provider.dart';
import '../../data/providers/user_api_provider.dart';
import '../../data/repositories/enquiry_repository.dart';
import '../../data/repositories/finder_post_repository.dart';
import '../../data/repositories/reference_repository.dart';
import '../../data/repositories/saved_repository.dart';
import '../../data/repositories/search_repository.dart';
import '../../data/repositories/tenant_listing_repository.dart';
import '../../data/repositories/user_repository.dart';

/// Wires the whole graph once, in dependency order.
///
/// [DioClient] reads its token straight off the Supabase client rather than
/// from [AuthService], which keeps the network layer free of a circular
/// dependency on the service that needs it.
class InitialBinding {
  const InitialBinding._();

  static Future<void> register() async {
    final client = DioClient(
      tokenProvider: () =>
          sb.Supabase.instance.client.auth.currentSession?.accessToken,
      onRefresh: () async {
        try {
          final res = await sb.Supabase.instance.client.auth.refreshSession();
          return res.session?.accessToken;
        } catch (_) {
          return null;
        }
      },
      onSessionExpired: () {
        if (Get.isRegistered<AuthService>()) {
          Get.find<AuthService>().user.value = null;
        }
      },
    );
    Get.put<DioClient>(client, permanent: true);

    // Providers — raw Dio calls, one per resource.
    Get.put(AuthApiProvider(client), permanent: true);
    Get.put(UserApiProvider(client), permanent: true);
    Get.put(ReferenceApiProvider(client), permanent: true);
    Get.put(TenantListingApiProvider(client), permanent: true);
    Get.put(FinderPostApiProvider(client), permanent: true);
    Get.put(EnquiryApiProvider(client), permanent: true);
    Get.put(SavedApiProvider(client), permanent: true);
    Get.put(SearchApiProvider(client), permanent: true);

    // Repositories — models in and out, the only thing that talks to providers.
    Get.put(
      UserRepository(Get.find<AuthApiProvider>(), Get.find<UserApiProvider>()),
      permanent: true,
    );
    Get.put(
      ReferenceRepository(Get.find<ReferenceApiProvider>()),
      permanent: true,
    );
    Get.put(
      TenantListingRepository(Get.find<TenantListingApiProvider>()),
      permanent: true,
    );
    Get.put(
      FinderPostRepository(Get.find<FinderPostApiProvider>()),
      permanent: true,
    );
    Get.put(EnquiryRepository(Get.find<EnquiryApiProvider>()), permanent: true);
    Get.put(SavedRepository(Get.find<SavedApiProvider>()), permanent: true);
    Get.put(SearchRepository(Get.find<SearchApiProvider>()), permanent: true);

    // Services — app-wide state that outlives any single route.
    await Get.putAsync<AuthService>(
      () => AuthService(Get.find<UserRepository>()).init(),
      permanent: true,
    );
    await Get.putAsync<ReferenceService>(
      () => ReferenceService(Get.find<ReferenceRepository>()).init(),
      permanent: true,
    );
    await Get.putAsync<OnboardingService>(
      () => OnboardingService().init(),
      permanent: true,
    );
    Get.put(ShortlistService(Get.find<SavedRepository>()), permanent: true);
    Get.put(
      EnquiryBadgeService(Get.find<EnquiryRepository>()),
      permanent: true,
    );
  }

  /// Everything that needs a signed-in user, warmed once after auth so the
  /// first screen is not waiting on three sequential round trips.
  static Future<void> warmUpSignedIn() async {
    await Future.wait([
      Get.find<ReferenceService>().ensureLoaded(),
      Get.find<ShortlistService>().refresh(),
      Get.find<EnquiryBadgeService>().refresh(),
    ]);
  }

  /// Clears per-user state on sign-out so the next account starts clean.
  static void clearSignedInState() {
    Get.find<ShortlistService>().clear();
    Get.find<EnquiryBadgeService>().clear();
  }
}
