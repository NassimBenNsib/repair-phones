import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/design/apple_tokens.dart';

/// Bloc « squelette » à effet shimmer pour les états de chargement.
class Skeleton extends StatelessWidget {
  const Skeleton({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.radius = AppleRadii.sm,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    final base = colors.fill;
    final highlight = colors.isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.5);

    final box = Container(
      width: width,
      height: height,
      decoration: ShapeDecoration(
        color: base,
        shape: AppleRadii.shape(radius),
      ),
    );

    if (MediaQuery.disableAnimationsOf(context)) return box;

    return box
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 1200.ms,
          color: highlight,
        );
  }
}
