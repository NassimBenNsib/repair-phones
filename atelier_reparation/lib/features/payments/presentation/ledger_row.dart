import 'package:atelier_reparation/core/format/app_formats.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../invoices/domain/invoice.dart';
import '../application/payment_history.dart';

/// Ligne du journal des paiements (facture / acompte / avoir / remboursement).
class PaymentLedgerRow extends StatelessWidget {
  const PaymentLedgerRow({
    super.key,
    required this.entry,
    required this.df,
    this.showClient = true,
    this.onTap,
  });

  final LedgerEntry entry;
  final DateFormat df;
  final bool showClient;
  final VoidCallback? onTap;

  ({IconData icon, Color color}) _visual(AppleColors c) => switch (entry.kind) {
        LedgerKind.invoicePayment => (
            icon: Icons.payments_outlined,
            color: c.green
          ),
        LedgerKind.deposit => (
            icon: Icons.account_balance_wallet_outlined,
            color: c.blue
          ),
        LedgerKind.application => (icon: Icons.card_giftcard, color: c.indigo),
        LedgerKind.refund => (icon: Icons.undo, color: c.red),
      };

  String _title(AppLocalizations l) => switch (entry.kind) {
        LedgerKind.invoicePayment => entry.method.label(l),
        LedgerKind.deposit => l.paymentKindDeposit,
        LedgerKind.application => l.paymentKindApplication,
        LedgerKind.refund => l.paymentKindRefund,
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final v = _visual(colors);
    final title = showClient && entry.clientName.isNotEmpty
        ? '${_title(l)} · ${entry.clientName}'
        : _title(l);
    final ref = entry.invoiceNumber == null || entry.invoiceNumber!.isEmpty
        ? '—'
        : entry.invoiceNumber!;

    final amountColor = entry.isCashOut
        ? colors.red
        : (entry.isInternal ? colors.secondaryLabel : colors.label);
    final amountText =
        '${entry.isCashOut ? '−' : ''}${AppFormats.money(entry.amount, decimals: 2)}';

    final content = Padding(
      padding:
          const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(v.icon, size: 20, color: v.color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppleTypography.body.copyWith(color: colors.label)),
                Text('$ref · ${df.format(entry.date)}',
                    style: AppleTypography.footnote
                        .copyWith(color: colors.secondaryLabel)),
              ],
            ),
          ),
          Text(amountText,
              style: AppleTypography.body
                  .copyWith(color: amountColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );

    if (onTap == null) return content;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        splashColor: colors.fill,
        highlightColor: colors.fill,
        child: content,
      ),
    );
  }
}
