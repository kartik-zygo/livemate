import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/onboarding_service.dart';
import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Eager, not lazy: SplashView never reads `controller`, so a lazyPut would
    // never be resolved and onReady() — the auth gate — would never run.
    Get.put(
      SplashController(Get.find<AuthService>(), Get.find<OnboardingService>()),
    );
  }
}
