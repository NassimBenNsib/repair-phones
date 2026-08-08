// Facettes catalogue (F1) : taxonomie multi-axes, carte `facets` produit
// (aller-retour + migration), requêtes et fusion réaffectant les valeurs.

import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/data/storage.dart';
import 'package:atelier_reparation/features/catalog/application/catalog_controller.dart';
import 'package:atelier_reparation/features/catalog/application/product_facets_controller.dart';
import 'package:atelier_reparation/features/catalog/data/product_mapper.dart';
import 'package:atelier_reparation/features/catalog/domain/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ProviderContainer _c() {
  final c = ProviderContainer(
      overrides: [localStoreProvider.overrideWithValue(InMemoryStore())]);
  addTearDown(c.dispose);
  return c;
}

void main() {
  test('Taxonomie facettes : dimensions (racines) + valeurs (enfants)', () {
    final facets = _c().read(productFacetsProvider.notifier);
    final dims = facets.topLevel().map((n) => n.id).toSet();
    expect(dims, containsAll(['brand', 'quality']));
    expect(facets.childrenOf('brand').map((n) => n.id),
        containsAll(['brand-apple', 'brand-samsung']));
    expect(facets.path('brand-apple'), 'Marque › Apple');
  });

  test('ProductMapper : facets aller-retour + défaut vide', () {
    final m = ProductMapper();
    const p = Product(
      id: 'p9',
      name: 'Écran',
      brand: 'Apple',
      categoryId: 'part-screen',
      options: [],
      variants: [],
      facets: {'brand': 'brand-apple', 'quality': 'quality-oem'},
    );
    expect(m.fromJson(m.toJson(p)).facets,
        {'brand': 'brand-apple', 'quality': 'quality-oem'});

    // Ancien produit sans facets → carte vide.
    final legacy = m.fromJson({
      'id': 'old',
      'name': 'X',
      'brand': '—',
      'categoryId': 'part',
      'options': const [],
      'variants': const [],
    });
    expect(legacy.facets, isEmpty);
  });

  test('productsWithFacet + fusion réaffecte la valeur', () {
    final c = _c();
    final catalog = c.read(catalogProvider.notifier);
    final facets = c.read(productFacetsProvider.notifier);

    // Données d'exemple : p1 & p2 en 'brand-apple'.
    expect(catalog.productsWithFacet('brand-apple').map((p) => p.id).toSet(),
        containsAll(['p1', 'p2']));

    // Fusion 'brand-apple' → 'brand-samsung' : les produits suivent, le nœud
    // disparaît.
    expect(facets.merge('brand-apple', 'brand-samsung'), 1);
    expect(facets.byId('brand-apple'), isNull);
    expect(catalog.byId('p1')!.facets['brand'], 'brand-samsung');
    expect(catalog.productsWithFacet('brand-apple'), isEmpty);
  });
}
