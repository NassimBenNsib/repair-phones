import 'package:flutter/material.dart';

import '../../core/design/apple_tokens.dart';
import '../../core/navigation/app_sections.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/apple/apple_scaffold.dart';

/// Écran générique « bientôt disponible » pour les sections non encore
/// implémentées. Conserve l'habillage du design system (grand titre, etc.).
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.section});

  final AppSection section;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final accent = context.accentColor;

    return AppleScaffold(
      title: section.label(l),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: ShapeDecoration(
                      color: accent.withValues(alpha: 0.14),
                      shape: AppleRadii.shape(AppleRadii.xxl),
                    ),
                    child: Icon(section.selectedIcon, color: accent, size: 44),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l.comingSoonTitle,
                    textAlign: TextAlign.center,
                    style: AppleTypography.title3.copyWith(color: colors.label),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l.comingSoonSubtitle,
                    textAlign: TextAlign.center,
                    style: AppleTypography.subheadline
                        .copyWith(color: colors.secondaryLabel),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
