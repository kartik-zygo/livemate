import 'package:get/get.dart';

import '../../../core/services/reference_service.dart';
import '../../../data/repositories/finder_post_repository.dart';
import '../controllers/create_finder_post_controller.dart';

class CreateFinderPostBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => CreateFinderPostController(
        Get.find<FinderPostRepository>(),
        Get.find<ReferenceService>(),
      ),
    );
  }
}
