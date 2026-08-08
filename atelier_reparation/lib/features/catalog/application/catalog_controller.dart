import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/local_store.dart';
import '../../../core/data/storage.dart';
import '../data/product_mapper.dart';
import '../domain/product.dart';

final productStoreProvider = Provider<CollectionStore<Product>>(
  (ref) => CollectionStore<Product>(ref.watch(localStoreProvider), ProductMapper()),
);

/// Catalogue produits, adossé au stockage local.
class CatalogController extends Notifier<List<Product>> {
  int _seq = 0;
  CollectionStore<Product> get _store => ref.read(productStoreProvider);

  @override
  List<Product> build() {
    _store.seedIfEmpty(sampleProducts);
    return _store.loadAll();
  }

  String _id(String prefix) => '$prefix${DateTime.now().microsecondsSinceEpoch}_${_seq++}';

  void addProduct({
    required String name,
    required String brand,
    required String categoryId,
    required double price,
    int stock = 0,
  }) {
    final id = _id('p');
    final product = Product(
      id: id,
      name: name,
      brand: brand,
      categoryId: categoryId,
      options: const [],
      variants: [
        ProductVariant(
          id: _id('v'),
          sku: 'SKU-${id.substring(id.length - 4)}',
          attributes: const {},
          price: price,
          stock: stock,
        ),
      ],
    );
    _store.upsert(product);
    state = [product, ...state];
  }

  /// Édite les champs de base d'un produit (nom / marque / catégorie /
  /// fournisseurs).
  void updateProduct(
    String id, {
    String? name,
    String? brand,
    String? categoryId,
    List<ProductSourcing>? sourcing,
    Map<String, String>? facets,
  }) {
    final p = byId(id);
    if (p == null) return;
    final updated = p.copyWith(
        name: name,
        brand: brand,
        categoryId: categoryId,
        sourcing: sourcing,
        facets: facets);
    _store.upsert(updated);
    state = [for (final x in state) if (x.id == id) updated else x];
  }

  /// Produits fournis par un fournisseur donné.
  List<Product> productsForSupplier(String supplierId) =>
      state.where((p) => p.supplierIds.contains(supplierId)).toList();

  /// Produits portant une valeur de facette donnée.
  List<Product> productsWithFacet(String valueId) =>
      state.where((p) => p.facets.values.contains(valueId)).toList();

  /// Remplace partout une valeur de facette par une autre (fusion/suppression
  /// d'un nœud de facette). Renvoie le nombre de produits modifiés.
  int reassignFacetValue(String fromId, String toId) {
    if (fromId == toId) return 0;
    var moved = 0;
    final next = [
      for (final p in state)
        if (p.facets.values.contains(fromId))
          () {
            moved++;
            final f = {
              for (final e in p.facets.entries)
                e.key: e.value == fromId ? toId : e.value
            };
            final u = p.copyWith(facets: f);
            _store.upsert(u);
            return u;
          }()
        else
          p,
    ];
    if (moved > 0) state = next;
    return moved;
  }

  /// Déplace tous les produits d'une catégorie vers une autre (ex. suppression
  /// de catégorie). Renvoie le nombre de produits déplacés.
  int reassignCategory(String fromId, String toId) {
    if (fromId == toId) return 0;
    var moved = 0;
    final next = [
      for (final p in state)
        if (p.categoryId == fromId)
          () {
            moved++;
            final u = p.copyWith(categoryId: toId);
            _store.upsert(u);
            return u;
          }()
        else
          p,
    ];
    if (moved > 0) state = next;
    return moved;
  }

  void addVariant(
    String productId, {
    required String label,
    required double price,
    required int stock,
  }) {
    final product = byId(productId);
    if (product == null) return;
    final updated = product.copyWith(variants: [
      ...product.variants,
      ProductVariant(
        id: _id('v'),
        sku: 'SKU-${label.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '').padRight(3, 'X').substring(0, 3)}',
        attributes: {'Variante': label},
        price: price,
        stock: stock,
      ),
    ]);
    _store.upsert(updated);
    state = [
      for (final p in state) if (p.id == productId) updated else p,
    ];
  }

  Product? byId(String id) {
    for (final p in state) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Ajuste le stock d'une variante (ex. réception d'une commande).
  void adjustVariantStock(String variantId, int delta) {
    for (final p in state) {
      final idx = p.variants.indexWhere((v) => v.id == variantId);
      if (idx < 0) continue;
      final v = p.variants[idx];
      final newStock = (v.stock + delta) < 0 ? 0 : v.stock + delta;
      final variants = [...p.variants]..[idx] = v.copyWith(stock: newStock);
      final updated = p.copyWith(variants: variants);
      _store.upsert(updated);
      state = [for (final x in state) if (x.id == p.id) updated else x];
      return;
    }
  }
}

final catalogProvider =
    NotifierProvider<CatalogController, List<Product>>(CatalogController.new);
