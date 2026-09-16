import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import 'glass.dart';

export 'glass.dart';

/// A frosted-glass card: a blurred, saturated sample of the ambient field
/// behind it, a diagonal fill that runs bright-to-thin, a specular hotspot in
/// the lit corner and a gradient rim light.
///
/// The [BackdropFilter] is opt-out via [blur] for the rare surface that sits on
/// a flat background where there is nothing worth sampling. It is *on* by
/// default, including in lists — the blur is what separates glass from
/// translucent plastic. [Glass.enableBackdropBlur] turns it off app-wide if the
/// cost ever stops being worth it.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
    this.radius = AppTheme.radiusLg,
    this.blur = true,
    this.blurSigma = Glass.blurCard,
    this.onTap,
    this.borderColor,
    this.fill,
    this.tint,
    this.elevated = false,
    this.specular = true,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final bool blur;
  final double blurSigma;
  final VoidCallback? onTap;

  /// Overrides the rim light. Given a colour, the rim runs from it at the lit
  /// edge to a faded version at the far edge.
  final Color? borderColor;

  /// Overrides the white pane fill entirely.
  final Color? fill;

  /// A colour bleeding *through* the glass, layered over the fill rather than
  /// replacing it — how a coloured object behind a pane shows up in it.
  final Color? tint;

  final bool elevated;
  final bool specular;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    Widget card = GlassSurface(
      radius: radius,
      padding: padding,
      blur: blur,
      blurSigma: blurSigma,
      fill: fill,
      tint: tint,
      rimColor: borderColor,
      specular: specular,
      elevation: elevated ? 1 : 0,
      child: child,
    );

    if (margin != null) {
      card = Padding(padding: margin!, child: card);
    }

    final tap = onTap;
    if (tap != null) {
      card = GlassTapTarget(onTap: tap, child: card);
    }

    final label = semanticLabel;
    if (label != null) {
      card = Semantics(label: label, button: tap != null, child: card);
    }

    return card;
  }
}
