import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_button.dart';
import 'entry_animation.dart';

/// Named illustrations, so screens reference intent rather than a file path.
enum AppIllustration {
  search('assets/illustrations/empty_search.svg'),
  saved('assets/illustrations/empty_saved.svg'),
  enquiries('assets/illustrations/empty_enquiries.svg'),
  listings('assets/illustrations/empty_listings.svg'),
  chooseCity('assets/illustrations/choose_city.svg'),
  success('assets/illustrations/success.svg'),
  error('assets/illustrations/error_state.svg'),
  authHero('assets/illustrations/auth_hero.svg'),
  logo('assets/brand/livemate_mark.svg');

  const AppIllustration(this.asset);
  final String asset;
}

/// Every empty state in the app: an illustration, one line of copy, and a way
/// forward. Never a bare "No results".
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.illustration = AppIllustration.search,
    this.actionLabel,
    this.onAction,
    this.secondaryLabel,
    this.onSecondary,
    this.compact = false,
  });

  final String title;
  final String? message;
  final AppIllustration illustration;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: 32,
          vertical: compact ? 20 : 40,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PopIn(
              child: SvgPicture.asset(
                illustration.asset,
                width: compact ? 150 : 200,
                excludeFromSemantics: true,
              ),
            ),
            SizedBox(height: compact ? 18 : 26),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.h2.copyWith(fontSize: compact ? 18 : 21),
            ),
            if (message != null) ...[
              const SizedBox(height: 9),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(height: 1.55),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                expand: false,
                size: AppButtonSize.compact,
              ),
            ],
            if (secondaryLabel != null && onSecondary != null) ...[
              const SizedBox(height: 6),
              AppButton.ghost(
                label: secondaryLabel!,
                onPressed: onSecondary,
                size: AppButtonSize.compact,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The error twin of [EmptyState] — same shape, retry-first copy.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    this.title = 'Something went wrong',
    this.onRetry,
    this.retryLabel = 'Try again',
    this.compact = false,
  });

  final String message;
  final String title;
  final VoidCallback? onRetry;
  final String retryLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) => EmptyState(
    illustration: AppIllustration.error,
    title: title,
    message: message,
    actionLabel: onRetry == null ? null : retryLabel,
    onAction: onRetry,
    compact: compact,
  );
}

/// A small tinted circle behind an icon — the motif used for inline empties and
/// section markers.
class TintedIcon extends StatelessWidget {
  const TintedIcon({
    super.key,
    required this.icon,
    this.color = AppColors.brand600,
    this.background,
    this.size = 44,
    this.iconSize = 21,
  });

  final IconData icon;
  final Color color;
  final Color? background;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: iconSize, color: color),
    );
  }
}
