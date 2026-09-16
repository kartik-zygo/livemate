import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/entry_animation.dart';
import '../../../core/widgets/glass.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/slide_art.dart';

/// The intro. Three slides, each a claim the app has to keep, ending on the
/// one that matters most — that a phone number is not the price of asking
/// about a room.
class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // The art gets whatever is comfortably spare after the copy and the
    // controls, so it never squeezes the text on a short screen.
    final artHeight = (size.height * 0.30).clamp(180.0, 300.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AmbientBackground(
        animate: true,
        child: SafeArea(
          child: Column(
            children: [
              const _TopBar(),
              Expanded(
                child: PageView.builder(
                  controller: controller.pageController,
                  onPageChanged: controller.onPageChanged,
                  itemCount: controller.slides.length,
                  itemBuilder: (context, i) =>
                      _Slide(index: i, artHeight: artHeight),
                ),
              ),
              const _Controls(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends GetView<OnboardingController> {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 14, 4),
      child: Row(
        children: [
          const LivemateLockup(markSize: 32, fontSize: 19),
          const Spacer(),
          Obx(
            () => AnimatedOpacity(
              duration: const Duration(milliseconds: 240),
              opacity: controller.isLast ? 0 : 1,
              child: IgnorePointer(
                ignoring: controller.isLast,
                child: GlassPill(
                  onTap: controller.finish,
                  semanticLabel: 'Skip the intro',
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  child: Text(
                    'Skip',
                    style: AppTextStyles.label.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkSecondary,
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

class _Slide extends GetView<OnboardingController> {
  const _Slide({required this.index, required this.artHeight});

  final int index;
  final double artHeight;

  @override
  Widget build(BuildContext context) {
    final slide = controller.slides[index];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => SlideArt(
              slide: slide,
              parallax: controller.offset.value - index,
              height: artHeight,
            ),
          ),
          const SizedBox(height: 26),
          EntryAnimation(
            key: ValueKey('eyebrow-$index'),
            child: Text(
              slide.eyebrow,
              style: AppTextStyles.eyebrow.copyWith(color: slide.accent),
            ),
          ),
          const SizedBox(height: 10),
          EntryAnimation(
            key: ValueKey('title-$index'),
            index: 1,
            child: Text(
              slide.title,
              style: AppTextStyles.display.copyWith(fontSize: 27, height: 1.22),
            ),
          ),
          const SizedBox(height: 12),
          EntryAnimation(
            key: ValueKey('body-$index'),
            index: 2,
            child: Text(
              slide.body,
              style: AppTextStyles.bodyLarge.copyWith(height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _Controls extends GetView<OnboardingController> {
  const _Controls();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      radius: 28,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Obx(() {
        final slide = controller.slides[controller.index.value];
        final last = controller.isLast;

        return Row(
          children: [
            _Dots(
              count: controller.slides.length,
              active: controller.index.value,
              accent: slide.accent,
              onTap: controller.goTo,
            ),
            const Spacer(),
            Flexible(
              child: _PrimaryButton(
                label: last ? 'Get started' : 'Next',
                icon: last
                    ? Icons.arrow_forward_rounded
                    : Icons.chevron_right_rounded,
                gradient: slide.gradient,
                accent: slide.accent,
                onTap: controller.next,
              ),
            ),
          ],
        );
      }),
    );
  }
}

/// Tappable, so someone who wants to go back a slide does not have to swipe
/// blindly. The active dot stretches rather than just changing colour.
class _Dots extends StatelessWidget {
  const _Dots({
    required this.count,
    required this.active,
    required this.accent,
    required this.onTap,
  });

  final int count;
  final int active;
  final Color accent;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final selected = i == active;
        return Semantics(
          button: true,
          selected: selected,
          label: 'Slide ${i + 1} of $count',
          child: GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                width: selected ? 26 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: selected
                      ? accent
                      : AppColors.inkPrimary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Gradient gradient;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GlassTapTarget(
        onTap: onTap,
        scale: 0.955,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.45),
                blurRadius: 22,
                offset: const Offset(0, 10),
                spreadRadius: -5,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.button.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(width: 7),
              Icon(icon, size: 20, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
