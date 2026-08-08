import 'package:atelier_reparation/core/format/app_formats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_badge.dart';
import '../../../shared/widgets/apple/apple_list_section.dart';
import '../../../shared/widgets/apple/apple_scaffold.dart';
import '../application/credit_notes_controller.dart';
import '../domain/credit_note.dart';
import 'credit_note_detail.dart';

/// Liste des avoirs (notes de crédit).
class CreditNotesScreen extends ConsumerWidget {
  const CreditNotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final items = ref.watch(creditNotesProvider);

    return AppleScaffold(
      title: l.creditNotes,
      slivers: [
        if (items.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Text(l.creditNoteEmpty,
                    style: AppleTypography.headline
                        .copyWith(color: colors.secondaryLabel)),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 24),
            sliver: SliverToBoxAdapter(
              child: AppleListSection(children: [
                for (final cn in items)
                  Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              CreditNoteDetailScreen(creditNoteId: cn.id))),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Row(children: [
                          Icon(Icons.receipt_long_outlined,
                              color: cn.status.color(colors)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    cn.isIssued
                                        ? cn.number
                                        : l.invoiceStatusDraft,
                                    style: AppleTypography.body
                                        .copyWith(color: colors.label)),
                                Text(cn.clientName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppleTypography.footnote.copyWith(
                                        color: colors.secondaryLabel)),
                              ],
                            ),
                          ),
                          AppleBadge(
                              label: cn.status.label(l),
                              color: cn.status.color(colors)),
                          const SizedBox(width: 8),
                          Text(AppFormats.money(cn.totals.total, decimals: 0),
                              style: AppleTypography.subheadline.copyWith(
                                  color: colors.label,
                                  fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
      ],
    );
  }
}
