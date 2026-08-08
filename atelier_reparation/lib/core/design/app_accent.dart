import 'package:flutter/widgets.dart';

import 'apple_colors.dart';

/// Couleur d'accent sélectionnable par l'utilisateur.
///
/// Chaque valeur se résout vers la teinte système correspondante du jeu
/// [AppleColors] actif (donc automatiquement adaptée au clair / sombre).
enum AppAccent {
  blue,
  green,
  orange,
  red,
  indigo,
  purple,
  teal;

  Color resolve(AppleColors colors) {
    switch (this) {
      case AppAccent.blue:
        return colors.blue;
      case AppAccent.green:
        return colors.green;
      case AppAccent.orange:
        return colors.orange;
      case AppAccent.red:
        return colors.red;
      case AppAccent.indigo:
        return colors.indigo;
      case AppAccent.purple:
        return colors.purple;
      case AppAccent.teal:
        return colors.teal;
    }
  }

  /// Échantillon stable (jeu clair) pour l'aperçu dans le sélecteur.
  Color get swatch => resolve(AppleColors.light);
}
