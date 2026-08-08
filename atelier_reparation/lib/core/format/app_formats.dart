import 'package:intl/intl.dart';

/// Devise configurable (code ISO + symbole affiché en suffixe).
class CurrencyOption {
  const CurrencyOption(this.code, this.symbol);
  final String code;
  final String symbol;
}

/// Devises proposées (le montant n'est pas converti : seul le symbole change).
const List<CurrencyOption> kCurrencies = [
  CurrencyOption('EUR', '€'),
  CurrencyOption('TND', 'DT'),
  CurrencyOption('MAD', 'DH'),
  CurrencyOption('DZD', 'DA'),
  CurrencyOption('USD', r'$'),
  CurrencyOption('GBP', '£'),
  CurrencyOption('CHF', 'CHF'),
  CurrencyOption('CAD', r'C$'),
  CurrencyOption('SAR', 'SAR'),
  CurrencyOption('AED', 'AED'),
];

CurrencyOption currencyByCode(String? code) => kCurrencies.firstWhere(
      (c) => c.code == code,
      orElse: () => kCurrencies.first,
    );

/// Format de date configurable.
enum AppDateFormat { dmy, mdy, ymd }

extension AppDateFormatX on AppDateFormat {
  String get pattern => switch (this) {
        AppDateFormat.dmy => 'dd/MM/yyyy',
        AppDateFormat.mdy => 'MM/dd/yyyy',
        AppDateFormat.ymd => 'yyyy-MM-dd',
      };

  String get sample => switch (this) {
        AppDateFormat.dmy => '31/12/2026',
        AppDateFormat.mdy => '12/31/2026',
        AppDateFormat.ymd => '2026-12-31',
      };
}

/// Formats régionaux globaux (devise + date), mis à jour par les réglages.
///
/// Volontairement statique : accessible partout (widgets, PDF, assistant) sans
/// injecter `ref`. Le contrôleur des réglages met ces valeurs à jour.
class AppFormats {
  AppFormats._();

  static CurrencyOption currency = kCurrencies.first;
  static AppDateFormat dateStyle = AppDateFormat.dmy;

  /// Langue pour le groupement des milliers / séparateur décimal.
  static String localeName = 'fr';

  /// Locale numérique effective : l'arabe utilise des chiffres latins
  /// (groupement à la française) pour rester lisible en atelier.
  static String get _numLocale => localeName == 'ar' ? 'fr' : localeName;

  /// Symbole de la devise active (suffixe, ex. « € »).
  static String get symbol => currency.symbol;

  /// Nombre groupé selon la locale (« 1 200 » / « 1,200 »).
  static String number(num v, {int decimals = 0}) =>
      (NumberFormat.decimalPattern(_numLocale)
            ..minimumFractionDigits = decimals
            ..maximumFractionDigits = decimals)
          .format(v);

  /// Montant formaté et groupé : « 1 200 € ».
  static String money(num v, {int decimals = 0}) =>
      '${number(v, decimals: decimals)} ${currency.symbol}';

  /// Formateur de date selon le style choisi.
  static DateFormat get dateFormat => DateFormat(dateStyle.pattern);

  static String date(DateTime d) => dateFormat.format(d);
}
