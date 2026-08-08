import 'package:flutter/material.dart';

import '../../../core/design/apple_tokens.dart';

/// Puce de filtre sélectionnable (façon iOS), enrichie et adaptable :
/// pastille de couleur optionnelle, badge de compteur, retour tactile par mise
/// à l'échelle, et couleur de sélection personnalisable.
class AppleChip extends StatefulWidget {
  const AppleChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.dotColor,
    this.count,
    this.selectedColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Petit point de couleur en tête (ex. couleur de statut).
  final Color? dotColor;

  /// Compteur affiché dans une bulle en fin de puce.
  final int? count;

  /// Couleur de fond à l'état sélectionné (défaut : accent).
  final Color? selectedColor;

  @override
  State<AppleChip> createState() => _AppleChipState();
}

class _AppleChipState extends State<AppleChip> {
  bool _down = false;

  void _set(bool v) {
    if (v != _down) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    final active = widget.selectedColor ?? context.accentColor;
    final selected = widget.selected;

    final bg = selected ? active : colors.fill;
    final fg = selected ? Colors.white : colors.label;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.95 : 1,
        duration: AppleMotion.fast,
        curve: AppleMotion.standard,
        child: AnimatedContainer(
          duration: AppleMotion.fast,
          padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 8),
          decoration: ShapeDecoration(
            color: bg,
            shape: AppleRadii.shape(AppleRadii.xl),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.dotColor != null && !selected) ...[
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: widget.dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                widget.label,
                style: AppleTypography.subheadline
                    .copyWith(color: fg, fontWeight: FontWeight.w600),
              ),
              if (widget.count != null) ...[
                const SizedBox(width: 6),
                _CountBubble(
                  count: widget.count!,
                  selected: selected,
                  foreground: fg,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CountBubble extends StatelessWidget {
  const _CountBubble({
    required this.count,
    required this.selected,
    required this.foreground,
  });

  final int count;
  final bool selected;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    return Container(
      constraints: const BoxConstraints(minWidth: 18),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected
            ? Colors.white.withValues(alpha: 0.28)
            : colors.label.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        '$count',
        style: AppleTypography.caption1
            .copyWith(color: foreground, fontWeight: FontWeight.w700),
      ),
    );
  }
}
