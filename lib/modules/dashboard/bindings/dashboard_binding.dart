import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/enquiry_badge_service.dart';
import '../../../core/services/reference_service.dart';
import '../../../core/services/shortlist_service.dart';
import '../../../data/repositories/enquiry_repository.dart';
import '../../../data/repositories/reference_repository.dart';
import '../../../data/repositories/saved_repository.dart';
import '../../../data/repositories/search_repository.dart';
import '../../discover/controllers/discover_controller.dart';
import '../../enquiries/controllers/enquiries_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../saved/controllers/saved_controller.dart';
import '../../search/controllers/listing_search_controller.dart';
import '../controllers/dashboard_controller.dart';

/// Every section lives inside one IndexedStack, so their controllers are
/// registered together and stay alive while the dashboard does — switching
/// sections must not refetch a feed the user already has.
///
/// Home reads from these same controllers rather than owning any state of its
/// own, which is why it costs nothing to open.
class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => DashboardController(
        Get.find<EnquiryBadgeService>(),
        Get.find<ShortlistService>(),
        Get.find<AuthService>(),
      ),
    );

    Get.lazyPut(
      () => DiscoverController(
        Get.find<SearchRepository>(),
        Get.find<ReferenceService>(),
      ),
    );

    Get.lazyPut(
      () => ListingSearchController(
        Get.find<SearchRepository>(),
        Get.find<ReferenceService>(),
      ),
    );

    Get.lazyPut(
      () => EnquiriesController(
        Get.find<EnquiryRepository>(),
        Get.find<EnquiryBadgeService>(),
      ),
    );

    Get.lazyPut(
      () => SavedController(
        Get.find<SavedRepository>(),
        Get.find<ShortlistService>(),
      ),
    );

    Get.lazyPut(
      () => ProfileController(
        Get.find<AuthService>(),
        Get.find<ReferenceRepository>(),
      ),
    );
  }
}
