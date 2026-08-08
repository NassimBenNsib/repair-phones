// Test de fumée : l'application démarre sur le tableau de bord (locale FR).

import 'package:atelier_reparation/app/app.dart';
import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/data/storage.dart';
import 'package:atelier_reparation/core/settings/settings_controller.dart';
import 'package:atelier_reparation/core/settings/settings_repository.dart';
import 'package:atelier_reparation/features/auth/application/session_controller.dart';
import 'package:atelier_reparation/features/auth/data/session_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Démarre sur le tableau de bord en français',
      (WidgetTester tester) async {
    // Pré-remplit les préférences : langue FR + session ouverte (admin).
    SharedPreferences.setMockInitialValues({
      'settings.locale': 'fr',
      'session.userId': 'seed-admin',
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            SettingsRepository(prefs),
          ),
          localStoreProvider.overrideWithValue(InMemoryStore()),
          sessionRepositoryProvider
              .overrideWithValue(SessionRepository(prefs)),
        ],
        child: const AtelierReparationApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tableau de bord'), findsWidgets);
  });
}
