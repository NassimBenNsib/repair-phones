import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Largeur du contenu des écrans.
enum ContentWidth {
  /// Contenu centré avec une largeur maximale (comportement historique).
  normal,

  /// Contenu occupant toute la largeur disponible.
  stretch;

  String label(AppLocalizations l) =>
      this == ContentWidth.normal ? l.contentNormal : l.contentStretch;
}

/// Comportement de la barre latérale (hors mobile).
enum SidebarMode {
  /// S'adapte à la largeur de la fenêtre (rail ↔ barre étendue).
  adaptive,

  /// Toujours étendue (icônes + libellés).
  expanded;

  String label(AppLocalizations l) =>
      this == SidebarMode.adaptive ? l.sidebarAdaptive : l.sidebarExpanded;
}

/// Style d'affichage de la liste des clients (liste, grille ou tableau).
enum ClientsListStyle {
  /// Liste verticale classique (avatar · nom · téléphone).
  list,

  /// Grille de cartes adaptative.
  grid,

  /// Tableau à colonnes (nom, type, téléphone, e-mail, ville).
  table;

  String label(AppLocalizations l) => switch (this) {
        ClientsListStyle.list => l.clientsViewList,
        ClientsListStyle.grid => l.clientsViewGrid,
        ClientsListStyle.table => l.clientsViewTable,
      };

  IconData get icon => switch (this) {
        ClientsListStyle.list => Icons.view_list,
        ClientsListStyle.grid => Icons.grid_view,
        ClientsListStyle.table => Icons.table_rows,
      };
}

/// Mode d'affichage des détails (réparations, clients…).
enum DetailLayout {
  /// Panneau latéral sur grand écran, page poussée sur petit écran.
  adaptive,

  /// Privilégie le panneau latéral dès qu'il y a la place.
  pane,

  /// Toujours une page séparée.
  page;

  String label(AppLocalizations l) => switch (this) {
        DetailLayout.adaptive => l.detailAdaptive,
        DetailLayout.pane => l.detailPane,
        DetailLayout.page => l.detailPage,
      };

  /// Décide d'un affichage maître/détail selon la largeur disponible.
  bool useTwoPane(double availableWidth) => switch (this) {
        DetailLayout.page => false,
        DetailLayout.pane => availableWidth >= 640,
        DetailLayout.adaptive => availableWidth >= 840,
      };
}
