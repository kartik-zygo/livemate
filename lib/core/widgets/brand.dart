import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import 'empty_state.dart';

/// The MyFlat Homes wordmark: "MyFlat" in brand orange, "Homes" in ink.
///
/// One widget rather than a literal in each screen, so the two halves can never
/// drift apart in weight, tracking or colour.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.fontSize = 32, this.style});

  final double fontSize;

  /// Overrides the base style. The two colours are applied on top of it.
  final TextStyle? style;

  static const String tagline = 'Find your place. Find your people.';

  @override
  Widget build(BuildContext context) {
    final base = (style ?? AppTextStyles.display).copyWith(
      fontSize: fontSize,
      height: 1.1,
    );

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'MyFlat',
            style: base.copyWith(color: AppColors.brand500),
          ),
          TextSpan(
            text: ' Homes',
            style: base.copyWith(color: AppColors.inkPrimary),
          ),
        ],
      ),
      semanticsLabel: 'MyFlat Homes',
    );
  }
}

/// The mark and the wordmark side by side — the horizontal lockup.
class BrandLockup extends StatelessWidget {
  const BrandLockup({
    super.key,
    this.markSize = 40,
    this.fontSize = 20,
    this.showTagline = false,
  });

  final double markSize;
  final double fontSize;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final lockup = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          AppIllustration.logo.asset,
          width: markSize,
          height: markSize,
          excludeFromSemantics: true,
        ),
        SizedBox(width: markSize * 0.28),
        BrandWordmark(fontSize: fontSize),
      ],
    );

    if (!showTagline) return lockup;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        lockup,
        SizedBox(height: markSize * 0.16),
        Text(
          BrandWordmark.tagline,
          style: AppTextStyles.caption.copyWith(fontSize: fontSize * 0.52),
        ),
      ],
    );
  }
}
