import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/local_store.dart';
import '../../../core/data/storage.dart';
import '../../invoices/domain/invoice.dart' show PaymentMethod;
import '../data/cash_session_mapper.dart';
import '../domain/cash_session.dart';
import 'payment_history.dart';

/// Calcule le rapport de caisse d'une session sur sa fenêtre `[openedAt, to]`
/// (`to` = clôture, sinon [asOf]). Fonction pure, testable.
CashReport computeCashReport(
  CashSession s,
  List<LedgerEntry> ledger, {
  DateTime? asOf,
}) {
  final to = s.closedAt ?? asOf ?? DateTime.now();
  final inWindow = ledger.where(
      (e) => !e.date.isBefore(s.openedAt) && !e.date.isAfter(to));

  var cashIn = 0.0, cashOut = 0.0;
  final byMethod = <PaymentMethod, double>{};
  for (final e in inWindow) {
    byMethod[e.method] = (byMethod[e.method] ?? 0) + e.cash;
    if (e.method == PaymentMethod.cash) {
      if (e.cash >= 0) {
        cashIn += e.cash;
      } else {
        cashOut += -e.cash;
      }
    }
  }

  return CashReport(
    from: s.openedAt,
    to: to,
    openingFloat: s.openingFloat,
    cashIn: cashIn,
    cashOut: cashOut,
    countedCash: s.countedCash,
    total: netCash(inWindow),
    byMethod: byMethod,
  );
}

final cashSessionStoreProvider = Provider<CollectionStore<CashSession>>(
  (ref) => CollectionStore<CashSession>(
      ref.watch(localStoreProvider), CashSessionMapper()),
);

/// Caisse : ouverture d'un fond, clôture avec comptage (rapport Z).
class CashRegisterController extends Notifier<List<CashSession>> {
  CollectionStore<CashSession> get _store => ref.read(cashSessionStoreProvider);

  @override
  List<CashSession> build() =>
      _store.loadAll()..sort((a, b) => b.openedAt.compareTo(a.openedAt));

  /// Session ouverte (au plus une), ou `null`.
  CashSession? get openSession {
    for (final s in state) {
      if (s.isOpen) return s;
    }
    return null;
  }

  /// Ouvre une session avec un fond de caisse ; no-op si déjà ouverte.
  CashSession? open(double openingFloat, {String? openedBy, DateTime? now}) {
    if (openSession != null) return openSession;
    final s = CashSession(
      id: const Uuid().v4(),
      openedAt: now ?? DateTime.now(),
      openingFloat: openingFloat,
      openedBy: openedBy,
    );
    _store.upsert(s);
    state = [s, ...state];
    return s;
  }

  /// Clôture la session ouverte avec les espèces comptées.
  void close(double countedCash, {String? closedBy, String? note, DateTime? now}) {
    final s = openSession;
    if (s == null) return;
    final closed = s.copyWith(
        closedAt: now ?? DateTime.now(),
        countedCash: countedCash,
        closedBy: closedBy,
        note: note);
    _store.upsert(closed);
    state = [for (final x in state) if (x.id == s.id) closed else x];
  }
}

final cashRegisterProvider =
    NotifierProvider<CashRegisterController, List<CashSession>>(
        CashRegisterController.new);
