import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/local_store.dart';
import '../../../core/data/storage.dart';
import '../../../core/domain/numbering.dart';
import '../data/repair_mapper.dart';
import '../domain/repair.dart';

final repairStoreProvider = Provider<CollectionStore<Repair>>(
  (ref) => CollectionStore<Repair>(ref.watch(localStoreProvider), RepairMapper()),
);

/// Réparations, adossées au stockage local (SQLite / mémoire).
///
/// Reste un `Notifier<List<Repair>>` synchrone (stockage local synchrone) →
/// l'UI ne change pas.
class RepairsController extends Notifier<List<Repair>> {
  CollectionStore<Repair> get _store => ref.read(repairStoreProvider);

  @override
  List<Repair> build() {
    _store.seedIfEmpty(sampleRepairs);
    return _store.loadAll();
  }

  Repair? byRef(String reference) {
    for (final r in state) {
      if (r.reference == reference) return r;
    }
    return null;
  }

  /// Référence unique, séquentielle et sans trou : `#R-2026-0001`.
  ///
  /// S'appuie sur le même service de numérotation que factures/devis (prefixe
  /// `R`) ; le `#` garde la cohérence visuelle avec l'historique (`#R-2048`).
  String _nextReference(int year) => '#${ref.read(numberingProvider).next('R', year)}';

  /// Crée une réparation à partir d'une fiche d'admission et l'ajoute en tête.
  ///
  /// Renvoie la réparation créée (avec sa référence générée) pour que l'appelant
  /// puisse ouvrir le détail dans la foulée.
  Repair add({
    required String device,
    DeviceKind kind = DeviceKind.phone,
    String? clientId,
    String? client,
    String? clientPhone,
    String? clientEmail,
    String? reportedIssue,
    RepairPriority priority = RepairPriority.normal,
    double deposit = 0,
    double taxRate = 0.20,
    DateTime? dueAt,
    String? openingEventLabel,
    DateTime? now,
  }) {
    final ts = now ?? DateTime.now();
    String? clean(String? v) => (v == null || v.trim().isEmpty) ? null : v.trim();
    final repair = Repair(
      reference: _nextReference(ts.year),
      device: device.trim(),
      kind: kind,
      client: client?.trim() ?? '',
      clientId: clientId,
      status: RepairStatus.received,
      priority: priority,
      progress: 0,
      updatedLabel: '',
      hoursAgo: 0,
      reportedIssue: clean(reportedIssue),
      clientPhone: clean(clientPhone),
      clientEmail: clean(clientEmail),
      deposit: deposit,
      taxRate: taxRate,
      createdAt: ts,
      dueAt: dueAt,
      events: [
        RepairEvent(
            at: ts, type: RepairEventType.created, label: openingEventLabel),
      ],
    );
    _store.upsert(repair);
    state = [repair, ...state];
    return repair;
  }

  /// Remplace la réparation portant la même référence.
  void update(Repair updated) {
    _store.upsert(updated);
    state = [
      for (final r in state)
        if (r.reference == updated.reference) updated else r,
    ];
  }

  /// Ajoute un événement horodaté au suivi d'une réparation.
  Repair _withEvent(Repair r, RepairEvent e) =>
      r.copyWith(events: [...r.events, e]);

  void setStatus(String reference, RepairStatus status, {DateTime? now}) {
    final r = byRef(reference);
    if (r == null || r.status == status) return;
    final ts = now ?? DateTime.now();
    // Horodate la 1re fin de réparation (pour la garantie). `null` = préserve.
    final completedAt = status.isDone && r.completedAt == null ? ts : null;
    final updated = _withEvent(
        r.copyWith(status: status, completedAt: completedAt),
        RepairEvent(at: ts, type: RepairEventType.status, detail: status.name));
    update(updated);
  }

  void setPaymentStatus(String reference, PaymentStatus payment,
      {DateTime? now}) {
    final r = byRef(reference);
    if (r == null || r.paymentStatus == payment) return;
    final updated = _withEvent(
        r.copyWith(paymentStatus: payment),
        RepairEvent(
            at: now ?? DateTime.now(),
            type: RepairEventType.payment,
            detail: payment.name));
    update(updated);
  }

  void assignTech(String reference, String? tech,
      {String? techId, DateTime? now}) {
    final r = byRef(reference);
    if (r == null) return;
    final updated = _withEvent(
        r.copyWith(assignedTech: tech, assignedTechId: techId),
        RepairEvent(
            at: now ?? DateTime.now(),
            type: RepairEventType.tech,
            detail: tech));
    update(updated);
  }

  /// Ajoute une photo (image encodée en base64) et journalise l'événement.
  void addPhoto(String reference, String base64, {DateTime? now}) {
    final r = byRef(reference);
    if (r == null || base64.isEmpty) return;
    final updated = _withEvent(
        r.copyWith(photos: [...r.photos, base64]),
        RepairEvent(at: now ?? DateTime.now(), type: RepairEventType.photo));
    update(updated);
  }

  /// Retire la photo à l'index donné (no-op hors bornes).
  void removePhoto(String reference, int index) {
    final r = byRef(reference);
    if (r == null || index < 0 || index >= r.photos.length) return;
    final photos = [...r.photos]..removeAt(index);
    update(r.copyWith(photos: photos));
  }

  void remove(String reference) {
    _store.remove(reference);
    state = [
      for (final r in state)
        if (r.reference != reference) r,
    ];
  }
}

final repairsProvider =
    NotifierProvider<RepairsController, List<Repair>>(RepairsController.new);
