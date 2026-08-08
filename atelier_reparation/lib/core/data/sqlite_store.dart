import 'dart:convert';

import 'package:sqlite3/sqlite3.dart';

import 'local_store.dart';

/// [LocalStore] adossé à SQLite (paquet `sqlite3`).
///
/// Un seul schéma générique : table `documents(collection, id, json, updatedAt,
/// deletedAt)`. Suppression logique (tombstone) via `deletedAt`.
class SqliteStore implements LocalStore {
  SqliteStore(this._db);

  final Database _db;

  void init() {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS documents (
        collection TEXT NOT NULL,
        id         TEXT NOT NULL,
        json       TEXT NOT NULL,
        updatedAt  TEXT NOT NULL,
        deletedAt  TEXT,
        PRIMARY KEY (collection, id)
      );
    ''');
  }

  @override
  List<Map<String, Object?>> all(String collection) {
    final rows = _db.select(
      'SELECT json FROM documents WHERE collection = ? AND deletedAt IS NULL',
      [collection],
    );
    return [
      for (final row in rows)
        jsonDecode(row['json'] as String) as Map<String, Object?>,
    ];
  }

  @override
  void put(String collection, String id, Map<String, Object?> json) {
    _db.execute(
      'INSERT OR REPLACE INTO documents (collection, id, json, updatedAt, deletedAt) '
      'VALUES (?, ?, ?, ?, NULL)',
      [collection, id, jsonEncode(json), DateTime.now().toIso8601String()],
    );
  }

  @override
  void delete(String collection, String id) {
    _db.execute(
      'UPDATE documents SET deletedAt = ? WHERE collection = ? AND id = ?',
      [DateTime.now().toIso8601String(), collection, id],
    );
  }

  @override
  List<SyncDoc> changesSince(String collection, DateTime? since) {
    final rows = since == null
        ? _db.select(
            'SELECT id, json, updatedAt, deletedAt FROM documents '
            'WHERE collection = ?',
            [collection],
          )
        : _db.select(
            'SELECT id, json, updatedAt, deletedAt FROM documents '
            'WHERE collection = ? AND updatedAt > ?',
            [collection, since.toIso8601String()],
          );
    return [
      for (final row in rows)
        SyncDoc(
          row['id'] as String,
          jsonDecode(row['json'] as String) as Map<String, Object?>,
          DateTime.parse(row['updatedAt'] as String),
          row['deletedAt'] == null
              ? null
              : DateTime.parse(row['deletedAt'] as String),
        ),
    ];
  }

  @override
  void applyRemote(String collection, SyncDoc doc) {
    _db.execute(
      'INSERT OR REPLACE INTO documents (collection, id, json, updatedAt, deletedAt) '
      'VALUES (?, ?, ?, ?, ?)',
      [
        collection,
        doc.id,
        jsonEncode(doc.json),
        doc.updatedAt.toIso8601String(),
        doc.deletedAt?.toIso8601String(),
      ],
    );
  }

  @override
  DateTime? updatedAtOf(String collection, String id) {
    final rows = _db.select(
      'SELECT updatedAt FROM documents WHERE collection = ? AND id = ?',
      [collection, id],
    );
    return rows.isEmpty ? null : DateTime.parse(rows.first['updatedAt'] as String);
  }
}
