import 'package:atelier_reparation/core/format/app_formats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_badge.dart';
import '../../../shared/widgets/apple/apple_chip.dart';
import '../../../shared/widgets/apple/apple_list_section.dart';
import '../../../shared/widgets/apple/apple_scaffold.dart';
import '../../../shared/widgets/apple/apple_search_field.dart';
import '../../clients/presentation/client_picker_sheet.dart';
import '../application/invoices_controller.dart';
import '../domain/invoice.dart';
import 'credit_notes_screen.dart';
import 'invoice_detail.dart';

class InvoicesScreen extends ConsumerStatefulWidget {
  const InvoicesScreen({super.key});

  static const String routeName = 'invoices';
  static const String routePath = '/invoices';

  @override
  ConsumerState<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends ConsumerState<InvoicesScreen> {
  String _query = '';
  InvoiceStatus? _filter;
  String? _selectedId;

  List<Invoice> _filtered(List<Invoice> all) {
    final q = _query.trim().toLowerCase();
    final now = DateTime.now();
    return all.where((x) {
      final matchStatus =
          _filter == null || x.effectiveStatus(now) == _filter;
      final matchQuery = q.isEmpty ||
          x.number.toLowerCase().contains(q) ||
          x.clientName.toLowerCase().contains(q);
      return matchStatus && matchQuery;
    }).toList();
  }

  Future<void> _add() async {
    final client = await showClientPickerSheet(context);
    if (client == null) return;
    final i = ref
        .read(invoicesProvider.notifier)
        .create(clientId: client.id, clientName: client.displayName);
    if (!mounted) return;
    final twoPane = ref
        .read(settingsControllerProvider.select((s) => s.detailLayout))
        .useTwoPane(MediaQuery.sizeOf(context).width);
    if (twoPane) {
      setState(() => _selectedId = i.id);
    } else if (context.mounted) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => InvoiceDetailScreen(invoiceId: i.id)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailLayout =
        ref.watch(settingsControllerProvider.select((s) => s.detailLayout));
    return LayoutBuilder(
      builder: (context, c) => detailLayout.useTwoPane(c.maxWidth)
          ? _twoPane(context)
          : _singlePane(context),
    );
  }

  Widget _filterBar(AppLocalizations l) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          AppleChip(
              label: l.repairsFilterAll,
              selected: _filter == null,
              onTap: () => setState(() => _filter = null)),
          for (final s in InvoiceStatus.values)
            AppleChip(
                label: s.label(l),
                selected: _filter == s,
                onTap: () => setState(() => _filter = s)),
        ],
      ),
    );
  }

  Widget _singlePane(BuildContext context) {
    final l = AppLocalizations.of(context);
    final results = _filtered(ref.watch(invoicesProvider));
    return AppleScaffold(
      title: l.navInvoices,
      actions: [
        IconButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const CreditNotesScreen())),
            icon:
                Icon(Icons.receipt_long_outlined, color: context.accentColor),
            tooltip: l.creditNotes),
        IconButton(
            onPressed: _add,
            icon: Icon(Icons.add, color: context.accentColor),
            tooltip: l.invoiceNew),
      ],
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 4),
          sliver: SliverToBoxAdapter(
            child: AppleSearchField(
                hintText: l.invoiceSearch,
                onChanged: (v) => setState(() => _query = v)),
          ),
        ),
        SliverToBoxAdapter(child: _filterBar(l)),
        SliverPadding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: results.isEmpty
                ? _Empty(l: l)
                : AppleListSection(
                    children: [
                      for (final x in results)
                        _InvoiceRow(
                          invoice: x,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) =>
                                    InvoiceDetailScreen(invoiceId: x.id)),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _twoPane(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final all = ref.watch(invoicesProvider);
    final results = _filtered(all);
    final shown = all.any((x) => x.id == _selectedId) ? _selectedId : null;

    final list = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
          child: Row(children: [
            Expanded(
              child: Text(l.navInvoices,
                  style: AppleTypography.title1.copyWith(color: colors.label)),
            ),
            IconButton(
                onPressed: _add,
                icon: Icon(Icons.add, color: context.accentColor),
                tooltip: l.invoiceNew),
          ]),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
          child: AppleSearchField(
              hintText: l.invoiceSearch,
              onChanged: (v) => setState(() => _query = v)),
        ),
        _filterBar(l),
        Expanded(
          child: results.isEmpty
              ? _Empty(l: l)
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    AppleListSection(
                      children: [
                        for (final x in results)
                          _InvoiceRow(
                            invoice: x,
                            selected: x.id == shown,
                            onTap: () => setState(() => _selectedId = x.id),
                          ),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );

    return ColoredBox(
      color: colors.groupedBackground,
      child: SafeArea(
        child: shown == null
            ? list
            : Row(
                children: [
                  SizedBox(width: 380, child: list),
                  VerticalDivider(
                      width: 0.5, thickness: 0.5, color: colors.separator),
                  Expanded(
                    child: InvoiceDetailView(
                      key: ValueKey(shown),
                      invoiceId: shown,
                      onClose: () => setState(() => _selectedId = null),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  const _InvoiceRow(
      {required this.invoice, required this.onTap, this.selected = false});

  final Invoice invoice;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final status = invoice.effectiveStatus(DateTime.now());
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected
            ? context.accentColor.withValues(alpha: 0.10)
            : Colors.transparent,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          splashColor: colors.fill,
          highlightColor: colors.fill,
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(invoice.number.isEmpty ? l.invoiceStatusDraft : invoice.number,
                          style:
                              AppleTypography.body.copyWith(color: colors.label)),
                      Text(invoice.clientName,
                          style: AppleTypography.footnote
                              .copyWith(color: colors.secondaryLabel)),
                    ],
                  ),
                ),
                AppleBadge(label: status.label(l), color: status.color(colors)),
                const SizedBox(width: 8),
                Text(AppFormats.money(invoice.totals.total, decimals: 0),
                    style: AppleTypography.subheadline.copyWith(
                        color: colors.label, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
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
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 56, color: colors.tertiaryLabel),
          const SizedBox(height: 12),
          Text(l.invoiceEmpty,
              style: AppleTypography.headline.copyWith(color: colors.label)),
          const SizedBox(height: 4),
          Text(l.invoiceEmptySubtitle,
              textAlign: TextAlign.center,
              style: AppleTypography.subheadline
                  .copyWith(color: colors.secondaryLabel)),
        ],
      ),
    );
  }
}
