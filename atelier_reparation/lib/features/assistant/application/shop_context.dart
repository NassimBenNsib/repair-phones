import 'package:atelier_reparation/core/format/app_formats.dart';
import '../../catalog/domain/product.dart';
import '../../invoices/domain/invoice.dart';
import '../../repairs/domain/repair.dart';

/// Seuil de stock bas partagé avec l'inventaire.
const int _lowStock = 3;

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Construit un instantané compact et factuel de l'atelier, injecté comme
/// contexte système pour l'assistant. Fonction pure (testable).
String buildShopContext({
  required List<Repair> repairs,
  required List<Invoice> invoices,
  required List<Product> products,
  required DateTime now,
}) {
  final inProgress =
      repairs.where((r) => r.status == RepairStatus.inProgress).length;
  final awaiting =
      repairs.where((r) => r.status == RepairStatus.awaitingParts).length;
  final dueToday = repairs
      .where((r) =>
          r.status.isActive && r.dueAt != null && _sameDay(r.dueAt!, now))
      .toList();

  final issued = invoices.where((i) => i.isIssued).toList();
  final revenue = issued.fold<double>(0, (s, i) => s + i.totals.total);
  final unpaid = issued.fold<double>(0, (s, i) => s + i.balanceDue);
  final overdue =
      invoices.where((i) => i.effectiveStatus(now) == InvoiceStatus.overdue);

  final lowStock = <String>[];
  for (final p in products) {
    for (final v in p.variants) {
      if (v.stock <= _lowStock) {
        final label = v.attributes.isEmpty ? p.name : '${p.name} — ${v.label}';
        lowStock.add('$label (${v.stock})');
      }
    }
  }

  final b = StringBuffer()
    ..writeln('Réparations en cours: $inProgress')
    ..writeln('En attente de pièces: $awaiting')
    ..writeln('Échéances aujourd\'hui: ${dueToday.length}');
  for (final r in dueToday.take(10)) {
    b.writeln('  - ${r.reference} · ${r.device} · ${r.client}');
  }
  b
    ..writeln('Chiffre d\'affaires facturé: ${AppFormats.money(revenue, decimals: 2)}')
    ..writeln('Impayés: ${AppFormats.money(unpaid, decimals: 2)}')
    ..writeln('Factures en retard: ${overdue.length}');
  for (final i in overdue.take(10)) {
    b.writeln(
        '  - ${i.number} · ${i.clientName} · reste ${AppFormats.money(i.balanceDue, decimals: 2)}');
  }
  b.writeln('Articles en stock bas (≤ $_lowStock): ${lowStock.length}');
  for (final s in lowStock.take(15)) {
    b.writeln('  - $s');
  }
  return b.toString();
}
