// Caisse (CR1) : rapport Z (fond + entrées/sorties espèces, attendu, écart,
// ventilation par mode) et cycle ouverture/clôture.

import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/data/storage.dart';
import 'package:atelier_reparation/features/payments/application/cash_register_controller.dart';
import 'package:atelier_reparation/features/payments/application/payment_history.dart';
import 'package:atelier_reparation/features/payments/domain/cash_session.dart';
import 'package:atelier_reparation/features/invoices/domain/invoice.dart'
    show PaymentMethod;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

LedgerEntry _e(LedgerKind kind, double amount, PaymentMethod method, DateTime d) =>
    LedgerEntry(
        kind: kind,
        date: d,
        amount: amount,
        method: method,
        clientId: 'c1',
        clientName: 'X');

void main() {
  test('computeCashReport : attendu, écart et ventilation par mode', () {
    final s = CashSession(
      id: 's1',
      openedAt: DateTime(2026, 5, 1, 9),
      openingFloat: 100,
      closedAt: DateTime(2026, 5, 1, 19),
      countedCash: 235, // compté
    );
    final ledger = [
      _e(LedgerKind.invoicePayment, 150, PaymentMethod.cash, DateTime(2026, 5, 1, 10)),
      _e(LedgerKind.refund, 20, PaymentMethod.cash, DateTime(2026, 5, 1, 12)), // sortie
      _e(LedgerKind.invoicePayment, 80, PaymentMethod.card, DateTime(2026, 5, 1, 14)),
      // Hors fenêtre (avant ouverture) → ignoré.
      _e(LedgerKind.invoicePayment, 999, PaymentMethod.cash, DateTime(2026, 4, 30)),
    ];

    final r = computeCashReport(s, ledger);
    expect(r.cashIn, 150);
    expect(r.cashOut, 20);
    expect(r.expectedCash, 100 + 150 - 20); // 230
    expect(r.variance, 235 - 230); // +5 (surplus)
    expect(r.byMethod[PaymentMethod.cash], 130); // 150 - 20
    expect(r.byMethod[PaymentMethod.card], 80);
    expect(r.total, 210); // net tous modes : 150 - 20 + 80
  });

  test('cycle ouverture / clôture : une seule session ouverte', () {
    final c = ProviderContainer(
        overrides: [localStoreProvider.overrideWithValue(InMemoryStore())]);
    addTearDown(c.dispose);
    final ctrl = c.read(cashRegisterProvider.notifier);

    expect(ctrl.openSession, isNull);
    final s = ctrl.open(150, now: DateTime(2026, 5, 1, 9))!;
    expect(ctrl.openSession!.id, s.id);
    // Réouverture → renvoie la même session (pas de doublon).
    expect(ctrl.open(999)!.id, s.id);
    expect(c.read(cashRegisterProvider).length, 1);

    ctrl.close(300, now: DateTime(2026, 5, 1, 19));
    expect(ctrl.openSession, isNull);
    final closed = c.read(cashRegisterProvider).single;
    expect(closed.isOpen, isFalse);
    expect(closed.countedCash, 300);
  });
}
