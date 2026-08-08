import 'package:flutter/foundation.dart';

import '../../invoices/domain/invoice.dart' show PaymentMethod;

/// Nature d'une écriture du compte client.
/// - [deposit] : acompte reçu sur le compte (crédit +).
/// - [application] : crédit appliqué à une facture (crédit −), lié à `invoiceId`.
/// - [refund] : remboursement au client (crédit −).
enum ClientPaymentKind { deposit, application, refund }

/// Écriture du grand-livre « compte client » (avoirs / acomptes).
///
/// Distinct des paiements de facture : un [deposit] n'est PAS un encaissement de
/// facture (donc pas du chiffre d'affaires) tant qu'il n'est pas appliqué.
@immutable
class ClientPayment {
  const ClientPayment({
    required this.id,
    required this.clientId,
    required this.date,
    required this.amount,
    required this.kind,
    this.method = PaymentMethod.cash,
    this.invoiceId,
    this.note,
  });

  final String id;
  final String clientId;
  final DateTime date;
  final double amount; // toujours positif ; le signe vient de [kind]
  final ClientPaymentKind kind;
  final PaymentMethod method;
  final String? invoiceId; // renseigné pour une application
  final String? note;

  /// Contribution signée au crédit disponible.
  double get signed => kind == ClientPaymentKind.deposit ? amount : -amount;

  Map<String, Object?> toJson() => {
        'id': id,
        'clientId': clientId,
        'date': date.toIso8601String(),
        'amount': amount,
        'kind': kind.name,
        'method': method.name,
        'invoiceId': invoiceId,
        'note': note,
      };

  factory ClientPayment.fromJson(Map<String, Object?> j) => ClientPayment(
        id: j['id'] as String,
        clientId: j['clientId'] as String? ?? '',
        date: DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime(2024),
        amount: (j['amount'] as num?)?.toDouble() ?? 0,
        kind: ClientPaymentKind.values.firstWhere(
          (k) => k.name == j['kind'],
          orElse: () => ClientPaymentKind.deposit,
        ),
        method: PaymentMethod.values.firstWhere(
          (m) => m.name == j['method'],
          orElse: () => PaymentMethod.cash,
        ),
        invoiceId: j['invoiceId'] as String?,
        note: j['note'] as String?,
      );
}

/// Crédit disponible d'un client = Σ des contributions signées.
double availableCredit(String clientId, List<ClientPayment> ledger) => ledger
    .where((e) => e.clientId == clientId)
    .fold<double>(0, (s, e) => s + e.signed);
