import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  const AppTheme._();

  static const double radiusSm = 10;
  static const double radiusMd = 16;
  static const double radiusLg = 22;
  static const double radiusXl = 28;

  static const BorderRadius cardRadius = BorderRadius.all(
    Radius.circular(radiusLg),
  );

  /// Soft warm elevation. [level] 0 is a resting card, 1 a lifted one.
  static List<BoxShadow> shadow({int level = 0}) => level == 0
      ? const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 24,
            offset: Offset(0, 8),
            spreadRadius: -6,
          ),
        ]
      : const [
          BoxShadow(
            color: Color(0x2E7C2D12),
            blurRadius: 34,
            offset: Offset(0, 16),
            spreadRadius: -8,
          ),
        ];

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.ground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.brand500,
        onPrimary: Colors.white,
        primaryContainer: AppColors.brand100,
        onPrimaryContainer: AppColors.brand700,
        secondary: AppColors.accent500,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.accent100,
        onSecondaryContainer: AppColors.accent700,
        error: AppColors.rose600,
        onError: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.inkPrimary,
        outline: AppColors.lineStrong,
        outlineVariant: AppColors.line,
      ),
      textTheme: _textTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.inkPrimary, size: 22),
        titleTextStyle: AppTextStyles.h2,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 1,
      ),
      splashFactory: InkSparkle.splashFactory,
      inputDecorationTheme: _inputTheme,
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink950,
        contentTextStyle: TextStyle(color: Colors.white, fontSize: 14),
        insetPadding: EdgeInsets.all(16),
      ),
      // Sheets and dialogs are glass panes that paint their own surface, so
      // Material must not paint one underneath them.
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalBackgroundColor: Colors.transparent,
        modalElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXl)),
        ),
        showDragHandle: false,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusXl)),
        ),
      ),
      // dialogTheme above is transparent because the app's own confirm dialog
      // paints a glass pane. Date pickers do not — they would inherit that
      // and render on nothing — so they get an explicit opaque surface.
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shadowColor: AppColors.shadow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusXl)),
        ),
        headerBackgroundColor: AppColors.brand500,
        headerForegroundColor: Colors.white,
        todayBorder: const BorderSide(color: AppColors.brand500),
      ),
      timePickerTheme: const TimePickerThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusXl)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.glassFill,
        selectedColor: AppColors.brand100,
        side: const BorderSide(color: AppColors.line),
        labelStyle: AppTextStyles.label,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.brand500,
        linearTrackColor: AppColors.brand100,
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.brand500,
        inactiveTrackColor: AppColors.brand100,
        thumbColor: Colors.white,
        overlayColor: Color(0x1FF97316),
        trackHeight: 4,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.white : Colors.white,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.brand500
              : AppColors.lineStrong,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.brand600,
        selectionColor: AppColors.brand100,
        selectionHandleColor: AppColors.brand500,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base) => base.copyWith(
    displaySmall: AppTextStyles.display,
    headlineMedium: AppTextStyles.h1,
    headlineSmall: AppTextStyles.h2,
    titleMedium: AppTextStyles.h3,
    bodyLarge: AppTextStyles.bodyLarge,
    bodyMedium: AppTextStyles.body,
    labelLarge: AppTextStyles.label,
    labelSmall: AppTextStyles.caption,
  );

  static final InputDecorationTheme _inputTheme = InputDecorationTheme(
    filled: true,
    // Inputs are glass too: translucent enough that the ambient field reads
    // through them, opaque enough to keep typed text at full contrast.
    fillColor: Colors.white.withValues(alpha: 0.55),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    hintStyle: AppTextStyles.body.copyWith(color: AppColors.inkFaint),
    labelStyle: AppTextStyles.label,
    floatingLabelStyle: AppTextStyles.label.copyWith(
      color: AppColors.brand700,
      fontWeight: FontWeight.w700,
    ),
    errorStyle: AppTextStyles.caption.copyWith(color: AppColors.rose600),
    border: _outline(AppColors.glassBorder, width: 1.2),
    enabledBorder: _outline(AppColors.glassBorder, width: 1.2),
    focusedBorder: _outline(AppColors.brand500, width: 1.6),
    errorBorder: _outline(AppColors.rose400),
    focusedErrorBorder: _outline(AppColors.rose500, width: 1.6),
    disabledBorder: _outline(AppColors.line),
  );

  static OutlineInputBorder _outline(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(color: color, width: width),
      );
}
