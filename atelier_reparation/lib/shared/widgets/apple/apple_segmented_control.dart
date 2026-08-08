import 'package:flutter/cupertino.dart';

import '../../../core/design/apple_tokens.dart';

/// Contrôle segmenté glissant façon iOS (filtre de période, bascule de vue…).
///
/// Fin habillage de [CupertinoSlidingSegmentedControl] raccordé aux jetons
/// Apple pour rester cohérent avec le reste du design system.
class AppleSegmentedControl<T extends Object> extends StatelessWidget {
  const AppleSegmentedControl({
    super.key,
    required this.segments,
    required this.value,
    required this.onChanged,
  });

  /// Libellés indexés par valeur, dans l'ordre d'affichage.
  final Map<T, String> segments;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;

    return CupertinoSlidingSegmentedControl<T>(
      groupValue: value,
      backgroundColor: colors.fill,
      thumbColor: colors.secondaryGroupedBackground,
      padding: const EdgeInsets.all(3),
      onValueChanged: (v) {
        if (v != null) onChanged(v);
      },
      children: {
        for (final entry in segments.entries)
          entry.key: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              entry.value,
              style: AppleTypography.subheadline.copyWith(
                color: colors.label,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      },
    );
  }
}
