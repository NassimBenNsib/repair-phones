import 'package:flutter/material.dart' show DateTimeRange;

import '../../cheques/domain/cheque.dart';
import '../../invoices/domain/invoice.dart' show PaymentMethod;
import 'payment_history.dart';

/// Période de filtre des écrans financiers.
enum FinancePeriod { all, month, quarter, year, custom }

extension FinancePeriodX on FinancePeriod {
  /// Intervalle demi-ouvert `[start, end)` ; `null` = aucune borne (tout).
  DateTimeRange? range(DateTime now, {DateTimeRange? custom}) {
    switch (this) {
      case FinancePeriod.all:
        return null;
      case FinancePeriod.month:
        return DateTimeRange(
          start: DateTime(now.year, now.month),
          end: DateTime(now.year, now.month + 1),
        );
      case FinancePeriod.quarter:
        final q = ((now.month - 1) ~/ 3) * 3 + 1; // 1,4,7,10
        return DateTimeRange(
          start: DateTime(now.year, q),
          end: DateTime(now.year, q + 3),
        );
      case FinancePeriod.year:
        return DateTimeRange(
          start: DateTime(now.year),
          end: DateTime(now.year + 1),
        );
      case FinancePeriod.custom:
        if (custom == null) return null;
        // Fin incluse → borne exclusive au lendemain.
        return DateTimeRange(
          start: DateTime(custom.start.year, custom.start.month, custom.start.day),
          end: DateTime(custom.end.year, custom.end.month, custom.end.day)
              .add(const Duration(days: 1)),
        );
    }
  }
}

/// Filtre financier partagé (période, client, type, moyen).
class FinanceFilter {
  const FinanceFilter({
    this.period = FinancePeriod.all,
    this.customRange,
    this.clientId,
    this.types = const {},
    this.method,
  });

  final FinancePeriod period;
  final DateTimeRange? customRange;
  final String? clientId;
  final Set<LedgerKind> types; // vide = tous
  final PaymentMethod? method; // null = tous

  FinanceFilter copyWith({
    FinancePeriod? period,
    DateTimeRange? customRange,
    bool clearCustomRange = false,
    String? clientId,
    bool clearClient = false,
    Set<LedgerKind>? types,
    PaymentMethod? method,
    bool clearMethod = false,
  }) =>
      FinanceFilter(
        period: period ?? this.period,
        customRange:
            clearCustomRange ? null : (customRange ?? this.customRange),
        clientId: clearClient ? null : (clientId ?? this.clientId),
        types: types ?? this.types,
        method: clearMethod ? null : (method ?? this.method),
      );

  bool _inRange(DateTime date, DateTime now) {
    final r = period.range(now, custom: customRange);
    if (r == null) return true;
    return !date.isBefore(r.start) && date.isBefore(r.end);
  }
}

/// Vrai si l'écriture passe le filtre.
bool matchesLedger(LedgerEntry e, FinanceFilter f, DateTime now) {
  if (!f._inRange(e.date, now)) return false;
  if (f.clientId != null && e.clientId != f.clientId) return false;
  if (f.types.isNotEmpty && !f.types.contains(e.kind)) return false;
  if (f.method != null && e.method != f.method) return false;
  return true;
}

/// Vrai si le chèque passe le filtre (période sur `receivedDate` + client).
bool matchesCheque(Cheque c, FinanceFilter f, DateTime now) {
  if (!f._inRange(c.receivedDate, now)) return false;
  if (f.clientId != null && c.clientId != f.clientId) return false;
  return true;
}

/// Ventilation d'un ensemble d'écritures : trésorerie nette répartie par type et
/// par moyen. Invariant : `sum(byMethod) == sum(byType) == net` (les
/// applications de crédit, internes, contribuent 0 et sont ignorées).
class FinanceBreakdown {
  const FinanceBreakdown({
    required this.byMethod,
    required this.byType,
    required this.net,
  });

  final Map<PaymentMethod, double> byMethod;
  final Map<LedgerKind, double> byType;
  final double net;

  bool get isEmpty => byMethod.isEmpty && byType.isEmpty;
}

/// Calcule la ventilation par moyen et par type sur la base de la trésorerie
/// nette (`LedgerEntry.cash`) — se réconcilie exactement avec [netCash].
FinanceBreakdown financeBreakdown(Iterable<LedgerEntry> entries) {
  final byMethod = <PaymentMethod, double>{};
  final byType = <LedgerKind, double>{};
  var net = 0.0;
  for (final e in entries) {
    final c = e.cash;
    if (c == 0) continue; // application de crédit : interne, ignorée
    byMethod[e.method] = (byMethod[e.method] ?? 0) + c;
    byType[e.kind] = (byType[e.kind] ?? 0) + c;
    net += c;
  }
  return FinanceBreakdown(byMethod: byMethod, byType: byType, net: net);
}
