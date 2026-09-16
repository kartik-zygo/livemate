import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:livemate/core/network/dio_client.dart';
import 'package:livemate/core/services/auth_service.dart';
import 'package:livemate/core/services/enquiry_badge_service.dart';
import 'package:livemate/core/services/onboarding_service.dart';
import 'package:livemate/core/services/reference_service.dart';
import 'package:livemate/core/services/shortlist_service.dart';
import 'package:livemate/data/models/city_model.dart';
import 'package:livemate/data/models/user_model.dart';
import 'package:livemate/data/providers/auth_api_provider.dart';
import 'package:livemate/data/providers/enquiry_api_provider.dart';
import 'package:livemate/data/providers/finder_post_api_provider.dart';
import 'package:livemate/data/providers/reference_api_provider.dart';
import 'package:livemate/data/providers/saved_api_provider.dart';
import 'package:livemate/data/providers/search_api_provider.dart';
import 'package:livemate/data/providers/tenant_listing_api_provider.dart';
import 'package:livemate/data/providers/user_api_provider.dart';
import 'package:livemate/data/repositories/enquiry_repository.dart';
import 'package:livemate/data/repositories/finder_post_repository.dart';
import 'package:livemate/data/repositories/reference_repository.dart';
import 'package:livemate/data/repositories/saved_repository.dart';
import 'package:livemate/data/repositories/search_repository.dart';
import 'package:livemate/data/repositories/tenant_listing_repository.dart';
import 'package:livemate/data/repositories/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures.dart';

/// The real object graph, minus the two services that reach outside the
/// process on construction.
///
/// Everything else — providers, repositories, controllers, views — is the
/// production code. Requests made during a pump fail against the test
/// binding's stub HTTP client and are swallowed by the controllers exactly as
/// a network error would be, which is all these tests need: the point is what
/// the widgets do while there is no data.
class TestGraph {
  const TestGraph._();

  /// [withData] swaps the read paths of the repositories for fixtures, so
  /// the screens render populated rather than empty. Half the reactive
  /// widgets in the app only exist inside a non-empty list.
  static Future<void> register({
    UserModel? user,
    CityModel? city,
    bool withData = false,
  }) async {
    // DioClient reads Env at construction, and Env reads dotenv.
    dotenv.testLoad(fileInput: '');
    SharedPreferences.setMockInitialValues(<String, Object>{});
    Get.testMode = true;
    await Get.deleteAll(force: true);

    final client = DioClient(
      tokenProvider: () => null,
      onRefresh: () async => null,
      onSessionExpired: () {},
    );
    Get.put<DioClient>(client, permanent: true);

    Get.put(AuthApiProvider(client), permanent: true);
    Get.put(UserApiProvider(client), permanent: true);
    Get.put(ReferenceApiProvider(client), permanent: true);
    Get.put(TenantListingApiProvider(client), permanent: true);
    Get.put(FinderPostApiProvider(client), permanent: true);
    Get.put(EnquiryApiProvider(client), permanent: true);
    Get.put(SavedApiProvider(client), permanent: true);
    Get.put(SearchApiProvider(client), permanent: true);

    Get.put(
      UserRepository(Get.find<AuthApiProvider>(), Get.find<UserApiProvider>()),
      permanent: true,
    );
    Get.put(
      ReferenceRepository(Get.find<ReferenceApiProvider>()),
      permanent: true,
    );
    Get.put<TenantListingRepository>(
      withData
          ? FakeTenantListingRepository(Get.find<TenantListingApiProvider>())
          : TenantListingRepository(Get.find<TenantListingApiProvider>()),
      permanent: true,
    );
    Get.put<FinderPostRepository>(
      withData
          ? FakeFinderPostRepository(Get.find<FinderPostApiProvider>())
          : FinderPostRepository(Get.find<FinderPostApiProvider>()),
      permanent: true,
    );
    Get.put<EnquiryRepository>(
      withData
          ? FakeEnquiryRepository(Get.find<EnquiryApiProvider>())
          : EnquiryRepository(Get.find<EnquiryApiProvider>()),
      permanent: true,
    );
    Get.put<SavedRepository>(
      withData
          ? FakeSavedRepository(Get.find<SavedApiProvider>())
          : SavedRepository(Get.find<SavedApiProvider>()),
      permanent: true,
    );
    Get.put<SearchRepository>(
      withData
          ? FakeSearchRepository(Get.find<SearchApiProvider>())
          : SearchRepository(Get.find<SearchApiProvider>()),
      permanent: true,
    );

    // AuthService subscribes to Supabase in onInit, and ReferenceService
    // touches disk in init. Both are stubbed; nothing else is.
    Get.put<AuthService>(
      _TestAuthService(Get.find<UserRepository>())..user.value = user,
      permanent: true,
    );
    final reference = _TestReferenceService(Get.find<ReferenceRepository>());
    if (city != null) reference.selectedCity.value = city;
    Get.put<ReferenceService>(reference, permanent: true);

    Get.put<OnboardingService>(
      await OnboardingService().init(),
      permanent: true,
    );
    Get.put(ShortlistService(Get.find<SavedRepository>()), permanent: true);
    Get.put(
      EnquiryBadgeService(Get.find<EnquiryRepository>()),
      permanent: true,
    );
  }

  static Future<void> reset() => Get.deleteAll(force: true);
}

class _TestAuthService extends AuthService {
  _TestAuthService(super.users);

  // The real onInit opens a Supabase auth stream, which needs an initialised
  // Supabase client. Skipping super is the entire point of this subclass.
  @override
  // ignore: must_call_super
  void onInit() {}
}

class _TestReferenceService extends ReferenceService {
  _TestReferenceService(super.repo);

  @override
  Future<void> ensureLoaded({bool force = false}) async {}
}
