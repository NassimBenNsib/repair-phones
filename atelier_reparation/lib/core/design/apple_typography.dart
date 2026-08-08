import 'package:flutter/material.dart';

import 'apple_colors.dart';

/// Échelle typographique inspirée des styles de texte iOS (San Francisco),
/// rendue avec la police variable **Inter** embarquée.
///
/// Comme Inter est une police variable, la graisse est appliquée à la fois via
/// [TextStyle.fontWeight] (pour la logique Flutter) et via
/// [FontVariation.weight] (pour piloter l'axe `wght` du fichier variable).
class AppleTypography {
  const AppleTypography._();

  static const String fontFamily = 'Inter';

  static List<FontVariation> _v(double weight) => [FontVariation.weight(weight)];

  static TextStyle _style({
    required double size,
    required double weight,
    required double height,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      height: height / size, // `height` Apple est exprimée en points → ratio.
      fontWeight: FontWeight.values[(weight ~/ 100) - 1],
      fontVariations: _v(weight),
      letterSpacing: letterSpacing,
    );
  }

  // Échelle « points » ≈ styles de texte iOS (taille / interligne).
  static final TextStyle largeTitle =
      _style(size: 34, weight: 700, height: 41, letterSpacing: 0.37);
  static final TextStyle title1 =
      _style(size: 28, weight: 700, height: 34, letterSpacing: 0.36);
  static final TextStyle title2 =
      _style(size: 22, weight: 700, height: 28, letterSpacing: 0.35);
  static final TextStyle title3 =
      _style(size: 20, weight: 600, height: 25, letterSpacing: 0.38);
  static final TextStyle headline =
      _style(size: 17, weight: 600, height: 22, letterSpacing: -0.43);
  static final TextStyle body =
      _style(size: 17, weight: 400, height: 22, letterSpacing: -0.43);
  static final TextStyle callout =
      _style(size: 16, weight: 400, height: 21, letterSpacing: -0.32);
  static final TextStyle subheadline =
      _style(size: 15, weight: 400, height: 20, letterSpacing: -0.24);
  static final TextStyle footnote =
      _style(size: 13, weight: 400, height: 18, letterSpacing: -0.08);
  static final TextStyle caption1 =
      _style(size: 12, weight: 400, height: 16);
  static final TextStyle caption2 =
      _style(size: 11, weight: 400, height: 13, letterSpacing: 0.06);

  /// Construit un [TextTheme] Material à partir de l'échelle, en appliquant les
  /// couleurs de libellé du jeu [colors] fourni.
  static TextTheme toTextTheme(AppleColors colors) {
    final label = colors.label;
    final secondary = colors.secondaryLabel;
    return TextTheme(
      displayLarge: largeTitle.copyWith(color: label),
      displayMedium: title1.copyWith(color: label),
      displaySmall: title2.copyWith(color: label),
      headlineMedium: title2.copyWith(color: label),
      headlineSmall: title3.copyWith(color: label),
      titleLarge: title3.copyWith(color: label),
      titleMedium: headline.copyWith(color: label),
      titleSmall: subheadline.copyWith(color: label),
      bodyLarge: body.copyWith(color: label),
      bodyMedium: callout.copyWith(color: label),
      bodySmall: footnote.copyWith(color: secondary),
      labelLarge: headline.copyWith(color: label),
      labelMedium: caption1.copyWith(color: secondary),
      labelSmall: caption2.copyWith(color: secondary),
    );
  }
}
