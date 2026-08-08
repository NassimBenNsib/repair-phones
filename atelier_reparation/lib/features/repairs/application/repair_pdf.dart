import 'dart:convert';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/format/app_formats.dart';
import '../../../core/pdf/pdf_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../clients/domain/client.dart';
import '../../company/domain/company_profile.dart';
import '../domain/repair.dart';
import 'repair_qr_codec.dart';

/// Données encodées dans le QR d'une réparation (via le codec partagé).
String repairQrData(Repair r) => RepairQrCodec.encode(r.reference);

/// Construit la **fiche de réparation** A4 : document professionnel complet
/// (client, appareil, récit, pièces/prestations, totaux, garantie, signatures)
/// avec en-tête de l'établissement et QR de la réparation.
Future<Uint8List> buildRepairSheet({
  required Repair repair,
  Client? client,
  required CompanyProfile company,
  required AppLocalizations l,
  bool rtl = false,
}) async =>
    (await _buildRepairDoc(
      repair: repair,
      client: client,
      company: company,
      l: l,
      rtl: rtl,
    ))
        .save();

/// Construit puis ouvre le dialogue d'impression/partage de la fiche.
Future<void> printRepairSheet({
  required Repair repair,
  Client? client,
  required CompanyProfile company,
  required AppLocalizations l,
  bool rtl = false,
}) async {
  final doc = await _buildRepairDoc(
    repair: repair,
    client: client,
    company: company,
    l: l,
    rtl: rtl,
  );
  await Printing.layoutPdf(onLayout: (_) => doc.save());
}

/// Construit le **ticket** compact (rouleau 80 mm) : référence, QR proéminent
/// et l'essentiel pour récupérer l'appareil.
Future<Uint8List> buildRepairTicket({
  required Repair repair,
  Client? client,
  required CompanyProfile company,
  required AppLocalizations l,
  bool rtl = false,
}) async =>
    (await _buildTicketDoc(
      repair: repair,
      client: client,
      company: company,
      l: l,
      rtl: rtl,
    ))
        .save();

/// Construit puis ouvre le dialogue d'impression/partage du ticket.
Future<void> printRepairTicket({
  required Repair repair,
  Client? client,
  required CompanyProfile company,
  required AppLocalizations l,
  bool rtl = false,
}) async {
  final doc = await _buildTicketDoc(
    repair: repair,
    client: client,
    company: company,
    l: l,
    rtl: rtl,
  );
  await Printing.layoutPdf(onLayout: (_) => doc.save());
}

Future<pw.Document> _buildTicketDoc({
  required Repair repair,
  required Client? client,
  required CompanyProfile company,
  required AppLocalizations l,
  required bool rtl,
}) async {
  final theme = await loadDocumentTheme();
  final doc = pw.Document(theme: theme);
  String money(double v) => AppFormats.money(v, decimals: 2);
  final name =
      client?.displayName ?? (repair.client.isNotEmpty ? repair.client : '—');

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.roll80,
      textDirection: rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
      margin: const pw.EdgeInsets.all(8),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Center(
            child: pw.Text(
                company.name.isNotEmpty ? company.name : l.appTitle,
                style: pw.TextStyle(
                    fontSize: 12, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 6),
          pw.Center(
            child: pw.Text(repair.reference,
                style: pw.TextStyle(
                    fontSize: 17, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.BarcodeWidget(
              data: repairQrData(repair),
              barcode: pw.Barcode.qrCode(),
              drawText: false,
              width: 120,
              height: 120,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Divider(color: PdfColors.grey500),
          _ticketRow(l.repairSectionClient, name),
          _ticketRow(l.repairSectionDevice, repair.device),
          if (repair.createdAt != null)
            _ticketRow(l.accountCreatedAt, AppFormats.date(repair.createdAt!)),
          if (repair.deposit > 0)
            _ticketRow(l.financeDeposit, money(repair.deposit)),
          _ticketRow(l.financeBalance, money(repair.balanceDue)),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text(l.repairTicketFooter,
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(
                    fontSize: 8, color: PdfColors.grey700)),
          ),
        ],
      ),
    ),
  );
  return doc;
}

pw.Widget _ticketRow(String label, String value) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('$label : ',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          pw.Expanded(
            child: pw.Text(value,
                textAlign: pw.TextAlign.right,
                style: const pw.TextStyle(fontSize: 9)),
          ),
        ],
      ),
    );

Future<pw.Document> _buildRepairDoc({
  required Repair repair,
  required Client? client,
  required CompanyProfile company,
  required AppLocalizations l,
  required bool rtl,
}) async {
  final theme = await loadDocumentTheme();
  final doc = pw.Document(theme: theme);
  final logo = company.hasLogo ? pw.MemoryImage(base64Decode(company.logo)) : null;

  String money(double v) => AppFormats.money(v, decimals: 2);

  final clientName =
      client?.displayName ?? (repair.client.isNotEmpty ? repair.client : '—');
  final clientPhone = client?.phone ?? repair.clientPhone;
  final clientEmail = client?.email ?? repair.clientEmail;
  final clientAddress = client?.address;

  final deviceRows = <(String, String?)>[
    (l.repairSectionDevice, repair.device),
    (l.deviceModel, [repair.brand, repair.model].where((s) => s != null && s.isNotEmpty).join(' ')),
    (l.deviceSerial, repair.serial),
    (l.deviceColor, repair.color),
    (l.deviceStorage, repair.storage),
    (l.devicePasscode, repair.passcode),
    (l.deviceAccessories,
        repair.accessories.isEmpty ? null : repair.accessories.join(', ')),
  ];
  final clientRows = <(String, String?)>[
    (l.repairSectionClient, clientName),
    (l.fieldPhone, clientPhone),
    (l.fieldEmail, clientEmail),
    (l.fieldAddress, clientAddress),
  ];

  final narrative = <(String, String?)>[
    (l.repairReported, repair.reportedIssue),
    (l.repairDiagnosis, repair.diagnosis),
    (l.repairWorkDone, repair.workDone),
  ].where((e) => e.$2 != null && e.$2!.trim().isNotEmpty).toList();

  final items = <List<String>>[
    for (final s in repair.services)
      [s.label, '1', money(s.price), money(s.price)],
    for (final p in repair.parts)
      [p.label, '${p.quantity}', money(p.unitPrice), money(p.total)],
  ];

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      textDirection: rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // En-tête : établissement à gauche, méta + QR à droite.
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (logo != null) ...[
                      pw.Image(logo, height: 48, width: 48, fit: pw.BoxFit.contain),
                      pw.SizedBox(width: 12),
                    ],
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                              company.name.isNotEmpty ? company.name : l.appTitle,
                              style: pw.TextStyle(
                                  fontSize: 18, fontWeight: pw.FontWeight.bold)),
                          for (final line in company.headerLines)
                            pw.Text(line,
                                style: const pw.TextStyle(
                                    fontSize: 9, color: PdfColors.grey700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(l.repairSheetTitle,
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text(repair.reference),
                  if (repair.createdAt != null)
                    pw.Text(AppFormats.date(repair.createdAt!),
                        style: const pw.TextStyle(
                            fontSize: 9, color: PdfColors.grey700)),
                  pw.SizedBox(height: 6),
                  pw.BarcodeWidget(
                    data: repairQrData(repair),
                    barcode: pw.Barcode.qrCode(),
                    drawText: false,
                    width: 68,
                    height: 68,
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Divider(color: PdfColors.grey400),
          pw.SizedBox(height: 8),
          // Deux colonnes : client / appareil.
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(child: _infoBlock(l.repairSectionClient, clientRows)),
              pw.SizedBox(width: 24),
              pw.Expanded(child: _infoBlock(l.repairSectionDevice, deviceRows)),
            ],
          ),
          // Récit.
          for (final n in narrative) ...[
            pw.SizedBox(height: 12),
            _sectionTitle(n.$1),
            pw.SizedBox(height: 2),
            pw.Text(n.$2!),
          ],
          // Pièces & prestations.
          if (items.isNotEmpty) ...[
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
                l.colDesignation,
                l.colQty,
                l.colUnitPrice,
                l.colLineTotal,
              ],
              data: items,
            ),
          ],
          pw.SizedBox(height: 16),
          // Totaux.
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.SizedBox(
              width: 240,
              child: pw.Column(children: [
                _totalLine(l.orderSubtotal, money(repair.partsTotal + repair.servicesTotal)),
                if (repair.discount > 0)
                  _totalLine(l.financeDiscount, '- ${money(repair.discount)}'),
                _totalLine(l.orderTax, money(repair.taxAmount)),
                pw.Divider(),
                _totalLine(l.orderTotal, money(repair.total), bold: true),
                if (repair.deposit > 0) ...[
                  _totalLine(l.financeDeposit, '- ${money(repair.deposit)}'),
                  _totalLine(l.financeBalance, money(repair.balanceDue), bold: true),
                ],
              ]),
            ),
          ),
          if (repair.warrantyMonths != null) ...[
            pw.SizedBox(height: 12),
            pw.Text('${l.repairWarranty} : ${repair.warrantyMonths} ${l.unitMonths}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          ],
          pw.Spacer(),
          // Signatures.
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _signature(l.repairSignatureClient),
              pw.SizedBox(width: 32),
              _signature(l.repairSignatureTech),
            ],
          ),
        ],
      ),
    ),
  );
  return doc;
}

pw.Widget _sectionTitle(String text) => pw.Text(
      text,
      style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.grey800),
    );

pw.Widget _infoBlock(String title, List<(String, String?)> rows) {
  final visible =
      rows.where((r) => r.$2 != null && r.$2!.trim().isNotEmpty).toList();
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _sectionTitle(title),
      pw.SizedBox(height: 4),
      for (final r in visible)
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 1),
          child: pw.RichText(
            text: pw.TextSpan(children: [
              pw.TextSpan(
                  text: '${r.$1} : ',
                  style: const pw.TextStyle(
                      fontSize: 9, color: PdfColors.grey600)),
              pw.TextSpan(
                  text: r.$2, style: const pw.TextStyle(fontSize: 10)),
            ]),
          ),
        ),
    ],
  );
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

pw.Widget _signature(String label) => pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 28),
          pw.Container(height: 0.5, color: PdfColors.grey500),
          pw.SizedBox(height: 3),
          pw.Text(label,
              style:
                  const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        ],
      ),
    );
