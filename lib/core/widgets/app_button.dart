import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/theme/app_theme.dart';
import 'glass.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

enum AppButtonSize { regular, compact }

/// The app's one button. Primary is the brand gradient; every variant keeps a
/// 44px minimum height and a subtle press scale.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.regular,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.expand = true,
  });

  const AppButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.regular,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.expand = true,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.ghost({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.regular,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.expand = false,
  }) : variant = AppButtonVariant.ghost;

  const AppButton.danger({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.regular,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.expand = true,
  }) : variant = AppButtonVariant.danger;

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool loading;
  final bool expand;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _down = false;

  bool get _enabled => widget.onPressed != null && !widget.loading;

  void _set(bool value) {
    if (_down != value && mounted) setState(() => _down = value);
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.size == AppButtonSize.regular ? 52.0 : 44.0;
    final radius = BorderRadius.circular(
      widget.size == AppButtonSize.regular ? 14 : 12,
    );
    final style = _styleFor(widget.variant);

    final content = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.loading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation(style.foreground),
            ),
          )
        else ...[
          if (widget.icon != null) ...[
            Icon(widget.icon, size: 19, color: style.foreground),
            const SizedBox(width: 9),
          ],
          Flexible(
            child: Text(
              widget.label,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.button.copyWith(
                color: style.foreground,
                fontSize: widget.size == AppButtonSize.compact ? 14 : 15,
              ),
            ),
          ),
          if (widget.trailingIcon != null) ...[
            const SizedBox(width: 8),
            Icon(widget.trailingIcon, size: 18, color: style.foreground),
          ],
        ],
      ],
    );

    return Opacity(
      opacity: _enabled ? 1 : 0.5,
      child: GestureDetector(
        onTapDown: _enabled ? (_) => _set(true) : null,
        onTapUp: _enabled ? (_) => _set(false) : null,
        onTapCancel: _enabled ? () => _set(false) : null,
        onTap: _enabled ? widget.onPressed : null,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _down ? 0.968 : 1,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: Container(
            height: height,
            width: widget.expand ? double.infinity : null,
            padding: EdgeInsets.symmetric(
              horizontal: widget.size == AppButtonSize.regular ? 22 : 16,
            ),
            decoration: BoxDecoration(
              gradient: style.gradient,
              color: style.background,
              borderRadius: radius,
              border: style.border,
              boxShadow: widget.variant == AppButtonVariant.primary && _enabled
                  ? const [
                      BoxShadow(
                        color: Color(0x38EA580C),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                        spreadRadius: -4,
                      ),
                    ]
                  : null,
            ),
            child: Center(child: content),
          ),
        ),
      ),
    );
  }

  _ButtonStyle _styleFor(AppButtonVariant variant) => switch (variant) {
    AppButtonVariant.primary => const _ButtonStyle(
      gradient: AppColors.primaryGradient,
      foreground: Colors.white,
    ),
    AppButtonVariant.secondary => _ButtonStyle(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.88),
          Colors.white.withValues(alpha: 0.58),
        ],
      ),
      foreground: AppColors.brand700,
      border: Border.all(color: AppColors.brand200, width: 1.2),
    ),
    AppButtonVariant.ghost => const _ButtonStyle(
      background: Colors.transparent,
      foreground: AppColors.brand700,
    ),
    AppButtonVariant.danger => _ButtonStyle(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.88),
          Colors.white.withValues(alpha: 0.58),
        ],
      ),
      foreground: AppColors.rose600,
      border: Border.all(
        color: AppColors.rose400.withValues(alpha: 0.55),
        width: 1.2,
      ),
    ),
  };
}

class _ButtonStyle {
  const _ButtonStyle({
    required this.foreground,
    this.background,
    this.gradient,
    this.border,
  });

  final Color foreground;
  final Color? background;
  final Gradient? gradient;
  final BoxBorder? border;
}

/// Circular icon-only button — always carries a semantic label and meets the
/// 44px tap target even when the visual is smaller.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.onPressed,
    this.color,
    this.background,
    this.size = 42,
    this.iconSize = 20,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? background;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Tooltip(
        message: semanticLabel,
        child: SizedBox(
          width: size < 44 ? 44 : size,
          height: size < 44 ? 44 : size,
          child: Center(
            child: GlassIconButton(
              icon: icon,
              semanticLabel: semanticLabel,
              onTap: onPressed,
              size: size,
              iconSize: iconSize,
              color: color ?? AppColors.inkPrimary,
              fill: background,
            ),
          ),
        ),
      ),
    );
  }
}

/// A pill-shaped action bar pinned above the keyboard / home indicator, used on
/// detail screens and multi-step forms.
class StickyActionBar extends StatelessWidget {
  const StickyActionBar({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: Glass.filter(Glass.blurPanel),
        child: _bar(context),
      ),
    );
  }

  Widget _bar(BuildContext context) {
    return Container(
      padding:
          padding ??
          EdgeInsets.fromLTRB(
            18,
            14,
            18,
            14 + MediaQuery.paddingOf(context).bottom,
          ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.62),
            Colors.white.withValues(alpha: 0.86),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.75),
            width: 1.2,
          ),
        ),
        boxShadow: AppTheme.shadow(level: 1),
      ),
      child: child,
    );
  }
}
