import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/login_controller.dart';
import '../widgets/auth_shell.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Welcome back',
      subtitle: 'Sign in to pick up where you left off.',
      form: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => FormErrorBanner(message: controller.formError.value)),
            AppTextField(
              label: 'Email',
              controller: controller.email,
              hint: 'you@example.com',
              prefixIcon: Icons.alternate_email_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: Validators.email,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ],
            ),
            const SizedBox(height: 16),
            Obx(
              () => AppTextField(
                label: 'Password',
                controller: controller.password,
                hint: 'Your password',
                prefixIcon: Icons.lock_rounded,
                obscureText: controller.obscure.value,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                validator: Validators.password,
                onSubmitted: (_) => controller.submit(),
                suffix: IconButton(
                  onPressed: controller.toggleObscure,
                  tooltip: controller.obscure.value
                      ? 'Show password'
                      : 'Hide password',
                  icon: Icon(
                    controller.obscure.value
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    size: 20,
                    color: AppColors.inkTertiary,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: AppButton.ghost(
                label: 'Forgot password?',
                size: AppButtonSize.compact,
                onPressed: controller.forgotPassword,
              ),
            ),
            const SizedBox(height: 6),
            Obx(
              () => AppButton(
                label: 'Sign in',
                icon: Icons.login_rounded,
                loading: controller.submitting.value,
                onPressed: controller.submit,
              ),
            ),
          ],
        ),
      ),
      footer: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('New to Livemate?', style: AppTextStyles.body),
          AppButton.ghost(
            label: 'Create an account',
            size: AppButtonSize.compact,
            onPressed: controller.goToSignUp,
          ),
        ],
      ),
    );
  }
}
