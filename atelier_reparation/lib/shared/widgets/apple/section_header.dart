import 'package:flutter/material.dart';

import '../../../core/design/apple_tokens.dart';

/// En-tête de section façon liste groupée iOS : titre proéminent et action
/// facultative alignée à droite (« Voir tout »).
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.fromLTRB(4, 0, 4, 10),
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;

    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppleTypography.title3.copyWith(color: colors.label),
            ),
          ),
          if (actionLabel != null)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: AppleTypography.body.copyWith(color: colors.blue),
              ),
            ),
        ],
      ),
    );
  }
}
