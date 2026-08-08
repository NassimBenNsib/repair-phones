import 'package:flutter/widgets.dart';

/// Palette sémantique inspirée des « System Colors » d'Apple (iOS / macOS HIG).
///
/// Deux jeux immuables sont fournis : [AppleColors.light] et [AppleColors.dark].
/// Les valeurs suivent les couleurs système documentées par Apple afin de
/// conserver une identité visuelle fidèle sur toutes les plateformes.
@immutable
class AppleColors {
  const AppleColors({
    required this.brightness,
    required this.blue,
    required this.green,
    required this.indigo,
    required this.orange,
    required this.pink,
    required this.purple,
    required this.red,
    required this.teal,
    required this.yellow,
    required this.systemBackground,
    required this.secondarySystemBackground,
    required this.tertiarySystemBackground,
    required this.groupedBackground,
    required this.secondaryGroupedBackground,
    required this.label,
    required this.secondaryLabel,
    required this.tertiaryLabel,
    required this.quaternaryLabel,
    required this.separator,
    required this.fill,
  });

  final Brightness brightness;

  // Teintes système (accentuation).
  final Color blue;
  final Color green;
  final Color indigo;
  final Color orange;
  final Color pink;
  final Color purple;
  final Color red;
  final Color teal;
  final Color yellow;

  // Fonds.
  final Color systemBackground;
  final Color secondarySystemBackground;
  final Color tertiarySystemBackground;
  final Color groupedBackground;
  final Color secondaryGroupedBackground;

  // Libellés (texte) — l'opacité décroît avec la hiérarchie.
  final Color label;
  final Color secondaryLabel;
  final Color tertiaryLabel;
  final Color quaternaryLabel;

  // Séparateur (hairline) et remplissage subtil.
  final Color separator;
  final Color fill;

  bool get isDark => brightness == Brightness.dark;

  /// Jeu clair (iOS light).
  static const AppleColors light = AppleColors(
    brightness: Brightness.light,
    blue: Color(0xFF007AFF),
    green: Color(0xFF34C759),
    indigo: Color(0xFF5856D6),
    orange: Color(0xFFFF9500),
    pink: Color(0xFFFF2D55),
    purple: Color(0xFFAF52DE),
    red: Color(0xFFFF3B30),
    teal: Color(0xFF30B0C7),
    yellow: Color(0xFFFFCC00),
    systemBackground: Color(0xFFFFFFFF),
    secondarySystemBackground: Color(0xFFF2F2F7),
    tertiarySystemBackground: Color(0xFFFFFFFF),
    groupedBackground: Color(0xFFF2F2F7),
    secondaryGroupedBackground: Color(0xFFFFFFFF),
    label: Color(0xFF000000),
    secondaryLabel: Color(0x993C3C43), // 60 %
    tertiaryLabel: Color(0x4D3C3C43), // 30 %
    quaternaryLabel: Color(0x2E3C3C43), // 18 %
    separator: Color(0x5C3C3C43), // 36 %
    fill: Color(0x1E787880), // 12 %
  );

  /// Jeu sombre (iOS dark).
  static const AppleColors dark = AppleColors(
    brightness: Brightness.dark,
    blue: Color(0xFF0A84FF),
    green: Color(0xFF30D158),
    indigo: Color(0xFF5E5CE6),
    orange: Color(0xFFFF9F0A),
    pink: Color(0xFFFF375F),
    purple: Color(0xFFBF5AF2),
    red: Color(0xFFFF453A),
    teal: Color(0xFF40C8E0),
    yellow: Color(0xFFFFD60A),
    systemBackground: Color(0xFF000000),
    secondarySystemBackground: Color(0xFF1C1C1E),
    tertiarySystemBackground: Color(0xFF2C2C2E),
    groupedBackground: Color(0xFF000000),
    secondaryGroupedBackground: Color(0xFF1C1C1E),
    label: Color(0xFFFFFFFF),
    secondaryLabel: Color(0x99EBEBF5), // 60 %
    tertiaryLabel: Color(0x4DEBEBF5), // 30 %
    quaternaryLabel: Color(0x29EBEBF5), // 16 %
    separator: Color(0xA6545458), // 65 %
    fill: Color(0x33787880), // 20 %
  );

  static AppleColors of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  /// Interpolation linéaire, requise par le [ThemeExtension] hôte.
  static AppleColors lerp(AppleColors a, AppleColors b, double t) {
    Color c(Color x, Color y) => Color.lerp(x, y, t)!;
    return AppleColors(
      brightness: t < 0.5 ? a.brightness : b.brightness,
      blue: c(a.blue, b.blue),
      green: c(a.green, b.green),
      indigo: c(a.indigo, b.indigo),
      orange: c(a.orange, b.orange),
      pink: c(a.pink, b.pink),
      purple: c(a.purple, b.purple),
      red: c(a.red, b.red),
      teal: c(a.teal, b.teal),
      yellow: c(a.yellow, b.yellow),
      systemBackground: c(a.systemBackground, b.systemBackground),
      secondarySystemBackground:
          c(a.secondarySystemBackground, b.secondarySystemBackground),
      tertiarySystemBackground:
          c(a.tertiarySystemBackground, b.tertiarySystemBackground),
      groupedBackground: c(a.groupedBackground, b.groupedBackground),
      secondaryGroupedBackground:
          c(a.secondaryGroupedBackground, b.secondaryGroupedBackground),
      label: c(a.label, b.label),
      secondaryLabel: c(a.secondaryLabel, b.secondaryLabel),
      tertiaryLabel: c(a.tertiaryLabel, b.tertiaryLabel),
      quaternaryLabel: c(a.quaternaryLabel, b.quaternaryLabel),
      separator: c(a.separator, b.separator),
      fill: c(a.fill, b.fill),
    );
  }
}
