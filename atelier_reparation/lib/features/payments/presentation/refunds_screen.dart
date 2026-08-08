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
import '../../clients/domain/client_payment.dart';
import '../application/finance_filter.dart';
import '../application/payment_history.dart';
import 'finance_filter_bar.dart';
import 'ledger_row.dart';

/// Journal des remboursements (sorties de trésorerie vers les clients).
class RefundsScreen extends ConsumerStatefulWidget {
  const RefundsScreen({super.key});

  static const String routeName = 'refunds';
  static const String routePath = '/refunds';

  @override
  ConsumerState<RefundsScreen> createState() => _RefundsScreenState();
}

class _RefundsScreenState extends ConsumerState<RefundsScreen> {
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
    final refunds = ref
        .watch(clientPaymentsProvider)
        .where((e) => e.kind == ClientPaymentKind.refund)
        .toList();
    final entries = buildPaymentHistory(
      invoices: const [],
      clientPayments: refunds,
      clientNames: clientNames,
    ).where((e) => matchesLedger(e, _filter, now)).toList();
    final total = entries.fold<double>(0, (s, e) => s + e.amount);

    return AppleScaffold(
      title: l.navRefunds,
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 4),
          sliver: SliverToBoxAdapter(
            child: AppleCard(
              child: Row(children: [
                Icon(Icons.undo, color: colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(l.refundsTotal,
                      style: AppleTypography.body
                          .copyWith(color: colors.secondaryLabel)),
                ),
                Text(AppFormats.money(total, decimals: 0),
                    style: AppleTypography.title3.copyWith(
                        color: colors.label, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
            child: FinanceFilterBar(
              filter: _filter,
              clientName: clientNames[_filter.clientId],
              showMethods: true,
              onChanged: (f) => setState(() => _filter = f),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
          sliver: SliverToBoxAdapter(
            child: entries.isEmpty
                ? _Empty(l: l)
                : AppleListSection(
                    children: [
                      for (final e in entries)
                        PaymentLedgerRow(entry: e, df: df),
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
      child: Column(children: [
        Icon(Icons.undo, size: 56, color: colors.tertiaryLabel),
        const SizedBox(height: 12),
        Text(l.refundsEmpty,
            style: AppleTypography.headline.copyWith(color: colors.label)),
        const SizedBox(height: 4),
        Text(l.refundsEmptySubtitle,
            textAlign: TextAlign.center,
            style: AppleTypography.subheadline
                .copyWith(color: colors.secondaryLabel)),
      ]),
    );
  }
}
