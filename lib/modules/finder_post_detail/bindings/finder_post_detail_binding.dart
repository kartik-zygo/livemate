import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../data/repositories/finder_post_repository.dart';
import '../controllers/finder_post_detail_controller.dart';

class FinderPostDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => FinderPostDetailController(
        Get.find<FinderPostRepository>(),
        Get.find<AuthService>(),
      ),
    );
  }
}
