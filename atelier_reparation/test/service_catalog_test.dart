// Catalogue de prestations : (dé)sérialisation complète + CRUD du contrôleur.

import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/data/storage.dart';
import 'package:atelier_reparation/core/taxonomy/taxonomy_node.dart';
import 'package:atelier_reparation/features/prestations/application/categories_controller.dart';
import 'package:atelier_reparation/features/prestations/application/service_catalog_controller.dart';
import 'package:atelier_reparation/features/prestations/data/service_mapper.dart';
import 'package:atelier_reparation/features/prestations/domain/service_category_node.dart';
import 'package:atelier_reparation/features/prestations/domain/service_template.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Prestations : moteur générique — 3 niveaux + fusion (reassign wiring)',
      () {
    final container = ProviderContainer(
        overrides: [localStoreProvider.overrideWithValue(InMemoryStore())]);
    addTearDown(container.dispose);
    final cats = container.read(categoriesProvider.notifier);
    final catalog = container.read(serviceCatalogProvider.notifier);

    // 3 niveaux : screen › Vitre AR › OLED.
    cats.add(const TaxonomyNode(id: 'sb', name: 'Vitre AR', parentId: 'screen'));
    cats.add(const TaxonomyNode(id: 'oled', name: 'OLED', parentId: 'sb'));
    expect(cats.descendantIds('screen'), containsAll(['sb', 'oled']));
    expect(cats.path('oled'), 'Écran › Vitre AR › OLED');

    // Une prestation en 'sb', puis fusion 'sb' → 'screen' réassigne la prestation.
    catalog.add(name: 'Vitre', price: 30, categoryId: 'sb');
    expect(cats.merge('sb', 'screen'), 1);
    expect(cats.byId('sb'), isNull);
    expect(cats.byId('oled')!.parentId, 'screen'); // enfant reparenté
    expect(
        container
            .read(serviceCatalogProvider)
            .where((s) => s.categoryId == 'sb')
            .isEmpty,
        isTrue); // prestation réassignée
  });

  test('ServiceMapper : aller-retour complet', () {
    const s = ServiceTemplate(
      id: 'x',
      name: 'Écran',
      description: 'desc',
      price: 49.5,
      categoryId: 'screen',
      durationMinutes: 45,
      vatRate: 0.2,
      cost: 20,
      active: false,
    );
    final m = ServiceMapper();
    final back = m.fromJson(m.toJson(s));
    expect(back.name, 'Écran');
    expect(back.price, 49.5);
    expect(back.categoryId, 'screen');
    expect(back.durationMinutes, 45);
    expect(back.vatRate, 0.2);
    expect(back.cost, 20);
    expect(back.active, isFalse);
    expect(back.margin, 29.5);
  });

  test('CRUD du contrôleur', () {
    final container = ProviderContainer(overrides: [
      localStoreProvider.overrideWithValue(InMemoryStore()),
    ]);
    addTearDown(container.dispose);
    final ctrl = container.read(serviceCatalogProvider.notifier);

    final seeded = container.read(serviceCatalogProvider).length;
    expect(seeded, sampleServiceTemplates.length);

    // add
    final created =
        ctrl.add(name: 'Test', price: 30, categoryId: 'battery');
    expect(container.read(serviceCatalogProvider).length, seeded + 1);
    expect(created.active, isTrue);

    // update
    ctrl.update(created.copyWith(price: 35));
    expect(
        container
            .read(serviceCatalogProvider)
            .firstWhere((s) => s.id == created.id)
            .price,
        35);

    // toggleActive
    ctrl.toggleActive(created.id);
    expect(
        container
            .read(serviceCatalogProvider)
            .firstWhere((s) => s.id == created.id)
            .active,
        isFalse);

    // remove
    ctrl.remove(created.id);
    expect(container.read(serviceCatalogProvider).length, seeded);
  });

  test('migration : ancien champ « category » → categoryId', () {
    final s = ServiceMapper().fromJson({
      'id': 'a',
      'name': 'n',
      'description': '',
      'price': 10.0,
      'category': 'battery', // ancien format
    });
    expect(s.categoryId, 'battery');
  });

  test('taxonomie : catégories semées + sous-catégorie + chemin', () {
    final container = ProviderContainer(overrides: [
      localStoreProvider.overrideWithValue(InMemoryStore()),
    ]);
    addTearDown(container.dispose);
    final cats = container.read(categoriesProvider.notifier);

    expect(container.read(categoriesProvider).length,
        seedServiceCategories.length);
    expect(cats.byId('screen')?.name, 'Écran');

    cats.add(const ServiceCategoryNode(
        id: 'screen-back', name: 'Vitre arrière', parentId: 'screen'));
    expect(cats.childrenOf('screen').length, 1);
    expect(cats.path('screen-back'), 'Écran › Vitre arrière');

    // Réaffectation des prestations d'une catégorie vers une autre.
    final svc = container.read(serviceCatalogProvider.notifier);
    final moved = container
        .read(serviceCatalogProvider)
        .where((s) => s.categoryId == 'battery')
        .length;
    svc.reassignCategory('battery', 'other');
    expect(
        container.read(serviceCatalogProvider).any((s) => s.categoryId == 'battery'),
        isFalse);
    expect(moved, greaterThan(0));
  });
}
