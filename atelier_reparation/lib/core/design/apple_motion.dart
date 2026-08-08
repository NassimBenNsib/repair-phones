import 'package:flutter/animation.dart';

/// Durées et courbes d'animation dans l'esprit d'Apple : rapides, souples,
/// sans rebond exagéré.
class AppleMotion {
  const AppleMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);

  /// Décélération standard (proche des transitions système iOS).
  static const Curve standard = Curves.easeOutCubic;

  /// Entrée/sortie douce pour les apparitions.
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;
}
