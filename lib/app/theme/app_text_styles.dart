import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Type scale: display/heading weights run 700–800 with tight tracking, body
/// stays 400–500 at comfortable tracking.
///
/// No custom font is bundled — the platform UI font carries the scale. To move
/// to Inter or Geist, drop the .ttf files into `assets/fonts/`, declare a
/// `fonts:` block in pubspec.yaml, and set [_family] to the family name.
class AppTextStyles {
  const AppTextStyles._();

  static const String? _family = null;

  static const TextStyle display = TextStyle(
    fontFamily: _family,
    fontSize: 32,
    height: 1.12,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.9,
    color: AppColors.inkPrimary,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: _family,
    fontSize: 26,
    height: 1.18,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.6,
    color: AppColors.inkPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: _family,
    fontSize: 21,
    height: 1.24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    color: AppColors.inkPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: _family,
    fontSize: 17,
    height: 1.3,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    color: AppColors.inkPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _family,
    fontSize: 15.5,
    height: 1.55,
    fontWeight: FontWeight.w400,
    color: AppColors.inkSecondary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: _family,
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.inkSecondary,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontFamily: _family,
    fontSize: 14,
    height: 1.45,
    fontWeight: FontWeight.w600,
    color: AppColors.inkPrimary,
  );

  static const TextStyle label = TextStyle(
    fontFamily: _family,
    fontSize: 12.5,
    height: 1.35,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: AppColors.inkSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _family,
    fontSize: 11.5,
    height: 1.35,
    fontWeight: FontWeight.w500,
    color: AppColors.inkTertiary,
  );

  /// Small all-caps eyebrow used above section headings.
  static const TextStyle eyebrow = TextStyle(
    fontFamily: _family,
    fontSize: 10.5,
    height: 1.3,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.4,
    color: AppColors.brand700,
  );

  /// Prices and other tabular numbers.
  static const TextStyle price = TextStyle(
    fontFamily: _family,
    fontSize: 18,
    height: 1.2,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.4,
    color: AppColors.brand700,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle button = TextStyle(
    fontFamily: _family,
    fontSize: 15,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
  );
}
