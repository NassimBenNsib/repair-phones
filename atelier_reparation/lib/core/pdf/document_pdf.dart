import 'package:atelier_reparation/core/format/app_formats.dart';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../domain/line_item.dart';
import '../domain/totals.dart';
import 'pdf_theme.dart';

/// Libellés localisés du document (en-têtes de colonnes + totaux).
typedef PdfLabels = ({
  String designation,
  String qty,
  String unitPrice,
  String lineTotal,
  String subtotal,
  String tax,
  String total,
});

/// Construit puis imprime/partage un document commercial (devis, facture…).
///
/// La police Amiri est embarquée pour couvrir l'arabe (et le latin) ; passer
/// [rtl] pour une mise en page de droite à gauche.
Future<void> printBusinessDocument({
  required String appName,
  required String title,
  required String number,
  required String partyName,
  required String dateLabel,
  required List<LineItem> lines,
  required Totals totals,
  required PdfLabels labels,
  List<String> sellerDetails = const [],
  Uint8List? logo,
  bool rtl = false,
}) async {
  final theme = await loadDocumentTheme();
  final doc = pw.Document(theme: theme);
  final logoImage = logo != null ? pw.MemoryImage(logo) : null;

  String money(double v) => AppFormats.money(v, decimals: 2);

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      textDirection: rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
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
                pw.Text(title,
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.Text(number),
                pw.Text(dateLabel),
              ]),
            ],
          ),
          pw.SizedBox(height: 24),
          pw.Text(partyName,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration:
                const pw.BoxDecoration(color: PdfColors.grey200),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerRight,
              2: pw.Alignment.centerRight,
              3: pw.Alignment.centerRight,
            },
            headers: [
              labels.designation,
              labels.qty,
              labels.unitPrice,
              labels.lineTotal,
            ],
            data: [
              for (final line in lines)
                [
                  line.label,
                  line.qty.toStringAsFixed(0),
                  money(line.unitPrice),
                  money(line.totalHT),
                ],
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.SizedBox(
              width: 220,
              child: pw.Column(children: [
                _totalLine(labels.subtotal, money(totals.subtotal)),
                _totalLine(labels.tax, money(totals.taxAmount)),
                pw.Divider(),
                _totalLine(labels.total, money(totals.total), bold: true),
              ]),
            ),
          ),
        ],
      ),
    ),
  );

  await Printing.layoutPdf(onLayout: (format) => doc.save());
}

pw.Widget _totalLine(String label, String value, {bool bold = false}) {
  final style = bold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null;
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [pw.Text(label, style: style), pw.Text(value, style: style)],
    ),
  );
}
