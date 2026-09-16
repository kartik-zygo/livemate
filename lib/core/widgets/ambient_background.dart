import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// The blurred colour field every glass surface samples: six large soft circles
/// in brand, accent, rose and two cool notes, over a warm ground.
///
/// Drawn with a [CustomPainter] and radial gradients rather than a
/// [BackdropFilter] — a blur that covers the whole screen is expensive on
/// mid-range Android, and the gradients are visually indistinguishable at this
/// radius while costing a fraction as much.
///
/// The two cool blobs are the reason the glass reads as glass. A pane sampling
/// a field of one hue just looks tinted; a pane sampling a field that shifts
/// hue across its width picks up a gradient of its own, which is what the eye
/// recognises as refraction.
class AmbientBackground extends StatefulWidget {
  const AmbientBackground({
    super.key,
    required this.child,
    this.intensity = 1,
    this.seed = 0,
    this.animate = false,
  });

  final Widget child;

  /// 0 fades the field out entirely; 1 is full strength.
  final double intensity;

  /// Shifts the blob layout so adjacent screens do not look identical.
  final int seed;

  /// Drifts the blobs along slow elliptical orbits, so glass panes catch a
  /// changing field rather than a frozen one. Costs a full-screen repaint per
  /// frame, so exactly one instance — the app shell — should turn it on.
  final bool animate;

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.animate) _start();
  }

  @override
  void didUpdateWidget(AmbientBackground old) {
    super.didUpdateWidget(old);
    if (widget.animate && _controller == null) {
      _start();
    } else if (!widget.animate && _controller != null) {
      _controller!.dispose();
      _controller = null;
    }
  }

  void _start() {
    _controller = AnimationController(
      vsync: this,
      // Slow enough that it is never a thing you watch — only something you
      // notice is different when you look up from a card.
      duration: const Duration(seconds: 42),
    )..repeat();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Honour reduced motion: the field still paints, it just stops moving.
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final controller = reduceMotion ? null : _controller;

    final Widget field = controller == null
        ? CustomPaint(
            painter: _AmbientPainter(
              intensity: widget.intensity,
              seed: widget.seed,
            ),
            isComplex: true,
            willChange: false,
            child: widget.child,
          )
        : AnimatedBuilder(
            animation: controller,
            builder: (context, child) => CustomPaint(
              painter: _AmbientPainter(
                intensity: widget.intensity,
                seed: widget.seed,
                phase: controller.value,
              ),
              isComplex: true,
              willChange: true,
              child: child,
            ),
            child: widget.child,
          );

    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.ground),
      child: field,
    );
  }
}

class _AmbientPainter extends CustomPainter {
  const _AmbientPainter({
    required this.intensity,
    required this.seed,
    this.phase = 0,
  });

  final double intensity;
  final int seed;

  /// 0–1 around one full orbit.
  final double phase;

  static const List<_Blob> _blobs = [
    _Blob(Offset(0.14, -0.06), 0.66, AppColors.brand500, 0.34, 0.030),
    _Blob(Offset(0.96, 0.08), 0.54, AppColors.rose400, 0.26, 0.026),
    _Blob(Offset(-0.16, 0.42), 0.60, AppColors.accent500, 0.20, 0.034),
    _Blob(Offset(0.88, 0.78), 0.70, AppColors.brand200, 0.30, 0.022),
    _Blob(Offset(0.36, 0.96), 0.56, AppColors.violet400, 0.18, 0.028),
    _Blob(Offset(0.66, 0.36), 0.44, AppColors.sky400, 0.14, 0.036),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0) return;

    final shortest = math.min(size.width, size.height);
    // A deterministic per-screen offset — no randomness, so the field never
    // jumps between rebuilds.
    final drift = (seed % 5) * 0.035;
    final angle = phase * 2 * math.pi;

    for (var i = 0; i < _blobs.length; i++) {
      final blob = _blobs[i];

      // Each blob runs its own ellipse, a third of a turn apart, so they never
      // line up into an obvious shared rotation.
      final orbit = angle + (i * 2 * math.pi / _blobs.length);
      final ox = math.cos(orbit) * blob.orbit;
      final oy = math.sin(orbit) * blob.orbit * 0.7;

      final center = Offset(
        (blob.center.dx + (i.isEven ? drift : -drift) + ox) * size.width,
        (blob.center.dy + (i.isOdd ? drift : -drift) + oy) * size.height,
      );
      final radius = blob.radius * shortest;
      final alpha = blob.opacity * intensity;

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            blob.color.withValues(alpha: alpha),
            blob.color.withValues(alpha: alpha * 0.45),
            blob.color.withValues(alpha: 0),
          ],
          stops: const [0, 0.55, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawCircle(center, radius, paint);
    }

    // A vignette pulls the corners down so floating glass panels keep their
    // edges against the field instead of dissolving into it.
    final vignette = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0x00000000),
          AppColors.ink950.withValues(alpha: 0.05 * intensity),
        ],
        stops: const [0.62, 1],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, vignette);
  }

  @override
  bool shouldRepaint(_AmbientPainter old) =>
      old.intensity != intensity || old.seed != seed || old.phase != phase;
}

class _Blob {
  const _Blob(this.center, this.radius, this.color, this.opacity, this.orbit);

  /// Fractions of the canvas, so the field scales with the screen.
  final Offset center;
  final double radius;
  final Color color;
  final double opacity;

  /// Half-width of the blob's drift ellipse, as a fraction of the canvas.
  final double orbit;
}
