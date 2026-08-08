import 'package:atelier_reparation/core/domain/line_item.dart';
import 'package:atelier_reparation/features/catalog/domain/product.dart';
import 'package:atelier_reparation/features/clients/domain/client.dart';
import 'package:atelier_reparation/features/dashboard/application/dashboard_metrics.dart';
import 'package:atelier_reparation/features/invoices/domain/invoice.dart';
import 'package:atelier_reparation/features/orders/domain/purchase_order.dart';
import 'package:atelier_reparation/features/repairs/domain/repair.dart';
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime(2026, 7, 18, 12);

Invoice _inv({
  required String number,
  required DateTime issueDate,
  double unitPrice = 100,
  List<Payment> payments = const [],
  DateTime? dueDate,
}) =>
    Invoice(
      id: 'i-$number',
      number: number,
      clientId: 'c1',
      clientName: 'Client',
      status: InvoiceStatus.issued,
      date: issueDate,
      issueDate: issueDate,
      dueDate: dueDate,
      lines: [LineItem(id: 'l', label: 'x', qty: 1, unitPrice: unitPrice)],
      payments: payments,
      taxRate: 0.20,
    );

Repair _rep(RepairStatus status, {DateTime? dueAt, DateTime? completedAt}) =>
    Repair(
      reference: 'r-${status.name}-${dueAt?.day ?? 0}',
      device: 'iPhone',
      kind: DeviceKind.phone,
      client: 'Client',
      status: status,
      priority: RepairPriority.normal,
      progress: 0,
      updatedLabel: '',
      hoursAgo: 1,
      dueAt: dueAt,
      completedAt: completedAt,
    );

Product _product(int stock) => Product(
      id: 'p1',
      name: 'Écran',
      brand: 'Apple',
      categoryId: 'part',
      options: const [],
      variants: [
        ProductVariant(
            id: 'v1', sku: 'S', attributes: const {}, price: 10, stock: stock),
      ],
    );

void main() {
  test('week: revenue window, previous window, and 7-point daily series', () {
    final invoices = [
      _inv(number: 'F1', issueDate: _now.subtract(const Duration(days: 1))),
      _inv(number: 'F2', issueDate: _now.subtract(const Duration(days: 3))),
      // 10 days ago → previous window (8..14 days back).
      _inv(number: 'F3', issueDate: _now.subtract(const Duration(days: 10))),
    ];
    final m = computeDashboard(
      now: _now,
      period: DashboardPeriod.week,
      invoices: invoices,
      repairs: const [],
      products: const [],
      clients: const [],
    );
    expect(m.series.length, 7);
    expect(m.revenue, closeTo(240, 1e-9)); // two invoices × 120 TTC
    expect(m.revenuePrevious, closeTo(120, 1e-9)); // the 10-day-old one
    expect(m.trendUp, isTrue);
    expect(m.trendPct, closeTo(100, 1e-9)); // 240 vs 120
  });

  test('year: 12 monthly points via computeYearSummary', () {
    final m = computeDashboard(
      now: _now,
      period: DashboardPeriod.year,
      invoices: [_inv(number: 'F1', issueDate: DateTime(2026, 3, 5))],
      repairs: const [],
      products: const [],
      clients: const [],
    );
    expect(m.series.length, 12);
    expect(m.series[2].value, closeTo(120, 1e-9)); // March
    expect(m.revenue, closeTo(120, 1e-9));
  });

  test('alerts count overdue invoices, low stock, due-today, awaiting parts', () {
    final invoices = [
      // Issued, due in the past, unpaid → overdue.
      _inv(
          number: 'F1',
          issueDate: _now.subtract(const Duration(days: 40)),
          dueDate: _now.subtract(const Duration(days: 10))),
    ];
    final repairs = [
      _rep(RepairStatus.inProgress, dueAt: _now),
      _rep(RepairStatus.awaitingParts),
      _rep(RepairStatus.completed),
    ];
    final m = computeDashboard(
      now: _now,
      period: DashboardPeriod.week,
      invoices: invoices,
      repairs: repairs,
      products: [_product(2), _product(9)], // one low, one ok
      clients: const [Client(id: 'c1', name: 'A', phone: '1')],
    );
    expect(m.alerts.overdueInvoices, 1);
    expect(m.alerts.lowStock, 1);
    expect(m.alerts.dueToday, 1);
    expect(m.alerts.awaitingParts, 1);
    expect(m.statusMix[RepairStatus.inProgress], 1);
    expect(m.activeTotal, 2);
    expect(m.clientCount, 1);
  });

  test('orders, unassigned repairs, and priority worklist', () {
    final orders = [
      // Ordered, expected in the past → overdue delivery.
      PurchaseOrder(
        id: 'O1',
        number: 'CMD1',
        supplierId: 's1',
        status: PoStatus.ordered,
        date: _now.subtract(const Duration(days: 20)),
        expectedDate: _now.subtract(const Duration(days: 3)),
        lines: [LineItem(id: 'l', label: 'x', qty: 1, unitPrice: 10)],
      ),
      // Ordered, expected in the future → not overdue.
      PurchaseOrder(
        id: 'O2',
        number: 'CMD2',
        supplierId: 's1',
        status: PoStatus.ordered,
        date: _now,
        expectedDate: _now.add(const Duration(days: 5)),
        lines: const [],
      ),
      // Received 45 days ago, unpaid → overdue payable (>30 days).
      PurchaseOrder(
        id: 'O3',
        number: 'CMD3',
        supplierId: 's1',
        status: PoStatus.received,
        date: _now.subtract(const Duration(days: 50)),
        receivedAt: _now.subtract(const Duration(days: 45)),
        taxRate: 0,
        lines: [LineItem(id: 'l', label: 'x', qty: 1, unitPrice: 100)],
      ),
      // Received 45 days ago but fully paid → not a payable.
      PurchaseOrder(
        id: 'O4',
        number: 'CMD4',
        supplierId: 's1',
        status: PoStatus.received,
        date: _now.subtract(const Duration(days: 50)),
        receivedAt: _now.subtract(const Duration(days: 45)),
        taxRate: 0,
        lines: [LineItem(id: 'l', label: 'x', qty: 1, unitPrice: 100)],
        payments: [Payment(id: 'p', date: _now, amount: 100)],
      ),
    ];
    final repairs = [
      // Active, past due → priority (and unassigned).
      _rep(RepairStatus.inProgress,
          dueAt: _now.subtract(const Duration(days: 5))),
      _rep(RepairStatus.diagnosing,
          dueAt: _now.subtract(const Duration(days: 2))),
      // Active, due in future → not a priority.
      _rep(RepairStatus.inProgress, dueAt: _now.add(const Duration(days: 3))),
      // Closed → never a priority even if past due.
      _rep(RepairStatus.delivered,
          dueAt: _now.subtract(const Duration(days: 9))),
    ];

    final m = computeDashboard(
      now: _now,
      period: DashboardPeriod.week,
      invoices: const [],
      repairs: repairs,
      products: const [],
      clients: const [],
      orders: orders,
    );

    expect(m.alerts.overdueDeliveries, 1);
    expect(m.alerts.overduePayables, 1); // O3 uniquement (O4 soldée)
    expect(m.alerts.unassignedRepairs, 3); // 3 actives, aucune assignée
    // Deux réparations actives en retard, la plus ancienne échéance d'abord.
    expect(m.priorityRepairs.length, 2);
    expect(m.priorityRepairs.first.dueAt!.isBefore(m.priorityRepairs[1].dueAt!),
        isTrue);
  });

  test('attentionCount sums disjoint entities (no repair double-count)', () {
    final invoices = [
      _inv(
          number: 'F1',
          issueDate: _now.subtract(const Duration(days: 40)),
          dueDate: _now.subtract(const Duration(days: 10))), // overdue
    ];
    final repairs = [
      // Overdue (priority) + awaiting-parts + unassigned all on ONE repair:
      // counts once via priorityRepairs, not thrice.
      _rep(RepairStatus.awaitingParts,
          dueAt: _now.subtract(const Duration(days: 4))),
      _rep(RepairStatus.inProgress, dueAt: _now), // due today
    ];
    final m = computeDashboard(
      now: _now,
      period: DashboardPeriod.week,
      invoices: invoices,
      repairs: repairs,
      products: [_product(1)], // low stock
      clients: const [],
    );
    // overdueInvoices(1) + lowStock(1) + dueToday(1) + priorityRepairs(1) = 4.
    // awaitingParts/unassigned are NOT added to the badge.
    expect(m.attentionCount, 4);
  });

  test('empty data yields zeros without throwing', () {
    final m = computeDashboard(
      now: _now,
      period: DashboardPeriod.month,
      invoices: const [],
      repairs: const [],
      products: const [],
      clients: const [],
    );
    expect(m.series.length, 30);
    expect(m.revenue, 0);
    expect(m.trendPct, 0);
    expect(m.outstanding, 0);
  });
}
