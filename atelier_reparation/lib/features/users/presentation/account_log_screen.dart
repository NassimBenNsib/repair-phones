import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../core/format/app_formats.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_list_section.dart';
import '../../../shared/widgets/apple/apple_scaffold.dart';
import '../../../shared/widgets/apple/list_empty_state.dart';
import '../application/account_log_controller.dart';
import '../domain/account_event.dart';

/// Journal global des comptes : « qui a fait quoi », du plus récent au plus ancien.
class AccountLogScreen extends ConsumerWidget {
  const AccountLogScreen({super.key});

  static const String routeName = 'account-log';
  static const String routePath = '/account-log';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final events = ref.watch(accountLogProvider);
    return AppleScaffold(
      title: l.accountLog,
      slivers: [
        if (events.isEmpty)
          SliverToBoxAdapter(
            child: ListEmptyState(
                icon: Icons.history, title: l.listNoResults),
          )
        else
          SliverPadding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 24),
            sliver: SliverToBoxAdapter(
              child: AppleListSection(
                children: [
                  for (final e in events) AccountEventTile(event: e),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Ligne d'un événement du journal des comptes.
class AccountEventTile extends StatelessWidget {
  const AccountEventTile({super.key, required this.event, this.showActor = true});

  final AccountEvent event;
  final bool showActor;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final tint = event.kind.warns ? colors.orange : colors.blue;
    final sub = <String>[
      if (showActor && event.actorEmail.isNotEmpty) event.actorEmail,
      if (event.targetEmail != null &&
          event.targetEmail != event.actorEmail)
        '→ ${event.targetEmail}',
    ].join(' ');

    return Padding(
      padding:
          const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: ShapeDecoration(
              color: tint.withValues(alpha: 0.16),
              shape: AppleRadii.shape(AppleRadii.sm),
            ),
            child: Icon(event.kind.icon, size: 18, color: tint),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.kind.label(l),
                    style: AppleTypography.body.copyWith(color: colors.label)),
                if (sub.isNotEmpty)
                  Text(sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppleTypography.footnote
                          .copyWith(color: colors.secondaryLabel)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(AppFormats.date(event.at),
              style: AppleTypography.caption1
                  .copyWith(color: colors.tertiaryLabel)),
        ],
      ),
    );
  }
}
