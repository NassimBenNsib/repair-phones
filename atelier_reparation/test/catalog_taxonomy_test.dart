// Catalogue S1 : (dé)sérialisation avec categoryId, migration sûre depuis
// l'ancien enum `category`, et taxonomie (seed + hiérarchie + chemin).

import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/data/storage.dart';
import 'package:atelier_reparation/features/catalog/application/catalog_controller.dart';
import 'package:atelier_reparation/features/catalog/application/product_categories_controller.dart';
import 'package:atelier_reparation/features/catalog/data/product_mapper.dart';
import 'package:atelier_reparation/features/catalog/domain/product.dart';
import 'package:atelier_reparation/features/catalog/domain/product_category_node.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ProductMapper : aller-retour avec categoryId', () {
    const p = Product(
      id: 'p9',
      name: 'Écran iPhone 14',
      brand: 'Apple',
      categoryId: 'part-screen',
      options: [ProductOption(name: 'Qualité', values: ['OEM', 'Compatible'])],
      variants: [
        ProductVariant(
            id: 'v1',
            sku: 'SCR-14',
            attributes: {'Qualité': 'OEM'},
            price: 159,
            stock: 3),
      ],
    );
    final m = ProductMapper();
    final back = m.fromJson(m.toJson(p));
    expect(back.categoryId, 'part-screen');
    expect(back.name, 'Écran iPhone 14');
    expect(back.options.single.values, ['OEM', 'Compatible']);
    expect(back.variants.single.price, 159);
  });

  test('ProductMapper : migration depuis l\'ancien champ enum `category`', () {
    final m = ProductMapper();
    // Ancien format (avant taxonomie) : `category` = nom d'énumération.
    final legacy = m.fromJson({
      'id': 'old1',
      'name': 'Coque',
      'brand': 'Spigen',
      'category': 'accessory',
      'options': const [],
      'variants': const [],
    });
    expect(legacy.categoryId, 'accessory');

    // Aucune catégorie → défaut `part`.
    final none = m.fromJson({
      'id': 'old2',
      'name': 'Pièce inconnue',
      'brand': '—',
      'options': const [],
      'variants': const [],
    });
    expect(none.categoryId, 'part');
  });

  test('Taxonomie : seed, hiérarchie et chemin', () {
    final container = ProviderContainer(overrides: [
      localStoreProvider.overrideWithValue(InMemoryStore()),
    ]);
    addTearDown(container.dispose);
    final cats = container.read(productCategoriesProvider.notifier);

    // 3 racines (ex-énumération).
    final roots = cats.topLevel().map((n) => n.id).toSet();
    expect(roots, containsAll(['part', 'accessory', 'service']));

    // Sous-catégories de « Pièce ».
    final partChildren = cats.childrenOf('part').map((n) => n.id).toSet();
    expect(partChildren, containsAll(['part-screen', 'part-battery']));

    // Chemin lisible.
    expect(cats.path('part-screen'), 'Pièce › Écrans');
    expect(cats.path('part'), 'Pièce');
    expect(cats.nameOf('accessory'), 'Accessoire');
    expect(cats.byId('inexistant'), isNull);
  });

  test('Taxonomie : ajout d\'une sous-catégorie', () {
    final container = ProviderContainer(overrides: [
      localStoreProvider.overrideWithValue(InMemoryStore()),
    ]);
    addTearDown(container.dispose);
    final cats = container.read(productCategoriesProvider.notifier);

    cats.add(const ProductCategoryNode(
        id: 'part-camera', name: 'Caméras', parentId: 'part', iconKey: 'camera'));
    expect(cats.childrenOf('part').any((n) => n.id == 'part-camera'), isTrue);
    expect(cats.path('part-camera'), 'Pièce › Caméras');
  });

  test('CatalogController : édition produit (nom / marque / catégorie)', () {
    final container = ProviderContainer(overrides: [
      localStoreProvider.overrideWithValue(InMemoryStore()),
    ]);
    addTearDown(container.dispose);
    final ctrl = container.read(catalogProvider.notifier);

    ctrl.updateProduct('p1',
        name: 'Écran iPhone 13 Pro', categoryId: 'part-battery');
    final p1 = ctrl.byId('p1')!;
    expect(p1.name, 'Écran iPhone 13 Pro');
    expect(p1.categoryId, 'part-battery');
    expect(p1.variants, isNotEmpty); // variantes préservées
  });

  test('CatalogController : reassignCategory déplace les produits', () {
    final container = ProviderContainer(overrides: [
      localStoreProvider.overrideWithValue(InMemoryStore()),
    ]);
    addTearDown(container.dispose);
    final ctrl = container.read(catalogProvider.notifier);

    // p1 est en 'part-screen' dans les données d'exemple.
    final moved = ctrl.reassignCategory('part-screen', 'part');
    expect(moved, greaterThanOrEqualTo(1));
    expect(ctrl.byId('p1')!.categoryId, 'part');
    // Idempotent : plus rien à déplacer.
    expect(ctrl.reassignCategory('part-screen', 'part'), 0);
  });

  test('ProductMapper : sourcing aller-retour + migration supplierIds', () {
    final m = ProductMapper();
    const p = Product(
      id: 'p9',
      name: 'Écran',
      brand: 'Apple',
      categoryId: 'part-screen',
      options: [],
      variants: [],
      sourcing: [
        ProductSourcing(supplierId: 's1', purchasePrice: 60, preferred: true),
        ProductSourcing(supplierId: 's2'),
      ],
    );
    final back = m.fromJson(m.toJson(p));
    expect(back.supplierIds, ['s1', 's2']);
    expect(back.sourcing.first.purchasePrice, 60);
    expect(back.sourcing.first.preferred, isTrue);
    expect(back.preferredSourcing!.supplierId, 's1');

    // Migration : ancien `supplierIds` (liste d'ids) → sourcing sans prix.
    final legacy = m.fromJson({
      'id': 'old',
      'name': 'X',
      'brand': '—',
      'categoryId': 'part',
      'supplierIds': ['sA', 'sB'],
      'options': const [],
      'variants': const [],
    });
    expect(legacy.supplierIds, ['sA', 'sB']);
    expect(legacy.sourcing.first.purchasePrice, isNull);

    // Aucun fournisseur → vide.
    final none = m.fromJson({
      'id': 'n',
      'name': 'X',
      'brand': '—',
      'categoryId': 'part',
      'options': const [],
      'variants': const [],
    });
    expect(none.supplierIds, isEmpty);
  });

  test('CatalogController : productsForSupplier + édition des fournisseurs', () {
    final container = ProviderContainer(overrides: [
      localStoreProvider.overrideWithValue(InMemoryStore()),
    ]);
    addTearDown(container.dispose);
    final ctrl = container.read(catalogProvider.notifier);

    // Données d'exemple : p1 & p2 fournis par 'seed-ifixfr'.
    final ifix = ctrl.productsForSupplier('seed-ifixfr').map((p) => p.id).toSet();
    expect(ifix, containsAll(['p1', 'p2']));
    expect(ifix.contains('p3'), isFalse);

    // Édition des approvisionnements.
    ctrl.updateProduct('p4',
        sourcing: [const ProductSourcing(supplierId: 'seed-mobileparts')]);
    expect(ctrl.productsForSupplier('seed-mobileparts').any((p) => p.id == 'p4'),
        isTrue);
  });
}
