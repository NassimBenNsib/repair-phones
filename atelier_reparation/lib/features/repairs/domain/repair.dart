import 'package:flutter/material.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';

/// Cycle de vie d'une réparation (ordre = progression de l'atelier).
/// Les 3 valeurs historiques (inProgress/awaitingParts/completed) sont
/// conservées → migration sans perte des données existantes.
enum RepairStatus {
  received,
  diagnosing,
  awaitingParts,
  inProgress,
  completed,
  delivered,
  cancelled,
}

extension RepairStatusX on RepairStatus {
  String label(AppLocalizations l) => switch (this) {
        RepairStatus.received => l.statusReceived,
        RepairStatus.diagnosing => l.statusDiagnosing,
        RepairStatus.awaitingParts => l.statusAwaitingParts,
        RepairStatus.inProgress => l.statusInProgress,
        RepairStatus.completed => l.statusCompleted,
        RepairStatus.delivered => l.statusDelivered,
        RepairStatus.cancelled => l.statusCancelled,
      };

  Color color(AppleColors c) => switch (this) {
        RepairStatus.received => c.secondaryLabel,
        RepairStatus.diagnosing => c.indigo,
        RepairStatus.awaitingParts => c.orange,
        RepairStatus.inProgress => c.blue,
        RepairStatus.completed => c.green,
        RepairStatus.delivered => c.teal,
        RepairStatus.cancelled => c.red,
      };

  IconData get icon => switch (this) {
        RepairStatus.received => Icons.inbox_outlined,
        RepairStatus.diagnosing => Icons.troubleshoot,
        RepairStatus.awaitingParts => Icons.hourglass_empty,
        RepairStatus.inProgress => Icons.build_circle_outlined,
        RepairStatus.completed => Icons.check_circle_outline,
        RepairStatus.delivered => Icons.local_shipping_outlined,
        RepairStatus.cancelled => Icons.cancel_outlined,
      };

  /// Travail clos (terminé, livré ou annulé) → n'apparaît plus comme « actif ».
  bool get isClosed =>
      this == RepairStatus.completed ||
      this == RepairStatus.delivered ||
      this == RepairStatus.cancelled;

  /// Réparation ouverte (en cours de traitement).
  bool get isActive => !isClosed;

  /// Terminée avec succès (hors annulation).
  bool get isDone =>
      this == RepairStatus.completed || this == RepairStatus.delivered;

  /// Statut suivant dans le flux (`null` si terminal). Saute l'annulation.
  RepairStatus? get next => switch (this) {
        RepairStatus.received => RepairStatus.diagnosing,
        RepairStatus.diagnosing => RepairStatus.inProgress,
        RepairStatus.awaitingParts => RepairStatus.inProgress,
        RepairStatus.inProgress => RepairStatus.completed,
        RepairStatus.completed => RepairStatus.delivered,
        RepairStatus.delivered => null,
        RepairStatus.cancelled => null,
      };
}

/// Priorité d'une réparation.
enum RepairPriority { low, normal, high }

extension RepairPriorityX on RepairPriority {
  String label(AppLocalizations l) => switch (this) {
        RepairPriority.low => l.repairPriorityLow,
        RepairPriority.normal => l.repairPriorityNormal,
        RepairPriority.high => l.repairPriorityHigh,
      };

  Color color(AppleColors c) => switch (this) {
        RepairPriority.low => c.secondaryLabel,
        RepairPriority.normal => c.blue,
        RepairPriority.high => c.red,
      };
}

/// Statut de paiement.
enum PaymentStatus { unpaid, partial, paid }

extension PaymentStatusX on PaymentStatus {
  String label(AppLocalizations l) => switch (this) {
        PaymentStatus.unpaid => l.paymentUnpaid,
        PaymentStatus.partial => l.paymentPartial,
        PaymentStatus.paid => l.paymentPaid,
      };

  Color color(AppleColors c) => switch (this) {
        PaymentStatus.unpaid => c.red,
        PaymentStatus.partial => c.orange,
        PaymentStatus.paid => c.green,
      };
}

/// Catégorie d'appareil (détermine l'icône).
enum DeviceKind { phone, laptop, tablet, watch, other }

extension DeviceKindX on DeviceKind {
  IconData get icon => switch (this) {
        DeviceKind.phone => Icons.smartphone,
        DeviceKind.laptop => Icons.laptop_mac,
        DeviceKind.tablet => Icons.tablet_mac,
        DeviceKind.watch => Icons.watch,
        DeviceKind.other => Icons.devices_other,
      };

  String label(AppLocalizations l) => switch (this) {
        DeviceKind.phone => l.deviceKindPhone,
        DeviceKind.laptop => l.deviceKindLaptop,
        DeviceKind.tablet => l.deviceKindTablet,
        DeviceKind.watch => l.deviceKindWatch,
        DeviceKind.other => l.deviceKindOther,
      };
}

/// Critère de tri de la liste des réparations.
enum RepairSort { recent, priority, cost }

extension RepairSortX on RepairSort {
  String label(AppLocalizations l) => switch (this) {
        RepairSort.recent => l.repairSortRecent,
        RepairSort.priority => l.repairSortPriority,
        RepairSort.cost => l.repairSortCost,
      };

  int compare(Repair a, Repair b) => switch (this) {
        RepairSort.recent => a.hoursAgo.compareTo(b.hoursAgo),
        RepairSort.priority => b.priority.index.compareTo(a.priority.index),
        RepairSort.cost => b.total.compareTo(a.total),
      };
}

/// Prestation (main-d'œuvre / service) facturée.
@immutable
class RepairService {
  const RepairService(this.label, this.price);
  final String label;
  final double price;
}

/// Pièce utilisée (quantité × prix unitaire).
@immutable
class RepairPart {
  const RepairPart({
    required this.label,
    this.quantity = 1,
    this.unitPrice = 0,
  });
  final String label;
  final int quantity;
  final double unitPrice;
  double get total => quantity * unitPrice;
}

/// Nature d'un événement du suivi (pour un rendu localisé).
enum RepairEventType { created, status, tech, payment, photo, note }

/// Événement horodaté du suivi. [type] + [detail] permettent au calque UI de
/// localiser le libellé ; [label] reste disponible pour les événements libres.
@immutable
class RepairEvent {
  const RepairEvent({
    required this.at,
    this.type = RepairEventType.note,
    this.detail,
    this.label,
    this.icon = Icons.check,
  });

  final DateTime at;
  final RepairEventType type;

  /// Donnée brute (nom de statut, nom de technicien…) ; localisée à l'affichage.
  final String? detail;

  /// Libellé libre (événements historiques / notes). Peut être nul.
  final String? label;
  final IconData icon;
}

/// Fiche de réparation.
@immutable
class Repair {
  const Repair({
    required this.reference,
    required this.device,
    required this.kind,
    required this.client,
    this.clientId,
    required this.status,
    required this.priority,
    required this.progress,
    required this.updatedLabel,
    required this.hoursAgo,
    this.reportedIssue,
    this.diagnosis,
    this.workDone,
    this.brand,
    this.model,
    this.serial,
    this.color,
    this.storage,
    this.accessories = const [],
    this.intakeCondition,
    this.passcode,
    this.backupConsent = false,
    this.assignedTech,
    this.assignedTechId,
    this.createdBy,
    this.location,
    this.clientPhone,
    this.clientEmail,
    this.parts = const [],
    this.services = const [],
    this.discount = 0,
    this.taxRate = 0.20,
    this.deposit = 0,
    this.paymentStatus = PaymentStatus.unpaid,
    this.warrantyMonths,
    this.photos = const [],
    this.createdAt,
    this.dueAt,
    this.completedAt,
    this.events = const [],
    this.observations,
    this.note,
  });

  final String reference;
  final String device;
  final DeviceKind kind;
  final String client; // libellé client (cache d'affichage)
  final String? clientId; // lien fort vers le client (id)
  final RepairStatus status;
  final RepairPriority priority;
  final double progress;
  final String updatedLabel;
  final int hoursAgo;

  // Récit de la réparation.
  final String? reportedIssue;
  final String? diagnosis;
  final String? workDone;

  // Identité de l'appareil.
  final String? brand;
  final String? model;
  final String? serial;
  final String? color;
  final String? storage;
  final List<String> accessories;
  final String? intakeCondition;
  final String? passcode;
  final bool backupConsent;

  // Personnes & logistique.
  final String? assignedTech; // libellé technicien (cache d'affichage)
  final String? assignedTechId; // lien fort vers l'employé (id)
  final String? createdBy;
  final String? location;
  final String? clientPhone;
  final String? clientEmail;

  // Finances.
  final List<RepairPart> parts;
  final List<RepairService> services;
  final double discount;
  final double taxRate;
  final double deposit;
  final PaymentStatus paymentStatus;
  final int? warrantyMonths;

  final List<String> photos;
  final DateTime? createdAt;
  final DateTime? dueAt;
  final DateTime? completedAt;
  final List<RepairEvent> events;
  final String? observations;
  final String? note;

  double get partsTotal => parts.fold(0, (s, p) => s + p.total);
  double get servicesTotal => services.fold(0, (s, e) => s + e.price);
  double get subtotal => partsTotal + servicesTotal - discount;
  double get taxAmount => subtotal * taxRate;
  double get total => subtotal + taxAmount;
  double get balanceDue {
    final b = total - deposit;
    return b < 0 ? 0 : b;
  }

  bool get isCompleted => status.isClosed;
  bool get isOverdue =>
      dueAt != null && status.isActive && DateTime.now().isAfter(dueAt!);

  /// Fin de garantie (à partir de la date de fin de réparation), ou `null`.
  DateTime? get warrantyUntil {
    if (warrantyMonths == null) return null;
    final from = completedAt ?? createdAt;
    if (from == null) return null;
    return DateTime(from.year, from.month + warrantyMonths!, from.day);
  }

  bool get isUnderWarranty {
    final until = warrantyUntil;
    return until != null && DateTime.now().isBefore(until);
  }

  Repair copyWith({
    String? device,
    DeviceKind? kind,
    String? client,
    String? clientId,
    RepairStatus? status,
    RepairPriority? priority,
    double? progress,
    String? reportedIssue,
    String? diagnosis,
    String? workDone,
    String? brand,
    String? model,
    String? serial,
    String? color,
    String? storage,
    List<String>? accessories,
    String? intakeCondition,
    String? passcode,
    bool? backupConsent,
    String? assignedTech,
    String? assignedTechId,
    String? createdBy,
    String? location,
    String? clientPhone,
    String? clientEmail,
    List<RepairPart>? parts,
    List<RepairService>? services,
    double? discount,
    double? taxRate,
    double? deposit,
    PaymentStatus? paymentStatus,
    int? warrantyMonths,
    List<String>? photos,
    DateTime? dueAt,
    DateTime? completedAt,
    List<RepairEvent>? events,
    String? observations,
    String? note,
  }) {
    return Repair(
      reference: reference,
      device: device ?? this.device,
      kind: kind ?? this.kind,
      client: client ?? this.client,
      clientId: clientId ?? this.clientId,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      progress: progress ?? this.progress,
      updatedLabel: updatedLabel,
      hoursAgo: hoursAgo,
      reportedIssue: reportedIssue ?? this.reportedIssue,
      diagnosis: diagnosis ?? this.diagnosis,
      workDone: workDone ?? this.workDone,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      serial: serial ?? this.serial,
      color: color ?? this.color,
      storage: storage ?? this.storage,
      accessories: accessories ?? this.accessories,
      intakeCondition: intakeCondition ?? this.intakeCondition,
      passcode: passcode ?? this.passcode,
      backupConsent: backupConsent ?? this.backupConsent,
      assignedTech: assignedTech ?? this.assignedTech,
      assignedTechId: assignedTechId ?? this.assignedTechId,
      createdBy: createdBy ?? this.createdBy,
      location: location ?? this.location,
      clientPhone: clientPhone ?? this.clientPhone,
      clientEmail: clientEmail ?? this.clientEmail,
      parts: parts ?? this.parts,
      services: services ?? this.services,
      discount: discount ?? this.discount,
      taxRate: taxRate ?? this.taxRate,
      deposit: deposit ?? this.deposit,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      warrantyMonths: warrantyMonths ?? this.warrantyMonths,
      photos: photos ?? this.photos,
      createdAt: createdAt,
      dueAt: dueAt ?? this.dueAt,
      completedAt: completedAt ?? this.completedAt,
      events: events ?? this.events,
      observations: observations ?? this.observations,
      note: note ?? this.note,
    );
  }
}

/// Jeu de données de démonstration (dates relatives à maintenant).
final List<Repair> sampleRepairs = _buildSamples();

List<Repair> _buildSamples() {
  final now = DateTime.now();
  DateTime ago(Duration d) => now.subtract(d);
  DateTime inH(int h) => now.add(Duration(hours: h));

  return [
    Repair(
      reference: '#R-2048',
      device: 'iPhone 13 — écran',
      kind: DeviceKind.phone,
      client: 'Sofia Haddad',
      clientPhone: '+33612345678',
      clientEmail: 'sofia.haddad@example.com',
      status: RepairStatus.inProgress,
      priority: RepairPriority.high,
      progress: 0.6,
      updatedLabel: '2 h',
      hoursAgo: 2,
      reportedIssue: 'Écran fissuré après une chute, tactile partiel.',
      diagnosis: 'Vitre + dalle LCD à remplacer, châssis intact.',
      brand: 'Apple',
      model: 'iPhone 13',
      serial: '356789101112131',
      color: 'Minuit',
      storage: '128 Go',
      accessories: ['SIM', 'Coque'],
      intakeCondition: 'Coque rayée, Face ID fonctionnel.',
      passcode: '1234',
      backupConsent: true,
      assignedTech: 'Karim B.',
      createdBy: 'Léa M.',
      location: 'Bac A3',
      parts: [
        RepairPart(label: 'Écran OLED', unitPrice: 79),
        RepairPart(label: 'Adhésif', unitPrice: 4),
      ],
      services: [
        RepairService('Remplacement écran', 40),
        RepairService('Diagnostic', 25),
      ],
      deposit: 50,
      paymentStatus: PaymentStatus.partial,
      warrantyMonths: 3,
      createdAt: ago(const Duration(hours: 6)),
      dueAt: inH(4),
      events: [
        RepairEvent(label: 'Fiche créée', at: ago(const Duration(hours: 6)), icon: Icons.add),
        RepairEvent(label: 'Diagnostic effectué', at: ago(const Duration(hours: 4)), icon: Icons.search),
        RepairEvent(label: 'Réparation en cours', at: ago(const Duration(hours: 2)), icon: Icons.build),
      ],
      observations: 'Coque rayée à la prise en charge, Face ID fonctionnel.',
      note: 'Client pressé, contacter avant 18 h.',
    ),
    Repair(
      reference: '#R-2047',
      device: 'MacBook Air — batterie',
      kind: DeviceKind.laptop,
      client: 'Lucas Martin',
      clientPhone: '+33698765432',
      status: RepairStatus.awaitingParts,
      priority: RepairPriority.normal,
      progress: 0.3,
      updatedLabel: '1 j',
      hoursAgo: 24,
      reportedIssue: 'Autonomie très faible, extinctions soudaines.',
      diagnosis: 'Batterie gonflée, cycles > 1200.',
      brand: 'Apple',
      model: 'MacBook Air A2179',
      assignedTech: 'Karim B.',
      location: 'Étagère B1',
      parts: [RepairPart(label: 'Batterie A2179', unitPrice: 90)],
      services: [RepairService('Remplacement batterie', 60)],
      paymentStatus: PaymentStatus.unpaid,
      createdAt: ago(const Duration(days: 1)),
      dueAt: inH(48),
      observations: 'Gonflement de la batterie constaté.',
    ),
    Repair(
      reference: '#R-2046',
      device: 'iPad — connecteur',
      kind: DeviceKind.tablet,
      client: 'Emma Dubois',
      clientPhone: '+33711223344',
      status: RepairStatus.completed,
      priority: RepairPriority.low,
      progress: 1,
      updatedLabel: '3 j',
      hoursAgo: 72,
      parts: [RepairPart(label: 'Nappe de charge', unitPrice: 22)],
      services: [RepairService('Remplacement connecteur', 45)],
      deposit: 89,
      paymentStatus: PaymentStatus.paid,
      warrantyMonths: 6,
      createdAt: ago(const Duration(days: 5)),
      completedAt: ago(const Duration(days: 3)),
    ),
    Repair(
      reference: '#R-2045',
      device: 'Galaxy S22 — vitre',
      kind: DeviceKind.phone,
      client: 'Noah Bernard',
      clientPhone: '+33655443322',
      status: RepairStatus.inProgress,
      priority: RepairPriority.normal,
      progress: 0.45,
      updatedLabel: '5 h',
      hoursAgo: 5,
      parts: [RepairPart(label: 'Vitre arrière', unitPrice: 35)],
      services: [RepairService('Remplacement vitre', 40)],
      createdAt: ago(const Duration(hours: 8)),
      dueAt: inH(6),
    ),
    Repair(
      reference: '#R-2044',
      device: 'Dell XPS — clavier',
      kind: DeviceKind.laptop,
      client: 'Chloé Petit',
      status: RepairStatus.completed,
      priority: RepairPriority.low,
      progress: 1,
      updatedLabel: '4 j',
      hoursAgo: 96,
      services: [RepairService('Remplacement clavier', 70)],
      parts: [RepairPart(label: 'Clavier AZERTY', unitPrice: 25)],
      deposit: 95,
      paymentStatus: PaymentStatus.paid,
      createdAt: ago(const Duration(days: 6)),
      completedAt: ago(const Duration(days: 4)),
    ),
    Repair(
      reference: '#R-2043',
      device: 'Apple Watch — écran',
      kind: DeviceKind.watch,
      client: 'Adam Roche',
      clientPhone: '+33600112233',
      status: RepairStatus.awaitingParts,
      priority: RepairPriority.high,
      progress: 0.2,
      updatedLabel: '6 h',
      hoursAgo: 6,
      parts: [RepairPart(label: 'Écran Series 7', unitPrice: 110)],
      services: [RepairService('Remplacement écran', 55)],
      paymentStatus: PaymentStatus.unpaid,
      createdAt: ago(const Duration(hours: 10)),
      dueAt: ago(const Duration(hours: 2)), // en retard
      note: 'Pièce commandée le 12/07.',
    ),
  ];
}
