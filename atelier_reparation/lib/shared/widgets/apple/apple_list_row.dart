import 'package:flutter/material.dart';

import '../../../core/design/apple_tokens.dart';

/// Ligne d'une liste groupée iOS.
///
/// Structure : pastille d'icône optionnelle, titre + sous-titre, valeur et/ou
/// chevron à droite. Utilisée dans [AppleListSection].
class AppleListRow extends StatelessWidget {
  const AppleListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.leadingTint,
    this.trailingText,
    this.showChevron = false,
    this.onTap,
    this.onLongPress,
  });

  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Color? leadingTint;
  final String? trailingText;
  final bool showChevron;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    final tint = leadingTint ?? colors.blue;

    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (leadingIcon != null) ...[
            Container(
              width: 30,
              height: 30,
              decoration: ShapeDecoration(
                color: tint,
                shape: AppleRadii.shape(AppleRadii.sm),
              ),
              child: Icon(leadingIcon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppleTypography.body.copyWith(color: colors.label),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppleTypography.footnote
                        .copyWith(color: colors.secondaryLabel),
                  ),
              ],
            ),
          ),
          if (trailingText != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 8),
              child: Text(
                trailingText!,
                style: AppleTypography.body
                    .copyWith(color: colors.secondaryLabel),
              ),
            ),
          if (showChevron)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 6),
              child: Icon(
                context.chevronForward,
                size: 20,
                color: colors.tertiaryLabel,
              ),
            ),
        ],
      ),
    );

    if (onTap == null && onLongPress == null) return row;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        splashColor: colors.fill,
        highlightColor: colors.fill,
        child: row,
      ),
    );
  }
}
