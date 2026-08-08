import 'package:flutter/widgets.dart';
import 'package:smooth_corner/smooth_corner.dart';

/// Rayons de coin et fabriques de formes « squircle » (courbure continue),
/// signature visuelle d'Apple, via le paquet `smooth_corner`.
class AppleRadii {
  const AppleRadii._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;

  /// Lissage des coins (0 = coin arrondi classique, 1 = squircle maximal).
  static const double smoothing = 0.6;

  static BorderRadius circular(double r) => BorderRadius.circular(r);

  /// Forme squircle prête à l'emploi pour `Card.shape`, `Material.shape`, etc.
  static SmoothRectangleBorder shape(
    double cornerRadius, {
    BorderSide side = BorderSide.none,
  }) {
    return SmoothRectangleBorder(
      smoothness: smoothing,
      side: side,
      borderRadius: BorderRadius.circular(cornerRadius),
    );
  }
}
