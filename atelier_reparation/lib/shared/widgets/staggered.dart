import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Entrée en cascade (fondu + léger glissement) respectant « réduire les
/// animations ». [index] échelonne le délai ; réutilisable par tout écran qui
/// empile des sections (tableau de bord, listes…).
Widget staggerIn(BuildContext context, int index, Widget child) {
  if (MediaQuery.disableAnimationsOf(context)) return child;
  final delay = (40 * index).ms;
  return child
      .animate()
      .fadeIn(duration: 350.ms, delay: delay)
      .slideY(begin: 0.08, end: 0, duration: 350.ms, delay: delay);
}
