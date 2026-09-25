import 'package:flutter/material.dart';

/// The MyFlat Homes palette, mirrored from the web app's terracotta re-theme.
///
/// Role assignments matter for contrast: [brand500] is a *fill* colour and must
/// never be used for text on a light surface — use [brand700] there instead.
class AppColors {
  const AppColors._();

  // Brand — warm terracotta
  static const Color brand100 = Color(0xFFFFEDD5);
  static const Color brand200 = Color(0xFFFED7AA);
  static const Color brand500 = Color(0xFFF97316); // primary actions
  static const Color brand600 = Color(0xFFEA580C); // pressed / gradient end
  static const Color brand700 = Color(0xFFC2410C); // headings and prices

  // Accent — teal: success, "available", verified
  static const Color accent100 = Color(0xFFCCFBF1);
  static const Color accent500 = Color(0xFF14B8A6);
  static const Color accent600 = Color(0xFF0D9488);
  static const Color accent700 = Color(0xFF0F766E);

  // Rose — ambient gradient only, plus destructive affordances
  static const Color rose400 = Color(0xFFFB7185);
  static const Color rose500 = Color(0xFFF43F5E);
  static const Color rose600 = Color(0xFFE11D48);

  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber700 = Color(0xFFB45309);

  /// Ambient-field only. Glass needs colour variety behind it or it reads as
  /// flat translucent plastic, so the background field carries two cool notes
  /// the foreground palette never uses.
  static const Color violet400 = Color(0xFFA78BFA);
  static const Color sky400 = Color(0xFF38BDF8);

  // Ink — warm near-black at three emphasis levels
  static const Color ink950 = Color(0xFF1F1613);
  static const Color inkPrimary = ink950;
  static const Color inkSecondary = Color(0xB31F1613); // 70%
  static const Color inkTertiary = Color(0x801F1613); // 50%
  static const Color inkFaint = Color(0x4D1F1613); // 30%

  // Surfaces
  static const Color ground = Color(0xFFFDFAF7);
  static const Color surface = Colors.white;
  static const Color surfaceMuted = Color(0xFFF6F1EC);
  static const Color line = Color(0xFFEDE4DC);
  static const Color lineStrong = Color(0xFFDCCFC4);

  // ── Glass ─────────────────────────────────────────────────────────────
  // A pane of frosted glass is not one flat translucent fill. It is brighter
  // where the light lands and thinner where it does not, it carries a hard
  // specular line along its lit rim, and it sits on a shadow with both a tight
  // contact edge and a wide ambient falloff. These tokens name those parts.

  /// Legacy single-stop fill and hairline, kept for surfaces that want a plain
  /// translucent panel rather than the full pane treatment.
  static const Color glassFill = Color(0x8CFFFFFF); // white @ 55%
  static const Color glassBorder = Color(0x99FFFFFF); // white @ 60%

  /// The two ends of a pane's fill: lit corner, then shadowed corner.
  static const Color glassTop = Color(0xC7FFFFFF); // white @ 78%
  static const Color glassMid = Color(0x82FFFFFF); // white @ 51%
  static const Color glassBottom = Color(0x5CFFFFFF); // white @ 36%

  /// Rim light. The lit edge is nearly opaque white; the opposite edge keeps
  /// just enough to separate the pane from whatever is behind it.
  static const Color glassRimBright = Color(0xF2FFFFFF); // white @ 95%
  static const Color glassRimDim = Color(0x33FFFFFF); // white @ 20%

  /// The specular hotspot dropped into a pane's lit corner.
  static const Color glassSpecular = Color(0x8AFFFFFF); // white @ 54%

  /// Soft warm shadow used under every raised surface.
  static const Color shadow = Color(0x1F7C2D12); // rgba(124,45,18,0.12)

  /// The two halves of a glass shadow: a tight contact shadow that anchors the
  /// pane, and a wide ambient one that gives it height.
  static const Color glassShadowContact = Color(0x1A7C2D12);
  static const Color glassShadowAmbient = Color(0x2E7C2D12);
  static const Color glassShadowDeep = Color(0x3D7C2D12);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brand500, brand600],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent500, accent600],
  );

  /// The default pane fill: lit corner to shadowed corner across the diagonal.
  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [glassTop, glassMid, glassBottom],
    stops: [0, 0.55, 1],
  );

  /// Shimmer skeleton base/highlight, warmed to sit on [ground].
  static const Color shimmerBase = Color(0xFFEFE7E0);
  static const Color shimmerHighlight = Color(0xFFFBF7F3);
}
