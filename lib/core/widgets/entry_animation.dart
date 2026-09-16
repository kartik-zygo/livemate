import 'package:flutter/material.dart';

/// Entry motion: fade in while sliding up 14px, eased out over ~340ms, with a
/// ~50ms stagger across list items.
///
/// The stagger is capped at [maxStaggered] so a 50-item list does not end with
/// rows arriving two seconds late.
class EntryAnimation extends StatefulWidget {
  const EntryAnimation({
    super.key,
    required this.child,
    this.index = 0,
    this.duration = const Duration(milliseconds: 340),
    this.stagger = const Duration(milliseconds: 50),
    this.offset = 14,
    this.maxStaggered = 8,
    this.enabled = true,
  });

  final Widget child;
  final int index;
  final Duration duration;
  final Duration stagger;
  final double offset;
  final int maxStaggered;
  final bool enabled;

  @override
  State<EntryAnimation> createState() => _EntryAnimationState();
}

class _EntryAnimationState extends State<EntryAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  @override
  void initState() {
    super.initState();
    if (!widget.enabled) {
      _controller.value = 1;
      return;
    }
    final steps = widget.index.clamp(0, widget.maxStaggered);
    Future<void>.delayed(widget.stagger * steps, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Honour the platform's reduced-motion setting.
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) => Opacity(
        opacity: _curve.value,
        child: Transform.translate(
          offset: Offset(0, widget.offset * (1 - _curve.value)),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

/// Scale-and-fade used for hero moments — a success confirmation, an empty
/// state illustration.
class PopIn extends StatelessWidget {
  const PopIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 420),
  });

  final Widget child;
  final Duration delay;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) return child;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutBack,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.scale(scale: 0.88 + (0.12 * t), child: child),
      ),
      child: child,
    );
  }
}
