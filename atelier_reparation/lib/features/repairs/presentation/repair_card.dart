import 'package:atelier_reparation/core/format/app_formats.dart';
import 'package:flutter/material.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_badge.dart';
import '../../../shared/widgets/apple/apple_card.dart';
import '../../../shared/widgets/apple/apple_progress_bar.dart';
import '../domain/repair.dart';

/// Carte de réparation du flux : icône teintée par statut, badges de statut et
/// priorité, barre de progression pour les réparations en cours.
class RepairCard extends StatelessWidget {
  const RepairCard({
    super.key,
    required this.repair,
    required this.onTap,
    this.selected = false,
  });

  final Repair repair;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final accent = context.accentColor;
    final statusColor = repair.status.color(colors);

    // Fond sélectionné : teinte d'accent OPAQUE et légère (posée sur la surface)
    // → reste clair et lisible, sans laisser transparaître le fond gris.
    final selectedBg = Color.alphaBlend(
      accent.withValues(alpha: 0.10),
      colors.secondaryGroupedBackground,
    );

    return AppleCard(
      onTap: onTap,
      color: selected ? selectedBg : null,
      borderColor: selected ? accent : null,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: ShapeDecoration(
                  color: statusColor.withValues(alpha: 0.16),
                  shape: AppleRadii.shape(AppleRadii.md),
                ),
                child: Icon(repair.kind.icon, color: statusColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      repair.device,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppleTypography.headline
                          .copyWith(color: colors.label),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${repair.reference} · ${repair.client}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppleTypography.footnote
                          .copyWith(color: colors.secondaryLabel),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(context.chevronForward, size: 20, color: colors.tertiaryLabel),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              AppleBadge(label: repair.status.label(l), color: statusColor),
              const SizedBox(width: 8),
              if (repair.priority == RepairPriority.high)
                AppleBadge(
                  label: repair.priority.label(l),
                  color: repair.priority.color(colors),
                  icon: Icons.priority_high,
                ),
              const Spacer(),
              Text(
                AppFormats.money(repair.total, decimals: 0),
                style: AppleTypography.subheadline.copyWith(
                  color: colors.label,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (repair.status.isActive) ...[
            const SizedBox(height: 12),
            AppleProgressBar(value: repair.progress, color: statusColor),
          ],
        ],
      ),
    );
  }
}
