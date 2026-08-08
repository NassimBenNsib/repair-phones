import 'dart:typed_data';

import 'package:atelier_reparation/core/format/app_formats.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../features/orders/domain/purchase_order.dart';
import '../../features/suppliers/application/supplier_statement.dart';
import 'pdf_theme.dart';

/// Libellés localisés du relevé fournisseur.
typedef SupplierStatementLabels = ({
  String title,
  String date,
  String number,
  String status,
  String amount,
  String purchased,
  String onOrder,
  String overdue,
  String paid,
  String payable,
  String bucketNotDue,
  String bucket1to30,
  String bucket31to60,
  String bucket60plus,
});

/// Construit puis imprime/partage un relevé fournisseur : liste des commandes
/// (date, n°, statut, montant TTC) + synthèse achats reçus / en commande /
/// vieillissement. Réutilise le thème partagé (Amiri, RTL, logo).
Future<void> printSupplierStatement({
  required String appName,
  required String partyName,
  required String dateLabel,
  required SupplierStatement statement,
  required SupplierStatementLabels labels,
  required String Function(PoStatus) statusLabel,
  List<String> sellerDetails = const [],
  Uint8List? logo,
  bool rtl = false,
}) async {
  final theme = await loadDocumentTheme();
  final doc = pw.Document(theme: theme);
  final logoImage = logo != null ? pw.MemoryImage(logo) : null;
  final df = AppFormats.dateFormat;
  String money(double v) => AppFormats.money(v, decimals: 2);

  String bucketLabel(PoAgeBucket b) => switch (b) {
        PoAgeBucket.notDue => labels.bucketNotDue,
        PoAgeBucket.d1to30 => labels.bucket1to30,
        PoAgeBucket.d31to60 => labels.bucket31to60,
        PoAgeBucket.d60plus => labels.bucket60plus,
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
            2: pw.Alignment.centerLeft,
            3: pw.Alignment.centerRight,
          },
          headers: [
            labels.date,
            labels.number,
            labels.status,
            labels.amount,
          ],
          data: [
            for (final o in statement.orders)
              [
                df.format(o.date),
                o.number,
                statusLabel(o.status),
                money(o.totals.total),
              ],
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.SizedBox(
            width: 260,
            child: pw.Column(children: [
              _line(labels.purchased, money(statement.purchasedTtc),
                  bold: true),
              _line(labels.paid, money(statement.paidTtc)),
              if (statement.payableTtc > 0.005)
                _line(labels.payable, money(statement.payableTtc), bold: true),
              for (final b in PoAgeBucket.values)
                if ((statement.payableAging[b] ?? 0) > 0.005)
                  _line('  ${bucketLabel(b)}',
                      money(statement.payableAging[b]!)),
              pw.SizedBox(height: 4),
              _line(labels.onOrder, money(statement.onOrderTtc)),
              if (statement.overdueTtc > 0.005)
                _line(labels.overdue, money(statement.overdueTtc)),
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
