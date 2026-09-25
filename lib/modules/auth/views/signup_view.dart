import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/signup_controller.dart';
import '../widgets/auth_shell.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      showHero: false,
      onBack: controller.goToLogin,
      title: 'Create your account',
      subtitle: 'One profile to list a room or find one.',
      form: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => FormErrorBanner(message: controller.formError.value)),
            AppTextField(
              label: 'Full name',
              controller: controller.fullName,
              hint: 'Asha Ramesh',
              prefixIcon: Icons.person_rounded,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              validator: Validators.fullName,
              maxLength: 80,
            ),
            const SizedBox(height: 8),
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
                hint: 'At least 6 characters',
                prefixIcon: Icons.lock_rounded,
                obscureText: controller.obscure.value,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                validator: Validators.password,
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
            const SizedBox(height: 16),
            Obx(
              () => AppTextField(
                label: 'Confirm password',
                controller: controller.confirmPassword,
                hint: 'Type it again',
                prefixIcon: Icons.lock_reset_rounded,
                obscureText: controller.obscure.value,
                textInputAction: TextInputAction.done,
                validator: controller.validateConfirm,
                onSubmitted: (_) => controller.submit(),
              ),
            ),
            const SizedBox(height: 14),
            Obx(
              () => InkWell(
                onTap: controller.acceptedTerms.toggle,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: controller.acceptedTerms.value,
                          onChanged: (v) =>
                              controller.acceptedTerms.value = v ?? false,
                          activeColor: AppColors.brand500,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          'I agree to the MyFlat Homes terms of use and '
                          'privacy policy.',
                          style: AppTextStyles.body.copyWith(fontSize: 13.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Obx(
              () => AppButton(
                label: 'Create account',
                icon: Icons.arrow_forward_rounded,
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
          Text('Already have an account?', style: AppTextStyles.body),
          AppButton.ghost(
            label: 'Sign in',
            size: AppButtonSize.compact,
            onPressed: controller.goToLogin,
          ),
        ],
      ),
    );
  }
}
