// Écran Prestations : rendu, recherche, filtre par catégorie, et modes
// grille/tableau sans débordement.

import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/data/storage.dart';
import 'package:atelier_reparation/core/settings/settings_controller.dart';
import 'package:atelier_reparation/core/settings/settings_repository.dart';
import 'package:atelier_reparation/features/prestations/application/categories_controller.dart';
import 'package:atelier_reparation/features/prestations/application/service_catalog_controller.dart';
import 'package:atelier_reparation/features/prestations/domain/service_category_node.dart';
import 'package:atelier_reparation/features/prestations/presentation/services_screen.dart';
import 'package:atelier_reparation/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pump(WidgetTester tester,
    {String style = 'list', Size size = const Size(420, 900)}) async {
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
      home: Material(child: ServicesScreen()),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('rendu + recherche + filtre catégorie', (tester) async {
    await _pump(tester);
    expect(find.text('Diagnostic'), findsWidgets);
    expect(find.text('Remplacement écran'), findsOneWidget);

    // Recherche.
    await tester.enterText(find.byType(TextField).first, 'écran');
    await tester.pumpAndSettle();
    expect(find.text('Remplacement écran'), findsOneWidget);
    expect(find.text('Remplacement batterie'), findsNothing);

    // Réinitialise puis filtre par catégorie « Batterie ».
    await tester.enterText(find.byType(TextField).first, '');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Batterie').first);
    await tester.pumpAndSettle();
    expect(find.text('Remplacement batterie'), findsOneWidget);
    expect(find.text('Remplacement écran'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('créer une prestation via le formulaire', (tester) async {
    await _pump(tester);
    final container =
        ProviderScope.containerOf(tester.element(find.byType(ServicesScreen)));
    final before = container.read(serviceCatalogProvider).length;

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(1), 'Nettoyage haut-parleur'); // nom
    await tester.enterText(fields.at(3), '18'); // prix
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    final services = container.read(serviceCatalogProvider);
    expect(services.length, before + 1);
    expect(services.any((s) => s.name == 'Nettoyage haut-parleur'), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dupliquer une prestation', (tester) async {
    await _pump(tester);
    final container =
        ProviderScope.containerOf(tester.element(find.byType(ServicesScreen)));
    final before = container.read(serviceCatalogProvider).length;

    await tester.tap(find.text('Remplacement écran'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dupliquer'));
    await tester.pumpAndSettle();

    final svc = container.read(serviceCatalogProvider);
    expect(svc.length, before + 1);
    expect(svc.any((s) => s.name == 'Remplacement écran (copie)'), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('drill-down catégorie → sous-catégorie (rollup)', (tester) async {
    await _pump(tester);
    final container =
        ProviderScope.containerOf(tester.element(find.byType(ServicesScreen)));
    // Sous-catégorie sous « screen » + une prestation dedans.
    container.read(categoriesProvider.notifier).add(const ServiceCategoryNode(
        id: 'sb', name: 'Vitre AR', parentId: 'screen'));
    container
        .read(serviceCatalogProvider.notifier)
        .add(name: 'Vitre TEST', price: 30, categoryId: 'sb');
    await tester.pumpAndSettle();

    // « Écran » : rollup → inclut la sous-catégorie.
    await tester.tap(find.text('Écran').first);
    await tester.pumpAndSettle();
    expect(find.text('Remplacement écran'), findsOneWidget);
    expect(find.text('Vitre TEST'), findsOneWidget);

    // Sous-catégorie « Vitre AR » → seulement sa prestation.
    await tester.tap(find.text('Vitre AR').first);
    await tester.pumpAndSettle();
    expect(find.text('Vitre TEST'), findsOneWidget);
    expect(find.text('Remplacement écran'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final style in const ['grid', 'table']) {
    for (final w in const [420.0, 1200.0]) {
      testWidgets('« $style » ne déborde pas en ${w.toInt()}px', (tester) async {
        await _pump(tester, style: style, size: Size(w, 900));
        expect(tester.takeException(), isNull);
      });
    }
  }
}
