import 'package:flutter/widgets.dart';

/// Classes de taille adaptatives, alignées sur les seuils Material 3 / iPadOS.
enum SizeClass { compact, medium, expanded }

/// Seuils de largeur et utilitaires responsive.
class AppleBreakpoints {
  const AppleBreakpoints._();

  static const double medium = 600; // téléphone large / petite tablette
  static const double expanded = 1024; // tablette large / desktop

  static SizeClass of(double width) {
    if (width >= expanded) return SizeClass.expanded;
    if (width >= medium) return SizeClass.medium;
    return SizeClass.compact;
  }
}

/// Accès ergonomique aux informations responsive depuis un [BuildContext].
extension ResponsiveX on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  SizeClass get sizeClass => AppleBreakpoints.of(screenWidth);

  bool get isCompact => sizeClass == SizeClass.compact;
  bool get isMedium => sizeClass == SizeClass.medium;
  bool get isExpanded => sizeClass == SizeClass.expanded;

  /// Sélectionne une valeur selon la classe de taille courante.
  T adaptive<T>({required T compact, T? medium, T? expanded}) {
    switch (sizeClass) {
      case SizeClass.expanded:
        return expanded ?? medium ?? compact;
      case SizeClass.medium:
        return medium ?? compact;
      case SizeClass.compact:
        return compact;
    }
  }
}
