import 'package:flutter/material.dart';

import '../../../core/design/apple_tokens.dart';
import 'animated_counter.dart';
import 'apple_badge.dart';
import 'apple_card.dart';
import 'apple_chart.dart';

/// Carte d'indicateur clé : pastille d'icône, valeur animée, variation
/// (tendance) et mini-courbe. Cœur visuel du tableau de bord 2.0.
class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.tint,
    this.trendLabel,
    this.trendUp = true,
    this.spark = const [],
    this.onTap,
    this.unit,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color tint;
  final String? trendLabel;
  final bool trendUp;
  final List<double> spark;
  final VoidCallback? onTap;

  /// Suffixe optionnel affiché après la valeur (ex. la devise).
  final String? unit;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;

    return AppleCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: ShapeDecoration(
                  color: tint.withValues(alpha: 0.16),
                  shape: AppleRadii.shape(AppleRadii.md),
                ),
                child: Icon(icon, color: tint, size: 21),
              ),
              const Spacer(),
              if (trendLabel != null)
                AppleBadge(
                  label: trendLabel!,
                  color: trendUp ? colors.green : colors.red,
                  icon: trendUp ? Icons.arrow_upward : Icons.arrow_downward,
                ),
            ],
          ),
          const SizedBox(height: 14),
          // Réduit au besoin pour ne jamais déborder sur les cartes étroites.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedCounter(
                  value: value,
                  style: AppleTypography.title1.copyWith(color: colors.label),
                ),
                if (unit != null) ...[
                  const SizedBox(width: 3),
                  Text(unit!,
                      style: AppleTypography.headline
                          .copyWith(color: colors.secondaryLabel)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppleTypography.subheadline
                .copyWith(color: colors.secondaryLabel),
          ),
          if (spark.isNotEmpty) ...[
            const SizedBox(height: 12),
            Sparkline(values: spark, color: tint, height: 36),
          ],
        ],
      ),
    );
  }
}
