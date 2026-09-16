import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/theme/app_theme.dart';
import 'app_button.dart';
import 'empty_state.dart';
import 'glass.dart';

/// Toasts and confirmation dialogs, so every screen speaks in the same voice.
class AppFeedback {
  const AppFeedback._();

  static void success(String message, {String? title}) => _toast(
    message,
    title: title,
    color: AppColors.accent600,
    icon: Icons.check_circle_rounded,
  );

  static void error(String message, {String? title}) => _toast(
    message,
    title: title,
    color: AppColors.rose600,
    icon: Icons.error_rounded,
  );

  static void info(String message, {String? title}) => _toast(
    message,
    title: title,
    color: AppColors.brand600,
    icon: Icons.info_rounded,
  );

  static void _toast(
    String message, {
    required Color color,
    required IconData icon,
    String? title,
  }) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.rawSnackbar(
      messageText: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 21),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  Text(title, style: AppTextStyles.bodyStrong),
                  const SizedBox(height: 2),
                ],
                Text(message, style: AppTextStyles.body),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white.withValues(alpha: 0.93),
      borderColor: AppColors.glassBorder,
      borderWidth: 1,
      borderRadius: AppTheme.radiusMd,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      boxShadows: AppTheme.shadow(level: 1),
      animationDuration: const Duration(milliseconds: 320),
      forwardAnimationCurve: Curves.easeOutCubic,
    );
  }

  /// Returns true only when the user explicitly confirms.
  static Future<bool> confirm({
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool destructive = false,
    IconData icon = Icons.help_rounded,
  }) async {
    final result = await Get.dialog<bool>(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: GlassSurface(
          radius: AppTheme.radiusXl,
          blurSigma: Glass.blurOverlay,
          elevation: 2,
          rimWidth: 1.5,
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TintedIcon(
                icon: icon,
                color: destructive ? AppColors.rose600 : AppColors.brand600,
                size: 52,
                iconSize: 25,
              ),
              const SizedBox(height: 18),
              Text(title, textAlign: TextAlign.center, style: AppTextStyles.h3),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: AppButton.secondary(
                      label: cancelLabel,
                      size: AppButtonSize.compact,
                      onPressed: () => Get.back(result: false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: destructive
                        ? AppButton.danger(
                            label: confirmLabel,
                            size: AppButtonSize.compact,
                            onPressed: () => Get.back(result: true),
                          )
                        : AppButton(
                            label: confirmLabel,
                            size: AppButtonSize.compact,
                            onPressed: () => Get.back(result: true),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
    return result ?? false;
  }
}
