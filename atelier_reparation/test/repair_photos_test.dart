// PH1 — photos de réparation : ajout (base64 + événement) et suppression.

import 'dart:convert';

import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/data/storage.dart';
import 'package:atelier_reparation/features/repairs/application/repairs_controller.dart';
import 'package:atelier_reparation/features/repairs/domain/repair.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ProviderContainer makeContainer() {
    final c = ProviderContainer(
        overrides: [localStoreProvider.overrideWithValue(InMemoryStore())]);
    addTearDown(c.dispose);
    return c;
  }

  test('addPhoto stocke le base64 et journalise un événement photo', () {
    final c = makeContainer();
    final ctrl = c.read(repairsProvider.notifier);
    final r = ctrl.add(device: 'iPhone 12', client: 'Client');

    final b64 = base64Encode([1, 2, 3, 4]);
    ctrl.addPhoto(r.reference, b64, now: DateTime(2026, 3, 10));

    final saved = ctrl.byRef(r.reference)!;
    expect(saved.photos, [b64]);
    expect(saved.events.last.type, RepairEventType.photo);

    // Persisté dans le stockage (rechargeable).
    final reloaded = c.read(repairStoreProvider).loadAll().firstWhere(
        (x) => x.reference == r.reference);
    expect(reloaded.photos, [b64]);
  });

  test('addPhoto ignore une chaîne vide', () {
    final c = makeContainer();
    final ctrl = c.read(repairsProvider.notifier);
    final r = ctrl.add(device: 'iPad', client: 'Client');
    ctrl.addPhoto(r.reference, '');
    expect(ctrl.byRef(r.reference)!.photos, isEmpty);
  });

  test('removePhoto retire par index et tolère les bornes', () {
    final c = makeContainer();
    final ctrl = c.read(repairsProvider.notifier);
    final r = ctrl.add(device: 'Mac', client: 'Client');
    ctrl.addPhoto(r.reference, 'a');
    ctrl.addPhoto(r.reference, 'b');

    ctrl.removePhoto(r.reference, 5); // hors bornes → no-op
    expect(ctrl.byRef(r.reference)!.photos, ['a', 'b']);

    ctrl.removePhoto(r.reference, 0);
    expect(ctrl.byRef(r.reference)!.photos, ['b']);
  });
}
