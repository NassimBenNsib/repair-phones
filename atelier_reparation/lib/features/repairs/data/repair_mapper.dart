import '../../../core/data/local_store.dart';
import '../domain/repair.dart';

/// (Dé)sérialisation d'une [Repair] pour le stockage local.
///
/// Identifiée par sa `reference`. Les icônes d'événements ne sont pas
/// sérialisées (elles casseraient le tree-shaking) → icône par défaut au chargement.
class RepairMapper implements EntityMapper<Repair> {
  @override
  String get collection => 'repairs';

  @override
  String idOf(Repair r) => r.reference;

  @override
  Map<String, Object?> toJson(Repair r) => {
        'reference': r.reference,
        'device': r.device,
        'kind': r.kind.name,
        'client': r.client,
        'clientId': r.clientId,
        'status': r.status.name,
        'priority': r.priority.name,
        'progress': r.progress,
        'updatedLabel': r.updatedLabel,
        'hoursAgo': r.hoursAgo,
        'reportedIssue': r.reportedIssue,
        'diagnosis': r.diagnosis,
        'workDone': r.workDone,
        'brand': r.brand,
        'model': r.model,
        'serial': r.serial,
        'color': r.color,
        'storage': r.storage,
        'accessories': r.accessories,
        'intakeCondition': r.intakeCondition,
        'passcode': r.passcode,
        'backupConsent': r.backupConsent,
        'assignedTech': r.assignedTech,
        'assignedTechId': r.assignedTechId,
        'createdBy': r.createdBy,
        'location': r.location,
        'clientPhone': r.clientPhone,
        'clientEmail': r.clientEmail,
        'parts': [
          for (final p in r.parts)
            {'label': p.label, 'quantity': p.quantity, 'unitPrice': p.unitPrice},
        ],
        'services': [
          for (final s in r.services) {'label': s.label, 'price': s.price},
        ],
        'discount': r.discount,
        'taxRate': r.taxRate,
        'deposit': r.deposit,
        'paymentStatus': r.paymentStatus.name,
        'warrantyMonths': r.warrantyMonths,
        'photos': r.photos,
        'createdAt': r.createdAt?.toIso8601String(),
        'dueAt': r.dueAt?.toIso8601String(),
        'completedAt': r.completedAt?.toIso8601String(),
        'events': [
          for (final e in r.events)
            {
              'at': e.at.toIso8601String(),
              'type': e.type.name,
              'detail': e.detail,
              'label': e.label,
            },
        ],
        'observations': r.observations,
        'note': r.note,
      };

  @override
  Repair fromJson(Map<String, Object?> j) => Repair(
        reference: j['reference'] as String,
        device: j['device'] as String? ?? '',
        kind: _enum(DeviceKind.values, j['kind'], DeviceKind.other),
        client: j['client'] as String? ?? '',
        clientId: j['clientId'] as String?,
        status: _enum(RepairStatus.values, j['status'], RepairStatus.inProgress),
        priority: _enum(RepairPriority.values, j['priority'], RepairPriority.normal),
        progress: _d(j['progress']) ?? 0,
        updatedLabel: j['updatedLabel'] as String? ?? '',
        hoursAgo: _i(j['hoursAgo']) ?? 0,
        reportedIssue: j['reportedIssue'] as String?,
        diagnosis: j['diagnosis'] as String?,
        workDone: j['workDone'] as String?,
        brand: j['brand'] as String?,
        model: j['model'] as String?,
        serial: j['serial'] as String?,
        color: j['color'] as String?,
        storage: j['storage'] as String?,
        accessories: _strList(j['accessories']),
        intakeCondition: j['intakeCondition'] as String?,
        passcode: j['passcode'] as String?,
        backupConsent: (j['backupConsent'] as bool?) ?? false,
        assignedTech: j['assignedTech'] as String?,
        assignedTechId: j['assignedTechId'] as String?,
        createdBy: j['createdBy'] as String?,
        location: j['location'] as String?,
        clientPhone: j['clientPhone'] as String?,
        clientEmail: j['clientEmail'] as String?,
        parts: [
          for (final p in (j['parts'] as List? ?? const []))
            RepairPart(
              label: (p as Map)['label'].toString(),
              quantity: _i(p['quantity']) ?? 1,
              unitPrice: _d(p['unitPrice']) ?? 0,
            ),
        ],
        services: [
          for (final s in (j['services'] as List? ?? const []))
            RepairService((s as Map)['label'].toString(), _d(s['price']) ?? 0),
        ],
        discount: _d(j['discount']) ?? 0,
        taxRate: _d(j['taxRate']) ?? 0.20,
        deposit: _d(j['deposit']) ?? 0,
        paymentStatus:
            _enum(PaymentStatus.values, j['paymentStatus'], PaymentStatus.unpaid),
        warrantyMonths: _i(j['warrantyMonths']),
        photos: _strList(j['photos']),
        createdAt: _dt(j['createdAt']),
        dueAt: _dt(j['dueAt']),
        completedAt: _dt(j['completedAt']),
        events: [
          for (final e in (j['events'] as List? ?? const []))
            RepairEvent(
              at: _dt((e as Map)['at']) ?? DateTime.now(),
              type: _enum(RepairEventType.values, e['type'],
                  RepairEventType.note),
              detail: e['detail'] as String?,
              label: e['label'] as String?,
            ),
        ],
        observations: j['observations'] as String?,
        note: j['note'] as String?,
      );

  // --- Helpers de conversion (robustes au round-trip JSON) ---
  static T _enum<T extends Enum>(List<T> values, Object? name, T fallback) =>
      values.firstWhere((e) => e.name == name, orElse: () => fallback);
  static double? _d(Object? v) => v == null ? null : (v as num).toDouble();
  static int? _i(Object? v) => v == null ? null : (v as num).toInt();
  static DateTime? _dt(Object? v) =>
      v == null ? null : DateTime.tryParse(v as String);
  static List<String> _strList(Object? v) =>
      [for (final x in (v as List? ?? const [])) x.toString()];
}
