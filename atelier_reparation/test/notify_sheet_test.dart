// Notifier le client (N2) : la feuille pré-remplit un message et « Envoyer »
// enregistre une entrée au journal de communication.

import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/data/storage.dart';
import 'package:atelier_reparation/core/settings/settings_controller.dart';
import 'package:atelier_reparation/core/settings/settings_repository.dart';
import 'package:atelier_reparation/features/notifications/application/notification_log_controller.dart';
import 'package:atelier_reparation/features/notifications/presentation/notify_sheet.dart';
import 'package:atelier_reparation/features/repairs/application/repairs_controller.dart';
import 'package:atelier_reparation/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('« Envoyer » journalise une communication', (tester) async {
    SharedPreferences.setMockInitialValues({'settings.locale': 'fr'});
    final prefs = await SharedPreferences.getInstance();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(600, 1800);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(overrides: [
      localStoreProvider.overrideWithValue(InMemoryStore()),
      settingsRepositoryProvider.overrideWithValue(SettingsRepository(prefs)),
    ]);
    addTearDown(container.dispose);
    final r = container.read(repairsProvider.notifier).add(
        device: 'iPhone', clientId: 'c1', clientPhone: '0600000000');

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (ctx) => Center(
              child: ElevatedButton(
                onPressed: () => showNotifySheet(ctx, r),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    // La feuille est ouverte : le champ message est pré-rempli.
    expect(find.text('Envoyer'), findsOneWidget);

    await tester.ensureVisible(find.text('Envoyer'));
    await tester.tap(find.text('Envoyer'));
    await tester.pumpAndSettle();

    // Une communication a été journalisée pour cette réparation (l'ouverture de
    // l'appli externe échoue silencieusement en test, mais l'intention est tracée).
    final log = container.read(notificationLogProvider.notifier);
    expect(log.forRepair(r.reference).length, 1);
    expect(log.forRepair(r.reference).single.to, '0600000000');
  });
}
