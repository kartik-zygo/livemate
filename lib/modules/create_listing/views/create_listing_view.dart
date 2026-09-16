import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/glass_card.dart';
import '../../auth/widgets/auth_shell.dart';
import '../controllers/create_listing_controller.dart';
import '../widgets/listing_steps.dart';

class CreateListingView extends GetView<CreateListingController> {
  const CreateListingView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) controller.back();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AmbientBackground(
          child: SafeArea(
            child: Column(
              children: [
                _StepHeader(controller: controller),
                Expanded(
                  child: Obx(
                    () => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      switchInCurve: Curves.easeOutCubic,
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween(
                            begin: const Offset(0.05, 0),
                            end: Offset.zero,
                          ).animate(anim),
                          child: child,
                        ),
                      ),
                      child: _StepBody(
                        key: ValueKey(controller.step.value),
                        controller: controller,
                      ),
                    ),
                  ),
                ),
                _StepActions(controller: controller),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.controller});

  final CreateListingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 4, 18, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: controller.back,
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: 'Back',
              ),
              Expanded(
                // Not reactive: `isEditing` is a plain getter over the listing
                // passed in as an argument, fixed for the life of the screen.
                // Wrapping it in Obx registered no observable, which is
                // exactly what makes GetX throw.
                child: Text(
                  controller.isEditing ? 'Edit listing' : 'List a room',
                  style: AppTextStyles.h2,
                ),
              ),
              Obx(
                () => Text(
                  'Step ${controller.stepIndex + 1} of ${controller.totalSteps}',
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Obx(
              () => ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: controller.progress),
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.7),
                    valueColor: const AlwaysStoppedAnimation(
                      AppColors.brand500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepBody extends StatelessWidget {
  const _StepBody({super.key, required this.controller});

  final CreateListingController controller;

  @override
  Widget build(BuildContext context) {
    final step = controller.step.value;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
      children: [
        Text(step.title, style: AppTextStyles.display.copyWith(fontSize: 25)),
        const SizedBox(height: 6),
        Text(
          step.blurb,
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.inkTertiary),
        ),
        const SizedBox(height: 18),
        Obx(() => FormErrorBanner(message: controller.formError.value)),
        GlassCard(
          padding: const EdgeInsets.all(18),
          child: switch (step) {
            ListingStep.basics => BasicsStep(controller: controller),
            ListingStep.location => LocationStep(controller: controller),
            ListingStep.property => PropertyStep(controller: controller),
            ListingStep.amenities => AmenitiesStep(controller: controller),
            ListingStep.photos => PhotosStep(controller: controller),
          },
        ),
      ],
    );
  }
}

class _StepActions extends StatelessWidget {
  const _StepActions({required this.controller});

  final CreateListingController controller;

  @override
  Widget build(BuildContext context) {
    return StickyActionBar(
      child: Obx(() {
        final isLast = controller.stepIndex == controller.totalSteps - 1;
        final busy =
            controller.submitting.value || controller.uploadingPhotos.value;

        if (!isLast) {
          return Row(
            children: [
              if (controller.stepIndex > 0) ...[
                Expanded(
                  child: AppButton.secondary(
                    label: 'Back',
                    onPressed: controller.back,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                flex: 2,
                child: AppButton(
                  label: 'Continue',
                  trailingIcon: Icons.arrow_forward_rounded,
                  onPressed: controller.next,
                ),
              ),
            ],
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!controller.meetsPublishThreshold)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_rounded,
                      size: 16,
                      color: AppColors.amber700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Saving with fewer than 3 photos keeps this listing a '
                        'draft — it will not appear in search yet.',
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: AppButton.secondary(
                    label: 'Back',
                    onPressed: busy ? null : controller.back,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: AppButton(
                    label: controller.meetsPublishThreshold
                        ? 'Publish listing'
                        : 'Save as draft',
                    icon: controller.meetsPublishThreshold
                        ? Icons.rocket_launch_rounded
                        : Icons.save_rounded,
                    loading: busy,
                    onPressed: controller.submit,
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
