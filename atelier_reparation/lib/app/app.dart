import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/router/app_router.dart';
import '../core/settings/settings_controller.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';

/// Racine de l'application.
///
/// Utilise `MaterialApp.router` (navigation déléguée à go_router) et réagit aux
/// préférences utilisateur (thème, accent, langue) via [settingsControllerProvider].
class AtelierReparationApp extends ConsumerWidget {
  const AtelierReparationApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final settings = ref.watch(settingsControllerProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(settings.accent),
      darkTheme: AppTheme.dark(settings.accent),
      themeMode: settings.themeMode,
      locale: settings.locale,
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
