import 'package:flutter/material.dart';

import '../../../core/design/apple_tokens.dart';

/// Surface de base du design system : coins squircle, fond « grouped »,
/// profondeur douce en clair et bordure hairline en sombre.
///
/// Sert de fondation aux autres composants (tuiles, listes, sections).
class AppleCard extends StatelessWidget {
  const AppleCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = AppleRadii.lg,
    this.color,
    this.onTap,
    this.elevated = false,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final VoidCallback? onTap;

  /// Ombre plus marquée (cartes mises en avant).
  final bool elevated;

  /// Bordure d'accentuation (ex. sélection). Prioritaire sur la bordure sombre.
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.apple;
    final colors = tokens.colors;

    // Bordure : accent si demandé, sinon hairline en sombre uniquement.
    final side = borderColor != null
        ? BorderSide(color: borderColor!, width: 2)
        : colors.isDark
            ? BorderSide(color: colors.separator, width: 0.5)
            : BorderSide.none;

    final surface = DecoratedBox(
      decoration: ShapeDecoration(
        color: color ?? colors.secondaryGroupedBackground,
        shape: AppleRadii.shape(radius, side: side),
        shadows: elevated ? tokens.cardShadowMedium : tokens.cardShadow,
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return surface;
    return _Pressable(onTap: onTap!, child: surface);
  }
}

/// Enveloppe un enfant d'un léger effet d'enfoncement (scale) au toucher, à la
/// manière des cartes iOS. Remplace l'encre Material (désactivée globalement).
class _Pressable extends StatefulWidget {
  const _Pressable({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (v != _down) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: AppleMotion.fast,
        curve: AppleMotion.standard,
        child: widget.child,
      ),
    );
  }
}
