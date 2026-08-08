// Réparations : création (add) — référence séquentielle, valeurs par défaut,
// persistance ; et ouverture de la fiche d'admission depuis l'écran.

import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/data/storage.dart';
import 'package:atelier_reparation/core/settings/settings_controller.dart';
import 'package:atelier_reparation/core/settings/settings_repository.dart';
import 'package:atelier_reparation/features/notifications/application/notification_log_controller.dart';
import 'package:atelier_reparation/features/notifications/domain/message_template.dart';
import 'package:atelier_reparation/features/notifications/domain/notification_log.dart';
import 'package:atelier_reparation/features/repairs/application/repairs_controller.dart';
import 'package:atelier_reparation/features/repairs/domain/repair.dart';
import 'package:atelier_reparation/features/repairs/presentation/repair_detail.dart';
import 'package:atelier_reparation/features/repairs/presentation/repairs_screen.dart';
import 'package:atelier_reparation/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('add() : référence séquentielle, défauts, événement d\'ouverture', () {
    final container = ProviderContainer(overrides: [
      localStoreProvider.overrideWithValue(InMemoryStore()),
    ]);
    addTearDown(container.dispose);
    final ctrl = container.read(repairsProvider.notifier);
    final before = container.read(repairsProvider).length;

    final r = ctrl.add(
      device: 'iPhone 13 — écran',
      kind: DeviceKind.phone,
      clientId: 'c1',
      client: 'Alice Martin',
      clientPhone: '0600000000',
      reportedIssue: 'Écran cassé',
      deposit: 30,
      openingEventLabel: 'Fiche créée',
      now: DateTime(2026, 1, 5),
    );

    expect(r.reference, '#R-2026-0001');
    expect(r.status, RepairStatus.received); // nouveau flux : démarre « Reçue »
    expect(r.progress, 0);
    expect(r.clientId, 'c1');
    expect(r.client, 'Alice Martin');
    expect(r.reportedIssue, 'Écran cassé');
    expect(r.deposit, 30);
    expect(r.createdAt, DateTime(2026, 1, 5));
    expect(r.events.single.label, 'Fiche créée');
    // Ajoutée en tête et récupérable par référence.
    expect(container.read(repairsProvider).length, before + 1);
    expect(container.read(repairsProvider).first.reference, '#R-2026-0001');
    expect(ctrl.byRef('#R-2026-0001'), isNotNull);
  });

  test('setStatus : ajoute un événement, horodate la fin, calcule la garantie',
      () {
    final container = ProviderContainer(overrides: [
      localStoreProvider.overrideWithValue(InMemoryStore()),
    ]);
    addTearDown(container.dispose);
    final ctrl = container.read(repairsProvider.notifier);
    final r = ctrl.add(
        device: 'iPhone',
        clientId: 'c1',
        now: DateTime(2026, 1, 10),
        openingEventLabel: 'Fiche créée');
    final before = r.events.length; // 1 (création)

    ctrl.setStatus(r.reference, RepairStatus.inProgress,
        now: DateTime(2026, 1, 11));
    ctrl.setStatus(r.reference, RepairStatus.completed,
        now: DateTime(2026, 1, 12));

    final done = ctrl.byRef(r.reference)!;
    expect(done.status, RepairStatus.completed);
    expect(done.events.length, before + 2); // 2 changements horodatés
    expect(done.events.last.type, RepairEventType.status);
    expect(done.events.last.detail, 'completed');
    // completedAt fixé à la 1re fin → garantie calculable.
    expect(done.completedAt, DateTime(2026, 1, 12));

    // Garantie 6 mois depuis la fin.
    final warr = done.copyWith(warrantyMonths: 6);
    expect(warr.warrantyUntil, DateTime(2026, 7, 12));

    // No-op si statut inchangé (pas d'événement en double).
    ctrl.setStatus(done.reference, RepairStatus.completed);
    expect(ctrl.byRef(done.reference)!.events.length, before + 2);
  });

  test('add() : références uniques et incrémentées', () {
    final container = ProviderContainer(overrides: [
      localStoreProvider.overrideWithValue(InMemoryStore()),
    ]);
    addTearDown(container.dispose);
    final ctrl = container.read(repairsProvider.notifier);

    final a = ctrl.add(device: 'A', clientId: 'c1', now: DateTime(2026, 3, 1));
    final b = ctrl.add(device: 'B', clientId: 'c2', now: DateTime(2026, 6, 1));
    expect(a.reference, '#R-2026-0001');
    expect(b.reference, '#R-2026-0002');
    expect(a.reference == b.reference, isFalse);
  });

  test('add() : persiste dans le magasin (survit à un nouveau contrôleur)', () {
    final store = InMemoryStore();
    final c1 = ProviderContainer(
        overrides: [localStoreProvider.overrideWithValue(store)]);
    c1.read(repairsProvider.notifier).add(
        device: 'iPad', clientId: 'c9', now: DateTime(2026, 2, 2));
    c1.dispose();

    // Nouveau conteneur, même magasin → la réparation est rechargée.
    final c2 = ProviderContainer(
        overrides: [localStoreProvider.overrideWithValue(store)]);
    addTearDown(c2.dispose);
    expect(c2.read(repairsProvider.notifier).byRef('#R-2026-0001'), isNotNull);
  });

  testWidgets('détail : « Faire avancer » progresse le statut', (tester) async {
    SharedPreferences.setMockInitialValues({'settings.locale': 'fr'});
    final prefs = await SharedPreferences.getInstance();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(500, 1600);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(overrides: [
      localStoreProvider.overrideWithValue(InMemoryStore()),
      settingsRepositoryProvider.overrideWithValue(SettingsRepository(prefs)),
    ]);
    addTearDown(container.dispose);
    final r = container
        .read(repairsProvider.notifier)
        .add(device: 'iPhone', clientId: 'c1'); // statut « Reçue »

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RepairDetailScreen(reference: r.reference),
      ),
    ));
    await tester.pumpAndSettle();

    // Reçue → (avancer) → Diagnostic.
    await tester.tap(find.textContaining('Faire avancer'));
    await tester.pumpAndSettle();
    final done = container.read(repairsProvider.notifier).byRef(r.reference)!;
    expect(done.status, RepairStatus.diagnosing);
    expect(done.events.last.type, RepairEventType.status);
  });

  testWidgets('détail : badge « Sous garantie » après réparation terminée',
      (tester) async {
    SharedPreferences.setMockInitialValues({'settings.locale': 'fr'});
    final prefs = await SharedPreferences.getInstance();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(500, 1600);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(overrides: [
      localStoreProvider.overrideWithValue(InMemoryStore()),
      settingsRepositoryProvider.overrideWithValue(SettingsRepository(prefs)),
    ]);
    addTearDown(container.dispose);
    final ctrl = container.read(repairsProvider.notifier);
    final r = ctrl.add(device: 'iPhone', clientId: 'c1');
    ctrl.update(ctrl.byRef(r.reference)!.copyWith(warrantyMonths: 6));
    ctrl.setStatus(r.reference, RepairStatus.completed); // completedAt = now

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RepairDetailScreen(reference: r.reference),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Sous garantie'), findsOneWidget);
  });

  testWidgets('détail : la section Communications liste les messages envoyés',
      (tester) async {
    SharedPreferences.setMockInitialValues({'settings.locale': 'fr'});
    final prefs = await SharedPreferences.getInstance();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(500, 2000);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(overrides: [
      localStoreProvider.overrideWithValue(InMemoryStore()),
      settingsRepositoryProvider.overrideWithValue(SettingsRepository(prefs)),
    ]);
    addTearDown(container.dispose);
    final r = container
        .read(repairsProvider.notifier)
        .add(device: 'iPhone', clientId: 'c1', clientPhone: '0600');
    container.read(notificationLogProvider.notifier).add(NotificationLogEntry(
          id: 'n1',
          at: DateTime(2026, 2, 2, 10),
          channel: MessageChannel.sms,
          to: '0600',
          body: 'Votre appareil est prêt',
          repairRef: r.reference,
        ));

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RepairDetailScreen(reference: r.reference),
      ),
    ));
    await tester.pumpAndSettle();

    // La section est en bas de la fiche (ListView paresseux) → on défile.
    await tester.scrollUntilVisible(
        find.textContaining('appareil est prêt'), 300,
        scrollable: find.byType(Scrollable).first);
    expect(find.textContaining('appareil est prêt'), findsOneWidget);
  });

  testWidgets('le « ＋ » ouvre la fiche d\'admission', (tester) async {
    SharedPreferences.setMockInitialValues({'settings.locale': 'fr'});
    final prefs = await SharedPreferences.getInstance();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(420, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        localStoreProvider.overrideWithValue(InMemoryStore()),
        settingsRepositoryProvider.overrideWithValue(SettingsRepository(prefs)),
      ],
      child: const MaterialApp(
        locale: Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Material(child: RepairsScreen()),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Nouvelle réparation'));
    await tester.pumpAndSettle();

    // La feuille est ouverte : titre + champ appareil + client à choisir.
    expect(find.text('Nouvelle réparation'), findsOneWidget);
    expect(find.text('Appareil'), findsWidgets);
    expect(find.text('Sélectionner un client'), findsOneWidget);
  });
}
