// Écran Profil : rendu pour l'utilisateur connecté + changement de mot de passe
// (mauvais actuel → erreur, correct → mise à jour du hash).

import 'package:atelier_reparation/core/auth/hashing.dart';
import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/data/storage.dart';
import 'package:atelier_reparation/core/settings/settings_controller.dart';
import 'package:atelier_reparation/core/settings/settings_repository.dart';
import 'package:atelier_reparation/features/auth/application/session_controller.dart';
import 'package:atelier_reparation/features/auth/data/session_repository.dart';
import 'package:atelier_reparation/features/profile/presentation/profile_screen.dart';
import 'package:atelier_reparation/features/users/application/users_controller.dart';
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
  tester.view.physicalSize = const Size(500, 900);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(ProviderScope(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(SettingsRepository(prefs)),
      localStoreProvider.overrideWithValue(InMemoryStore()),
      sessionRepositoryProvider.overrideWithValue(SessionRepository(prefs)),
    ],
    child: MaterialApp(
      locale: const Locale('fr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Material(child: ProfileScreen()),
    ),
  ));
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(ProfileScreen)));
}

void main() {
  testWidgets('affiche le compte connecté', (tester) async {
    await _pump(tester);
    expect(find.text('admin@atelier.fr'), findsWidgets);
    expect(find.text('Changer le mot de passe'), findsOneWidget);
    expect(find.text('Changer le code PIN'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('changement de mot de passe : mauvais actuel puis correct',
      (tester) async {
    final container = await _pump(tester);
    await tester.tap(find.text('Changer le mot de passe'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    // Mauvais mot de passe actuel → erreur.
    await tester.enterText(fields.at(0), 'wrong');
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(find.text('Mot de passe actuel incorrect'), findsOneWidget);

    // Correct + nouveau confirmé.
    await tester.enterText(fields.at(0), 'admin');
    await tester.enterText(fields.at(1), 'nouveau123');
    await tester.enterText(fields.at(2), 'nouveau123');
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    final admin =
        container.read(usersProvider).firstWhere((u) => u.id == 'seed-admin');
    expect(verifySecret('nouveau123', admin.passwordHash), isTrue);
    expect(tester.takeException(), isNull);
  });
}
