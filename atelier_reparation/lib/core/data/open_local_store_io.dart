import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import 'local_store.dart';
import 'sqlite_store.dart';

/// Natif → base SQLite dans le dossier de support de l'application.
Future<LocalStore> openLocalStore() async {
  final dir = await getApplicationSupportDirectory();
  final path = '${dir.path}${Platform.pathSeparator}atelier.sqlite';
  final db = sqlite3.open(path);
  return SqliteStore(db)..init();
}
