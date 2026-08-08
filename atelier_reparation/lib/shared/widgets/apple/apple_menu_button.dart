import 'package:flutter/material.dart';

import '../../../core/design/apple_tokens.dart';
import 'apple_button.dart';

/// Bouton à menu déroulant (pull-down) façon iOS/macOS, adapté à toutes les
/// plateformes : le menu s'ancre sous le bouton (idéal desktop/web) et
/// fonctionne au toucher.
class AppleMenuButton<T> extends StatelessWidget {
  const AppleMenuButton({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.options,
    required this.onSelected,
    this.anchorBuilder,
  });

  final String label;
  final IconData icon;
  final T value;

  /// Options ordonnées (valeur → libellé).
  final Map<T, String> options;
  final ValueChanged<T> onSelected;

  /// Ancre personnalisée (ex. bouton-icône). Si nul, un `AppleButton` gris est
  /// utilisé.
  final Widget Function(BuildContext, MenuController)? anchorBuilder;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    final accent = context.accentColor;

    return MenuAnchor(
      alignmentOffset: const Offset(0, 6),
      style: MenuStyle(
        backgroundColor:
            WidgetStatePropertyAll(colors.secondaryGroupedBackground),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(8),
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 6)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: AppleRadii.circular(AppleRadii.lg),
            side: BorderSide(color: colors.separator, width: 0.5),
          ),
        ),
      ),
      menuChildren: [
        for (final entry in options.entries)
          MenuItemButton(
            leadingIcon: SizedBox(
              width: 20,
              child: entry.key == value
                  ? Icon(Icons.check, size: 18, color: accent)
                  : null,
            ),
            style: MenuItemButton.styleFrom(
              foregroundColor: colors.label,
              padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 14, vertical: 4),
            ),
            onPressed: () => onSelected(entry.key),
            child: Text(entry.value, style: AppleTypography.body),
          ),
      ],
      builder: (context, controller, child) =>
          anchorBuilder?.call(context, controller) ??
          AppleButton(
            label: label,
            icon: icon,
            style: AppleButtonStyle.gray,
            onPressed: () =>
                controller.isOpen ? controller.close() : controller.open(),
          ),
    );
  }
}
