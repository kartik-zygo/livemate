import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/config/env.dart';
import '../../../core/utils/enum_meta.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/city_picker_sheet.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/pills.dart';
import '../../../data/models/enums.dart';
import '../../auth/widgets/auth_shell.dart';
import '../controllers/create_finder_post_controller.dart';

class CreateFinderPostView extends GetView<CreateFinderPostController> {
  const CreateFinderPostView({super.key});

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
          seed: 1,
          child: SafeArea(
            child: Column(
              children: [
                _Header(controller: controller),
                Expanded(
                  child: Obx(
                    () => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      switchInCurve: Curves.easeOutCubic,
                      child: _Body(
                        key: ValueKey(controller.step.value),
                        controller: controller,
                      ),
                    ),
                  ),
                ),
                _Actions(controller: controller),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final CreateFinderPostController controller;

  @override
  Widget build(BuildContext context) => Padding(
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
            Expanded(child: Text('Find a room', style: AppTextStyles.h2)),
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
                  valueColor: const AlwaysStoppedAnimation(AppColors.accent500),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _Body extends StatelessWidget {
  const _Body({super.key, required this.controller});

  final CreateFinderPostController controller;

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
        if (step == FinderStep.tier)
          _TierStep(controller: controller)
        else
          GlassCard(
            padding: const EdgeInsets.all(18),
            child: step == FinderStep.brief
                ? _BriefStep(controller: controller)
                : _PreferencesStep(controller: controller),
          ),
      ],
    );
  }
}

class _BriefStep extends StatelessWidget {
  const _BriefStep({required this.controller});

  final CreateFinderPostController controller;

  @override
  Widget build(BuildContext context) => Form(
    key: controller.formKeys[FinderStep.brief],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => CityPickerField(
            label: 'City you are looking in',
            city: controller.city.value,
            errorText: controller.cityError.value,
            onPicked: (city) {
              controller.city.value = city;
              controller.cityError.value = null;
            },
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: RupeeField(
                label: 'Budget from',
                controller: controller.budgetMin,
                required: true,
                validator: Validators.budget,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RupeeField(
                label: 'Budget up to',
                controller: controller.budgetMax,
                required: true,
                validator: Validators.budget,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'You will match rooms whose rent overlaps this range.',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 18),
        AppTextField(
          label: 'A line about you',
          controller: controller.note,
          hint: 'Working professional, non-smoker, quiet on weeknights.',
          maxLines: 4,
          minLines: 3,
          maxLength: 500,
          textCapitalization: TextCapitalization.sentences,
          validator: Validators.note,
        ),
      ],
    ),
  );
}

class _PreferencesStep extends StatelessWidget {
  const _PreferencesStep({required this.controller});

  final CreateFinderPostController controller;

  @override
  Widget build(BuildContext context) => Form(
    key: controller.formKeys[FinderStep.preferences],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Flatmates',
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
            children: Gender.values
                .map(
                  (g) => SelectChip(
                    label: g.label,
                    icon: g.icon,
                    selected: controller.genderPreference.value == g,
                    onTap: () => controller.genderPreference.value = g,
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                label: 'Age from',
                controller: controller.ageMin,
                hint: '21',
                keyboardType: TextInputType.number,
                validator: (v) =>
                    Validators.optionalRange(v, min: 18, max: 100, unit: 'age'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                label: 'Age to',
                controller: controller.ageMax,
                hint: '35',
                keyboardType: TextInputType.number,
                validator: (v) =>
                    Validators.optionalRange(v, min: 18, max: 100, unit: 'age'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Obx(() {
          final tags = controller.tags;
          if (tags.isEmpty) {
            return Text(
              'Lifestyle tags are loading. You can post without them.',
              style: AppTextStyles.caption,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Lifestyle tags',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.inkPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${controller.tagIds.length} / ${Env.maxTagsPerFinderPost}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final category in TagCategory.values)
                if (tags.any((t) => t.category == category)) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 4),
                    child: Text(category.label, style: AppTextStyles.caption),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags
                        .where((t) => t.category == category)
                        .map(
                          (t) => SelectChip(
                            label: t.label,
                            icon: category.icon,
                            selected: controller.tagIds.contains(t.id),
                            enabled:
                                controller.tagIds.contains(t.id) ||
                                !controller.atTagLimit,
                            onTap: () => controller.toggleTag(t.id),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                ],
            ],
          );
        }),
      ],
    ),
  );
}

class _TierStep extends StatelessWidget {
  const _TierStep({required this.controller});

  final CreateFinderPostController controller;

  @override
  Widget build(BuildContext context) => Obx(
    () => Column(
      children: [
        for (final tier in PostTier.values) ...[
          _TierCard(
            tier: tier,
            selected: controller.tier.value == tier,
            onTap: () => controller.tier.value = tier,
          ),
          const SizedBox(height: 13),
        ],
      ],
    ),
  );
}

class _TierCard extends StatelessWidget {
  const _TierCard({
    required this.tier,
    required this.selected,
    required this.onTap,
  });

  final PostTier tier;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      elevated: selected,
      fill: selected
          ? AppColors.brand100.withValues(alpha: 0.8)
          : Colors.white.withValues(alpha: 0.82),
      borderColor: selected ? AppColors.brand500 : AppColors.line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TintedIcon(
                icon: tier.icon,
                size: 46,
                iconSize: 22,
                color: selected ? AppColors.brand700 : AppColors.inkTertiary,
              ),
              const SizedBox(width: 14),
              Expanded(child: Text(tier.label, style: AppTextStyles.h3)),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppColors.brand500 : Colors.transparent,
                  border: Border.all(
                    color: selected ? AppColors.brand500 : AppColors.lineStrong,
                    width: 2,
                  ),
                ),
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 15,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(tier.blurb, style: AppTextStyles.body),
          const SizedBox(height: 13),
          ...tier.perks.map(
            (perk) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: AppColors.accent600,
                  ),
                  const SizedBox(width: 9),
                  Expanded(child: Text(perk, style: AppTextStyles.caption)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.controller});

  final CreateFinderPostController controller;

  @override
  Widget build(BuildContext context) => StickyActionBar(
    child: Obx(() {
      final isLast = controller.stepIndex == controller.totalSteps - 1;

      return Row(
        children: [
          if (controller.stepIndex > 0) ...[
            Expanded(
              child: AppButton.secondary(
                label: 'Back',
                onPressed: controller.submitting.value ? null : controller.back,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            flex: 2,
            child: isLast
                ? AppButton(
                    label: 'Publish post',
                    icon: Icons.check_rounded,
                    loading: controller.submitting.value,
                    onPressed: controller.submit,
                  )
                : AppButton(
                    label: 'Continue',
                    trailingIcon: Icons.arrow_forward_rounded,
                    onPressed: controller.next,
                  ),
          ),
        ],
      );
    }),
  );
}
