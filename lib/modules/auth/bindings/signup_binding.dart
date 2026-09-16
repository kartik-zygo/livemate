import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../controllers/signup_controller.dart';

class SignupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SignupController(Get.find<AuthService>()));
  }
}
