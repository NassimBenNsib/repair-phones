import 'dart:typed_data';

import 'package:atelier_reparation/core/format/app_formats.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../features/clients/application/client_statement.dart';
import 'pdf_theme.dart';

/// Libellés localisés du relevé de compte.
typedef StatementLabels = ({
  String title,
  String date,
  String detail,
  String debit,
  String credit,
  String balance,
  String opening,
  String closing,
  String invoice, // "Facture {ref}"
  String deposit, // "Acompte"
  String payment, // "Règlement"
});

/// Construit puis imprime/partage un relevé de compte client (débit / crédit /
/// solde courant). Réutilise le thème partagé des documents (police Amiri, RTL).
Future<void> printStatementDocument({
  required String appName,
  required String partyName,
  required String dateLabel,
  required ClientStatement statement,
  required StatementLabels labels,
  List<String> sellerDetails = const [],
  Uint8List? logo,
  bool rtl = false,
}) async {
  final theme = await loadDocumentTheme();
  final doc = pw.Document(theme: theme);
  final logoImage = logo != null ? pw.MemoryImage(logo) : null;
  final df = AppFormats.dateFormat;
  String money(double v) => AppFormats.money(v, decimals: 2);

  String rowLabel(StatementLine line) => switch (line.type) {
        StatementEntryType.invoice => '${labels.invoice} ${line.reference}',
        StatementEntryType.deposit =>
          '${labels.deposit} · ${line.reference}',
        StatementEntryType.payment =>
          '${labels.payment} · ${line.reference}',
      };

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      textDirection: rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (logoImage != null) ...[
                  pw.Image(logoImage, height: 48, width: 48,
                      fit: pw.BoxFit.contain),
                  pw.SizedBox(width: 12),
                ],
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(appName,
                        style: pw.TextStyle(
                            fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    for (final line in sellerDetails)
                      pw.Text(line,
                          style: const pw.TextStyle(
                              fontSize: 9, color: PdfColors.grey700)),
                  ],
                ),
              ],
            ),
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
              pw.Text(labels.title,
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Text(dateLabel),
            ]),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Text(partyName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 12),
        pw.TableHelper.fromTextArray(
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.centerLeft,
            2: pw.Alignment.centerRight,
            3: pw.Alignment.centerRight,
            4: pw.Alignment.centerRight,
          },
          headers: [
            labels.date,
            labels.detail,
            labels.debit,
            labels.credit,
            labels.balance,
          ],
          data: [
            if (statement.from != null)
              ['', labels.opening, '', '', money(statement.openingBalance)],
            for (final line in statement.lines)
              [
                df.format(line.date),
                rowLabel(line),
                line.debit > 0 ? money(line.debit) : '',
                line.credit > 0 ? money(line.credit) : '',
                money(line.balance),
              ],
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.SizedBox(
            width: 240,
            child: pw.Column(children: [
              _line(labels.debit, money(statement.totalDebit)),
              _line(labels.credit, money(statement.totalCredit)),
              pw.Divider(),
              _line(labels.closing, money(statement.closingBalance), bold: true),
            ]),
          ),
        ),
      ],
    ),
  );

  await Printing.layoutPdf(onLayout: (format) => doc.save());
}

pw.Widget _line(String label, String value, {bool bold = false}) {
  final style = bold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null;
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [pw.Text(label, style: style), pw.Text(value, style: style)],
    ),
  );
}
