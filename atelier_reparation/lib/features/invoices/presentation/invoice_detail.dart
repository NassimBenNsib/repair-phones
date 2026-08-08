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
import '../../../shared/widgets/apple/apple_chip.dart';
import '../../../shared/widgets/apple/apple_text_field.dart';
import '../../../shared/widgets/apple/section_header.dart';
import '../../catalog/presentation/product_picker_sheet.dart';
import '../../cheques/application/cheques_controller.dart';
import '../../cheques/domain/cheque.dart';
import '../../clients/presentation/client_picker_sheet.dart';
import '../../company/application/company_controller.dart';
import '../../company/domain/company_profile.dart';
import '../../prestations/presentation/service_picker_sheet.dart';
import '../application/credit_notes_controller.dart';
import '../application/invoices_controller.dart';
import '../domain/invoice.dart';
import 'credit_note_detail.dart';

class InvoiceDetailEmpty extends StatelessWidget {
  const InvoiceDetailEmpty({super.key});

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
            Icon(Icons.receipt_long_outlined,
                size: 64, color: colors.tertiaryLabel),
            const SizedBox(height: 16),
            Text(l.invoiceEmpty,
                style: AppleTypography.title3.copyWith(color: colors.label)),
          ],
        ),
      ),
    );
  }
}

class InvoiceDetailScreen extends StatelessWidget {
  const InvoiceDetailScreen({super.key, required this.invoiceId});
  final String invoiceId;

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
      body: InvoiceDetailView(invoiceId: invoiceId),
    );
  }
}

class InvoiceDetailView extends ConsumerWidget {
  const InvoiceDetailView({super.key, required this.invoiceId, this.onClose});

  final String invoiceId;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final i = ref.watch(invoicesProvider.notifier).byId(invoiceId);
    ref.watch(invoicesProvider); // rebuild on changes
    if (i == null) return const InvoiceDetailEmpty();
    final ctrl = ref.read(invoicesProvider.notifier);
    final df = AppFormats.dateFormat;
    final t = i.totals;
    final status = i.effectiveStatus(DateTime.now());
    final editable = i.status == InvoiceStatus.draft; // verrouillé après émission

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
              Text(i.number.isEmpty ? l.invoiceStatusDraft : i.number,
                  style: AppleTypography.title3.copyWith(color: colors.label)),
              const SizedBox(height: 4),
              Text(i.clientName,
                  style: AppleTypography.subheadline
                      .copyWith(color: colors.secondaryLabel)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AppleBadge(
                      label: status.label(l),
                      color: status.color(colors),
                      icon: Icons.circle),
                  if (i.dueDate != null)
                    AppleBadge(
                        label: '${l.invoiceDueDate} ${df.format(i.dueDate!)}',
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

        // Client (change, brouillon seulement).
        if (editable) ...[
          const SizedBox(height: 12),
          AppleButton(
            label: i.clientName,
            icon: Icons.person_outline,
            style: AppleButtonStyle.gray,
            expand: true,
            onPressed: () => _pickClient(context, ctrl, i),
          ),
        ],

        // Détail (lignes).
        SectionHeader(
            title: l.quoteSectionLines,
            padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 8)),
        if (i.lines.isEmpty)
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
                for (final line in i.lines)
                  _LineRow(
                    line: line,
                    editable: editable,
                    colors: colors,
                    onQty: (v) => ctrl.updateLine(i.id, line.copyWith(qty: v)),
                    onRemove: () => ctrl.removeLine(i.id, line.id),
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
                  onPressed: () => _addService(context, ctrl, i),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppleButton(
                  label: l.quoteAddPart,
                  icon: Icons.add,
                  style: AppleButtonStyle.tinted,
                  expand: true,
                  onPressed: () => _addPart(context, ctrl, i),
                ),
              ),
            ],
          ),
        ],

        // Totaux + solde.
        const SizedBox(height: 16),
        AppleCard(
          child: Column(
            children: [
              _totalRow(l.orderSubtotal, t.subtotal, colors),
              _totalRow(l.orderTax, t.taxAmount, colors),
              Divider(color: colors.separator, height: 16),
              _totalRow(l.orderTotal, t.total, colors, bold: true),
              if (i.amountPaid > 0) ...[
                const SizedBox(height: 4),
                _totalRow(l.invoiceSectionPayments, -i.amountPaid, colors),
                _totalRow(l.invoiceBalance, i.balanceDue, colors, bold: true),
              ],
            ],
          ),
        ),

        // Paiements (facture émise).
        if (i.isIssued) ...[
          SectionHeader(
              title: l.invoiceSectionPayments,
              padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 8)),
          if (i.payments.isEmpty)
            AppleCard(
              child: Text(l.invoiceNoPayments,
                  style: AppleTypography.body
                      .copyWith(color: colors.secondaryLabel)),
            )
          else
            AppleCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  for (final p in i.payments)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      child: Row(
                        children: [
                          Icon(Icons.payments_outlined,
                              size: 18, color: colors.secondaryLabel),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                                '${p.method.label(l)} · ${df.format(p.date)}',
                                style: AppleTypography.body
                                    .copyWith(color: colors.label)),
                          ),
                          Text(AppFormats.money(p.amount, decimals: 2),
                              style: AppleTypography.body.copyWith(
                                  color: colors.label,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          if (i.balanceDue > 0.005) ...[
            const SizedBox(height: 10),
            AppleButton(
              label: l.invoiceRecordPayment,
              icon: Icons.add,
              style: AppleButtonStyle.tinted,
              expand: true,
              onPressed: () => _recordPayment(context, ref, ctrl, i),
            ),
          ],
        ],

        // Actions.
        const SizedBox(height: 20),
        if (i.status == InvoiceStatus.draft)
          AppleButton(
            label: l.invoiceIssue,
            icon: Icons.verified_outlined,
            expand: true,
            onPressed: i.lines.isEmpty ? null : () => ctrl.issue(i.id),
          ),
        if (i.isIssued) ...[
          AppleButton(
            label: l.quoteExportPdf,
            icon: Icons.picture_as_pdf_outlined,
            expand: true,
            onPressed: () =>
                _exportPdf(context, l, i, ref.read(companyProvider)),
          ),
          const SizedBox(height: 8),
          AppleButton(
            label: l.creditNoteNew,
            icon: Icons.receipt_long_outlined,
            style: AppleButtonStyle.gray,
            expand: true,
            onPressed: () => _createCreditNote(context, ref, i),
          ),
        ],
      ],
    );
  }

  /// Crée un avoir pré-rempli depuis la facture puis ouvre son détail.
  void _createCreditNote(BuildContext context, WidgetRef ref, Invoice i) {
    final cn = ref.read(creditNotesProvider.notifier).createFrom(
          clientId: i.clientId,
          clientName: i.clientName,
          invoiceId: i.id,
          lines: i.lines,
          taxRate: i.taxRate,
        );
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => CreditNoteDetailScreen(creditNoteId: cn.id)));
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
      BuildContext context, InvoicesController ctrl, Invoice i) async {
    final s = await showServicePickerSheet(context);
    if (s == null) return;
    ctrl.addLine(
        i.id,
        LineItem(
            id: const Uuid().v4(),
            label: s.label,
            unitPrice: s.price,
            taxRate: i.taxRate));
  }

  Future<void> _addPart(
      BuildContext context, InvoicesController ctrl, Invoice i) async {
    final p = await showProductPickerSheet(context);
    if (p == null) return;
    ctrl.addLine(
        i.id,
        LineItem(
            id: const Uuid().v4(),
            label: p.label,
            unitPrice: p.price,
            taxRate: i.taxRate,
            productId: p.productId,
            variantId: p.variantId));
  }

  Future<void> _pickClient(
      BuildContext context, InvoicesController ctrl, Invoice i) async {
    final c = await showClientPickerSheet(context);
    if (c != null) {
      ctrl.update(i.copyWith(clientId: c.id, clientName: c.displayName));
    }
  }

  Future<void> _recordPayment(BuildContext context, WidgetRef ref,
      InvoicesController ctrl, Invoice i) async {
    final r = await showDialog<_PaymentResult>(
      context: context,
      builder: (_) => _PaymentDialog(suggested: i.balanceDue),
    );
    if (r == null) return;
    ctrl.addPayment(i.id, r.payment);
    if (r.isCheque) {
      ref.read(chequesProvider.notifier).add(Cheque(
            id: const Uuid().v4(),
            invoiceId: i.id,
            clientId: i.clientId,
            clientName: i.clientName,
            paymentId: r.payment.id,
            number: r.chequeNumber,
            bank: r.chequeBank,
            drawer: r.chequeDrawer,
            amount: r.payment.amount,
            receivedDate: DateTime.now(),
            dueDate: r.chequeDueDate,
          ));
    }
  }

  Future<void> _exportPdf(BuildContext context, AppLocalizations l, Invoice i,
      CompanyProfile company) async {
    await printBusinessDocument(
      appName: company.name.isNotEmpty ? company.name : l.appTitle,
      title: l.navInvoices,
      number: i.number,
      partyName: i.clientName,
      dateLabel: AppFormats.dateFormat.format(i.issueDate ?? i.date),
      lines: i.lines,
      totals: i.totals,
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

/// Résultat du dialogue : le paiement + les détails de chèque éventuels.
class _PaymentResult {
  const _PaymentResult(
    this.payment, {
    this.chequeNumber = '',
    this.chequeBank = '',
    this.chequeDrawer = '',
    this.chequeDueDate,
  });
  final Payment payment;
  final String chequeNumber;
  final String chequeBank;
  final String chequeDrawer;
  final DateTime? chequeDueDate;
  bool get isCheque => payment.method == PaymentMethod.check;
}

/// Boîte de dialogue : montant + moyen de paiement (+ chèque si « Chèque »).
class _PaymentDialog extends StatefulWidget {
  const _PaymentDialog({required this.suggested});
  final double suggested;

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  late final TextEditingController _amount =
      TextEditingController(text: widget.suggested.toStringAsFixed(2));
  final _num = TextEditingController();
  final _bank = TextEditingController();
  final _drawer = TextEditingController();
  DateTime? _due;
  PaymentMethod _method = PaymentMethod.cash;

  @override
  void dispose() {
    _amount.dispose();
    _num.dispose();
    _bank.dispose();
    _drawer.dispose();
    super.dispose();
  }

  void _submit() {
    final value = double.tryParse(_amount.text.replaceAll(',', '.')) ?? 0;
    if (value <= 0) return;
    Navigator.of(context).pop(_PaymentResult(
      Payment(
        id: const Uuid().v4(),
        date: DateTime.now(),
        amount: value,
        method: _method,
      ),
      chequeNumber: _num.text.trim(),
      chequeBank: _bank.text.trim(),
      chequeDrawer: _drawer.text.trim(),
      chequeDueDate: _due,
    ));
  }

  Future<void> _pickDue() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _due ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (d != null) setState(() => _due = d);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    return AlertDialog(
      backgroundColor: colors.secondaryGroupedBackground,
      title: Text(l.invoiceRecordPayment),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppleTextField(
              controller: _amount,
              label: l.invoiceAmount,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              suffix: AppFormats.symbol,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in PaymentMethodX.manual)
                  AppleChip(
                      label: m.label(l),
                      selected: _method == m,
                      onTap: () => setState(() => _method = m)),
              ],
            ),
            if (_method == PaymentMethod.check) ...[
              const SizedBox(height: 12),
              AppleTextField(controller: _num, label: l.chequeNumber),
              const SizedBox(height: 10),
              AppleTextField(controller: _bank, label: l.chequeBank),
              const SizedBox(height: 10),
              AppleTextField(controller: _drawer, label: l.chequeDrawer),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: Text(l.chequeDueDate,
                      style: AppleTypography.subheadline
                          .copyWith(color: colors.secondaryLabel)),
                ),
                TextButton(
                  onPressed: _pickDue,
                  child: Text(_due == null
                      ? l.notProvided
                      : AppFormats.dateFormat.format(_due!)),
                ),
              ]),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.commonCancel)),
        TextButton(onPressed: _submit, child: Text(l.commonSave)),
      ],
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
