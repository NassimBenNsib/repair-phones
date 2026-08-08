import 'package:flutter/material.dart';

import '../../../core/design/apple_tokens.dart';

/// Barre de progression fine et arrondie, animée jusqu'à [value] (0..1).
class AppleProgressBar extends StatelessWidget {
  const AppleProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 6,
  });

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    final clamped = value.clamp(0.0, 1.0);
    final animate = !MediaQuery.disableAnimationsOf(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Stack(
        children: [
          Container(height: height, color: colors.fill),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth * clamped;
              return AnimatedContainer(
                duration: animate ? AppleMotion.slow : Duration.zero,
                curve: AppleMotion.standard,
                height: height,
                width: width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(height),
                  gradient: LinearGradient(
                    colors: [color.withValues(alpha: 0.7), color],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
