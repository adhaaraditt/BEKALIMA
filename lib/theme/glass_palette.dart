import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Warna permukaan liquid glass yang ikut diinterpolasi oleh `AnimatedTheme`
/// milik [MaterialApp]. Dengan begitu mode terang dan gelap tidak lagi
/// berganti mendadak di tengah animasi seperti saat membaca `brightness`.
@immutable
class GlassPalette extends ThemeExtension<GlassPalette> {
  final Color gradientStart;
  final Color gradientEnd;
  final Color navGradientStart;
  final Color navGradientEnd;
  final Color border;
  final Color shadow;
  final Color highlight;

  const GlassPalette({
    required this.gradientStart,
    required this.gradientEnd,
    required this.navGradientStart,
    required this.navGradientEnd,
    required this.border,
    required this.shadow,
    required this.highlight,
  });

  static final GlassPalette light = GlassPalette(
    gradientStart: Colors.white.withValues(alpha: 0.96),
    gradientEnd: AppColors.cream.withValues(alpha: 0.88),
    navGradientStart: Colors.white.withValues(alpha: 0.92),
    navGradientEnd: Colors.white.withValues(alpha: 0.72),
    border: Colors.white.withValues(alpha: 0.85),
    shadow: AppColors.textPrimary.withValues(alpha: 0.06),
    highlight: Colors.white.withValues(alpha: 0.5),
  );

  static final GlassPalette dark = GlassPalette(
    gradientStart: AppColors.darkSurfaceHigh.withValues(alpha: 0.94),
    gradientEnd: AppColors.darkSurface.withValues(alpha: 0.88),
    navGradientStart: AppColors.darkSurfaceHigh.withValues(alpha: 0.96),
    navGradientEnd: AppColors.darkSurface.withValues(alpha: 0.90),
    border: Colors.white.withValues(alpha: 0.10),
    shadow: Colors.black.withValues(alpha: 0.45),
    highlight: Colors.white.withValues(alpha: 0),
  );

  @override
  GlassPalette copyWith({
    Color? gradientStart,
    Color? gradientEnd,
    Color? navGradientStart,
    Color? navGradientEnd,
    Color? border,
    Color? shadow,
    Color? highlight,
  }) {
    return GlassPalette(
      gradientStart: gradientStart ?? this.gradientStart,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      navGradientStart: navGradientStart ?? this.navGradientStart,
      navGradientEnd: navGradientEnd ?? this.navGradientEnd,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
      highlight: highlight ?? this.highlight,
    );
  }

  @override
  GlassPalette lerp(covariant GlassPalette? other, double t) {
    if (other == null) return this;

    return GlassPalette(
      gradientStart: Color.lerp(gradientStart, other.gradientStart, t)!,
      gradientEnd: Color.lerp(gradientEnd, other.gradientEnd, t)!,
      navGradientStart: Color.lerp(
        navGradientStart,
        other.navGradientStart,
        t,
      )!,
      navGradientEnd: Color.lerp(navGradientEnd, other.navGradientEnd, t)!,
      border: Color.lerp(border, other.border, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
    );
  }
}

GlassPalette glassPaletteOf(BuildContext context) =>
    Theme.of(context).extension<GlassPalette>() ?? GlassPalette.light;