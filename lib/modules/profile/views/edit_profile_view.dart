import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/enum_meta.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/pills.dart';
import '../../../data/models/enums.dart';
import '../../auth/widgets/auth_shell.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AmbientBackground(
        seed: 4,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 4, 18, 6),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: Get.back<void>,
                      icon: const Icon(Icons.arrow_back_rounded),
                      tooltip: 'Back',
                    ),
                    Text('Edit profile', style: AppTextStyles.h2),
                  ],
                ),
              ),
              Expanded(
                child: Form(
                  key: controller.formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
                    children: [
                      Obx(
                        () => FormErrorBanner(
                          message: controller.formError.value,
                        ),
                      ),
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTextField(
                              label: 'Full name',
                              controller: controller.fullName,
                              prefixIcon: Icons.person_rounded,
                              textCapitalization: TextCapitalization.words,
                              maxLength: 80,
                              required: true,
                              validator: Validators.fullName,
                            ),
                            const SizedBox(height: 8),
                            AppTextField(
                              label: 'Phone',
                              controller: controller.phone,
                              hint: '+91 98765 43210',
                              prefixIcon: Icons.phone_rounded,
                              keyboardType: TextInputType.phone,
                              maxLength: 20,
                              helper:
                                  'Shared only with people whose enquiry you '
                                  'accept.',
                              validator: Validators.phone,
                            ),
                            const SizedBox(height: 8),
                            AppTextField(
                              label: 'Occupation',
                              controller: controller.occupation,
                              hint: 'Software engineer',
                              prefixIcon: Icons.work_rounded,
                              maxLength: 80,
                              textCapitalization: TextCapitalization.sentences,
                              validator: Validators.occupation,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('About you', style: AppTextStyles.h3),
                            const SizedBox(height: 14),
                            AppTextField(
                              label: 'Bio',
                              controller: controller.bio,
                              hint:
                                  'Working professional, early riser, keep to '
                                  'myself on weeknights.',
                              maxLines: 5,
                              minLines: 3,
                              maxLength: 500,
                              textCapitalization: TextCapitalization.sentences,
                              validator: Validators.bio,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Gender',
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.inkPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 9),
                            Obx(
                              () => Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: ProfileGender.values
                                    .map(
                                      (g) => SelectChip(
                                        label: g.label,
                                        icon: g.icon,
                                        selected: controller.gender.value == g,
                                        onTap: () => controller.gender.value =
                                            controller.gender.value == g
                                            ? null
                                            : g,
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Obx(
                              () => PickerField(
                                label: 'Date of birth',
                                icon: Icons.cake_rounded,
                                value: controller.dateOfBirth.value == null
                                    ? null
                                    : Fmt.date(controller.dateOfBirth.value),
                                placeholder: 'Select your date of birth',
                                onTap: () =>
                                    controller.pickDateOfBirth(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              StickyActionBar(
                child: Obx(
                  () => AppButton(
                    label: 'Save changes',
                    icon: Icons.check_rounded,
                    loading: controller.saving.value,
                    onPressed: controller.save,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
