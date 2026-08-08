// Gestion des sélections intelligentes (G3) : rendu + création avec règle prix.

import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/data/storage.dart';
import 'package:atelier_reparation/core/settings/settings_controller.dart';
import 'package:atelier_reparation/core/settings/settings_repository.dart';
import 'package:atelier_reparation/features/catalog/application/smart_views_controller.dart';
import 'package:atelier_reparation/features/catalog/presentation/smart_views_screen.dart';
import 'package:atelier_reparation/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _pump(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({'settings.locale': 'fr'});
  final prefs = await SharedPreferences.getInstance();
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(600, 2200);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer(overrides: [
    localStoreProvider.overrideWithValue(InMemoryStore()),
    settingsRepositoryProvider.overrideWithValue(SettingsRepository(prefs)),
  ]);
  addTearDown(container.dispose);

  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(
      locale: Locale('fr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Material(child: SmartViewsScreen()),
    ),
  ));
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('rend les sélections semées', (tester) async {
    await _pump(tester);
    expect(find.text('En rupture'), findsOneWidget);
    expect(find.text('Petit prix'), findsOneWidget);
    expect(find.text('Stock bas'), findsOneWidget);
  });

  testWidgets('crée une sélection avec règle prix max', (tester) async {
    final container = await _pump(tester);
    final before = container.read(smartViewsProvider).length;

    await tester.tap(find.byTooltip('Nouvelle sélection'));
    await tester.pumpAndSettle();
    // Champs du formulaire : nom(0), prix min(1), prix max(2), marque(3).
    await tester.enterText(find.byType(TextField).at(0), 'Chers');
    await tester.enterText(find.byType(TextField).at(2), '50');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Enregistrer'));
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    final views = container.read(smartViewsProvider);
    expect(views.length, before + 1);
    expect(views.firstWhere((v) => v.name == 'Chers').rule.priceMax, 50);
  });
}
