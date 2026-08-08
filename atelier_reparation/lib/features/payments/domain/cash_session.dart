import 'package:flutter/foundation.dart';

import '../../invoices/domain/invoice.dart' show PaymentMethod;

/// Session de caisse : un cycle « ouverture (fond de caisse) → clôture (comptage) ».
@immutable
class CashSession {
  const CashSession({
    required this.id,
    required this.openedAt,
    required this.openingFloat,
    this.closedAt,
    this.countedCash,
    this.openedBy,
    this.closedBy,
    this.note,
  });

  final String id;
  final DateTime openedAt;

  /// Fond de caisse à l'ouverture.
  final double openingFloat;
  final DateTime? closedAt;

  /// Espèces réellement comptées à la clôture.
  final double? countedCash;
  final String? openedBy;
  final String? closedBy;
  final String? note;

  bool get isOpen => closedAt == null;

  CashSession copyWith({
    DateTime? closedAt,
    double? countedCash,
    String? closedBy,
    String? note,
  }) =>
      CashSession(
        id: id,
        openedAt: openedAt,
        openingFloat: openingFloat,
        closedAt: closedAt ?? this.closedAt,
        countedCash: countedCash ?? this.countedCash,
        openedBy: openedBy,
        closedBy: closedBy ?? this.closedBy,
        note: note ?? this.note,
      );
}

/// Rapport de caisse (« Z ») calculé pour une session sur sa fenêtre temporelle.
@immutable
class CashReport {
  const CashReport({
    required this.from,
    required this.to,
    required this.openingFloat,
    required this.cashIn,
    required this.cashOut,
    required this.countedCash,
    required this.total,
    required this.byMethod,
  });

  final DateTime from;
  final DateTime to;
  final double openingFloat;

  /// Encaissements espèces (positifs).
  final double cashIn;

  /// Sorties espèces (remboursements, magnitude positive).
  final double cashOut;
  final double? countedCash;

  /// Trésorerie nette tous modes sur la fenêtre.
  final double total;

  /// Net encaissé par mode de paiement (espèces, carte, virement…).
  final Map<PaymentMethod, double> byMethod;

  /// Espèces attendues en caisse = fond + entrées − sorties.
  double get expectedCash => openingFloat + cashIn - cashOut;

  /// Écart de caisse (comptées − attendues), `null` tant que non comptées.
  double? get variance =>
      countedCash == null ? null : countedCash! - expectedCash;
}
