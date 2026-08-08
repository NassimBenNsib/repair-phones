// Catalogue d'intégrations : rendu des fournisseurs, filtre par catégorie, et
// configuration d'un fournisseur (enregistre la config → statut « Actif »).

import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/data/storage.dart';
import 'package:atelier_reparation/core/settings/settings_controller.dart';
import 'package:atelier_reparation/core/settings/settings_repository.dart';
import 'package:atelier_reparation/features/integrations/application/integrations_controller.dart';
import 'package:atelier_reparation/features/integrations/domain/integration.dart';
import 'package:atelier_reparation/features/integrations/presentation/integrations_screen.dart';
import 'package:atelier_reparation/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _pump(WidgetTester tester,
    {Size size = const Size(500, 900)}) async {
  SharedPreferences.setMockInitialValues({'settings.locale': 'fr'});
  final prefs = await SharedPreferences.getInstance();
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(ProviderScope(
    overrides: [
      localStoreProvider.overrideWithValue(InMemoryStore()),
      settingsRepositoryProvider.overrideWithValue(SettingsRepository(prefs)),
    ],
    child: MaterialApp(
      locale: const Locale('fr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Material(child: IntegrationsScreen()),
    ),
  ));
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(
      tester.element(find.byType(IntegrationsScreen)));
}

void main() {
  testWidgets('affiche le catalogue et filtre par catégorie', (tester) async {
    await _pump(tester);
    expect(find.text('Flouci'), findsOneWidget);
    expect(find.text('Stripe'), findsOneWidget);
    expect(find.text('WhatsApp Business'), findsOneWidget);

    // Filtre « Messagerie » (la puce, pas l'en-tête) → masque les paiements.
    await tester.tap(find.text('Messagerie').first);
    await tester.pumpAndSettle();
    expect(find.text('WhatsApp Business'), findsOneWidget);
    expect(find.text('Flouci'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('configurer Stripe → statut Actif', (tester) async {
    final container = await _pump(tester);

    await tester.tap(find.text('Stripe'));
    await tester.pumpAndSettle();

    // Renseigne la clé secrète et active.
    await tester.enterText(find.byType(TextField).last, 'sk_test_123');
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    final stripe = container
        .read(integrationsProvider)
        .firstWhere((i) => i.kind == IntegrationKind.stripe);
    expect(stripe.enabled, isTrue);
    expect(stripe.config['secretKey'], 'sk_test_123');
    expect(stripe.status, IntegrationStatus.active);
    expect(find.text('Actif'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rendu sans débordement en 1200px', (tester) async {
    await _pump(tester, size: const Size(1200, 900));
    expect(find.text('Konnect'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
