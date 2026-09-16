import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../app/bindings/initial_binding.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_feedback.dart';

class LoginController extends GetxController {
  LoginController(this._auth);

  final AuthService _auth;

  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();

  final RxBool submitting = false.obs;
  final RxBool obscure = true.obs;
  final RxnString formError = RxnString();

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    super.onClose();
  }

  void toggleObscure() => obscure.toggle();

  Future<void> submit() async {
    formError.value = null;
    if (!(formKey.currentState?.validate() ?? false)) return;

    submitting.value = true;
    try {
      await _auth.signIn(email: email.text, password: password.text);
      await InitialBinding.warmUpSignedIn();
      Get.offAllNamed(Routes.root);
    } catch (e) {
      formError.value = AuthService.describeAuthError(e).message;
    } finally {
      submitting.value = false;
    }
  }

  Future<void> forgotPassword() async {
    final address = email.text.trim();
    if (Validators.email(address) != null) {
      formError.value = 'Enter your email above first, then tap Forgot.';
      return;
    }

    final confirmed = await AppFeedback.confirm(
      title: 'Send a reset link?',
      message: 'We will email a password reset link to $address.',
      confirmLabel: 'Send link',
    );
    if (!confirmed) return;

    try {
      await _auth.sendPasswordReset(address);
      AppFeedback.success('Reset link sent to $address.');
    } on ApiException catch (e) {
      AppFeedback.error(e.message);
    } catch (e) {
      AppFeedback.error(AuthService.describeAuthError(e).message);
    }
  }

  void goToSignUp() => Get.toNamed(Routes.signup);
}
