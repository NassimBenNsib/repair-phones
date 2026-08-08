// Fiche fournisseur (S5) : produits fournis + commandes + « lier » un produit
// commandé mais non encore rattaché.

import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/data/storage.dart';
import 'package:atelier_reparation/core/domain/line_item.dart';
import 'package:atelier_reparation/core/settings/settings_controller.dart';
import 'package:atelier_reparation/core/settings/settings_repository.dart';
import 'package:atelier_reparation/features/catalog/application/catalog_controller.dart';
import 'package:atelier_reparation/features/orders/application/orders_controller.dart';
import 'package:atelier_reparation/features/suppliers/application/suppliers_controller.dart';
import 'package:atelier_reparation/features/suppliers/presentation/supplier_detail.dart';
import 'package:atelier_reparation/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _pump(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({'settings.locale': 'fr'});
  final prefs = await SharedPreferences.getInstance();
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(500, 1400);
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
      home: Material(
          child: SupplierDetailView(supplierId: 'seed-mobileparts')),
    ),
  ));
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('produits fournis + commande listée', (tester) async {
    final container = await _pump(tester);
    // p1 (Écran iPhone 13) est fourni par seed-mobileparts (données d'exemple).
    expect(find.text('Écran iPhone 13'), findsOneWidget);
    expect(find.text('Produits fournis  ·  1'), findsOneWidget);

    // Une commande pour ce fournisseur apparaît dans la section.
    final po = container.read(ordersProvider.notifier).create('seed-mobileparts');
    await tester.pumpAndSettle();
    expect(find.text(po.number), findsOneWidget);
  });

  testWidgets('produit commandé non lié → « Lier » le rattache', (tester) async {
    final container = await _pump(tester);
    // Commande avec une ligne sur p4 (non lié à ce fournisseur).
    final po = container.read(ordersProvider.notifier).create('seed-mobileparts');
    container.read(ordersProvider.notifier).addLine(
        po.id, const LineItem(id: 'l1', label: 'Diag', productId: 'p4'));
    await tester.pumpAndSettle();

    expect(find.text('Déjà commandés (non liés)'), findsOneWidget);
    expect(find.text('Diagnostic complet'), findsOneWidget);

    await tester.tap(find.text('Lier'));
    await tester.pumpAndSettle();

    final p4 = container.read(catalogProvider).firstWhere((p) => p.id == 'p4');
    expect(p4.supplierIds.contains('seed-mobileparts'), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('suppression bloquée si référencé (garde-fou)', (tester) async {
    final container = await _pump(tester); // seed-mobileparts fournit p1
    await tester.tap(find.byTooltip('Supprimer'));
    await tester.pumpAndSettle();
    expect(find.textContaining('référencé'), findsOneWidget); // avertissement
    // Le fournisseur est conservé.
    expect(
        container.read(suppliersProvider).any((s) => s.id == 'seed-mobileparts'),
        isTrue);
  });
}
