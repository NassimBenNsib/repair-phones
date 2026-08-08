// Écran Catégories : rendu de l'arbre semé + création d'une catégorie.

import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/data/storage.dart';
import 'package:atelier_reparation/core/settings/settings_controller.dart';
import 'package:atelier_reparation/core/settings/settings_repository.dart';
import 'package:atelier_reparation/features/prestations/application/categories_controller.dart';
import 'package:atelier_reparation/features/prestations/presentation/categories_screen.dart';
import 'package:atelier_reparation/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('rendu de l\'arbre + création d\'une catégorie', (tester) async {
    SharedPreferences.setMockInitialValues({'settings.locale': 'fr'});
    final prefs = await SharedPreferences.getInstance();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(600, 1200);
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
        home: Material(child: CategoriesScreen()),
      ),
    ));
    await tester.pumpAndSettle();

    final container =
        ProviderScope.containerOf(tester.element(find.byType(CategoriesScreen)));
    expect(find.text('Écran'), findsWidgets); // catégorie semée
    final before = container.read(categoriesProvider).length;

    // Nouvelle catégorie via le « + » de la barre (par info-bulle).
    await tester.tap(find.byTooltip('Nouvelle catégorie'));
    await tester.pumpAndSettle();
    // .at(1) : le champ recherche de l'écran est .first, le nom du formulaire suit.
    await tester.enterText(find.byType(TextField).at(1), 'Vitres');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    final cats = container.read(categoriesProvider);
    expect(cats.length, before + 1);
    expect(cats.any((c) => c.name == 'Vitres' && c.parentId == null), isTrue);
    expect(tester.takeException(), isNull);
  });
}
