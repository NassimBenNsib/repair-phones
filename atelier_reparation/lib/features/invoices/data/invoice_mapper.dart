import '../../../core/data/local_store.dart';
import '../../../core/domain/line_item.dart';
import '../domain/invoice.dart';

/// (Dé)sérialisation d'une [Invoice] pour le stockage local.
class InvoiceMapper implements EntityMapper<Invoice> {
  @override
  String get collection => 'invoices';

  @override
  String idOf(Invoice i) => i.id;

  @override
  Map<String, Object?> toJson(Invoice i) => {
        'id': i.id,
        'number': i.number,
        'clientId': i.clientId,
        'clientName': i.clientName,
        'quoteId': i.quoteId,
        'repairId': i.repairId,
        'status': i.status.name,
        'date': i.date.toIso8601String(),
        'issueDate': i.issueDate?.toIso8601String(),
        'dueDate': i.dueDate?.toIso8601String(),
        'discount': i.discount,
        'taxRate': i.taxRate,
        'deposit': i.deposit,
        'notes': i.notes,
        'lines': [for (final l in i.lines) l.toJson()],
        'payments': [for (final p in i.payments) p.toJson()],
      };

  @override
  Invoice fromJson(Map<String, Object?> j) => Invoice(
        id: j['id'] as String,
        number: j['number'] as String? ?? '',
        clientId: j['clientId'] as String? ?? '',
        clientName: j['clientName'] as String? ?? '',
        quoteId: j['quoteId'] as String?,
        repairId: j['repairId'] as String?,
        status: InvoiceStatus.values.firstWhere(
          (s) => s.name == j['status'],
          orElse: () => InvoiceStatus.draft,
        ),
        date: DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime(2024),
        issueDate: j['issueDate'] == null
            ? null
            : DateTime.tryParse(j['issueDate'] as String),
        dueDate: j['dueDate'] == null
            ? null
            : DateTime.tryParse(j['dueDate'] as String),
        discount: (j['discount'] as num?)?.toDouble() ?? 0,
        taxRate: (j['taxRate'] as num?)?.toDouble() ?? 0.20,
        deposit: (j['deposit'] as num?)?.toDouble() ?? 0,
        notes: j['notes'] as String?,
        lines: [
          for (final l in (j['lines'] as List? ?? const []))
            LineItem.fromJson(Map<String, Object?>.from(l as Map)),
        ],
        payments: [
          for (final p in (j['payments'] as List? ?? const []))
            Payment.fromJson(Map<String, Object?>.from(p as Map)),
        ],
      );
}
