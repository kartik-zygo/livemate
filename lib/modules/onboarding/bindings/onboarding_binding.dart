import 'package:get/get.dart';

import '../../../core/services/onboarding_service.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OnboardingController(Get.find<OnboardingService>()));
  }
}
