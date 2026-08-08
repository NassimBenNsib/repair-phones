import 'package:flutter/material.dart';

import '../../../core/design/apple_tokens.dart';

/// Pastille de statut colorée (badge) façon iOS : texte teinté sur fond
/// translucide de la même teinte.
class AppleBadge extends StatelessWidget {
  const AppleBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 4),
      decoration: ShapeDecoration(
        color: color.withValues(alpha: 0.15),
        shape: AppleRadii.shape(AppleRadii.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppleTypography.caption1.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
