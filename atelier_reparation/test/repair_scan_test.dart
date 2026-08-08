// Scanner : repli par saisie manuelle (sans caméra, comme sur Windows/Linux).
// La caméra elle-même n'est pas testable (matériel) — on couvre la navigation.

import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/data/storage.dart';
import 'package:atelier_reparation/features/repairs/application/repairs_controller.dart';
import 'package:atelier_reparation/features/repairs/presentation/repair_scan_screen.dart';
import 'package:atelier_reparation/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<String?> _pushScan(WidgetTester tester) async {
  String? popped;
  await tester.pumpWidget(ProviderScope(
    overrides: [localStoreProvider.overrideWithValue(InMemoryStore())],
    child: MaterialApp(
      locale: const Locale('fr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              popped = await Navigator.of(context).push<String>(
                MaterialPageRoute(builder: (_) => const RepairScanScreen()),
              );
            },
            child: const Text('go'),
          ),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('go'));
  await tester.pumpAndSettle();
  return popped;
}

// Force une plateforme sans caméra → seule la saisie manuelle est rendue,
// aucun contrôleur MobileScanner n'est instancié. Le drapeau doit être remis à
// zéro AVANT la fin du corps du test (vérif d'invariants de flutter_test).
void main() {
  testWidgets('sans caméra : message d\'indisponibilité + panneau manuel',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    await _pushScan(tester);
    expect(find.text('Scan par caméra indisponible sur cette plateforme'),
        findsOneWidget);
    expect(find.text('Saisir la référence'), findsOneWidget);
    // Pas de bouton « décoder une image » sans contrôleur caméra.
    expect(find.text('Décoder depuis une image'), findsNothing);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('saisie d\'une référence connue → ouvre (pop la référence)',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    final container = ProviderContainer(
        overrides: [localStoreProvider.overrideWithValue(InMemoryStore())]);
    addTearDown(container.dispose);
    // Référence issue des données d'exemple.
    final sample = container.read(repairsProvider).first.reference;

    late String? result;
    await tester.pumpWidget(ProviderScope(
      overrides: [localStoreProvider.overrideWithValue(InMemoryStore())],
      child: MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () async {
                  result = await Navigator.of(context).push<String>(
                    MaterialPageRoute(
                        builder: (_) => const RepairScanScreen()),
                  );
                },
                child: const Text('go'),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), sample);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ouvrir'));
    await tester.pumpAndSettle();

    expect(result, sample);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('référence inconnue → « introuvable », pas de navigation',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    await _pushScan(tester);
    await tester.enterText(find.byType(TextField), '#R-0000-9999');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ouvrir'));
    await tester.pumpAndSettle();
    expect(find.text('Réparation introuvable'), findsOneWidget);
    // Toujours sur l'écran de scan.
    expect(find.text('Saisir la référence'), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });
}
