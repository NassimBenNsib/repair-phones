import 'dart:convert';
import 'dart:ui' as ui;

import 'package:atelier_reparation/core/format/app_formats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../core/pdf/document_pdf.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_badge.dart';
import '../../../shared/widgets/apple/apple_button.dart';
import '../../../shared/widgets/apple/apple_card.dart';
import '../../../shared/widgets/apple/apple_list_row.dart';
import '../../../shared/widgets/apple/apple_list_section.dart';
import '../../../shared/widgets/apple/section_header.dart';
import '../../company/application/company_controller.dart';
import '../application/credit_notes_controller.dart';
import '../domain/credit_note.dart';

/// Détail d'un avoir : en-tête, lignes, totaux ; émission, PDF, suppression.
class CreditNoteDetailScreen extends ConsumerWidget {
  const CreditNoteDetailScreen({super.key, required this.creditNoteId});
  final String creditNoteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    CreditNote? cn;
    for (final x in ref.watch(creditNotesProvider)) {
      if (x.id == creditNoteId) {
        cn = x;
        break;
      }
    }

    if (cn == null) {
      return Scaffold(
        backgroundColor: colors.groupedBackground,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(context.backIcon, size: 20),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: Center(child: Text(l.creditNoteEmpty)),
      );
    }
    final note = cn;
    final ctrl = ref.read(creditNotesProvider.notifier);
    final totals = note.totals;

    return Scaffold(
      backgroundColor: colors.groupedBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(context.backIcon, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(note.isIssued ? note.number : l.invoiceStatusDraft),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          AppleCard(
            elevated: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(
                        note.isIssued ? note.number : l.creditNote,
                        style: AppleTypography.title3
                            .copyWith(color: colors.label)),
                  ),
                  AppleBadge(
                      label: note.status.label(l),
                      color: note.status.color(colors)),
                ]),
                const SizedBox(height: 4),
                Text(note.clientName,
                    style: AppleTypography.body.copyWith(color: colors.label)),
                Text(DateFormat('dd/MM/yyyy')
                    .format(note.issueDate ?? note.date),
                    style: AppleTypography.footnote
                        .copyWith(color: colors.secondaryLabel)),
                if (note.reason != null && note.reason!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text('${l.creditNoteReason} : ${note.reason}',
                      style: AppleTypography.footnote
                          .copyWith(color: colors.secondaryLabel)),
                ],
              ],
            ),
          ),

          SectionHeader(
              title: l.orderSectionLines,
              padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 8)),
          AppleListSection(children: [
            for (final line in note.lines)
              AppleListRow(
                title: line.label,
                subtitle:
                    '${AppFormats.number(line.qty)} × ${AppFormats.money(line.unitPrice)}',
                trailingText: AppFormats.money(line.totalHT, decimals: 0),
              ),
          ]),

          const SizedBox(height: 16),
          AppleCard(
            child: Column(children: [
              _row(l.orderSubtotal, totals.subtotal, colors),
              _row(l.orderTax, totals.taxAmount, colors),
              Divider(color: colors.separator, height: 16),
              _row(l.orderTotal, totals.total, colors, bold: true),
            ]),
          ),

          const SizedBox(height: 20),
          if (note.status == CreditNoteStatus.draft)
            AppleButton(
              label: l.creditNoteIssue,
              icon: Icons.verified_outlined,
              expand: true,
              onPressed: note.lines.isEmpty ? null : () => ctrl.issue(note.id),
            ),
          if (note.isIssued)
            AppleButton(
              label: l.quoteExportPdf,
              icon: Icons.picture_as_pdf_outlined,
              expand: true,
              onPressed: () => _exportPdf(context, l, note, ref),
            ),
          const SizedBox(height: 8),
          AppleButton(
            label: l.actionDelete,
            icon: Icons.delete_outline,
            style: AppleButtonStyle.destructive,
            expand: true,
            onPressed: () {
              ctrl.remove(note.id);
              Navigator.of(context).maybePop();
            },
          ),
        ],
      ),
    );
  }

  Widget _row(String label, double v, AppleColors colors, {bool bold = false}) {
    final style = bold
        ? AppleTypography.headline.copyWith(color: colors.label)
        : AppleTypography.body.copyWith(color: colors.secondaryLabel);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(child: Text(label, style: style)),
        Text(AppFormats.money(v, decimals: 2), style: style),
      ]),
    );
  }

  Future<void> _exportPdf(BuildContext context, AppLocalizations l,
      CreditNote cn, WidgetRef ref) async {
    final company = ref.read(companyProvider);
    await printBusinessDocument(
      appName: company.name.isNotEmpty ? company.name : l.appTitle,
      title: l.creditNote,
      number: cn.number,
      partyName: cn.clientName,
      dateLabel: AppFormats.dateFormat.format(cn.issueDate ?? cn.date),
      lines: cn.lines,
      totals: cn.totals,
      sellerDetails: company.headerLines,
      logo: company.hasLogo ? base64Decode(company.logo) : null,
      rtl: Directionality.of(context) == ui.TextDirection.rtl,
      labels: (
        designation: l.colDesignation,
        qty: l.colQty,
        unitPrice: l.colUnitPrice,
        lineTotal: l.colLineTotal,
        subtotal: l.orderSubtotal,
        tax: l.orderTax,
        total: l.orderTotal,
      ),
    );
  }
}
