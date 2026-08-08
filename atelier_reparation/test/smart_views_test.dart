// Sélections intelligentes (G1) : évaluation des règles, (dé)sérialisation,
// et productsFor sur le catalogue d'exemple.

import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/data/storage.dart';
import 'package:atelier_reparation/features/catalog/application/catalog_controller.dart';
import 'package:atelier_reparation/features/catalog/application/smart_views_controller.dart';
import 'package:atelier_reparation/features/catalog/data/smart_view_mapper.dart';
import 'package:atelier_reparation/features/catalog/domain/product.dart';
import 'package:atelier_reparation/features/catalog/domain/smart_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Product _p({
  double price = 50,
  int stock = 5,
  String brand = 'Apple',
  Map<String, String> facets = const {},
}) =>
    Product(
      id: 'x',
      name: 'Pièce',
      brand: brand,
      categoryId: 'part',
      options: const [],
      variants: [
        ProductVariant(
            id: 'v', sku: 'S', attributes: const {}, price: price, stock: stock),
      ],
      facets: facets,
    );

void main() {
  test('smartMatches : stock, prix, marque, facette', () {
    expect(smartMatches(_p(stock: 0), const SmartRule(stock: 'out')), isTrue);
    expect(smartMatches(_p(stock: 2), const SmartRule(stock: 'out')), isFalse);
    expect(smartMatches(_p(stock: 2), const SmartRule(stock: 'low')), isTrue);
    expect(smartMatches(_p(stock: 9), const SmartRule(stock: 'low')), isFalse);

    expect(smartMatches(_p(price: 15), const SmartRule(priceMax: 20)), isTrue);
    expect(smartMatches(_p(price: 30), const SmartRule(priceMax: 20)), isFalse);

    expect(smartMatches(_p(brand: 'Apple'), const SmartRule(brand: 'app')), isTrue);
    expect(smartMatches(_p(brand: 'Spigen'), const SmartRule(brand: 'app')), isFalse);

    expect(
        smartMatches(_p(facets: {'brand': 'brand-apple'}),
            const SmartRule(facetValueId: 'brand-apple')),
        isTrue);
    // Combinaison ET : marque OK mais prix trop haut → refusé.
    expect(
        smartMatches(_p(brand: 'Apple', price: 99),
            const SmartRule(brand: 'app', priceMax: 20)),
        isFalse);
  });

  test('SmartViewMapper : aller-retour (règle imbriquée)', () {
    final m = SmartViewMapper();
    const v = SmartView(
        id: 'v1',
        name: 'Test',
        colorHex: 0xFF34C759,
        rule: SmartRule(stock: 'low', priceMax: 30, facetValueId: 'brand-apple'));
    final back = m.fromJson(m.toJson(v));
    expect(back.name, 'Test');
    expect(back.rule.stock, 'low');
    expect(back.rule.priceMax, 30);
    expect(back.rule.facetValueId, 'brand-apple');
  });

  test('productsFor : « Petit prix » (≤ 20 €) = la coque à 19 €', () {
    final c = ProviderContainer(
        overrides: [localStoreProvider.overrideWithValue(InMemoryStore())]);
    addTearDown(c.dispose);
    final smart = c.read(smartViewsProvider.notifier);
    final products = c.read(catalogProvider);

    // sv-cheap → priceMax 20 : seule la coque (p3, 19 €).
    final ids = smart.productsFor('sv-cheap', products).map((p) => p.id).toSet();
    expect(ids, contains('p3'));
    expect(ids.contains('p1'), isFalse);
  });
}
