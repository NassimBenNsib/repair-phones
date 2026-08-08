// Sélecteur de prestations : n'affiche que les prestations actives et filtre
// par catégorie (intégration du catalogue géré).

import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/data/storage.dart';
import 'package:atelier_reparation/features/prestations/application/service_catalog_controller.dart';
import 'package:atelier_reparation/features/prestations/presentation/service_picker_sheet.dart';
import 'package:atelier_reparation/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('picker : actives uniquement + filtre catégorie', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(500, 1000);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    late ProviderContainer container;
    await tester.pumpWidget(ProviderScope(
      overrides: [localStoreProvider.overrideWithValue(InMemoryStore())],
      child: MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Consumer(builder: (ctx, ref, _) {
            container = ProviderScope.containerOf(ctx);
            return Center(
              child: TextButton(
                onPressed: () => showServicePickerSheet(ctx),
                child: const Text('open'),
              ),
            );
          }),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // Désactive « Remplacement batterie » (s-battery).
    container.read(serviceCatalogProvider.notifier).toggleActive('s-battery');
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Remplacement écran'), findsOneWidget); // actif
    expect(find.text('Remplacement batterie'), findsNothing); // inactif → masqué

    // Filtre catégorie « Diagnostic ».
    await tester.tap(find.text('Diagnostic').first);
    await tester.pumpAndSettle();
    expect(find.text('Diagnostic'), findsWidgets);
    expect(find.text('Remplacement écran'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
