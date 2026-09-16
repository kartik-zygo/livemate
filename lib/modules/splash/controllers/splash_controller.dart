import 'dart:async';

import 'package:get/get.dart';

import '../../../app/bindings/initial_binding.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/onboarding_service.dart';

/// The auth gate. A restored session goes straight to the shell, everything
/// else to sign-in — after a short beat so the brand mark does not flash.
class SplashController extends GetxController {
  SplashController(this._auth, this._onboarding);

  final AuthService _auth;
  final OnboardingService _onboarding;

  @override
  void onReady() {
    super.onReady();
    _decide();
  }

  Future<void> _decide() async {
    // AuthService.init() already ran in the initial binding; this only waits
    // out the animation so the transition does not feel like a glitch.
    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (_auth.isSignedIn && _auth.profile != null) {
      // Warm reference data, the shortlist and the badge in the background —
      // a failure there must never strand the user on the splash screen.
      unawaited(InitialBinding.warmUpSignedIn().catchError((Object _) {}));
      Get.offAllNamed(Routes.root);
      return;
    }

    // A restored session skips the intro entirely: someone who has signed in
    // before does not need to be sold the app again.
    Get.offAllNamed(_onboarding.seen.value ? Routes.login : Routes.onboarding);
  }
}
