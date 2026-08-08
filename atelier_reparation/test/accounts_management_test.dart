// Gestion des comptes : activité, horodatage, et action « Réinitialiser le PIN »
// qui journalise un événement.

import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/data/storage.dart';
import 'package:atelier_reparation/core/settings/settings_controller.dart';
import 'package:atelier_reparation/core/settings/settings_repository.dart';
import 'package:atelier_reparation/features/auth/application/session_controller.dart';
import 'package:atelier_reparation/features/auth/data/session_repository.dart';
import 'package:atelier_reparation/features/users/application/account_log_controller.dart';
import 'package:atelier_reparation/features/users/domain/account_event.dart';
import 'package:atelier_reparation/features/users/presentation/user_detail.dart';
import 'package:atelier_reparation/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _pump(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({
    'settings.locale': 'fr',
    'session.userId': 'seed-admin',
  });
  final prefs = await SharedPreferences.getInstance();
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(700, 1200);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(ProviderScope(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(SettingsRepository(prefs)),
      localStoreProvider.overrideWithValue(InMemoryStore()),
      sessionRepositoryProvider.overrideWithValue(SessionRepository(prefs)),
    ],
    child: const MaterialApp(
      locale: Locale('fr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Material(child: UserDetailView(userId: 'seed-admin')),
    ),
  ));
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(UserDetailView)));
}

void main() {
  testWidgets('activité affichée + réinitialiser le PIN journalise',
      (tester) async {
    final container = await _pump(tester);

    // Sections de gestion présentes.
    expect(find.text('Activité'), findsOneWidget);
    expect(find.text('Actions'), findsOneWidget);
    // Le journal semé contient une connexion.
    expect(find.text('Connexion'), findsWidgets);

    // Réinitialiser le PIN → affiche un secret, puis journalise pinReset.
    await tester.tap(find.text('Réinitialiser le PIN'));
    await tester.pumpAndSettle();
    expect(find.text('Secret temporaire (démo)'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    final log = container.read(accountLogProvider);
    expect(log.any((e) => e.kind == AccountEventKind.pinReset), isTrue);
    expect(tester.takeException(), isNull);
  });
}
