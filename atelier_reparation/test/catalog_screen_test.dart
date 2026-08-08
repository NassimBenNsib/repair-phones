// Écran Catalogue : rendu, recherche, filtre catégorie (drill-down + rollup),
// et modes grille/tableau sans débordement.

import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/data/storage.dart';
import 'package:atelier_reparation/core/settings/settings_controller.dart';
import 'package:atelier_reparation/core/settings/settings_repository.dart';
import 'package:atelier_reparation/features/catalog/application/catalog_controller.dart';
import 'package:atelier_reparation/features/catalog/application/product_categories_controller.dart';
import 'package:atelier_reparation/features/catalog/presentation/catalog_screen.dart';
import 'package:atelier_reparation/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pump(WidgetTester tester,
    {String style = 'list', Size size = const Size(430, 1000)}) async {
  SharedPreferences.setMockInitialValues({
    'settings.locale': 'fr',
    'settings.clientsListStyle': style,
  });
  final prefs = await SharedPreferences.getInstance();
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(ProviderScope(
    overrides: [
      localStoreProvider.overrideWithValue(InMemoryStore()),
      settingsRepositoryProvider.overrideWithValue(SettingsRepository(prefs)),
    ],
    child: const MaterialApp(
      locale: Locale('fr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Material(child: CatalogScreen()),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('rendu + recherche', (tester) async {
    await _pump(tester);
    expect(find.text('Écran iPhone 13'), findsOneWidget);
    expect(find.text('Batterie MacBook Air'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'batterie');
    await tester.pumpAndSettle();
    expect(find.text('Batterie MacBook Air'), findsOneWidget);
    expect(find.text('Écran iPhone 13'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('filtre catégorie : drill-down + rollup', (tester) async {
    await _pump(tester);

    // « Pièce » (rollup) → écran + batterie, mais pas la coque (accessoire).
    await tester.tap(find.text('Pièce'));
    await tester.pumpAndSettle();
    expect(find.text('Écran iPhone 13'), findsOneWidget);
    expect(find.text('Batterie MacBook Air'), findsOneWidget);
    expect(find.text('Coque renforcée'), findsNothing);

    // Sous-catégorie « Écrans » → uniquement l'écran.
    await tester.tap(find.text('Écrans'));
    await tester.pumpAndSettle();
    expect(find.text('Écran iPhone 13'), findsOneWidget);
    expect(find.text('Batterie MacBook Air'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sélection intelligente : « Petit prix »', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('Petit prix'));
    await tester.pumpAndSettle();
    // Seul un produit ≤ 20 € (la coque à 19 €) reste.
    expect(find.text('Coque renforcée'), findsOneWidget);
    expect(find.text('Écran iPhone 13'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('filtre par facette (Marque × Qualité)', (tester) async {
    await _pump(tester);
    // « Apple » (facette Marque) → écran + batterie, pas la coque.
    await tester.tap(find.text('Apple'));
    await tester.pumpAndSettle();
    expect(find.text('Écran iPhone 13'), findsOneWidget);
    expect(find.text('Batterie MacBook Air'), findsOneWidget);
    expect(find.text('Coque renforcée'), findsNothing);

    // + « OEM » (facette Qualité) → seul l'écran (la batterie n'a pas de qualité).
    await tester.tap(find.text('OEM'));
    await tester.pumpAndSettle();
    expect(find.text('Écran iPhone 13'), findsOneWidget);
    expect(find.text('Batterie MacBook Air'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('catégorie archivée : masquée des filtres, produits conservés',
      (tester) async {
    await _pump(tester);
    expect(find.text('Accessoire'), findsOneWidget); // chip présent

    final container = ProviderScope.containerOf(
        tester.element(find.byType(CatalogScreen)));
    final before = container.read(catalogProvider).length;
    final ctrl = container.read(productCategoriesProvider.notifier);
    ctrl.update(ctrl.byId('accessory')!.copyWith(active: false));
    await tester.pumpAndSettle();

    expect(find.text('Accessoire'), findsNothing); // chip masqué
    expect(container.read(catalogProvider).length, before); // produits conservés
    expect(tester.takeException(), isNull);
  });

  for (final style in const ['grid', 'table']) {
    for (final w in const [430.0, 1200.0]) {
      testWidgets('« $style » ne déborde pas en ${w.toInt()}px', (tester) async {
        await _pump(tester, style: style, size: Size(w, 1000));
        expect(tester.takeException(), isNull);
      });
    }
  }
}
