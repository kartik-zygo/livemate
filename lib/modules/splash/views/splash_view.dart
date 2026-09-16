import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/empty_state.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        animate: true,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _AnimatedMark(),
              const SizedBox(height: 24),
              const LivemateWordmark(fontSize: 34),
              const SizedBox(height: 8),
              Text(
                LivemateWordmark.tagline,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.inkTertiary,
                ),
              ),
              const SizedBox(height: 46),
              const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The mark fades and scales in, then settles — a single 900ms gesture that
/// covers the session check happening behind it.
class _AnimatedMark extends StatefulWidget {
  @override
  State<_AnimatedMark> createState() => _AnimatedMarkState();
}

class _AnimatedMarkState extends State<_AnimatedMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 780),
  )..forward();

  late final Animation<double> _scale = Tween<double>(
    begin: 0.72,
    end: 1,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.6, curve: Curves.easeOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fade,
    child: ScaleTransition(
      scale: _scale,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3DEA580C),
              blurRadius: 34,
              offset: Offset(0, 14),
              spreadRadius: -6,
            ),
          ],
        ),
        child: SvgPicture.asset(
          AppIllustration.logo.asset,
          width: 96,
          height: 96,
          semanticsLabel: 'Livemate',
        ),
      ),
    ),
  );
}
