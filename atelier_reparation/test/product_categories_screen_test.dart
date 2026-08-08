// Écran de gestion des catégories du catalogue : rendu de l'arbre + création
// d'une catégorie racine.

import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/data/storage.dart';
import 'package:atelier_reparation/core/settings/settings_controller.dart';
import 'package:atelier_reparation/core/settings/settings_repository.dart';
import 'package:atelier_reparation/core/taxonomy/taxonomy_node.dart';
import 'package:atelier_reparation/features/catalog/application/product_categories_controller.dart';
import 'package:atelier_reparation/features/catalog/presentation/product_categories_screen.dart';
import 'package:atelier_reparation/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _pump(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(420, 1000);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues({'settings.locale': 'fr'});
  final prefs = await SharedPreferences.getInstance();
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
      home: Material(child: ProductCategoriesScreen()),
    ),
  ));
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('rend l\'arbre des catégories (racines seedées)', (tester) async {
    await _pump(tester);
    expect(find.text('Pièce'), findsWidgets);
    expect(find.text('Accessoire'), findsWidgets);
    expect(find.text('Écrans'), findsOneWidget); // sous-catégorie
  });

  testWidgets('crée une catégorie racine via « + »', (tester) async {
    final container = await _pump(tester);
    final before = container
        .read(productCategoriesProvider)
        .where((n) => n.parentId == null)
        .length;

    await tester.tap(find.byTooltip('Nouvelle catégorie'));
    await tester.pumpAndSettle();
    // .at(1) : .first = champ recherche de l'écran ; le nom du formulaire suit.
    await tester.enterText(find.byType(TextField).at(1), 'Outils');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    final roots = container
        .read(productCategoriesProvider)
        .where((n) => n.parentId == null)
        .toList();
    expect(roots.length, before + 1);
    expect(roots.any((n) => n.name == 'Outils'), isTrue);
  });

  testWidgets('arbre récursif : affiche un 3e niveau', (tester) async {
    final container = await _pump(tester);
    container.read(productCategoriesProvider.notifier).add(
        const TaxonomyNode(id: 'oled', name: 'OLED', parentId: 'part-screen'));
    await tester.pumpAndSettle();
    // part › Écrans › OLED — les trois niveaux sont rendus (dépli par défaut).
    expect(find.text('Pièce'), findsOneWidget);
    expect(find.text('Écrans'), findsOneWidget);
    expect(find.text('OLED'), findsOneWidget);
  });

  testWidgets('recherche : filtre l\'arbre (liste plate)', (tester) async {
    await _pump(tester);
    // Recherche « batter » → « Batteries », pas « Écrans ».
    await tester.enterText(find.byType(TextField).first, 'batter');
    await tester.pumpAndSettle();
    expect(find.text('Batteries'), findsOneWidget);
    expect(find.text('Écrans'), findsNothing);
  });

  testWidgets('bouton « + » d\'une ligne crée une sous-catégorie',
      (tester) async {
    final container = await _pump(tester);
    // Premier bouton d'ajout-enfant = ligne « Pièce » (racine, order 0).
    await tester.tap(find.byTooltip('Ajouter une sous-catégorie').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(1), 'Nappes');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    final nappes = container
        .read(productCategoriesProvider)
        .where((n) => n.name == 'Nappes');
    expect(nappes.length, 1);
    expect(nappes.first.parentId, 'part');
  });
}
