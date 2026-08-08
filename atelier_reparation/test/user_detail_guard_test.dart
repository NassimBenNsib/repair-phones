// Garde-fou UI : désactiver le dernier administrateur est refusé (message +
// aucun changement persisté).

import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/data/storage.dart';
import 'package:atelier_reparation/core/settings/settings_controller.dart';
import 'package:atelier_reparation/core/settings/settings_repository.dart';
import 'package:atelier_reparation/features/auth/application/session_controller.dart';
import 'package:atelier_reparation/features/auth/data/session_repository.dart';
import 'package:atelier_reparation/features/users/application/users_controller.dart';
import 'package:atelier_reparation/features/users/presentation/user_detail.dart';
import 'package:atelier_reparation/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('désactiver le dernier admin est bloqué', (tester) async {
    SharedPreferences.setMockInitialValues({
      'settings.locale': 'fr',
      'session.userId': 'seed-admin',
    });
    final prefs = await SharedPreferences.getInstance();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(600, 1000);
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

    final container =
        ProviderScope.containerOf(tester.element(find.byType(UserDetailView)));

    // Passer en édition, désactiver le compte, enregistrer.
    await tester.tap(find.text('Modifier'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    expect(find.text('Au moins un administrateur actif est requis'),
        findsOneWidget);
    // L'admin reste actif (rien n'a été persisté).
    final admin =
        container.read(usersProvider).firstWhere((u) => u.id == 'seed-admin');
    expect(admin.active, isTrue);
  });
}
