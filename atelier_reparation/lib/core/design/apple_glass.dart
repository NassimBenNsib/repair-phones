import 'dart:ui';

import 'package:flutter/material.dart';

import 'apple_colors.dart';

/// Jetons et utilitaires « verre dépoli » (vibrancy) façon barres iOS/macOS.
class AppleGlass {
  const AppleGlass._();

  static const double blurSigma = 20;

  /// Couleur de recouvrement translucide posée par-dessus le flou.
  static Color overlay(AppleColors colors) {
    return colors.isDark
        ? colors.systemBackground.withValues(alpha: 0.72)
        : colors.systemBackground.withValues(alpha: 0.78);
  }
}

/// Enveloppe un [child] d'un fond en verre dépoli (flou + recouvrement).
///
/// À utiliser pour les barres supérieures et la navigation. Le flou peut être
/// désactivé (par ex. pour respecter « réduire la transparence » ou sur du
/// matériel peu performant) via [enabled].
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    required this.colors,
    this.enabled = true,
    this.border,
  });

  final Widget child;
  final AppleColors colors;
  final bool enabled;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: colors.groupedBackground,
          border: border,
        ),
        child: child,
      );
    }

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigmaOf, sigmaY: blurSigmaOf),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppleGlass.overlay(colors),
            border: border,
          ),
          child: child,
        ),
      ),
    );
  }

  double get blurSigmaOf => AppleGlass.blurSigma;
}
