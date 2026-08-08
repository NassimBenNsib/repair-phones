import 'package:flutter/material.dart';

import '../../../core/design/apple_tokens.dart';

/// Compteur animé : interpole la valeur affichée de 0 (ou de l'ancienne valeur)
/// jusqu'à [value], façon widgets de statistiques iOS.
class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 700),
  });

  final int value;
  final TextStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final effective = style ??
        AppleTypography.title1.copyWith(color: context.appleColors.label);

    if (reduceMotion) return Text('$value', style: effective);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: AppleMotion.standard,
      builder: (context, v, _) => Text('${v.round()}', style: effective),
    );
  }
}
