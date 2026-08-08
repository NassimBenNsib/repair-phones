import 'dart:convert';

import '../data/local_store.dart';

/// Sauvegarde / restauration de toutes les données locales sous forme d'un
/// document JSON unique, indépendamment des mappers typés (opère directement
/// sur les documents bruts du [LocalStore]).
class BackupService {
  BackupService(this._store);

  final LocalStore _store;

  /// Toutes les collections persistées (source unique de vérité pour la
  /// sauvegarde). Garder synchronisé avec les `EntityMapper.collection`.
  static const List<String> collections = [
    'clients',
    'repairs',
    'products',
    'services',
    'suppliers',
    'employees',
    'users',
    'purchase_orders',
    'quotes',
    'invoices',
    'company',
    'client_payments',
    'cheques',
    'sequences',
  ];

  /// Clé primaire d'un document selon sa collection (les réparations sont
  /// identifiées par leur `reference`, tout le reste par `id`).
  static String idField(String collection) =>
      collection == 'repairs' ? 'reference' : 'id';

  /// Sérialise toutes les collections en JSON indenté.
  String exportJson() {
    final data = <String, Object?>{
      'version': 1,
      'collections': {
        for (final c in collections) c: _store.all(c),
      },
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Restaure les données depuis un JSON produit par [exportJson].
  /// Écrase les documents de même id ; renvoie le nombre de documents importés.
  int importJson(String json) {
    final root = jsonDecode(json) as Map<String, Object?>;
    final cols = (root['collections'] as Map?) ?? const {};
    var imported = 0;
    for (final entry in cols.entries) {
      final collection = entry.key.toString();
      final idf = idField(collection);
      for (final raw in (entry.value as List? ?? const [])) {
        final doc = Map<String, Object?>.from(raw as Map);
        final id = doc[idf]?.toString();
        if (id != null && id.isNotEmpty) {
          _store.put(collection, id, doc);
          imported++;
        }
      }
    }
    return imported;
  }
}
