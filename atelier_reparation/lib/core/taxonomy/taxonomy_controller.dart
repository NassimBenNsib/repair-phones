import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_store.dart';
import '../data/storage.dart';
import 'taxonomy_mapper.dart';
import 'taxonomy_node.dart';

/// Contrôleur générique d'une taxonomie (profondeur illimitée) adossé au
/// stockage local. Un domaine le sous-classe en fournissant [collection],
/// [seed] et, pour la fusion, [reassignEntities].
abstract class TaxonomyController extends Notifier<List<TaxonomyNode>> {
  /// Collection de stockage (ex. `product_categories`).
  String get collection;

  /// Données initiales (semées si la collection est vide).
  List<TaxonomyNode> get seed;

  /// Réassigne les entités (produits/prestations) d'une catégorie à une autre.
  /// Surchargé par le domaine ; no-op par défaut.
  void reassignEntities(String fromId, String toId) {}

  CollectionStore<TaxonomyNode> get _store => CollectionStore<TaxonomyNode>(
      ref.read(localStoreProvider), TaxonomyMapper(collection));

  @override
  List<TaxonomyNode> build() {
    _store.seedIfEmpty(seed);
    return _store.loadAll()..sort((a, b) => a.order.compareTo(b.order));
  }

  // --- Lecture -------------------------------------------------------------

  TaxonomyNode? byId(String? id) {
    if (id == null) return null;
    for (final n in state) {
      if (n.id == id) return n;
    }
    return null;
  }

  String nameOf(String? id) => byId(id)?.name ?? '';

  /// Chaîne du nœud jusqu'à la racine (protégée contre les cycles).
  List<TaxonomyNode> pathNodes(String? id) {
    final out = <TaxonomyNode>[];
    final seen = <String>{};
    var cur = byId(id);
    while (cur != null && seen.add(cur.id)) {
      out.insert(0, cur);
      cur = byId(cur.parentId);
    }
    return out;
  }

  /// Chemin lisible « Racine › … › Feuille ».
  String path(String? id) => pathNodes(id).map((n) => n.name).join(' › ');

  List<TaxonomyNode> topLevel() =>
      state.where((n) => n.parentId == null).toList();

  List<TaxonomyNode> childrenOf(String parentId) =>
      state.where((n) => n.parentId == parentId).toList();

  /// Tous les descendants (enfants, petits-enfants, … à toute profondeur).
  /// N'inclut PAS le nœud lui-même.
  Set<String> descendantIds(String id) {
    final out = <String>{};
    final stack = <String>[id];
    while (stack.isNotEmpty) {
      final cur = stack.removeLast();
      for (final n in state) {
        if (n.parentId == cur && out.add(n.id)) stack.add(n.id);
      }
    }
    return out;
  }

  /// Vrai si [code] n'est pas déjà pris par un autre nœud.
  bool isCodeUnique(String code, {String? exceptId}) {
    final c = code.trim().toLowerCase();
    if (c.isEmpty) return true;
    return !state.any(
        (n) => n.id != exceptId && (n.code ?? '').trim().toLowerCase() == c);
  }

  // --- Écriture ------------------------------------------------------------

  void add(TaxonomyNode node) {
    _store.upsert(node);
    state = [...state, node]..sort((a, b) => a.order.compareTo(b.order));
  }

  void update(TaxonomyNode node) {
    _store.upsert(node);
    state = [
      for (final n in state)
        if (n.id == node.id) node else n
    ]..sort((a, b) => a.order.compareTo(b.order));
  }

  void remove(String id) {
    _store.remove(id);
    state = [for (final n in state) if (n.id != id) n];
  }

  /// Déplacerait [id] sous l'un de ses propres descendants (cycle) ?
  bool _wouldCycle(String id, String? newParentId) {
    if (newParentId == null) return false;
    if (newParentId == id) return true;
    return descendantIds(id).contains(newParentId);
  }

  /// Reparente un nœud (`newParentId == null` = promotion en racine). Renvoie
  /// `false` si le déplacement créerait un cycle.
  bool move(String id, String? newParentId) {
    final n = byId(id);
    if (n == null || _wouldCycle(id, newParentId)) return false;
    update(n.copyWith(parentId: newParentId, clearParent: newParentId == null));
    return true;
  }

  /// Fusionne [fromId] dans [intoId] : réassigne ses entités, reparente ses
  /// enfants sous [intoId], puis supprime [fromId]. Renvoie 1 si effectuée.
  int merge(String fromId, String intoId) {
    if (fromId == intoId || byId(fromId) == null || byId(intoId) == null) {
      return 0;
    }
    reassignEntities(fromId, intoId);
    for (final child in childrenOf(fromId)) {
      update(child.copyWith(parentId: intoId));
    }
    remove(fromId);
    return 1;
  }
}
