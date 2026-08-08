import 'package:atelier_reparation/core/format/app_formats.dart';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../core/domain/line_item.dart';
import '../../../core/pdf/document_pdf.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_badge.dart';
import '../../../shared/widgets/apple/apple_button.dart';
import '../../../shared/widgets/apple/apple_card.dart';
import '../../../shared/widgets/apple/apple_sheet.dart';
import '../../../shared/widgets/apple/section_header.dart';
import '../../catalog/presentation/product_picker_sheet.dart';
import '../../clients/presentation/client_picker_sheet.dart';
import '../../company/application/company_controller.dart';
import '../../company/domain/company_profile.dart';
import '../../invoices/application/invoices_controller.dart';
import '../../invoices/presentation/invoice_detail.dart';
import '../../prestations/presentation/service_picker_sheet.dart';
import '../application/quotes_controller.dart';
import '../domain/quote.dart';

class QuoteDetailEmpty extends StatelessWidget {
  const QuoteDetailEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    return ColoredBox(
      color: colors.groupedBackground,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.description_outlined,
                size: 64, color: colors.tertiaryLabel),
            const SizedBox(height: 16),
            Text(l.quoteEmpty,
                style: AppleTypography.title3.copyWith(color: colors.label)),
          ],
        ),
      ),
    );
  }
}

class QuoteDetailScreen extends StatelessWidget {
  const QuoteDetailScreen({super.key, required this.quoteId});
  final String quoteId;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    return Scaffold(
      backgroundColor: colors.groupedBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(context.backIcon, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: QuoteDetailView(quoteId: quoteId),
    );
  }
}

class QuoteDetailView extends ConsumerWidget {
  const QuoteDetailView({super.key, required this.quoteId, this.onClose});

  final String quoteId;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final q = ref.watch(quotesProvider.notifier).byId(quoteId);
    ref.watch(quotesProvider); // rebuild on changes
    if (q == null) return const QuoteDetailEmpty();
    final ctrl = ref.read(quotesProvider.notifier);
    final df = AppFormats.dateFormat;
    final t = q.totals;
    final editable =
        q.status == QuoteStatus.draft || q.status == QuoteStatus.sent;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        if (onClose != null)
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: IconButton(
                onPressed: onClose,
                icon: Icon(Icons.close, color: colors.secondaryLabel)),
          ),

        // En-tête.
        AppleCard(
          elevated: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(q.number,
                  style: AppleTypography.title3.copyWith(color: colors.label)),
              const SizedBox(height: 4),
              Text(q.clientName,
                  style: AppleTypography.subheadline
                      .copyWith(color: colors.secondaryLabel)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  GestureDetector(
                    onTap: () => _pickStatus(context, ctrl, q),
                    child: AppleBadge(
                        label: q.status.label(l),
                        color: q.status.color(colors),
                        icon: Icons.circle),
                  ),
                  if (q.validUntil != null)
                    AppleBadge(
                        label:
                            '${l.quoteValidUntil} ${df.format(q.validUntil!)}',
                        color: colors.secondaryLabel,
                        icon: Icons.event),
                  AppleBadge(
                      label: AppFormats.money(t.total, decimals: 0),
                      color: colors.secondaryLabel,
                      icon: Icons.euro),
                ],
              ),
            ],
          ),
        ),

        // Client (change).
        if (editable) ...[
          const SizedBox(height: 12),
          AppleButton(
            label: q.clientName,
            icon: Icons.person_outline,
            style: AppleButtonStyle.gray,
            expand: true,
            onPressed: () => _pickClient(context, ctrl, q),
          ),
        ],

        // Détail (lignes).
        SectionHeader(
            title: l.quoteSectionLines,
            padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 8)),
        if (q.lines.isEmpty)
          AppleCard(
            child: Text(l.orderNoLines,
                style:
                    AppleTypography.body.copyWith(color: colors.secondaryLabel)),
          )
        else
          AppleCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                for (final line in q.lines)
                  _LineRow(
                    line: line,
                    editable: editable,
                    colors: colors,
                    onQty: (v) => ctrl.updateLine(q.id, line.copyWith(qty: v)),
                    onRemove: () => ctrl.removeLine(q.id, line.id),
                  ),
              ],
            ),
          ),
        if (editable) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: AppleButton(
                  label: l.quoteAddService,
                  icon: Icons.add,
                  style: AppleButtonStyle.tinted,
                  expand: true,
                  onPressed: () => _addService(context, ctrl, q),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppleButton(
                  label: l.quoteAddPart,
                  icon: Icons.add,
                  style: AppleButtonStyle.tinted,
                  expand: true,
                  onPressed: () => _addPart(context, ctrl, q),
                ),
              ),
            ],
          ),
        ],

        // Totaux.
        const SizedBox(height: 16),
        AppleCard(
          child: Column(
            children: [
              _totalRow(l.orderSubtotal, t.subtotal, colors),
              _totalRow(l.orderTax, t.taxAmount, colors),
              Divider(color: colors.separator, height: 16),
              _totalRow(l.orderTotal, t.total, colors, bold: true),
            ],
          ),
        ),

        // Actions.
        const SizedBox(height: 20),
        AppleButton(
          label: l.quoteExportPdf,
          icon: Icons.picture_as_pdf_outlined,
          expand: true,
          onPressed: () => _exportPdf(context, l, q, ref.read(companyProvider)),
        ),
        if (q.status == QuoteStatus.accepted) ...[
          const SizedBox(height: 12),
          AppleButton(
            label: l.quoteConvertInvoice,
            icon: Icons.receipt_long_outlined,
            style: AppleButtonStyle.gray,
            expand: true,
            onPressed: () => _convertToInvoice(context, ref, q),
          ),
        ],
      ],
    );
  }

  Future<void> _convertToInvoice(
      BuildContext context, WidgetRef ref, Quote q) async {
    final invoice = ref.read(invoicesProvider.notifier).createFrom(
          clientId: q.clientId,
          clientName: q.clientName,
          lines: q.lines,
          quoteId: q.id,
          discount: q.discount,
          taxRate: q.taxRate,
        );
    if (!context.mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => InvoiceDetailScreen(invoiceId: invoice.id)));
  }

  Widget _totalRow(String label, double v, AppleColors colors,
      {bool bold = false}) {
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

  Future<void> _addService(
      BuildContext context, QuotesController ctrl, Quote q) async {
    final s = await showServicePickerSheet(context);
    if (s == null) return;
    ctrl.addLine(
        q.id,
        LineItem(
            id: const Uuid().v4(),
            label: s.label,
            unitPrice: s.price,
            taxRate: q.taxRate));
  }

  Future<void> _addPart(
      BuildContext context, QuotesController ctrl, Quote q) async {
    final p = await showProductPickerSheet(context);
    if (p == null) return;
    ctrl.addLine(
        q.id,
        LineItem(
            id: const Uuid().v4(),
            label: p.label,
            unitPrice: p.price,
            taxRate: q.taxRate,
            productId: p.productId,
            variantId: p.variantId));
  }

  Future<void> _pickClient(
      BuildContext context, QuotesController ctrl, Quote q) async {
    final c = await showClientPickerSheet(context);
    if (c != null) {
      ctrl.update(q.copyWith(clientId: c.id, clientName: c.displayName));
    }
  }

  Future<void> _pickStatus(
      BuildContext context, QuotesController ctrl, Quote q) async {
    final l = AppLocalizations.of(context);
    final choice = await showAppleSelectionSheet<QuoteStatus>(
      context: context,
      title: q.status.label(l),
      selected: q.status,
      options: [
        for (final s in [
          QuoteStatus.draft,
          QuoteStatus.sent,
          QuoteStatus.accepted,
          QuoteStatus.refused,
        ])
          AppleSheetOption(s, s.label(l)),
      ],
    );
    if (choice != null) ctrl.setStatus(q.id, choice);
  }

  Future<void> _exportPdf(BuildContext context, AppLocalizations l, Quote q,
      CompanyProfile company) async {
    await printBusinessDocument(
      appName: company.name.isNotEmpty ? company.name : l.appTitle,
      title: l.navQuotes,
      number: q.number,
      partyName: q.clientName,
      dateLabel: AppFormats.dateFormat.format(q.date),
      lines: q.lines,
      totals: q.totals,
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

class _LineRow extends StatelessWidget {
  const _LineRow({
    required this.line,
    required this.editable,
    required this.colors,
    required this.onQty,
    required this.onRemove,
  });

  final LineItem line;
  final bool editable;
  final AppleColors colors;
  final ValueChanged<double> onQty;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppleTypography.body.copyWith(color: colors.label)),
                Text(
                    '${AppFormats.number(line.qty)} × ${AppFormats.money(line.unitPrice)}',
                    style: AppleTypography.footnote
                        .copyWith(color: colors.secondaryLabel)),
              ],
            ),
          ),
          if (editable) ...[
            _stepBtn(Icons.remove, () {
              if (line.qty > 1) onQty(line.qty - 1);
            }),
            SizedBox(
                width: 24,
                child: Text(line.qty.toStringAsFixed(0),
                    textAlign: TextAlign.center,
                    style: AppleTypography.body.copyWith(color: colors.label))),
            _stepBtn(Icons.add, () => onQty(line.qty + 1)),
            IconButton(
                onPressed: onRemove,
                icon: Icon(Icons.delete_outline, size: 20, color: colors.red)),
          ] else
            Text(AppFormats.money(line.totalHT, decimals: 0),
                style: AppleTypography.body.copyWith(
                    color: colors.label, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        alignment: Alignment.center,
        decoration: ShapeDecoration(
            color: colors.fill, shape: AppleRadii.shape(AppleRadii.sm)),
        child: Icon(icon, size: 16, color: colors.label),
      ),
    );
  }
}
