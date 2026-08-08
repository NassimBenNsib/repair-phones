import 'package:flutter/material.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';

/// Cycle de vie d'un chèque.
enum ChequeStatus { pending, deposited, cleared, bounced }

extension ChequeStatusX on ChequeStatus {
  String label(AppLocalizations l) => switch (this) {
        ChequeStatus.pending => l.chequeStatusPending,
        ChequeStatus.deposited => l.chequeStatusDeposited,
        ChequeStatus.cleared => l.chequeStatusCleared,
        ChequeStatus.bounced => l.chequeStatusBounced,
      };

  Color color(AppleColors c) => switch (this) {
        ChequeStatus.pending => c.orange,
        ChequeStatus.deposited => c.blue,
        ChequeStatus.cleared => c.green,
        ChequeStatus.bounced => c.red,
      };

  /// Étape suivante « normale » (null si terminal).
  ChequeStatus? get next => switch (this) {
        ChequeStatus.pending => ChequeStatus.deposited,
        ChequeStatus.deposited => ChequeStatus.cleared,
        _ => null,
      };
}

/// Chèque reçu, suivi du dépôt à l'encaissement (ou au rejet).
@immutable
class Cheque {
  const Cheque({
    required this.id,
    this.invoiceId,
    this.clientId,
    this.clientName = '',
    this.paymentId,
    this.number = '',
    this.bank = '',
    this.drawer = '',
    required this.amount,
    required this.receivedDate,
    this.dueDate,
    this.depositDate,
    this.status = ChequeStatus.pending,
  });

  final String id;
  final String? invoiceId;
  final String? clientId;
  final String clientName;
  final String? paymentId; // paiement de facture créé (pour l'annuler au rejet)
  final String number;
  final String bank;
  final String drawer; // émetteur
  final double amount;
  final DateTime receivedDate;
  final DateTime? dueDate;
  final DateTime? depositDate;
  final ChequeStatus status;

  /// Encaissé ou non (les non-encaissés sont « à suivre »).
  bool get isCleared => status == ChequeStatus.cleared;
  bool get isPendingCash =>
      status == ChequeStatus.pending || status == ChequeStatus.deposited;

  Cheque copyWith({ChequeStatus? status, DateTime? depositDate}) => Cheque(
        id: id,
        invoiceId: invoiceId,
        clientId: clientId,
        clientName: clientName,
        paymentId: paymentId,
        number: number,
        bank: bank,
        drawer: drawer,
        amount: amount,
        receivedDate: receivedDate,
        dueDate: dueDate,
        depositDate: depositDate ?? this.depositDate,
        status: status ?? this.status,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'invoiceId': invoiceId,
        'clientId': clientId,
        'clientName': clientName,
        'paymentId': paymentId,
        'number': number,
        'bank': bank,
        'drawer': drawer,
        'amount': amount,
        'receivedDate': receivedDate.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'depositDate': depositDate?.toIso8601String(),
        'status': status.name,
      };

  factory Cheque.fromJson(Map<String, Object?> j) => Cheque(
        id: j['id'] as String,
        invoiceId: j['invoiceId'] as String?,
        clientId: j['clientId'] as String?,
        clientName: j['clientName'] as String? ?? '',
        paymentId: j['paymentId'] as String?,
        number: j['number'] as String? ?? '',
        bank: j['bank'] as String? ?? '',
        drawer: j['drawer'] as String? ?? '',
        amount: (j['amount'] as num?)?.toDouble() ?? 0,
        receivedDate:
            DateTime.tryParse(j['receivedDate'] as String? ?? '') ?? DateTime(2024),
        dueDate: j['dueDate'] == null
            ? null
            : DateTime.tryParse(j['dueDate'] as String),
        depositDate: j['depositDate'] == null
            ? null
            : DateTime.tryParse(j['depositDate'] as String),
        status: ChequeStatus.values.firstWhere(
          (s) => s.name == j['status'],
          orElse: () => ChequeStatus.pending,
        ),
      );
}
