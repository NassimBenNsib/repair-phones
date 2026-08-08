import 'package:atelier_reparation/features/cheques/domain/cheque.dart';
import 'package:atelier_reparation/features/invoices/domain/invoice.dart';
import 'package:atelier_reparation/features/payments/application/finance_filter.dart';
import 'package:atelier_reparation/features/payments/application/payment_history.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime(2026, 5, 15); // Q2

LedgerEntry _e({
  required DateTime date,
  LedgerKind kind = LedgerKind.invoicePayment,
  PaymentMethod method = PaymentMethod.cash,
  String clientId = 'c1',
}) =>
    LedgerEntry(
      kind: kind,
      date: date,
      amount: 10,
      method: method,
      clientId: clientId,
      clientName: 'C',
    );

void main() {
  group('FinancePeriod.range', () {
    test('month is the current calendar month, half-open', () {
      final r = FinancePeriod.month.range(_now)!;
      expect(r.start, DateTime(2026, 5, 1));
      expect(r.end, DateTime(2026, 6, 1));
    });
    test('quarter covers Apr–Jun for a May date', () {
      final r = FinancePeriod.quarter.range(_now)!;
      expect(r.start, DateTime(2026, 4, 1));
      expect(r.end, DateTime(2026, 7, 1));
    });
    test('year is the calendar year', () {
      final r = FinancePeriod.year.range(_now)!;
      expect(r.start, DateTime(2026, 1, 1));
      expect(r.end, DateTime(2027, 1, 1));
    });
    test('all is unbounded', () {
      expect(FinancePeriod.all.range(_now), isNull);
    });
    test('custom makes the end date inclusive', () {
      final r = FinancePeriod.custom.range(_now,
          custom: DateTimeRange(
              start: DateTime(2026, 5, 10), end: DateTime(2026, 5, 20)))!;
      expect(r.start, DateTime(2026, 5, 10));
      expect(r.end, DateTime(2026, 5, 21)); // +1 day
    });
  });

  test('period boundaries: 1st in, last-ms of prior month out', () {
    const f = FinanceFilter(period: FinancePeriod.month);
    expect(matchesLedger(_e(date: DateTime(2026, 5, 1)), f, _now), isTrue);
    expect(
        matchesLedger(
            _e(date: DateTime(2026, 4, 30, 23, 59, 59, 999)), f, _now),
        isFalse);
    expect(matchesLedger(_e(date: DateTime(2026, 6, 1)), f, _now), isFalse);
  });

  test('client, type and method compose', () {
    final f = FinanceFilter(
      clientId: 'c1',
      types: const {LedgerKind.refund},
      method: PaymentMethod.card,
    );
    final match = _e(
        date: _now,
        kind: LedgerKind.refund,
        method: PaymentMethod.card,
        clientId: 'c1');
    expect(matchesLedger(match, f, _now), isTrue);
    // Wrong client / type / method each fail.
    expect(
        matchesLedger(match, f.copyWith(clientId: 'c2'), _now), isFalse);
    expect(
        matchesLedger(
            _e(date: _now, kind: LedgerKind.deposit, method: PaymentMethod.card),
            f,
            _now),
        isFalse);
    expect(
        matchesLedger(
            _e(date: _now, kind: LedgerKind.refund, method: PaymentMethod.cash),
            f,
            _now),
        isFalse);
  });

  test('financeBreakdown reconciles to netCash, per type and method', () {
    final entries = [
      _e(date: _now, method: PaymentMethod.card), // invoice +10 card
      _e(date: _now, kind: LedgerKind.deposit, method: PaymentMethod.cash), // +10
      _e(date: _now, kind: LedgerKind.refund, method: PaymentMethod.card), // -10
      _e(date: _now, kind: LedgerKind.application, method: PaymentMethod.credit), // 0
    ];
    final b = financeBreakdown(entries);
    // Applications are internal → dropped from both maps.
    expect(b.byType[LedgerKind.application], isNull);
    expect(b.byType[LedgerKind.invoicePayment], 10);
    expect(b.byType[LedgerKind.deposit], 10);
    expect(b.byType[LedgerKind.refund], -10);
    // Card = +10 invoice −10 refund = 0; cash = +10 deposit.
    expect(b.byMethod[PaymentMethod.card], 0);
    expect(b.byMethod[PaymentMethod.cash], 10);
    // Invariant: parts sum to the net.
    expect(b.net, netCash(entries));
    expect(b.byType.values.fold<double>(0, (s, v) => s + v), b.net);
    expect(b.byMethod.values.fold<double>(0, (s, v) => s + v), b.net);
  });

  test('matchesCheque filters by period and client', () {
    Cheque c(DateTime d, String client) => Cheque(
        id: 'x', clientId: client, amount: 5, receivedDate: d);
    const f = FinanceFilter(period: FinancePeriod.month, clientId: 'c1');
    expect(matchesCheque(c(DateTime(2026, 5, 3), 'c1'), f, _now), isTrue);
    expect(matchesCheque(c(DateTime(2026, 4, 3), 'c1'), f, _now), isFalse);
    expect(matchesCheque(c(DateTime(2026, 5, 3), 'c2'), f, _now), isFalse);
  });
}
