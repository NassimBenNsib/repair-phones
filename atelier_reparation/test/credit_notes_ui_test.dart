// Écran Avoirs (CN2) : la liste affiche un avoir, l'ouvre, l'émet (numéro
// légal) et affiche l'état émis.

import 'package:atelier_reparation/core/data/local_store.dart';
import 'package:atelier_reparation/core/data/storage.dart';
import 'package:atelier_reparation/core/domain/line_item.dart';
import 'package:atelier_reparation/core/settings/settings_controller.dart';
import 'package:atelier_reparation/core/settings/settings_repository.dart';
import 'package:atelier_reparation/features/invoices/application/credit_notes_controller.dart';
import 'package:atelier_reparation/features/invoices/presentation/credit_notes_screen.dart';
import 'package:atelier_reparation/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('liste des avoirs : ouvrir puis émettre assigne un numéro',
      (tester) async {
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

    // Un avoir brouillon issu d'une facture.
    final cn = container.read(creditNotesProvider.notifier).createFrom(
      clientId: 'c1',
      clientName: 'Jean Dupont',
      invoiceId: 'i1',
      lines: [const LineItem(id: 'l', label: 'Retour écran', qty: 1, unitPrice: 50)],
      reason: 'Retour',
    );

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        locale: Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Material(child: CreditNotesScreen()),
      ),
    ));
    await tester.pumpAndSettle();

    // La liste montre le client et l'état brouillon.
    expect(find.text('Jean Dupont'), findsOneWidget);

    // Ouvrir le détail.
    await tester.tap(find.text('Jean Dupont'));
    await tester.pumpAndSettle();

    // Émettre.
    await tester.ensureVisible(find.text("Émettre l'avoir"));
    await tester.tap(find.text("Émettre l'avoir"));
    await tester.pumpAndSettle();

    final issued = container.read(creditNotesProvider.notifier).byId(cn.id)!;
    expect(issued.isIssued, isTrue);
    expect(issued.number, startsWith('AVOIR-'));
    // Le numéro est affiché dans le détail.
    expect(find.text(issued.number), findsWidgets);
  });
}
