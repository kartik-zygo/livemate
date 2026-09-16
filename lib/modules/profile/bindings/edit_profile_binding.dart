import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../data/repositories/user_repository.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => EditProfileController(
        Get.find<UserRepository>(),
        Get.find<AuthService>(),
      ),
    );
  }
}
