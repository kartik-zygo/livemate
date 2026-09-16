import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';

/// One dial for the whole frosted-glass system.
///
/// Everything visual about a glass pane is assembled from these constants, so
/// the look can be tuned in one place rather than across forty widgets.
class Glass {
  const Glass._();

  /// Master switch for [BackdropFilter]. Turning it off keeps every other part
  /// of the treatment — the layered fill, the rim light, the specular hotspot,
  /// the two-part shadow — and drops only the sampled blur, which is the one
  /// piece that costs GPU time on every frame.
  ///
  /// Blur is on because the ambient field behind it is what makes these read as
  /// glass rather than as translucent plastic. If the app ever has to run on
  /// low-end hardware, this is the flag to flip.
  static const bool enableBackdropBlur = true;

  /// Blur radii in logical pixels, by how far the surface is meant to detach
  /// from what is behind it.
  static const double blurChip = 10;
  static const double blurCard = 20;
  static const double blurPanel = 32;
  static const double blurOverlay = 44;

  /// Real glass concentrates the colour behind it rather than passing it
  /// through unchanged. Without this the blurred field goes milky and the
  /// screen loses its warmth.
  static const double saturation = 1.4;

  static ImageFilter filter(double sigma, {double saturate = saturation}) {
    final blur = ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);
    if (saturate == 1) return blur;
    return ImageFilter.compose(outer: saturationFilter(saturate), inner: blur);
  }

  /// A luminance-preserving saturation matrix — boosting chroma without
  /// shifting how bright the result reads.
  static ColorFilter saturationFilter(double s) {
    const double lr = 0.2126;
    const double lg = 0.7152;
    const double lb = 0.0722;
    final double ir = (1 - s) * lr;
    final double ig = (1 - s) * lg;
    final double ib = (1 - s) * lb;

    return ColorFilter.matrix(<double>[
      ir + s, ig, ib, 0, 0, //
      ir, ig + s, ib, 0, 0, //
      ir, ig, ib + s, 0, 0, //
      0, 0, 0, 1, 0, //
    ]);
  }

  /// A glass shadow in two parts: a tight contact shadow that anchors the pane,
  /// and a wide ambient one that gives it height. [level] 0 is a resting pane,
  /// 1 a lifted one, 2 an overlay.
  static List<BoxShadow> shadow({int level = 0}) => switch (level) {
    0 => const [
      BoxShadow(
        color: AppColors.glassShadowContact,
        blurRadius: 10,
        offset: Offset(0, 3),
        spreadRadius: -3,
      ),
      BoxShadow(
        color: AppColors.glassShadowAmbient,
        blurRadius: 30,
        offset: Offset(0, 12),
        spreadRadius: -10,
      ),
    ],
    1 => const [
      BoxShadow(
        color: AppColors.glassShadowContact,
        blurRadius: 12,
        offset: Offset(0, 4),
        spreadRadius: -3,
      ),
      BoxShadow(
        color: AppColors.glassShadowDeep,
        blurRadius: 44,
        offset: Offset(0, 20),
        spreadRadius: -12,
      ),
    ],
    _ => const [
      BoxShadow(
        color: AppColors.glassShadowContact,
        blurRadius: 16,
        offset: Offset(0, 6),
        spreadRadius: -4,
      ),
      BoxShadow(
        color: AppColors.glassShadowDeep,
        blurRadius: 64,
        offset: Offset(0, 28),
        spreadRadius: -14,
      ),
    ],
  };
}

/// The single frosted-glass primitive every other glass widget is built from.
///
/// Layers, painted in order: the blurred backdrop, a diagonal fill that runs
/// bright-to-thin, a specular hotspot in the lit corner, the content, and
/// finally a gradient rim stroke drawn *over* everything so the pane keeps a
/// hard lit edge no matter what sits inside it.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius,
    this.radius = AppTheme.radiusLg,
    this.padding,
    this.blur = true,
    this.blurSigma = Glass.blurCard,
    this.fill,
    this.tint,
    this.tintStrength = 0.14,
    this.rimColor,
    this.rimWidth = 1.2,
    this.specular = true,
    this.shadows,
    this.elevation = 0,
  });

  final Widget child;
  final BorderRadius? borderRadius;
  final double radius;
  final EdgeInsetsGeometry? padding;

  final bool blur;
  final double blurSigma;

  /// Overrides the default white pane fill. The gradient is rebuilt around it,
  /// so a tinted card still runs bright-to-thin across its diagonal.
  final Color? fill;

  /// A colour pulled *into* the glass — how something coloured behind a pane
  /// bleeds through it. Layered over [fill] rather than replacing it.
  final Color? tint;
  final double tintStrength;

  /// Overrides the rim light. Given a colour, the rim runs from that colour at
  /// the lit edge to a faded version of it at the far edge.
  final Color? rimColor;
  final double rimWidth;

  final bool specular;
  final List<BoxShadow>? shadows;
  final int elevation;

  @override
  Widget build(BuildContext context) {
    final shape = borderRadius ?? BorderRadius.circular(radius);

    final base = fill;
    final Gradient fillGradient = base == null
        ? AppColors.glassGradient
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              base.withValues(alpha: (base.a * 1.08).clamp(0.0, 1.0)),
              base,
              base.withValues(alpha: base.a * 0.68),
            ],
            stops: const [0, 0.55, 1],
          );

    final tintColor = tint;

    Widget pane = Stack(
      fit: StackFit.passthrough,
      children: [
        // The pane: fill, then whatever colour bleeds through it, then the
        // hotspot where the light lands.
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: fillGradient),
              child: tintColor == null
                  ? null
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            tintColor.withValues(alpha: tintStrength),
                            tintColor.withValues(alpha: tintStrength * 0.25),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ),
        if (specular)
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.85, -1),
                    radius: 1.15,
                    colors: [AppColors.glassSpecular, Color(0x00FFFFFF)],
                    stops: [0, 0.62],
                  ),
                ),
              ),
            ),
          ),

        // Content sizes the stack.
        if (padding == null)
          child
        else
          Padding(padding: padding!, child: child),

        // Rim last: an edge that content can never paint over.
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _GlassRimPainter(
                shape: shape,
                width: rimWidth,
                color: rimColor,
              ),
            ),
          ),
        ),
      ],
    );

    if (blur && Glass.enableBackdropBlur) {
      pane = BackdropFilter(filter: Glass.filter(blurSigma), child: pane);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: shape,
        boxShadow: shadows ?? Glass.shadow(level: elevation),
      ),
      child: ClipRRect(borderRadius: shape, child: pane),
    );
  }
}

/// Strokes the pane's edge with a gradient rather than a flat colour, so the
/// rim reads as light catching one side of a bevel.
class _GlassRimPainter extends CustomPainter {
  const _GlassRimPainter({
    required this.shape,
    required this.width,
    required this.color,
  });

  final BorderRadius shape;
  final double width;
  final Color? color;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || width <= 0) return;

    final rect = Offset.zero & size;
    final override = color;
    final bright = override ?? AppColors.glassRimBright;
    final dim = override == null
        ? AppColors.glassRimDim
        : override.withValues(alpha: override.a * 0.28);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          bright,
          dim,
          bright.withValues(alpha: bright.a * 0.5),
        ],
        stops: const [0, 0.5, 1],
      ).createShader(rect);

    canvas.drawRRect(shape.toRRect(rect).deflate(width / 2), paint);
  }

  @override
  bool shouldRepaint(_GlassRimPainter old) =>
      old.shape != shape || old.width != width || old.color != color;
}

/// A glass surface that presses. Everything tappable and glass uses this, so
/// the press feel is identical across cards, pills and buttons.
class GlassTapTarget extends StatefulWidget {
  const GlassTapTarget({
    super.key,
    required this.child,
    required this.onTap,
    this.scale = 0.972,
    this.duration = const Duration(milliseconds: 220),
  });

  final Widget child;
  final VoidCallback onTap;
  final double scale;
  final Duration duration;

  @override
  State<GlassTapTarget> createState() => _GlassTapTargetState();
}

class _GlassTapTargetState extends State<GlassTapTarget> {
  bool _down = false;

  void _set(bool value) {
    if (_down != value && mounted) setState(() => _down = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

/// A floating glass panel — shell chrome, drawers, sheets. Blurs harder and
/// sits higher than a card does.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.radius = AppTheme.radiusXl,
    this.blurSigma = Glass.blurPanel,
    this.elevation = 1,
    this.tint,
    this.fill,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double radius;
  final double blurSigma;
  final int elevation;
  final Color? tint;
  final Color? fill;

  @override
  Widget build(BuildContext context) {
    final panel = GlassSurface(
      borderRadius: borderRadius,
      radius: radius,
      padding: padding,
      blurSigma: blurSigma,
      elevation: elevation,
      tint: tint,
      fill: fill,
      rimWidth: 1.4,
      child: child,
    );

    return margin == null ? panel : Padding(padding: margin!, child: panel);
  }
}

/// A small frosted pill — filter chips, counters, inline labels. Blurs lightly:
/// at this size a heavy blur just reads as grey.
class GlassPill extends StatelessWidget {
  const GlassPill({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    this.radius = 30,
    this.onTap,
    this.tint,
    this.tintStrength = 0.14,
    this.fill,
    this.rimColor,
    this.semanticLabel,
    this.selected = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  final Color? tint;
  final double tintStrength;
  final Color? fill;
  final Color? rimColor;
  final String? semanticLabel;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    Widget pill = GlassSurface(
      radius: radius,
      padding: padding,
      blurSigma: Glass.blurChip,
      rimWidth: selected ? 1.4 : 1,
      rimColor: rimColor,
      tint: tint,
      tintStrength: tintStrength,
      fill: fill,
      specular: false,
      shadows: const [
        BoxShadow(
          color: AppColors.glassShadowContact,
          blurRadius: 12,
          offset: Offset(0, 4),
          spreadRadius: -4,
        ),
      ],
      child: child,
    );

    final tap = onTap;
    if (tap != null) {
      pill = GlassTapTarget(onTap: tap, scale: 0.955, child: pill);
    }

    final label = semanticLabel;
    if (label != null) {
      pill = Semantics(
        button: tap != null,
        selected: selected,
        label: label,
        child: pill,
      );
    }

    return pill;
  }
}

/// A circular glass control. Always meets the 44px tap target even when the
/// visible disc is smaller.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.onTap,
    this.size = 44,
    this.iconSize = 21,
    this.color = AppColors.inkPrimary,
    this.tint,
    this.fill,
    this.badge = 0,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final Color color;
  final Color? tint;
  final Color? fill;

  /// A count rendered in the top-right corner. 0 hides it.
  final int badge;

  @override
  Widget build(BuildContext context) {
    Widget disc = GlassSurface(
      radius: size / 2,
      blurSigma: Glass.blurChip,
      tint: tint,
      fill: fill,
      rimWidth: 1.2,
      shadows: const [
        BoxShadow(
          color: AppColors.glassShadowContact,
          blurRadius: 14,
          offset: Offset(0, 5),
          spreadRadius: -4,
        ),
      ],
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(icon, size: iconSize, color: color),
      ),
    );

    if (badge > 0) {
      disc = Stack(
        clipBehavior: Clip.none,
        children: [
          disc,
          Positioned(right: -3, top: -3, child: GlassBadge(count: badge)),
        ],
      );
    }

    final Widget target = SizedBox(
      width: size < 44 ? 44 : size,
      height: size < 44 ? 44 : size,
      child: Center(child: disc),
    );

    final tap = onTap;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: tap == null
          ? target
          : GlassTapTarget(onTap: tap, scale: 0.9, child: target),
    );
  }
}

/// The count badge used on nav destinations and icon buttons.
class GlassBadge extends StatelessWidget {
  const GlassBadge({super.key, required this.count, this.compact = false});

  final int count;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 5.5, vertical: 2),
      constraints: BoxConstraints(minWidth: compact ? 16 : 19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.rose400, AppColors.rose600],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.85),
          width: 1.4,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x59E11D48),
            blurRadius: 10,
            offset: Offset(0, 3),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: compact ? 9.5 : 10.5,
          fontWeight: FontWeight.w800,
          height: 1.25,
        ),
      ),
    );
  }
}

/// Wraps a modal bottom sheet in glass. Sheets sit over the ambient field, so
/// they get the heaviest blur in the app and a rim along their top edge.
class GlassSheet extends StatelessWidget {
  const GlassSheet({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 4, 20, 22),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// The shared `showModalBottomSheet` configuration — a transparent sheet
  /// background, so the glass rather than Material paints the surface.
  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool isScrollControlled = true,
  }) => showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    elevation: 0,
    showDragHandle: false,
    barrierColor: const Color(0x591F1613),
    builder: builder,
  );

  @override
  Widget build(BuildContext context) {
    const shape = BorderRadius.vertical(
      top: Radius.circular(AppTheme.radiusXl),
    );

    return GlassSurface(
      borderRadius: shape,
      blurSigma: Glass.blurOverlay,
      elevation: 2,
      rimWidth: 1.5,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4.5,
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.inkFaint,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Flexible(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
