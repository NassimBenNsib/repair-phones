import '../../../core/data/local_store.dart';
import '../../../core/domain/line_item.dart';
import '../../invoices/domain/invoice.dart' show Payment;
import '../domain/purchase_order.dart';

/// (Dé)sérialisation d'une [PurchaseOrder] pour le stockage local.
class OrderMapper implements EntityMapper<PurchaseOrder> {
  @override
  String get collection => 'purchase_orders';

  @override
  String idOf(PurchaseOrder o) => o.id;

  @override
  Map<String, Object?> toJson(PurchaseOrder o) => {
        'id': o.id,
        'number': o.number,
        'supplierId': o.supplierId,
        'status': o.status.name,
        'date': o.date.toIso8601String(),
        'expectedDate': o.expectedDate?.toIso8601String(),
        'receivedAt': o.receivedAt?.toIso8601String(),
        'taxRate': o.taxRate,
        'notes': o.notes,
        'lines': [for (final l in o.lines) l.toJson()],
        'payments': [for (final p in o.payments) p.toJson()],
      };

  @override
  PurchaseOrder fromJson(Map<String, Object?> j) => PurchaseOrder(
        id: j['id'] as String,
        number: j['number'] as String? ?? '',
        supplierId: j['supplierId'] as String? ?? '',
        status: PoStatus.values.firstWhere(
          (s) => s.name == j['status'],
          orElse: () => PoStatus.draft,
        ),
        date: DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime(2024),
        expectedDate: j['expectedDate'] == null
            ? null
            : DateTime.tryParse(j['expectedDate'] as String),
        receivedAt: j['receivedAt'] == null
            ? null
            : DateTime.tryParse(j['receivedAt'] as String),
        taxRate: (j['taxRate'] as num?)?.toDouble() ?? 0.20,
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
