import 'package:flutter/material.dart';

import '../../../core/design/apple_tokens.dart';
import 'apple_button.dart';

/// État vide partagé des répertoires (clients, fournisseurs, comptes…).
///
/// Deux usages :
/// - **collection vide** : titre + sous-titre + un raccourci de création
///   optionnel ([actionLabel]/[onAction]) ;
/// - **aucun résultat** (recherche/filtre) : titre neutre, sans action.
class ListEmptyState extends StatelessWidget {
  const ListEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    final hasAction = actionLabel != null && onAction != null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: colors.tertiaryLabel),
          const SizedBox(height: 12),
          Text(title,
              textAlign: TextAlign.center,
              style: AppleTypography.headline.copyWith(color: colors.label)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!,
                textAlign: TextAlign.center,
                style: AppleTypography.subheadline
                    .copyWith(color: colors.secondaryLabel)),
          ],
          if (hasAction) ...[
            const SizedBox(height: 16),
            // Se réduit plutôt que de déborder si le libellé est long sur une
            // colonne étroite (répertoires en écran étroit).
            FittedBox(
              fit: BoxFit.scaleDown,
              child: AppleButton(
                label: actionLabel!,
                icon: Icons.add,
                style: AppleButtonStyle.tinted,
                onPressed: onAction,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
