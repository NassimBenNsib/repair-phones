// Moteur de taxonomie générique (via le contrôleur concret du catalogue) :
// profondeur illimitée, déplacement anti-cycle, fusion, code unique, chemin.

import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/data/storage.dart';
import 'package:atelier_reparation/core/taxonomy/taxonomy_node.dart';
import 'package:atelier_reparation/features/catalog/application/catalog_controller.dart';
import 'package:atelier_reparation/features/catalog/application/product_categories_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ProviderContainer _c() {
  final c = ProviderContainer(
      overrides: [localStoreProvider.overrideWithValue(InMemoryStore())]);
  addTearDown(c.dispose);
  return c;
}

void main() {
  test('descendantIds : profondeur illimitée (3 niveaux)', () {
    final c = _c();
    final cats = c.read(productCategoriesProvider.notifier);
    // part › part-screen › (nouveau) OLED
    cats.add(const TaxonomyNode(
        id: 'oled', name: 'OLED', parentId: 'part-screen'));

    final d = cats.descendantIds('part');
    expect(d, containsAll(['part-screen', 'part-battery', 'oled']));
    expect(cats.path('oled'), 'Pièce › Écrans › OLED');
  });

  test('move : reparent OK, cycle refusé', () {
    final c = _c();
    final cats = c.read(productCategoriesProvider.notifier);

    // Promotion d'une sous-catégorie en racine.
    expect(cats.move('part-battery', null), isTrue);
    expect(cats.byId('part-battery')!.parentId, isNull);

    // Cycle : déplacer 'part' sous son descendant 'part-screen' → refusé.
    expect(cats.move('part', 'part-screen'), isFalse);
    // Soi-même comme parent → refusé.
    expect(cats.move('part', 'part'), isFalse);
  });

  test('merge : réassigne les produits, reparente les enfants, supprime', () {
    final c = _c();
    final cats = c.read(productCategoriesProvider.notifier);
    final catalog = c.read(catalogProvider.notifier);

    // Enfant sous part-battery pour vérifier le reparentage.
    cats.add(const TaxonomyNode(
        id: 'batt-oem', name: 'OEM', parentId: 'part-battery'));

    // p2 est en 'part-battery' (données d'exemple).
    final done = cats.merge('part-battery', 'part-screen');
    expect(done, 1);
    expect(cats.byId('part-battery'), isNull); // supprimée
    expect(catalog.byId('p2')!.categoryId, 'part-screen'); // produit réassigné
    expect(cats.byId('batt-oem')!.parentId, 'part-screen'); // enfant reparenté
  });

  test('isCodeUnique', () {
    final c = _c();
    final cats = c.read(productCategoriesProvider.notifier);
    cats.add(const TaxonomyNode(
        id: 'x', name: 'X', parentId: 'part', code: 'C-01'));

    expect(cats.isCodeUnique('C-01'), isFalse);
    expect(cats.isCodeUnique('c-01'), isFalse); // insensible à la casse
    expect(cats.isCodeUnique('C-02'), isTrue);
    expect(cats.isCodeUnique('C-01', exceptId: 'x'), isTrue);
    expect(cats.isCodeUnique(''), isTrue); // vide = pas de contrainte
  });
}
