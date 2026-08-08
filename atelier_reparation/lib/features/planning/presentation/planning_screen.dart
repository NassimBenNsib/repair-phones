import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_badge.dart';
import '../../../shared/widgets/apple/apple_list_section.dart';
import '../../../shared/widgets/apple/apple_scaffold.dart';
import '../../../shared/widgets/apple/section_header.dart';
import '../../repairs/application/repairs_controller.dart';
import '../../repairs/domain/repair.dart';
import '../../repairs/presentation/repair_detail.dart';

/// Regroupement d'une réparation par échéance.
enum _Bucket { overdue, today, tomorrow, thisWeek, later, noDate }

extension _BucketX on _Bucket {
  String title(AppLocalizations l) => switch (this) {
        _Bucket.overdue => l.planningOverdue,
        _Bucket.today => l.planningToday,
        _Bucket.tomorrow => l.planningTomorrow,
        _Bucket.thisWeek => l.planningThisWeek,
        _Bucket.later => l.planningLater,
        _Bucket.noDate => l.planningNoDate,
      };
}

/// Planning : réparations actives regroupées par échéance (`dueAt`), de la
/// plus urgente à la plus lointaine.
class PlanningScreen extends ConsumerWidget {
  const PlanningScreen({super.key});

  static const String routeName = 'planning';
  static const String routePath = '/planning';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Réparations non terminées, réparties par échéance.
    final groups = {for (final b in _Bucket.values) b: <Repair>[]};
    for (final r in ref.watch(repairsProvider)) {
      if (r.status.isClosed) continue;
      groups[_bucketFor(r.dueAt, today)]!.add(r);
    }
    // Tri interne par date d'échéance croissante.
    for (final list in groups.values) {
      list.sort((a, b) => (a.dueAt ?? DateTime(9999))
          .compareTo(b.dueAt ?? DateTime(9999)));
    }
    final hasAny = groups.values.any((g) => g.isNotEmpty);

    return AppleScaffold(
      title: l.navPlanning,
      slivers: [
        if (!hasAny)
          SliverFillRemaining(hasScrollBody: false, child: _Empty(l: l))
        else
          for (final b in _Bucket.values)
            if (groups[b]!.isNotEmpty) ...[
              SliverPadding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 4),
                sliver: SliverToBoxAdapter(
                  child: SectionHeader(
                      title: '${b.title(l)}  ·  ${groups[b]!.length}'),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: AppleListSection(
                    children: [
                      for (final r in groups[b]!)
                        _RepairRow(
                          repair: r,
                          overdue: b == _Bucket.overdue,
                          colors: colors,
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

  _Bucket _bucketFor(DateTime? due, DateTime today) {
    if (due == null) return _Bucket.noDate;
    final day = DateTime(due.year, due.month, due.day);
    final diff = day.difference(today).inDays;
    if (diff < 0) return _Bucket.overdue;
    if (diff == 0) return _Bucket.today;
    if (diff == 1) return _Bucket.tomorrow;
    if (diff <= 7) return _Bucket.thisWeek;
    return _Bucket.later;
  }
}

class _RepairRow extends StatelessWidget {
  const _RepairRow(
      {required this.repair, required this.overdue, required this.colors});

  final Repair repair;
  final bool overdue;
  final AppleColors colors;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final r = repair;
    final due = r.dueAt;
    final dueText = due == null
        ? ''
        : DateFormat(overdue ? 'dd/MM' : 'HH:mm').format(due);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => RepairDetailScreen(reference: r.reference))),
        splashColor: colors.fill,
        highlightColor: colors.fill,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  color: r.priority.color(colors).withValues(alpha: 0.16),
                  shape: AppleRadii.shape(AppleRadii.sm),
                ),
                child: Icon(r.kind.icon,
                    size: 17, color: r.priority.color(colors)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.device,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            AppleTypography.body.copyWith(color: colors.label)),
                    Text(
                        r.assignedTech == null
                            ? r.client
                            : '${r.client} · ${r.assignedTech}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppleTypography.footnote
                            .copyWith(color: colors.secondaryLabel)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (dueText.isNotEmpty)
                    Text(dueText,
                        style: AppleTypography.subheadline.copyWith(
                            color: overdue ? colors.red : colors.label,
                            fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  AppleBadge(
                      label: r.status.label(l), color: r.status.color(colors)),
                ],
              ),
            ],
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_available_outlined,
              size: 56, color: colors.tertiaryLabel),
          const SizedBox(height: 12),
          Text(l.planningEmpty,
              style: AppleTypography.headline.copyWith(color: colors.label)),
          const SizedBox(height: 4),
          Text(l.planningEmptySubtitle,
              textAlign: TextAlign.center,
              style: AppleTypography.subheadline
                  .copyWith(color: colors.secondaryLabel)),
        ],
      ),
    );
  }
}
