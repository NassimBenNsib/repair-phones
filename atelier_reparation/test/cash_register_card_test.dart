// Caisse (CR2) : la carte ouvre une session depuis l'écran Paiements et bascule
// en état ouvert (espèces attendues + clôture).

import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/data/storage.dart';
import 'package:atelier_reparation/core/settings/settings_controller.dart';
import 'package:atelier_reparation/core/settings/settings_repository.dart';
import 'package:atelier_reparation/features/payments/application/cash_register_controller.dart';
import 'package:atelier_reparation/features/payments/presentation/payments_screen.dart';
import 'package:atelier_reparation/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('carte caisse : ouverture depuis Paiements', (tester) async {
    SharedPreferences.setMockInitialValues({'settings.locale': 'fr'});
    final prefs = await SharedPreferences.getInstance();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(600, 1800);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(overrides: [
      localStoreProvider.overrideWithValue(InMemoryStore()),
      settingsRepositoryProvider.overrideWithValue(SettingsRepository(prefs)),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        locale: Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Material(child: PaymentsScreen()),
      ),
    ));
    await tester.pumpAndSettle();

    // Caisse fermée → bouton d'ouverture.
    expect(find.textContaining('Caisse fermée'), findsOneWidget);
    expect(find.text('Ouvrir la caisse'), findsOneWidget);
    await tester.tap(find.text('Ouvrir la caisse'));
    await tester.pumpAndSettle();

    // Feuille : saisir le fond de caisse puis confirmer (bouton de la feuille).
    await tester.enterText(find.byType(TextField).first, '150');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ouvrir la caisse').last);
    await tester.pumpAndSettle();

    // Session ouverte + la carte affiche « Espèces attendues ».
    expect(container.read(cashRegisterProvider.notifier).openSession, isNotNull);
    expect(
        container.read(cashRegisterProvider.notifier).openSession!.openingFloat,
        150);
    expect(find.text('Espèces attendues'), findsOneWidget);
    expect(find.text('Clôturer la caisse'), findsOneWidget);
  });
}
