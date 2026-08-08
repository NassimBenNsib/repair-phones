import 'package:flutter/material.dart';

import '../../core/design/apple_tokens.dart';
import '../../shared/widgets/apple/apple_avatar.dart';
import '../../shared/widgets/apple/apple_badge.dart';
import '../../shared/widgets/apple/apple_button.dart';
import '../../shared/widgets/apple/apple_card.dart';
import '../../shared/widgets/apple/apple_chart.dart';
import '../../shared/widgets/apple/apple_chip.dart';
import '../../shared/widgets/apple/apple_list_row.dart';
import '../../shared/widgets/apple/apple_list_section.dart';
import '../../shared/widgets/apple/apple_scaffold.dart';
import '../../shared/widgets/apple/apple_search_field.dart';
import '../../shared/widgets/apple/kpi_card.dart';
import '../../shared/widgets/apple/section_header.dart';
import '../../shared/widgets/apple/skeleton.dart';

/// Galerie de composants (outil de QA visuelle).
///
/// Affiche chaque composant du design system pour vérifier rapidement le rendu
/// dans chaque thème / accent / langue. Route : `/gallery`.
class ComponentGallery extends StatelessWidget {
  const ComponentGallery({super.key});

  static const String routeName = 'gallery';
  static const String routePath = '/gallery';

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;

    Widget block(String title, Widget child) => SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(title: title),
                child,
              ],
            ),
          ),
        );

    return AppleScaffold(
      title: 'Design Gallery',
      slivers: [
        block(
          'Buttons',
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              AppleButton(label: 'Filled', onPressed: () {}),
              AppleButton(
                  label: 'Tinted',
                  style: AppleButtonStyle.tinted,
                  onPressed: () {}),
              AppleButton(
                  label: 'Gray',
                  style: AppleButtonStyle.gray,
                  onPressed: () {}),
              AppleButton(
                  label: 'Plain',
                  style: AppleButtonStyle.plain,
                  onPressed: () {}),
              AppleButton(
                  label: 'Delete',
                  icon: Icons.delete_outline,
                  style: AppleButtonStyle.destructive,
                  onPressed: () {}),
              const AppleButton(label: 'Loading', loading: true),
            ],
          ),
        ),
        block(
          'Badges & Chips',
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppleBadge(label: 'Bleu', color: colors.blue),
              AppleBadge(
                  label: 'Vert', color: colors.green, icon: Icons.check),
              AppleBadge(label: 'Orange', color: colors.orange),
              AppleBadge(label: 'Rouge', color: colors.red),
              AppleChip(label: 'Actif', selected: true, onTap: () {}),
              AppleChip(label: 'Inactif', selected: false, onTap: () {}),
            ],
          ),
        ),
        block('Search field', const AppleSearchField(hintText: 'Rechercher…')),
        block(
          'Avatars',
          const Row(
            children: [
              AppleAvatar(name: 'Sofia Haddad'),
              SizedBox(width: 10),
              AppleAvatar(name: 'Lucas Martin'),
              SizedBox(width: 10),
              AppleAvatar(name: 'Emma Dubois'),
            ],
          ),
        ),
        block(
          'KPI card',
          SizedBox(
            width: 220,
            child: KpiCard(
              label: 'En cours',
              value: 42,
              icon: Icons.build,
              tint: colors.blue,
              trendLabel: '+8%',
              spark: const [3, 5, 4, 6, 5, 8, 12],
            ),
          ),
        ),
        block(
          'Bar chart',
          AppleCard(
            child: AppleBarChart(
              color: context.accentColor,
              values: const [4, 7, 5, 9, 6, 11, 8],
              labels: const ['L', 'M', 'M', 'J', 'V', 'S', 'D'],
            ),
          ),
        ),
        block(
          'List section',
          AppleListSection(
            children: [
              AppleListRow(
                  leadingIcon: Icons.settings,
                  leadingTint: colors.blue,
                  title: 'Ligne de navigation',
                  showChevron: true,
                  onTap: () {}),
              AppleListRow(
                  leadingIcon: Icons.info_outline,
                  leadingTint: colors.green,
                  title: 'Ligne avec valeur',
                  trailingText: 'Valeur'),
            ],
          ),
        ),
        block(
          'Skeleton (loading)',
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skeleton(width: 200, height: 18),
              SizedBox(height: 10),
              Skeleton(width: 140, height: 14),
            ],
          ),
        ),
      ],
    );
  }
}
