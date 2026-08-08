import 'package:atelier_reparation/core/format/app_formats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_button.dart';
import '../../../shared/widgets/apple/apple_card.dart';
import '../../../shared/widgets/apple/apple_sheet.dart';
import '../../../shared/widgets/apple/apple_text_field.dart';
import '../../invoices/domain/invoice.dart';
import '../application/cash_register_controller.dart';
import '../application/payment_history.dart';
import '../domain/cash_session.dart';

/// Carte caisse : ouvre/clôture une session et affiche l'état espèces courant.
class CashRegisterCard extends ConsumerWidget {
  const CashRegisterCard({super.key, required this.ledger});
  final List<LedgerEntry> ledger;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    ref.watch(cashRegisterProvider);
    final ctrl = ref.read(cashRegisterProvider.notifier);
    final session = ctrl.openSession;

    if (session == null) {
      return AppleCard(
        child: Row(children: [
          Icon(Icons.point_of_sale, color: colors.secondaryLabel),
          const SizedBox(width: 12),
          Expanded(
            child: Text('${l.cashRegister} · ${l.cashClosed}',
                style: AppleTypography.body.copyWith(color: colors.label)),
          ),
          AppleButton(
            label: l.cashOpen,
            icon: Icons.lock_open,
            style: AppleButtonStyle.tinted,
            onPressed: () => _openSheet(context, ref),
          ),
        ]),
      );
    }

    final report = computeCashReport(session, ledger);
    return AppleCard(
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Icon(Icons.point_of_sale, color: context.accentColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(l.cashRegister,
                  style: AppleTypography.headline.copyWith(color: colors.label)),
            ),
            Text(l.cashSince(DateFormat('dd/MM HH:mm').format(session.openedAt)),
                style: AppleTypography.footnote
                    .copyWith(color: colors.secondaryLabel)),
          ]),
          const SizedBox(height: 12),
          _kv(l.cashOpeningFloat, report.openingFloat, colors),
          _kv('+ ${l.paymentMethodCash}', report.cashIn, colors, positive: true),
          if (report.cashOut > 0)
            _kv('− ${l.paymentKindRefund}', report.cashOut, colors,
                negative: true),
          Divider(color: colors.separator, height: 18),
          _kv(l.cashExpected, report.expectedCash, colors, bold: true),
          const SizedBox(height: 12),
          AppleButton(
            label: l.cashClose,
            icon: Icons.lock_outline,
            expand: true,
            onPressed: () => _closeSheet(context, ref, session, report),
          ),
        ],
      ),
    );
  }

  Widget _kv(String label, double value, AppleColors colors,
      {bool bold = false, bool positive = false, bool negative = false}) {
    final style = bold
        ? AppleTypography.headline.copyWith(color: colors.label)
        : AppleTypography.body.copyWith(color: colors.secondaryLabel);
    final valColor = positive
        ? colors.green
        : (negative ? colors.red : (bold ? colors.label : colors.label));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Expanded(child: Text(label, style: style)),
        Text(AppFormats.money(value, decimals: 2),
            style: (bold
                    ? AppleTypography.headline
                    : AppleTypography.body)
                .copyWith(color: valColor)),
      ]),
    );
  }

  Future<void> _openSheet(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final ctrl = TextEditingController(text: '0');
    return showAppleSheet<void>(
      context: context,
      title: l.cashOpen,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppleTextField(
                controller: ctrl,
                label: l.cashOpeningFloat,
                suffix: AppFormats.symbol,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 16),
            AppleButton(
              label: l.cashOpen,
              icon: Icons.check,
              expand: true,
              onPressed: () {
                final v = double.tryParse(
                        ctrl.text.trim().replaceAll(',', '.')) ??
                    0;
                ref.read(cashRegisterProvider.notifier).open(v);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _closeSheet(BuildContext context, WidgetRef ref,
          CashSession session, CashReport report) =>
      showAppleSheet<void>(
        context: context,
        title: l10nOf(context).cashClose,
        builder: (_) => _CloseForm(session: session, report: report),
      );
}

AppLocalizations l10nOf(BuildContext c) => AppLocalizations.of(c);

/// Formulaire de clôture : espèces comptées + aperçu de l'écart, puis Z.
class _CloseForm extends ConsumerStatefulWidget {
  const _CloseForm({required this.session, required this.report});
  final CashSession session;
  final CashReport report;

  @override
  ConsumerState<_CloseForm> createState() => _CloseFormState();
}

class _CloseFormState extends ConsumerState<_CloseForm> {
  final _counted = TextEditingController();

  @override
  void initState() {
    super.initState();
    _counted.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _counted.dispose();
    super.dispose();
  }

  double? get _countedValue => _counted.text.trim().isEmpty
      ? null
      : double.tryParse(_counted.text.trim().replaceAll(',', '.'));

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final r = widget.report;
    final counted = _countedValue;
    final variance = counted == null ? null : counted - r.expectedCash;

    Widget row(String k, String v, {Color? color, bool bold = false}) {
      final s = (bold ? AppleTypography.headline : AppleTypography.body)
          .copyWith(color: color ?? colors.label);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          Expanded(
              child: Text(k,
                  style: bold
                      ? s
                      : AppleTypography.body
                          .copyWith(color: colors.secondaryLabel))),
          Text(v, style: s),
        ]),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ventilation par mode.
          for (final e in r.byMethod.entries)
            row(e.key.label(l), AppFormats.money(e.value, decimals: 2)),
          Divider(color: colors.separator, height: 18),
          row(l.cashExpected, AppFormats.money(r.expectedCash, decimals: 2),
              bold: true),
          const SizedBox(height: 12),
          AppleTextField(
              controller: _counted,
              label: l.cashCounted,
              suffix: AppFormats.symbol,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true)),
          if (variance != null) ...[
            const SizedBox(height: 10),
            row(l.cashVariance, AppFormats.money(variance, decimals: 2),
                color: variance.abs() < 0.005
                    ? colors.green
                    : (variance < 0 ? colors.red : colors.orange),
                bold: true),
          ],
          const SizedBox(height: 16),
          AppleButton(
            label: l.cashClose,
            icon: Icons.check,
            expand: true,
            onPressed: counted == null
                ? null
                : () {
                    ref
                        .read(cashRegisterProvider.notifier)
                        .close(counted);
                    Navigator.of(context).pop();
                  },
          ),
        ],
      ),
    );
  }
}
