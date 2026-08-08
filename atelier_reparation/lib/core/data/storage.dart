import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_store.dart';

/// Fournit le [LocalStore] actif.
///
/// Surchargé au démarrage ([main]) avec l'implémentation persistante
/// (SQLite sur natif, mémoire sur le Web).
final localStoreProvider = Provider<LocalStore>(
  (ref) => throw UnimplementedError('localStoreProvider non initialisé'),
);
