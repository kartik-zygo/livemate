import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../app/bindings/initial_binding.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';

class SignupController extends GetxController {
  SignupController(this._auth);

  final AuthService _auth;

  final formKey = GlobalKey<FormState>();
  final fullName = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  final RxBool submitting = false.obs;
  final RxBool obscure = true.obs;
  final RxBool acceptedTerms = true.obs;
  final RxnString formError = RxnString();

  @override
  void onClose() {
    fullName.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.onClose();
  }

  void toggleObscure() => obscure.toggle();

  String? validateConfirm(String? value) {
    if ((value ?? '').isEmpty) return 'Re-enter your password';
    if (value != password.text) return 'Passwords do not match';
    return null;
  }

  Future<void> submit() async {
    formError.value = null;
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (!acceptedTerms.value) {
      formError.value = 'Accept the terms to create an account.';
      return;
    }

    submitting.value = true;
    try {
      // signUp signs in and then calls GET /auth/me, which is what actually
      // creates the profile row on the backend.
      await _auth.signUp(
        email: email.text,
        password: password.text,
        fullName: fullName.text,
      );
      await InitialBinding.warmUpSignedIn();
      Get.offAllNamed(Routes.root);
    } catch (e) {
      formError.value = AuthService.describeAuthError(e).message;
    } finally {
      submitting.value = false;
    }
  }

  void goToLogin() => Get.back<void>();
}
