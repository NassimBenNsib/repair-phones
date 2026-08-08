import 'package:flutter/widgets.dart';

/// Ombres douces à la manière d'Apple : diffuses, peu opaques, léger décalage
/// vertical. En thème sombre, la profondeur passe plutôt par une bordure
/// « hairline » (voir composants) — les ombres y sont donc quasi nulles.
class AppleShadows {
  const AppleShadows._();

  static List<BoxShadow> cardLow(Brightness brightness) {
    if (brightness == Brightness.dark) return const [];
    return const [
      BoxShadow(
        color: Color(0x14000000), // ~8 %
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
      BoxShadow(
        color: Color(0x0A000000), // ~4 %
        blurRadius: 2,
        offset: Offset(0, 1),
      ),
    ];
  }

  static List<BoxShadow> cardMedium(Brightness brightness) {
    if (brightness == Brightness.dark) return const [];
    return const [
      BoxShadow(
        color: Color(0x1F000000), // ~12 %
        blurRadius: 24,
        offset: Offset(0, 8),
      ),
      BoxShadow(
        color: Color(0x0F000000),
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ];
  }
}
