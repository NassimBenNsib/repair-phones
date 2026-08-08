// Réglages régionaux : la devise et le format de date pilotent AppFormats.

import 'package:atelier_reparation/core/format/app_formats.dart';
import 'package:atelier_reparation/core/settings/settings_controller.dart';
import 'package:atelier_reparation/core/settings/settings_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  tearDown(() {
    // Réinitialise l'état global pour ne pas polluer les autres tests.
    AppFormats.currency = kCurrencies.first;
    AppFormats.dateStyle = AppDateFormat.dmy;
    AppFormats.localeName = 'fr';
  });

  test('money() groupe les milliers et suit le symbole ; date() suit le format',
      () {
    // Locale « en » → séparateurs déterministes (virgule milliers, point décimal).
    AppFormats.localeName = 'en';
    AppFormats.currency = currencyByCode('TND');
    expect(AppFormats.money(1200), '1,200 DT');
    expect(AppFormats.money(99.5, decimals: 2), '99.50 DT');
    expect(AppFormats.number(1234567), '1,234,567');

    AppFormats.dateStyle = AppDateFormat.ymd;
    expect(AppFormats.date(DateTime(2026, 12, 31)), '2026-12-31');
  });

  test('le contrôleur des réglages met AppFormats à jour et persiste',
      () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(overrides: [
      settingsRepositoryProvider.overrideWithValue(SettingsRepository(prefs)),
    ]);
    addTearDown(container.dispose);

    // build() par défaut → EUR.
    expect(container.read(settingsControllerProvider).currency, 'EUR');
    expect(AppFormats.symbol, '€');

    container.read(settingsControllerProvider.notifier).setCurrency('MAD');
    expect(AppFormats.symbol, 'DH');
    expect(prefs.getString('settings.currency'), 'MAD');

    container
        .read(settingsControllerProvider.notifier)
        .setDateFormat(AppDateFormat.mdy);
    expect(AppFormats.dateStyle, AppDateFormat.mdy);
    expect(prefs.getString('settings.dateFormat'), 'mdy');
  });
}
