import 'package:flutter/material.dart';
import 'package:smooth_corner/smooth_corner.dart';

import '../../../core/design/apple_tokens.dart';

/// Feuille modale façon iOS (coins hauts arrondis, poignée, fond « grouped »).
Future<T?> showAppleSheet<T>({
  required BuildContext context,
  required String title,
  required WidgetBuilder builder,
}) {
  final colors = context.appleColors;
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: colors.secondaryGroupedBackground,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    isScrollControlled: true,
    shape: SmoothRectangleBorder(
      smoothness: AppleRadii.smoothing,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          // Étire le contenu sur toute la largeur : les feuilles internes qui
          // utilisent `stretch`/`expand` reçoivent ainsi une largeur bornée.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 36,
                height: 5,
                decoration: ShapeDecoration(
                  color: colors.tertiaryLabel,
                  shape: AppleRadii.shape(AppleRadii.sm),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
              child: Text(
                title,
                style: AppleTypography.headline.copyWith(color: colors.label),
              ),
            ),
            Flexible(child: builder(context)),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

/// Option pour [showAppleSelectionSheet].
class AppleSheetOption<T> {
  const AppleSheetOption(this.value, this.label, {this.leading});
  final T value;
  final String label;
  final Widget? leading;
}

/// Feuille de sélection : liste d'options avec coche sur l'option active.
Future<T?> showAppleSelectionSheet<T>({
  required BuildContext context,
  required String title,
  required List<AppleSheetOption<T>> options,
  required T selected,
}) {
  return showAppleSheet<T>(
    context: context,
    title: title,
    builder: (context) {
      final colors = context.appleColors;
      final accent = context.accentColor;
      return ListView(
        shrinkWrap: true,
        children: [
          for (final o in options)
            ListTile(
              leading: o.leading,
              title: Text(
                o.label,
                style: AppleTypography.body.copyWith(color: colors.label),
              ),
              trailing: o.value == selected
                  ? Icon(Icons.check, color: accent)
                  : null,
              onTap: () => Navigator.of(context).pop(o.value),
            ),
        ],
      );
    },
  );
}
