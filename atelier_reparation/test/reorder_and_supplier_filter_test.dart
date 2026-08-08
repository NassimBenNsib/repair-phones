// S6 : réappro depuis stock bas → commande fournisseur pré-remplie ; et filtre
// des fournisseurs par catégorie fournie.

import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/data/storage.dart';
import 'package:atelier_reparation/core/settings/settings_controller.dart';
import 'package:atelier_reparation/core/settings/settings_repository.dart';
import 'package:atelier_reparation/features/inventory/presentation/inventory_screen.dart';
import 'package:atelier_reparation/features/orders/application/orders_controller.dart';
import 'package:atelier_reparation/features/suppliers/presentation/suppliers_screen.dart';
import 'package:atelier_reparation/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pump(WidgetTester tester, Widget home,
    {Size size = const Size(500, 1200)}) async {
  SharedPreferences.setMockInitialValues(
      {'settings.locale': 'fr', 'settings.clientsListStyle': 'list'});
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
    child: MaterialApp(
      locale: const Locale('fr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Material(child: home),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('réappro : « Commander » crée une commande pré-remplie',
      (tester) async {
    await _pump(tester, const InventoryScreen(), size: const Size(700, 1400));
    final container =
        ProviderScope.containerOf(tester.element(find.byType(InventoryScreen)));

    // La 1re ligne est la plus faible en stock (p2 variante à 0, fournie par
    // seed-ifixfr) → bouton « Commander » (icône) sans feuille de choix.
    await tester.tap(find.byIcon(Icons.add_shopping_cart).first);
    await tester.pumpAndSettle();

    final orders = container.read(ordersProvider);
    expect(orders, isNotEmpty);
    expect(orders.first.supplierId, 'seed-ifixfr');
    final line = orders.first.lines.firstWhere((l) => l.productId == 'p2');
    // Prix d'achat du fournisseur (90) repris sur la ligne, pas le prix de vente.
    expect(line.unitPrice, 90);
  });

  testWidgets('inventaire : lignes stock bas sans débordement en 380px',
      (tester) async {
    await _pump(tester, const InventoryScreen(), size: const Size(380, 1400));
    expect(tester.takeException(), isNull);
  });

  testWidgets('fournisseurs : filtre par catégorie fournie', (tester) async {
    await _pump(tester, const SuppliersScreen());
    // Avant filtre : les trois fournisseurs d'exemple sont visibles.
    expect(find.text('MobileParts Pro'), findsOneWidget);
    expect(find.text('Accessoires Express'), findsOneWidget);

    // Filtre « Pièce » : MobileParts (fournit un écran) reste ; Accessoires
    // Express (ne fournit qu'une coque) disparaît.
    await tester.tap(find.text('Pièce'));
    await tester.pumpAndSettle();
    expect(find.text('MobileParts Pro'), findsOneWidget);
    expect(find.text('Accessoires Express'), findsNothing);
  });
}
