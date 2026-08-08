import 'package:atelier_reparation/core/format/app_formats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_badge.dart';
import '../../../shared/widgets/apple/apple_button.dart';
import '../../../shared/widgets/apple/apple_card.dart';
import '../../../shared/widgets/apple/apple_chip.dart';
import '../../../shared/widgets/apple/apple_list_section.dart';
import '../../../shared/widgets/apple/apple_scaffold.dart';
import '../../../shared/widgets/apple/apple_sheet.dart';
import '../../../shared/widgets/apple/apple_text_field.dart';
import '../../clients/application/clients_controller.dart';
import '../../invoices/presentation/invoice_detail.dart';
import '../../payments/application/finance_filter.dart';
import '../../payments/presentation/finance_filter_bar.dart';
import '../application/cheques_controller.dart';
import '../domain/cheque.dart';

/// Registre des chèques : suivi de l'encaissement, filtrable par statut.
class ChequesScreen extends ConsumerStatefulWidget {
  const ChequesScreen({super.key});

  static const String routeName = 'cheques';
  static const String routePath = '/cheques';

  @override
  ConsumerState<ChequesScreen> createState() => _ChequesScreenState();
}

class _ChequesScreenState extends ConsumerState<ChequesScreen> {
  ChequeStatus? _statusFilter;
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
    final all = ref
        .watch(chequesProvider)
        .where((c) => matchesCheque(c, _filter, now))
        .toList()
      ..sort((a, b) => b.receivedDate.compareTo(a.receivedDate));
    final shown = _statusFilter == null
        ? all
        : all.where((c) => c.status == _statusFilter).toList();

    final pending = all.where((c) => c.isPendingCash);
    final toCollect = pending.fold<double>(0, (s, c) => s + c.amount);

    return AppleScaffold(
      title: l.navCheques,
      actions: [
        IconButton(
          onPressed: _add,
          icon: Icon(Icons.add, color: context.accentColor),
          tooltip: l.chequeAdd,
        ),
      ],
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 4),
          sliver: SliverToBoxAdapter(
            child: AppleCard(
              child: Row(children: [
                Icon(Icons.account_balance_outlined, color: colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('${l.chequesToCollect} (${pending.length})',
                      style: AppleTypography.body
                          .copyWith(color: colors.secondaryLabel)),
                ),
                Text(AppFormats.money(toCollect, decimals: 0),
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
              onChanged: (f) => setState(() => _filter = f),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
            child: Wrap(spacing: 8, runSpacing: 8, children: [
              AppleChip(
                  label: l.repairsFilterAll,
                  selected: _statusFilter == null,
                  onTap: () => setState(() => _statusFilter = null)),
              for (final s in ChequeStatus.values)
                AppleChip(
                    label: s.label(l),
                    selected: _statusFilter == s,
                    onTap: () => setState(() => _statusFilter = s)),
            ]),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: shown.isEmpty
                ? _Empty(l: l)
                : AppleListSection(
                    children: [
                      for (final c in shown)
                        _ChequeRow(cheque: c, df: df, onTap: () => _actions(c)),
                    ],
                  ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  /// Saisie manuelle d'un chèque (hors facture).
  Future<void> _add() async {
    final cheque = await showDialog<Cheque>(
      context: context,
      builder: (_) => const _ChequeDialog(),
    );
    if (cheque != null) ref.read(chequesProvider.notifier).add(cheque);
  }

  /// Feuille d'actions : ouvrir la facture + avancer le cycle de vie / rejeter.
  Future<void> _actions(Cheque c) async {
    final l = AppLocalizations.of(context);
    final ctrl = ref.read(chequesProvider.notifier);
    await showAppleSheet<void>(
      context: context,
      title: c.number.isEmpty ? l.navCheques : c.number,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (c.invoiceId != null) ...[
              AppleButton(
                label: l.navInvoices,
                icon: Icons.receipt_long_outlined,
                style: AppleButtonStyle.gray,
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          InvoiceDetailScreen(invoiceId: c.invoiceId!)));
                },
              ),
              const SizedBox(height: 8),
            ],
            if (c.status.next != null) ...[
              AppleButton(
                label: c.status.next == ChequeStatus.deposited
                    ? l.chequeMarkDeposited
                    : l.chequeMarkCleared,
                icon: Icons.check,
                onPressed: () {
                  ctrl.setStatus(c.id, c.status.next!);
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 8),
            ],
            if (c.status != ChequeStatus.cleared &&
                c.status != ChequeStatus.bounced)
              AppleButton(
                label: l.chequeBounceAction,
                icon: Icons.block,
                style: AppleButtonStyle.gray,
                onPressed: () {
                  ctrl.bounce(c.id);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// Dialogue de saisie d'un chèque.
class _ChequeDialog extends StatefulWidget {
  const _ChequeDialog();

  @override
  State<_ChequeDialog> createState() => _ChequeDialogState();
}

class _ChequeDialogState extends State<_ChequeDialog> {
  final _num = TextEditingController();
  final _bank = TextEditingController();
  final _drawer = TextEditingController();
  final _amount = TextEditingController();
  DateTime? _due;

  @override
  void dispose() {
    _num.dispose();
    _bank.dispose();
    _drawer.dispose();
    _amount.dispose();
    super.dispose();
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

  void _submit() {
    final value = double.tryParse(_amount.text.replaceAll(',', '.')) ?? 0;
    if (value <= 0) return;
    final now = DateTime.now();
    Navigator.of(context).pop(Cheque(
      id: 'chq-${now.microsecondsSinceEpoch}',
      number: _num.text.trim(),
      bank: _bank.text.trim(),
      drawer: _drawer.text.trim(),
      amount: value,
      receivedDate: now,
      dueDate: _due,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    return AlertDialog(
      backgroundColor: colors.secondaryGroupedBackground,
      title: Text(l.chequeAdd),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          AppleTextField(
              controller: _amount,
              label: l.invoiceAmount,
              suffix: AppFormats.symbol,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true)),
          const SizedBox(height: 10),
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
                    : AppFormats.dateFormat.format(_due!))),
          ]),
        ]),
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

class _ChequeRow extends StatelessWidget {
  const _ChequeRow(
      {required this.cheque, required this.df, required this.onTap});

  final Cheque cheque;
  final DateFormat df;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final c = cheque;
    final title = [c.number, c.bank].where((s) => s.isNotEmpty).join(' · ');
    final sub = [
      if (c.clientName.isNotEmpty) c.clientName,
      if (c.dueDate != null) '${l.chequeDueDate} ${df.format(c.dueDate!)}',
    ].join(' · ');
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        splashColor: colors.fill,
        highlightColor: colors.fill,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 16, vertical: 12),
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title.isEmpty ? l.navCheques : title,
                      style:
                          AppleTypography.body.copyWith(color: colors.label)),
                  if (sub.isNotEmpty)
                    Text(sub,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppleTypography.footnote
                            .copyWith(color: colors.secondaryLabel)),
                ],
              ),
            ),
            AppleBadge(
                label: c.status.label(l), color: c.status.color(colors)),
            const SizedBox(width: 8),
            Text(AppFormats.money(c.amount, decimals: 0),
                style: AppleTypography.subheadline.copyWith(
                    color: colors.label, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
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
        Icon(Icons.account_balance_wallet_outlined,
            size: 56, color: colors.tertiaryLabel),
        const SizedBox(height: 12),
        Text(l.chequesEmpty,
            style: AppleTypography.headline.copyWith(color: colors.label)),
        const SizedBox(height: 4),
        Text(l.chequesEmptySubtitle,
            textAlign: TextAlign.center,
            style: AppleTypography.subheadline
                .copyWith(color: colors.secondaryLabel)),
      ]),
    );
  }
}
