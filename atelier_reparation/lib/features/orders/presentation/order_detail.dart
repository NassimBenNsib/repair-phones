import 'package:atelier_reparation/core/format/app_formats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/domain/line_item.dart';
import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_badge.dart';
import '../../../shared/widgets/apple/apple_button.dart';
import '../../../shared/widgets/apple/apple_card.dart';
import '../../../shared/widgets/apple/apple_chip.dart';
import '../../../shared/widgets/apple/apple_list_row.dart';
import '../../../shared/widgets/apple/apple_list_section.dart';
import '../../../shared/widgets/apple/apple_sheet.dart';
import '../../../shared/widgets/apple/apple_text_field.dart';
import '../../../shared/widgets/apple/section_header.dart';
import '../../catalog/presentation/product_picker_sheet.dart';
import '../../invoices/domain/invoice.dart' show PaymentMethod, PaymentMethodX;
import '../../suppliers/application/suppliers_controller.dart';
import '../application/orders_controller.dart';
import '../domain/purchase_order.dart';

class OrderDetailEmpty extends StatelessWidget {
  const OrderDetailEmpty({super.key});

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
            Icon(Icons.shopping_cart_outlined,
                size: 64, color: colors.tertiaryLabel),
            const SizedBox(height: 16),
            Text(l.orderEmpty,
                style: AppleTypography.title3.copyWith(color: colors.label)),
          ],
        ),
      ),
    );
  }
}

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.orderId});
  final String orderId;

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
      body: OrderDetailView(orderId: orderId),
    );
  }
}

class OrderDetailView extends ConsumerWidget {
  const OrderDetailView({super.key, required this.orderId, this.onClose});

  final String orderId;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final order = ref.watch(ordersProvider).where((o) => o.id == orderId);
    if (order.isEmpty) return const OrderDetailEmpty();
    final o = order.first;
    final ctrl = ref.read(ordersProvider.notifier);
    final df = AppFormats.dateFormat;
    String? supplier;
    for (final s in ref.watch(suppliersProvider)) {
      if (s.id == o.supplierId) {
        supplier = s.name;
        break;
      }
    }
    final totals = o.totals;
    final received = o.status == PoStatus.received;

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
              Text(o.number,
                  style: AppleTypography.title3.copyWith(color: colors.label)),
              const SizedBox(height: 4),
              Text(df.format(o.date),
                  style: AppleTypography.footnote
                      .copyWith(color: colors.secondaryLabel)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  GestureDetector(
                    onTap: received ? null : () => _pickStatus(context, ctrl, o),
                    child: AppleBadge(
                        label: o.status.label(l),
                        color: o.status.color(colors),
                        icon: Icons.circle),
                  ),
                  AppleBadge(
                      label: AppFormats.money(totals.total, decimals: 0),
                      color: colors.secondaryLabel,
                      icon: Icons.euro),
                ],
              ),
            ],
          ),
        ),

        // Fournisseur.
        SectionHeader(
            title: l.orderSupplier,
            padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 8)),
        AppleCard(
          onTap: received ? null : () => _pickSupplier(context, ref, ctrl, o),
          child: Row(
            children: [
              Expanded(
                child: Text(supplier ?? l.notProvided,
                    style: AppleTypography.body.copyWith(color: colors.label)),
              ),
              if (!received)
                Icon(context.chevronForward,
                    size: 18, color: colors.tertiaryLabel),
            ],
          ),
        ),

        // Articles.
        SectionHeader(
            title: l.orderSectionLines,
            padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 8)),
        if (o.lines.isEmpty)
          AppleCard(
            child: Text(l.orderNoLines,
                style: AppleTypography.body
                    .copyWith(color: colors.secondaryLabel)),
          )
        else
          AppleCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                for (final line in o.lines)
                  _LineRow(
                    line: line,
                    editable: !received,
                    colors: colors,
                    onQty: (q) => ctrl.updateLine(o.id, line.copyWith(qty: q)),
                    onRemove: () => ctrl.removeLine(o.id, line.id),
                  ),
              ],
            ),
          ),
        if (!received) ...[
          const SizedBox(height: 10),
          AppleButton(
            label: l.orderAddLine,
            icon: Icons.add,
            style: AppleButtonStyle.tinted,
            expand: true,
            onPressed: () => _addLine(context, ctrl, o),
          ),
        ],

        // Totaux.
        const SizedBox(height: 16),
        AppleCard(
          child: Column(
            children: [
              _totalRow(l.orderSubtotal, totals.subtotal, colors),
              _totalRow(l.orderTax, totals.taxAmount, colors),
              Divider(color: colors.separator, height: 16),
              _totalRow(l.orderTotal, totals.total, colors, bold: true),
              if (o.amountPaid > 0.005 || _apTracked(o)) ...[
                const SizedBox(height: 4),
                _totalRow(l.orderPaid, o.amountPaid, colors),
                _totalRow(l.orderBalanceDue, o.balanceDue, colors,
                    bold: true,
                    color: o.isPaid ? colors.green : colors.orange),
              ],
            ],
          ),
        ),

        // Règlements fournisseur (AP).
        if (o.payments.isNotEmpty) ...[
          SectionHeader(
              title: l.invoiceSectionPayments,
              padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 8)),
          AppleListSection(children: [
            for (final p in o.payments)
              AppleListRow(
                leadingIcon: Icons.payments_outlined,
                leadingTint: colors.green,
                title: p.method.label(l),
                subtitle: AppFormats.date(p.date),
                trailingText: AppFormats.money(p.amount, decimals: 2),
                onLongPress: () => ctrl.removePayment(o.id, p.id),
              ),
          ]),
        ],

        if (_apTracked(o) && !o.isPaid) ...[
          const SizedBox(height: 12),
          AppleButton(
            label: l.orderAddPayment,
            icon: Icons.add_card_outlined,
            style: AppleButtonStyle.tinted,
            expand: true,
            onPressed: () => _addPayment(context, ctrl, o),
          ),
        ],

        // Réception.
        if (!received && o.lines.isNotEmpty) ...[
          const SizedBox(height: 20),
          AppleButton(
            label: l.orderReceive,
            icon: Icons.inventory,
            expand: true,
            onPressed: () => ctrl.receive(o.id),
          ),
        ],
      ],
    );
  }

  /// La comptabilité fournisseur ne s'ouvre qu'une fois la commande engagée
  /// (passée ou reçue) et non nulle.
  bool _apTracked(PurchaseOrder o) =>
      (o.status == PoStatus.ordered || o.status == PoStatus.received) &&
      o.totals.total > 0.005;

  Future<void> _addPayment(
      BuildContext context, OrdersController ctrl, PurchaseOrder o) async {
    final result = await showDialog<({double amount, PaymentMethod method})>(
      context: context,
      builder: (_) => _PoPaymentDialog(suggested: o.balanceDue),
    );
    if (result == null) return;
    ctrl.addPayment(o.id, result.amount, method: result.method);
  }

  Widget _totalRow(String label, double value, AppleColors colors,
      {bool bold = false, Color? color}) {
    final style = bold
        ? AppleTypography.headline.copyWith(color: color ?? colors.label)
        : AppleTypography.body.copyWith(color: color ?? colors.secondaryLabel);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(AppFormats.money(value, decimals: 2), style: style),
        ],
      ),
    );
  }

  Future<void> _addLine(
      BuildContext context, OrdersController ctrl, PurchaseOrder o) async {
    final picked = await showProductPickerSheet(context);
    if (picked == null) return;
    ctrl.addLine(
      o.id,
      LineItem(
        id: const Uuid().v4(),
        label: picked.label,
        unitPrice: picked.price,
        taxRate: o.taxRate,
        productId: picked.productId,
        variantId: picked.variantId,
      ),
    );
  }

  Future<void> _pickStatus(
      BuildContext context, OrdersController ctrl, PurchaseOrder o) async {
    final l = AppLocalizations.of(context);
    final choice = await showAppleSelectionSheet<PoStatus>(
      context: context,
      title: l.orderStatusDraft,
      selected: o.status,
      options: [
        for (final s in [PoStatus.draft, PoStatus.ordered, PoStatus.cancelled])
          AppleSheetOption(s, s.label(l)),
      ],
    );
    if (choice != null) ctrl.update(o.copyWith(status: choice));
  }

  Future<void> _pickSupplier(BuildContext context, WidgetRef ref,
      OrdersController ctrl, PurchaseOrder o) async {
    final l = AppLocalizations.of(context);
    final suppliers = ref.read(suppliersProvider);
    final choice = await showAppleSelectionSheet<String>(
      context: context,
      title: l.orderSupplier,
      selected: o.supplierId,
      options: [for (final s in suppliers) AppleSheetOption(s.id, s.name)],
    );
    if (choice != null) ctrl.update(o.copyWith(supplierId: choice));
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
                  style: AppleTypography.body.copyWith(color: colors.label)),
            ),
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
          color: colors.fill,
          shape: AppleRadii.shape(AppleRadii.sm),
        ),
        child: Icon(icon, size: 16, color: colors.label),
      ),
    );
  }
}

/// Saisie d'un règlement fournisseur (montant + moyen).
class _PoPaymentDialog extends StatefulWidget {
  const _PoPaymentDialog({required this.suggested});
  final double suggested;

  @override
  State<_PoPaymentDialog> createState() => _PoPaymentDialogState();
}

class _PoPaymentDialogState extends State<_PoPaymentDialog> {
  late final TextEditingController _amount =
      TextEditingController(text: widget.suggested.toStringAsFixed(2));
  PaymentMethod _method = PaymentMethod.cash;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _submit() {
    final v = double.tryParse(_amount.text.replaceAll(',', '.')) ?? 0;
    if (v <= 0) return;
    Navigator.of(context).pop((amount: v, method: _method));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    return AlertDialog(
      backgroundColor: colors.secondaryGroupedBackground,
      title: Text(l.orderAddPayment),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppleTextField(
            controller: _amount,
            label: l.invoiceAmount,
            suffix: AppFormats.symbol,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
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
        ],
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
