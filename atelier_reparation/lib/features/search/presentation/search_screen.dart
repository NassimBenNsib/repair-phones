import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_list_row.dart';
import '../../../shared/widgets/apple/apple_list_section.dart';
import '../../../shared/widgets/apple/apple_scaffold.dart';
import '../../../shared/widgets/apple/apple_search_field.dart';
import '../../../shared/widgets/apple/section_header.dart';
import '../../clients/application/clients_controller.dart';
import '../../clients/presentation/client_detail_screen.dart';
import '../../invoices/application/invoices_controller.dart';
import '../../invoices/presentation/invoice_detail.dart';
import '../../quotes/application/quotes_controller.dart';
import '../../quotes/presentation/quote_detail.dart';
import '../../repairs/application/repairs_controller.dart';
import '../../repairs/presentation/repair_detail.dart';
import '../application/search.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  static const String routeName = 'search';
  static const String routePath = '/search';

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String _query = '';

  IconData _icon(SearchKind k) => switch (k) {
        SearchKind.client => Icons.person_outline,
        SearchKind.repair => Icons.build_outlined,
        SearchKind.invoice => Icons.receipt_long_outlined,
        SearchKind.quote => Icons.description_outlined,
      };

  String _group(AppLocalizations l, SearchKind k) => switch (k) {
        SearchKind.client => l.navClients,
        SearchKind.repair => l.navRepairs,
        SearchKind.invoice => l.navInvoices,
        SearchKind.quote => l.navQuotes,
      };

  void _open(SearchHit hit) {
    Widget? page;
    switch (hit.kind) {
      case SearchKind.client:
        final clients = ref.read(clientsProvider);
        for (final c in clients) {
          if (c.id == hit.id) {
            page = ClientDetailScreen(client: c);
            break;
          }
        }
      case SearchKind.repair:
        page = RepairDetailScreen(reference: hit.id);
      case SearchKind.invoice:
        page = InvoiceDetailScreen(invoiceId: hit.id);
      case SearchKind.quote:
        page = QuoteDetailScreen(quoteId: hit.id);
    }
    if (page != null) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => page!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;

    final hits = searchAll(
      _query,
      clients: ref.watch(clientsProvider),
      repairs: ref.watch(repairsProvider),
      invoices: ref.watch(invoicesProvider),
      quotes: ref.watch(quotesProvider),
    );

    return AppleScaffold(
      title: l.navSearch,
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
          sliver: SliverToBoxAdapter(
            child: AppleSearchField(
                hintText: l.searchPlaceholder,
                onChanged: (v) => setState(() => _query = v)),
          ),
        ),
        if (_query.trim().isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Column(children: [
                Icon(Icons.search, size: 56, color: colors.tertiaryLabel),
                const SizedBox(height: 12),
                Text(l.searchHint,
                    textAlign: TextAlign.center,
                    style: AppleTypography.subheadline
                        .copyWith(color: colors.secondaryLabel)),
              ]),
            ),
          )
        else if (hits.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Text(l.searchEmpty,
                    style: AppleTypography.headline
                        .copyWith(color: colors.label)),
              ),
            ),
          )
        else
          for (final kind in SearchKind.values)
            if (hits.any((h) => h.kind == kind)) ...[
              SliverPadding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 4),
                sliver: SliverToBoxAdapter(
                    child: SectionHeader(title: _group(l, kind))),
              ),
              SliverPadding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: AppleListSection(
                    children: [
                      for (final h in hits.where((h) => h.kind == kind))
                        AppleListRow(
                          leadingIcon: _icon(h.kind),
                          leadingTint: context.accentColor,
                          title: h.title,
                          subtitle: h.subtitle,
                          showChevron: true,
                          onTap: () => _open(h),
                        ),
                    ],
                  ),
                ),
              ),
            ],
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}
