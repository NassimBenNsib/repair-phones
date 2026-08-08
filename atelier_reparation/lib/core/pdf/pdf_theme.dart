import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;

/// Polices Amiri (couvrent l'arabe et le latin) chargées une seule fois.
pw.Font? _amiriRegular;
pw.Font? _amiriBold;

/// Thème PDF partagé par tous les documents : police Amiri embarquée pour
/// couvrir l'arabe (et le latin). Renvoie `null` si la police est indisponible
/// (repli sur le thème latin par défaut) — les documents restent générables.
Future<pw.ThemeData?> loadDocumentTheme() async {
  try {
    _amiriRegular ??=
        pw.Font.ttf(await rootBundle.load('assets/fonts/Amiri-Regular.ttf'));
    _amiriBold ??=
        pw.Font.ttf(await rootBundle.load('assets/fonts/Amiri-Bold.ttf'));
    return pw.ThemeData.withFont(
      base: _amiriRegular!,
      bold: _amiriBold!,
      fontFallback: [_amiriRegular!],
    );
  } catch (_) {
    return null;
  }
}
