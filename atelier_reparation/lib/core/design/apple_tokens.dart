import 'package:flutter/material.dart';

import 'app_accent.dart';
import 'apple_colors.dart';
import 'apple_shadows.dart';

export 'app_accent.dart';
export 'apple_breakpoints.dart';
export 'apple_colors.dart';
export 'apple_glass.dart';
export 'apple_motion.dart';
export 'apple_radii.dart';
export 'apple_shadows.dart';
export 'apple_spacing.dart';
export 'apple_typography.dart';

/// Jeton de thème central du design system Apple.
///
/// Enregistré comme [ThemeExtension] sur le `ThemeData` de l'application, il
/// expose la palette sémantique, la couleur d'accent choisie et les ombres qui
/// n'ont pas d'équivalent direct dans le `ColorScheme` Material.
///
/// Accès ergonomique : `context.apple`.
@immutable
class AppleTokens extends ThemeExtension<AppleTokens> {
  const AppleTokens({required this.colors, required this.accent});

  final AppleColors colors;

  /// Couleur d'accent résolue (déjà adaptée au clair / sombre).
  final Color accent;

  /// Construit les jetons pour une luminosité et un accent donnés.
  factory AppleTokens.resolve(Brightness brightness, AppAccent accent) {
    final colors = AppleColors.of(brightness);
    return AppleTokens(colors: colors, accent: accent.resolve(colors));
  }

  static final AppleTokens light =
      AppleTokens.resolve(Brightness.light, AppAccent.blue);
  static final AppleTokens dark =
      AppleTokens.resolve(Brightness.dark, AppAccent.blue);

  Brightness get brightness => colors.brightness;

  List<BoxShadow> get cardShadow => AppleShadows.cardLow(brightness);
  List<BoxShadow> get cardShadowMedium => AppleShadows.cardMedium(brightness);

  @override
  AppleTokens copyWith({AppleColors? colors, Color? accent}) => AppleTokens(
        colors: colors ?? this.colors,
        accent: accent ?? this.accent,
      );

  @override
  AppleTokens lerp(ThemeExtension<AppleTokens>? other, double t) {
    if (other is! AppleTokens) return this;
    return AppleTokens(
      colors: AppleColors.lerp(colors, other.colors, t),
      accent: Color.lerp(accent, other.accent, t)!,
    );
  }
}

/// Raccourci d'accès aux jetons Apple depuis un [BuildContext].
extension AppleTokensX on BuildContext {
  AppleTokens get apple =>
      Theme.of(this).extension<AppleTokens>() ?? AppleTokens.light;

  /// Accès direct à la palette sémantique.
  AppleColors get appleColors => apple.colors;

  /// Couleur d'accent active.
  Color get accentColor => apple.accent;

  bool get isRtl => Directionality.of(this) == TextDirection.rtl;

  /// Chevron « en avant » qui se reflète en RTL.
  IconData get chevronForward =>
      isRtl ? Icons.chevron_left : Icons.chevron_right;

  /// Flèche de retour qui se reflète en RTL.
  IconData get backIcon =>
      isRtl ? Icons.arrow_forward_ios : Icons.arrow_back_ios_new;
}
