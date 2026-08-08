import 'package:flutter/material.dart';

/// Nœud générique d'une taxonomie (catégorie ou sous-catégorie, profondeur
/// illimitée via [parentId]). Partagé par toutes les taxonomies de l'app
/// (catalogue, prestations, …).
///
/// L'icône n'est pas résolue ici : le cœur ne connaît que la clé [iconKey] ;
/// chaque domaine fournit sa propre table d'icônes.
@immutable
class TaxonomyNode {
  const TaxonomyNode({
    required this.id,
    required this.name,
    this.parentId,
    this.iconKey = 'other',
    this.colorHex = 0xFF8E8E93,
    this.order = 0,
    this.code,
    this.description,
    this.active = true,
  });

  final String id;
  final String name;
  final String? parentId;
  final String iconKey;
  final int colorHex;
  final int order;

  /// Référence manuelle (« numéro » CRM), ex. `CAT-014`. Unique si renseignée.
  final String? code;
  final String? description;

  /// Actif ; `false` = archivé (masqué des sélecteurs, données conservées).
  final bool active;

  bool get isSub => parentId != null;
  Color get color => Color(colorHex);

  TaxonomyNode copyWith({
    String? name,
    String? parentId,
    bool clearParent = false,
    String? iconKey,
    int? colorHex,
    int? order,
    String? code,
    bool clearCode = false,
    String? description,
    bool clearDescription = false,
    bool? active,
  }) =>
      TaxonomyNode(
        id: id,
        name: name ?? this.name,
        parentId: clearParent ? null : (parentId ?? this.parentId),
        iconKey: iconKey ?? this.iconKey,
        colorHex: colorHex ?? this.colorHex,
        order: order ?? this.order,
        code: clearCode ? null : (code ?? this.code),
        description: clearDescription ? null : (description ?? this.description),
        active: active ?? this.active,
      );
}
