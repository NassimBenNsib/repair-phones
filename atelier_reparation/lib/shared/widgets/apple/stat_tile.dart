import 'package:flutter/material.dart';

import '../../../core/design/apple_tokens.dart';
import 'apple_card.dart';

/// Tuile de statistique façon iOS : pastille d'icône teintée, grande valeur et
/// libellé secondaire. Remplace l'ancien `_StatCard`.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.tint,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;

  /// Teinte système (ex. `context.appleColors.blue`).
  final Color tint;
  final VoidCallback? onTap;

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
          Container(
            width: 40,
            height: 40,
            decoration: ShapeDecoration(
              color: tint.withValues(alpha: 0.16),
              shape: AppleRadii.shape(AppleRadii.md),
            ),
            child: Icon(icon, color: tint, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: AppleTypography.title1.copyWith(color: colors.label),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppleTypography.subheadline
                .copyWith(color: colors.secondaryLabel),
          ),
        ],
      ),
    );
  }
}
