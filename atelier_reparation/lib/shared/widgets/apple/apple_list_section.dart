import 'package:flutter/material.dart';
import 'package:smooth_corner/smooth_corner.dart';

import '../../../core/design/apple_tokens.dart';

/// Conteneur de liste groupée façon iOS : surface squircle unique dont les
/// lignes sont séparées par des « hairlines » indentées.
///
/// À utiliser avec [AppleListRow], mais accepte n'importe quel widget de ligne.
class AppleListSection extends StatelessWidget {
  const AppleListSection({
    super.key,
    required this.children,
    this.separatorIndent = 16,
  });

  final List<Widget> children;

  /// Indentation gauche du séparateur (aligne le trait sur le texte).
  final double separatorIndent;

  @override
  Widget build(BuildContext context) {
    final tokens = context.apple;
    final colors = tokens.colors;

    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i != children.length - 1) {
        rows.add(
          Divider(
            height: 0.5,
            thickness: 0.5,
            indent: separatorIndent,
            color: colors.separator,
          ),
        );
      }
    }

    return SmoothClipRRect(
      smoothness: AppleRadii.smoothing,
      borderRadius: AppleRadii.circular(AppleRadii.lg),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.secondaryGroupedBackground,
          border: colors.isDark
              ? Border.all(color: colors.separator, width: 0.5)
              : null,
          boxShadow: tokens.cardShadow,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: rows),
      ),
    );
  }
}
