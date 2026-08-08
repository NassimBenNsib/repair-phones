import 'package:atelier_reparation/core/format/app_formats.dart';
import 'package:flutter/material.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_card.dart';
import '../../../shared/widgets/apple/apple_chip.dart';
import '../../clients/presentation/client_picker_sheet.dart';
import '../../invoices/domain/invoice.dart';
import '../application/finance_filter.dart';
import '../application/payment_history.dart';

String _kindLabel(LedgerKind k, AppLocalizations l) => switch (k) {
      LedgerKind.invoicePayment => l.paymentKindInvoice,
      LedgerKind.deposit => l.paymentKindDeposit,
      LedgerKind.application => l.paymentKindApplication,
      LedgerKind.refund => l.paymentKindRefund,
    };

String _periodLabel(FinancePeriod p, AppLocalizations l) => switch (p) {
      FinancePeriod.all => l.financePeriodAll,
      FinancePeriod.month => l.financePeriodMonth,
      FinancePeriod.quarter => l.financePeriodQuarter,
      FinancePeriod.year => l.financePeriodYear,
      FinancePeriod.custom => l.financePeriodCustom,
    };

/// Sélecteur de période (chips) ; « Perso » ouvre un sélecteur de plage.
class PeriodSelector extends StatelessWidget {
  const PeriodSelector(
      {super.key, required this.filter, required this.onChanged});

  final FinanceFilter filter;
  final ValueChanged<FinanceFilter> onChanged;

  Future<void> _pick(BuildContext context, FinancePeriod p) async {
    if (p == FinancePeriod.custom) {
      final now = DateTime.now();
      final r = await showDateRangePicker(
        context: context,
        firstDate: DateTime(now.year - 3),
        lastDate: DateTime(now.year + 1),
        initialDateRange: filter.customRange,
      );
      if (r == null) return;
      onChanged(filter.copyWith(period: FinancePeriod.custom, customRange: r));
    } else {
      onChanged(filter.copyWith(period: p, clearCustomRange: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final p in FinancePeriod.values)
          AppleChip(
            label: _periodLabel(p, l),
            selected: filter.period == p,
            onTap: () => _pick(context, p),
          ),
      ],
    );
  }
}

/// Chip de filtre client : « Tous les clients » ou le client choisi (tap =
/// changer, ✕ = effacer).
class ClientFilterChip extends StatelessWidget {
  const ClientFilterChip({
    super.key,
    required this.filter,
    required this.clientName,
    required this.onChanged,
  });

  final FinanceFilter filter;
  final String? clientName; // résolu par l'écran depuis clientId
  final ValueChanged<FinanceFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final selected = filter.clientId != null;
    return AppleChip(
      label: selected ? (clientName ?? '—') : l.filterAllClients,
      selected: selected,
      onTap: () async {
        if (selected) {
          onChanged(filter.copyWith(clearClient: true));
          return;
        }
        final c = await showClientPickerSheet(context);
        if (c != null) onChanged(filter.copyWith(clientId: c.id));
      },
    );
  }
}

/// Carte de réconciliation : ventilation de la trésorerie nette du jeu filtré,
/// par type puis par moyen. Les parties se somment au total net affiché.
class FinanceBreakdownCard extends StatelessWidget {
  const FinanceBreakdownCard({super.key, required this.breakdown});

  final FinanceBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    if (breakdown.isEmpty) return const SizedBox.shrink();

    Widget row(String label, double value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(children: [
            Expanded(
              child: Text(label,
                  style: AppleTypography.footnote
                      .copyWith(color: colors.secondaryLabel)),
            ),
            Text(AppFormats.money(value, decimals: 0),
                style: AppleTypography.footnote.copyWith(
                    color: value < 0 ? colors.red : colors.label,
                    fontWeight: FontWeight.w600)),
          ]),
        );

    final typeRows = [
      for (final k in LedgerKind.values)
        if (breakdown.byType[k] != null)
          row(_kindLabel(k, l), breakdown.byType[k]!),
    ];
    final methodRows = [
      for (final m in PaymentMethod.values)
        if (breakdown.byMethod[m] != null)
          row(m.label(l), breakdown.byMethod[m]!),
    ];

    return AppleCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(l.financeBreakdown,
            style: AppleTypography.subheadline
                .copyWith(color: colors.label, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...typeRows,
        if (typeRows.isNotEmpty && methodRows.isNotEmpty) ...[
          const SizedBox(height: 6),
          Divider(height: 1, color: colors.separator),
          const SizedBox(height: 6),
        ],
        ...methodRows,
      ]),
    );
  }
}

/// Barre de filtres financiers : période + client + (types) + (moyens).
class FinanceFilterBar extends StatelessWidget {
  const FinanceFilterBar({
    super.key,
    required this.filter,
    required this.clientName,
    required this.onChanged,
    this.showTypes = false,
    this.showMethods = false,
  });

  final FinanceFilter filter;
  final String? clientName;
  final ValueChanged<FinanceFilter> onChanged;
  final bool showTypes;
  final bool showMethods;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PeriodSelector(filter: filter, onChanged: onChanged),
        const SizedBox(height: 8),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: ClientFilterChip(
              filter: filter, clientName: clientName, onChanged: onChanged),
        ),
        if (showTypes) ...[
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final k in LedgerKind.values)
              AppleChip(
                label: _kindLabel(k, l),
                selected: filter.types.contains(k),
                onTap: () {
                  final next = {...filter.types};
                  next.contains(k) ? next.remove(k) : next.add(k);
                  onChanged(filter.copyWith(types: next));
                },
              ),
          ]),
        ],
        if (showMethods) ...[
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final m in PaymentMethodX.manual)
              AppleChip(
                label: m.label(l),
                selected: filter.method == m,
                onTap: () => onChanged(filter.method == m
                    ? filter.copyWith(clearMethod: true)
                    : filter.copyWith(method: m)),
              ),
          ]),
        ],
      ],
    );
  }
}
