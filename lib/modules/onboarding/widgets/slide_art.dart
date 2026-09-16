import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/glass.dart';
import '../controllers/onboarding_controller.dart';

/// The artwork above each intro slide.
///
/// Built from the app's own glass primitives rather than an illustration, so
/// what you see in the intro is literally the surface you get on the next
/// screen. Three panes at different depths drift at different rates as you
/// swipe, which is what sells them as floating rather than pasted on.
class SlideArt extends StatelessWidget {
  const SlideArt({
    super.key,
    required this.slide,
    required this.parallax,
    this.height = 280,
  });

  final OnboardingSlide slide;

  /// This slide's distance from centre, in pages. 0 is centred, -1 is one page
  /// to the left. Drives the depth offsets.
  final double parallax;

  final double height;

  @override
  Widget build(BuildContext context) {
    // Clamped so a fast fling cannot throw the panes off the canvas.
    final p = parallax.clamp(-1.0, 1.0);

    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The glow the panes sample.
          Transform.translate(
            offset: Offset(p * -18, 0),
            child: Container(
              width: height * 0.92,
              height: height * 0.92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    slide.accent.withValues(alpha: 0.42),
                    slide.accent.withValues(alpha: 0.10),
                    slide.accent.withValues(alpha: 0),
                  ],
                  stops: const [0, 0.55, 1],
                ),
              ),
            ),
          ),

          // Back pane — furthest away, so it moves least.
          Transform.translate(
            offset: Offset(-92 + p * -26, -46),
            child: Transform.rotate(
              angle: -8 * math.pi / 180,
              child: _MiniCard(
                accent: slide.accent,
                width: 156,
                opacity: 0.75,
                lines: 2,
              ),
            ),
          ),

          // Front pane.
          Transform.translate(
            offset: Offset(84 + p * -52, 52),
            child: Transform.rotate(
              angle: 7 * math.pi / 180,
              child: _MiniCard(
                accent: slide.accent,
                width: 168,
                opacity: 0.9,
                lines: 3,
              ),
            ),
          ),

          // The badge sits closest, so it travels furthest.
          Transform.translate(
            offset: Offset(p * -78, -4),
            child: _IconBadge(slide: slide),
          ),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.slide});

  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) => Container(
    width: 96,
    height: 96,
    decoration: BoxDecoration(
      gradient: slide.gradient,
      borderRadius: BorderRadius.circular(30),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.55),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: slide.accent.withValues(alpha: 0.45),
          blurRadius: 34,
          offset: const Offset(0, 16),
          spreadRadius: -8,
        ),
      ],
    ),
    child: Icon(slide.icon, size: 44, color: Colors.white),
  );
}

/// A stand-in for a listing card: a thumbnail block and a couple of text bars.
/// Abstract on purpose — it reads as "the app" without pretending to be a real
/// listing that does not exist yet.
class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.accent,
    required this.width,
    required this.opacity,
    required this.lines,
  });

  final Color accent;
  final double width;
  final double opacity;
  final int lines;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: width,
        child: GlassSurface(
          radius: 20,
          blurSigma: Glass.blurCard,
          tint: accent,
          tintStrength: 0.1,
          elevation: 1,
          padding: const EdgeInsets.all(13),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accent.withValues(alpha: 0.35),
                      accent.withValues(alpha: 0.14),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 11),
              for (var i = 0; i < lines; i++) ...[
                _Bar(width: width * (i == 0 ? 0.62 : 0.44)),
                const SizedBox(height: 7),
              ],
              Row(
                children: [
                  Text(
                    '₹',
                    style: AppTextStyles.price.copyWith(
                      fontSize: 15,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 3),
                  _Bar(width: 34, height: 9),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.width, this.height = 7});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: AppColors.inkPrimary.withValues(alpha: 0.13),
      borderRadius: BorderRadius.circular(height / 2),
    ),
  );
}
