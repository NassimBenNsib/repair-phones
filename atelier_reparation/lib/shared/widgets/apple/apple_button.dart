import 'package:flutter/material.dart';

import '../../../core/design/apple_tokens.dart';

/// Variantes de bouton façon iOS.
enum AppleButtonStyle { filled, tinted, gray, plain, destructive }

/// Bouton du design system : coins squircle, retour tactile par mise à l'échelle
/// et déclinaisons de style/couleur inspirées d'iOS.
class AppleButton extends StatefulWidget {
  const AppleButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.style = AppleButtonStyle.filled,
    this.expand = false,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppleButtonStyle style;
  final bool expand;
  final bool loading;

  bool get _enabled => onPressed != null && !loading;

  @override
  State<AppleButton> createState() => _AppleButtonState();
}

class _AppleButtonState extends State<AppleButton> {
  bool _down = false;

  void _set(bool v) {
    if (v != _down) setState(() => _down = v);
  }

  ({Color bg, Color fg}) _palette(BuildContext context) {
    final colors = context.appleColors;
    final accent = context.accentColor;
    switch (widget.style) {
      case AppleButtonStyle.filled:
        return (bg: accent, fg: Colors.white);
      case AppleButtonStyle.tinted:
        return (bg: accent.withValues(alpha: 0.15), fg: accent);
      case AppleButtonStyle.gray:
        return (bg: colors.fill, fg: colors.label);
      case AppleButtonStyle.plain:
        return (bg: Colors.transparent, fg: accent);
      case AppleButtonStyle.destructive:
        return (bg: colors.red.withValues(alpha: 0.15), fg: colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _palette(context);
    final fg = widget._enabled ? p.fg : p.fg.withValues(alpha: 0.4);

    final child = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.loading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        else ...[
          if (widget.icon != null) ...[
            Icon(widget.icon, size: 19, color: fg),
            const SizedBox(width: 6),
          ],
          // `Flexible` (fit lâche) : le libellé garde sa taille naturelle quand
          // il y a de la place, mais se contracte au lieu de déborder sur les
          // boutons étroits ou dans les langues aux libellés plus longs.
          Flexible(
            child: Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppleTypography.headline.copyWith(color: fg),
            ),
          ),
        ],
      ],
    );

    return GestureDetector(
      onTapDown: widget._enabled ? (_) => _set(true) : null,
      onTapUp: widget._enabled ? (_) => _set(false) : null,
      onTapCancel: () => _set(false),
      onTap: widget._enabled ? widget.onPressed : null,
      child: AnimatedScale(
        scale: _down ? 0.96 : 1,
        duration: AppleMotion.fast,
        curve: AppleMotion.standard,
        child: Container(
          padding:
              const EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 13),
          decoration: ShapeDecoration(
            color: p.bg,
            shape: AppleRadii.shape(AppleRadii.md),
          ),
          child: child,
        ),
      ),
    );
  }
}
