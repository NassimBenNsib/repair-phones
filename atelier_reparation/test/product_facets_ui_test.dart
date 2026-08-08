// Facettes (F2) : badges sur le détail produit + édition d'une facette qui
// persiste dans `product.facets`.

import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/data/storage.dart';
import 'package:atelier_reparation/core/settings/settings_controller.dart';
import 'package:atelier_reparation/core/settings/settings_repository.dart';
import 'package:atelier_reparation/features/catalog/application/catalog_controller.dart';
import 'package:atelier_reparation/features/catalog/presentation/product_detail_screen.dart';
import 'package:atelier_reparation/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _pump(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({'settings.locale': 'fr'});
  final prefs = await SharedPreferences.getInstance();
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(600, 2200);
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
      home: ProductDetailScreen(productId: 'p1'),
    ),
  ));
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('détail : section Facettes affichée', (tester) async {
    await _pump(tester);
    // p1 = Écran iPhone, facettes {brand: Apple, quality: OEM}.
    expect(find.text('Facettes'), findsOneWidget); // en-tête de section
    expect(find.text('OEM'), findsWidgets); // valeur de facette présente
  });

  testWidgets('édition : changer la Marque persiste dans facets',
      (tester) async {
    final container = await _pump(tester);
    expect(container.read(catalogProvider).firstWhere((p) => p.id == 'p1')
        .facets['brand'], 'brand-apple');

    await tester.tap(find.byTooltip('Modifier'));
    await tester.pumpAndSettle();
    // La valeur « Samsung » de la dimension Marque apparaît dans le formulaire.
    await tester.ensureVisible(find.text('Samsung'));
    await tester.tap(find.text('Samsung'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Enregistrer'));
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    expect(
        container.read(catalogProvider).firstWhere((p) => p.id == 'p1')
            .facets['brand'],
        'brand-samsung');
  });
}
