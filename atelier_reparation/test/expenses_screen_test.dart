// Écran Dépenses (EX2) : création d'une dépense via le formulaire.

import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/data/storage.dart';
import 'package:atelier_reparation/core/settings/settings_controller.dart';
import 'package:atelier_reparation/core/settings/settings_repository.dart';
import 'package:atelier_reparation/features/expenses/application/expenses_controller.dart';
import 'package:atelier_reparation/features/expenses/presentation/expenses_screen.dart';
import 'package:atelier_reparation/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('crée une dépense via le formulaire', (tester) async {
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
        home: Material(child: ExpensesScreen()),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Aucune dépense'), findsOneWidget);
    await tester.tap(find.byTooltip('Nouvelle dépense'));
    await tester.pumpAndSettle();

    // Champs : libellé (0), montant HT (1), TVA (2).
    await tester.enterText(find.byType(TextField).at(0), 'Loyer mars');
    await tester.enterText(find.byType(TextField).at(1), '800');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Enregistrer'));
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    final list = container.read(expensesProvider);
    expect(list.length, 1);
    expect(list.single.label, 'Loyer mars');
    expect(list.single.amountHt, 800);
  });
}
