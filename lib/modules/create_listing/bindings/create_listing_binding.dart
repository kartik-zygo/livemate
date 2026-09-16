import 'package:get/get.dart';

import '../../../core/services/reference_service.dart';
import '../../../data/repositories/tenant_listing_repository.dart';
import '../controllers/create_listing_controller.dart';

class CreateListingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => CreateListingController(
        Get.find<TenantListingRepository>(),
        Get.find<ReferenceService>(),
      ),
    );
  }
}
