import 'package:flutter/material.dart';

import '../design/apple_tokens.dart';

/// Thème central de l'application, construit sur le design system Apple.
///
/// Le thème est piloté par une luminosité et une couleur d'[AppAccent] : la
/// palette « system colors », la typographie Inter, les coins squircle et la
/// profondeur discrète restent constantes, tandis que l'accent régénère le
/// `ColorScheme` et les [AppleTokens] (accès `context.apple`).
class AppTheme {
  const AppTheme._();

  static ThemeData light([AppAccent accent = AppAccent.blue]) =>
      _build(Brightness.light, accent);

  static ThemeData dark([AppAccent accent = AppAccent.blue]) =>
      _build(Brightness.dark, accent);

  static ThemeData _build(Brightness brightness, AppAccent accent) {
    final tokens = AppleTokens.resolve(brightness, accent);
    final c = tokens.colors;
    final accentColor = tokens.accent;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: accentColor,
      brightness: brightness,
    ).copyWith(
      primary: accentColor,
      surface: c.secondaryGroupedBackground,
      onSurface: c.label,
      outlineVariant: c.separator,
      error: c.red,
    );

    final textTheme = AppleTypography.toTextTheme(c);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      fontFamily: AppleTypography.fontFamily,
      scaffoldBackgroundColor: c.groupedBackground,
      extensions: [tokens],
      splashFactory: NoSplash.splashFactory,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: c.groupedBackground,
        foregroundColor: c.label,
        titleTextStyle: AppleTypography.headline.copyWith(color: c.label),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        color: c.secondaryGroupedBackground,
        margin: EdgeInsets.zero,
        shape: AppleRadii.shape(AppleRadii.lg),
      ),
      dividerTheme: DividerThemeData(
        color: c.separator,
        thickness: 0.5,
        space: 0.5,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          textStyle: AppleTypography.headline,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: AppleRadii.shape(AppleRadii.md),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
          textStyle: AppleTypography.body,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.secondaryGroupedBackground,
        border: OutlineInputBorder(
          borderRadius: AppleRadii.circular(AppleRadii.md),
          borderSide: BorderSide(color: c.separator),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppleRadii.circular(AppleRadii.md),
          borderSide: BorderSide(color: c.separator),
        ),
      ),
    );
  }
}
