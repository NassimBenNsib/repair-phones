import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_store.dart';
import '../data/storage.dart';

/// Génère des numéros de documents séquentiels par type et par année
/// (`CMD-2026-0001`, `DEVIS-2026-0001`, `FACT-2026-0001`).
///
/// Sans trou, adossé au stockage local (collection `sequences`).
class NumberingService {
  NumberingService(this._store);

  final LocalStore _store;

  String next(String prefix, int year) {
    final id = '$prefix-$year';
    var last = 0;
    for (final row in _store.all('sequences')) {
      if (row['id'] == id) last = (row['value'] as num).toInt();
    }
    final n = last + 1;
    _store.put('sequences', id, {'id': id, 'value': n});
    return '$prefix-$year-${n.toString().padLeft(4, '0')}';
  }
}

final numberingProvider = Provider<NumberingService>(
  (ref) => NumberingService(ref.watch(localStoreProvider)),
);
