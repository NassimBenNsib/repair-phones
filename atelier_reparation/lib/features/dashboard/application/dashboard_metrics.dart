import '../../accounting/application/accounting_summary.dart';
import '../../catalog/domain/product.dart';
import '../../clients/domain/client.dart';
import '../../inventory/presentation/inventory_screen.dart' show kLowStockThreshold;
import '../../invoices/domain/invoice.dart';
import '../../orders/domain/purchase_order.dart';
import '../../repairs/domain/repair.dart';

/// Fenêtre temporelle pilotant le tableau de bord.
enum DashboardPeriod { week, month, year }

/// Un point de la série de chiffre d'affaires (jour ou mois selon la période).
typedef RevenuePoint = ({DateTime date, double value});

/// Ancienneté (jours depuis réception) au-delà de laquelle un impayé fournisseur
/// est signalé « à régler ».
const int kPayableOverdueDays = 30;

/// Compteurs « à traiter » du bandeau d'alertes.
typedef DashboardAlerts = ({
  int overdueInvoices,
  int lowStock,
  int dueToday,
  int awaitingParts,
  int overdueDeliveries,
  int unassignedRepairs,
  int overduePayables,
});

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Synthèse du tableau de bord, calculée en une passe. Immuable et pure
/// (testable). Le CA et la trésorerie s'appuient sur les factures (dates
/// fiables) ; les statuts de réparation sur `status`.
class DashboardMetrics {
  const DashboardMetrics({
    required this.period,
    required this.revenue,
    required this.revenuePrevious,
    required this.series,
    required this.collected,
    required this.outstanding,
    required this.statusMix,
    required this.alerts,
    required this.priorityRepairs,
    required this.inProgress,
    required this.completedInWindow,
    required this.clientCount,
  });

  final DashboardPeriod period;
  final double revenue; // CA facturé sur la fenêtre
  final double revenuePrevious; // même fenêtre précédente (tendance)
  final List<RevenuePoint> series; // 7 / 30 jours, ou 12 mois
  final double collected; // encaissé sur la fenêtre
  final double outstanding; // impayés (instantané, toutes factures émises)
  final Map<RepairStatus, int> statusMix;
  final DashboardAlerts alerts;

  /// Réparations actives en retard (échéance dépassée), les plus urgentes
  /// d'abord — la « liste de priorités » actionnable du tableau de bord.
  final List<Repair> priorityRepairs;

  final int inProgress;
  final int completedInWindow;
  final int clientCount;

  int get activeTotal =>
      statusMix.entries.where((e) => e.key.isActive).fold(0, (s, e) => s + e.value);

  /// Nombre d'éléments « à traiter » pour la pastille de la cloche.
  ///
  /// Compte des entités disjointes (factures, commandes, produits, réparations
  /// en retard / dues aujourd'hui) pour éviter de sur-compter une même
  /// réparation ; `awaitingParts`/`unassignedRepairs` restent des tuiles mais
  /// ne gonflent pas la pastille.
  int get attentionCount =>
      alerts.overdueInvoices +
      alerts.overdueDeliveries +
      alerts.overduePayables +
      alerts.lowStock +
      alerts.dueToday +
      priorityRepairs.length;

  /// Variation en % vs la fenêtre précédente (0 si base nulle).
  double get trendPct {
    if (revenuePrevious == 0) return revenue > 0 ? 100 : 0;
    return (revenue - revenuePrevious) / revenuePrevious * 100;
  }

  bool get trendUp => revenue >= revenuePrevious;

  /// Valeurs brutes de la série (pour la sparkline / le graphe).
  List<double> get seriesValues => [for (final p in series) p.value];
}

/// Calcule la synthèse du tableau de bord pour la [period] sélectionnée.
DashboardMetrics computeDashboard({
  required DateTime now,
  required DashboardPeriod period,
  required List<Invoice> invoices,
  required List<Repair> repairs,
  required List<Product> products,
  required List<Client> clients,
  List<PurchaseOrder> orders = const [],
}) {
  final issued = invoices.where((i) => i.isIssued).toList();
  final today = DateTime(now.year, now.month, now.day);

  // --- Chiffre d'affaires + série + fenêtre précédente ---
  double revenue = 0;
  double revenuePrevious = 0;
  double collected = 0;
  final series = <RevenuePoint>[];

  if (period == DashboardPeriod.year) {
    final cur = computeYearSummary(invoices, now.year);
    final prev = computeYearSummary(invoices, now.year - 1);
    revenue = cur.ttc;
    revenuePrevious = prev.ttc;
    collected = cur.collected;
    for (var m = 0; m < 12; m++) {
      series.add((date: DateTime(now.year, m + 1), value: cur.months[m].ttc));
    }
  } else {
    final days = period == DashboardPeriod.week ? 7 : 30;
    final today = DateTime(now.year, now.month, now.day);
    final windowStart = today.subtract(Duration(days: days - 1));
    final prevStart = windowStart.subtract(Duration(days: days));

    for (final i in issued) {
      final d = i.issueDate;
      if (d == null) continue;
      final total = i.totals.total;
      if (!d.isBefore(windowStart)) {
        revenue += total;
      } else if (!d.isBefore(prevStart) && d.isBefore(windowStart)) {
        revenuePrevious += total;
      }
      for (final p in i.payments) {
        if (!p.date.isBefore(windowStart)) collected += p.amount;
      }
    }
    for (var k = 0; k < days; k++) {
      final day = windowStart.add(Duration(days: k));
      final value = issued
          .where((i) => i.issueDate != null && _sameDay(i.issueDate!, day))
          .fold<double>(0, (s, i) => s + i.totals.total);
      series.add((date: day, value: value));
    }
  }

  // --- Impayés (instantané) ---
  final outstanding = issued.fold<double>(0, (s, i) => s + i.balanceDue);

  // --- Répartition des statuts de réparation ---
  final statusMix = <RepairStatus, int>{
    for (final st in RepairStatus.values)
      st: repairs.where((r) => r.status == st).length,
  };

  // --- Alertes « à traiter » ---
  final overdue =
      invoices.where((i) => i.effectiveStatus(now) == InvoiceStatus.overdue).length;
  var lowStock = 0;
  for (final p in products) {
    for (final v in p.variants) {
      if (v.stock <= kLowStockThreshold) lowStock++;
    }
  }
  final dueToday = repairs
      .where((r) =>
          r.status.isActive && r.dueAt != null && _sameDay(r.dueAt!, now))
      .length;
  final awaiting =
      repairs.where((r) => r.status == RepairStatus.awaitingParts).length;
  final overdueDeliveries = orders
      .where((o) =>
          o.status == PoStatus.ordered &&
          (o.expectedDate ?? o.date).isBefore(today))
      .length;
  final overduePayables = orders
      .where((o) =>
          o.status == PoStatus.received &&
          o.balanceDue > 0.005 &&
          today.difference(o.receivedAt ?? o.date).inDays > kPayableOverdueDays)
      .length;
  final unassigned = repairs
      .where((r) =>
          r.status.isActive &&
          (r.assignedTech == null || r.assignedTech!.trim().isEmpty))
      .length;

  // --- Liste de priorités : réparations actives en retard (échéance passée) ---
  final priorityRepairs = repairs
      .where((r) =>
          r.status.isActive && r.dueAt != null && r.dueAt!.isBefore(today))
      .toList()
    ..sort((a, b) => a.dueAt!.compareTo(b.dueAt!));

  // --- Réparations terminées sur la fenêtre ---
  final windowStartForRepairs = switch (period) {
    DashboardPeriod.week => now.subtract(const Duration(days: 7)),
    DashboardPeriod.month => now.subtract(const Duration(days: 30)),
    DashboardPeriod.year => DateTime(now.year),
  };
  final completedInWindow = repairs
      .where((r) =>
          r.status.isDone &&
          r.completedAt != null &&
          r.completedAt!.isAfter(windowStartForRepairs))
      .length;

  return DashboardMetrics(
    period: period,
    revenue: revenue,
    revenuePrevious: revenuePrevious,
    series: series,
    collected: collected,
    outstanding: outstanding,
    statusMix: statusMix,
    alerts: (
      overdueInvoices: overdue,
      lowStock: lowStock,
      dueToday: dueToday,
      awaitingParts: awaiting,
      overdueDeliveries: overdueDeliveries,
      unassignedRepairs: unassigned,
      overduePayables: overduePayables,
    ),
    priorityRepairs: priorityRepairs,
    inProgress: statusMix[RepairStatus.inProgress] ?? 0,
    completedInWindow: completedInWindow,
    clientCount: clients.length,
  );
}
