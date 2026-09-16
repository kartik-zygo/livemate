import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/shortlist_service.dart';
import '../../../data/repositories/enquiry_repository.dart';
import '../../../data/repositories/tenant_listing_repository.dart';
import '../controllers/listing_detail_controller.dart';

class ListingDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => ListingDetailController(
        Get.find<TenantListingRepository>(),
        Get.find<EnquiryRepository>(),
        Get.find<AuthService>(),
        Get.find<ShortlistService>(),
      ),
    );
  }
}
