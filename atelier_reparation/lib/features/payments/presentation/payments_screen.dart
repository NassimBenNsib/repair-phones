import 'package:atelier_reparation/core/format/app_formats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_card.dart';
import '../../../shared/widgets/apple/apple_list_section.dart';
import '../../../shared/widgets/apple/apple_scaffold.dart';
import '../../clients/application/client_payments_controller.dart';
import '../../clients/application/clients_controller.dart';
import '../../invoices/application/invoices_controller.dart';
import '../../invoices/presentation/invoice_detail.dart';
import '../application/finance_filter.dart';
import '../application/payment_history.dart';
import 'cash_register_card.dart';
import 'finance_filter_bar.dart';
import 'ledger_row.dart';

/// Journal complet des paiements : encaissements de factures + mouvements de
/// compte client (acomptes / avoirs / remboursements), avec trésorerie nette.
class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  static const String routeName = 'payments';
  static const String routePath = '/payments';

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  FinanceFilter _filter = const FinanceFilter();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final df = AppFormats.dateFormat;
    final now = DateTime.now();

    final clientNames = {
      for (final c in ref.watch(clientsProvider)) c.id: c.displayName
    };
    final entries = buildPaymentHistory(
      invoices: ref.watch(invoicesProvider),
      clientPayments: ref.watch(clientPaymentsProvider),
      clientNames: clientNames,
    );

    final shown =
        entries.where((e) => matchesLedger(e, _filter, now)).toList();
    final total = netCash(shown);

    return AppleScaffold(
      title: l.navPayments,
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 4),
          sliver: SliverToBoxAdapter(
            child: CashRegisterCard(ledger: entries),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 4),
          sliver: SliverToBoxAdapter(
            child: AppleCard(
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(l.paymentsTotalCollected,
                        style: AppleTypography.body
                            .copyWith(color: colors.secondaryLabel)),
                  ),
                  Text(AppFormats.money(total, decimals: 2),
                      style: AppleTypography.title3.copyWith(
                          color: colors.label, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
            child: FinanceFilterBar(
              filter: _filter,
              clientName: clientNames[_filter.clientId],
              showTypes: true,
              showMethods: true,
              onChanged: (f) => setState(() => _filter = f),
            ),
          ),
        ),
        if (shown.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
            sliver: SliverToBoxAdapter(
              child: FinanceBreakdownCard(breakdown: financeBreakdown(shown)),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: shown.isEmpty
                ? _Empty(l: l)
                : AppleListSection(
                    children: [
                      for (final e in shown)
                        PaymentLedgerRow(
                          entry: e,
                          df: df,
                          onTap: e.invoiceId == null
                              ? null
                              : () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => InvoiceDetailScreen(
                                          invoiceId: e.invoiceId!))),
                        ),
                    ],
                  ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.payments_outlined, size: 56, color: colors.tertiaryLabel),
          const SizedBox(height: 12),
          Text(l.paymentsEmpty,
              style: AppleTypography.headline.copyWith(color: colors.label)),
          const SizedBox(height: 4),
          Text(l.paymentsEmptySubtitle,
              textAlign: TextAlign.center,
              style: AppleTypography.subheadline
                  .copyWith(color: colors.secondaryLabel)),
        ],
      ),
    );
  }
}
