import 'package:flutter/material.dart';

import '../../../core/taxonomy/taxonomy_node.dart';

/// Une catégorie du catalogue est un [TaxonomyNode] du moteur générique.
typedef ProductCategoryNode = TaxonomyNode;

/// Résolution de l'icône propre au catalogue (le cœur ne connaît que la clé).
extension ProductCategoryIcon on TaxonomyNode {
  IconData get icon =>
      kProductCategoryIcons[iconKey] ?? Icons.inventory_2_outlined;
}

/// Icônes disponibles pour une catégorie produit (clé stable → icône `const`,
/// compatible tree-shaking). Étendue au fil des besoins.
const Map<String, IconData> kProductCategoryIcons = {
  'part': Icons.memory,
  'accessory': Icons.headphones,
  'service': Icons.build_circle_outlined,
  'screen': Icons.smartphone,
  'battery': Icons.battery_charging_full,
  'connector': Icons.cable,
  'case': Icons.shield_outlined,
  'charger': Icons.power,
  'camera': Icons.camera_alt_outlined,
  'audio': Icons.speaker_outlined,
  'cable': Icons.usb,
  'tools': Icons.build_outlined,
  'other': Icons.inventory_2_outlined,
};

/// Palette de couleurs proposées pour une catégorie produit.
const List<int> kProductCategoryColors = [
  0xFF5E5CE6, // indigo
  0xFF30B0C7, // cyan
  0xFFFF9500, // orange
  0xFF0A84FF, // bleu
  0xFF34C759, // vert
  0xFF8E8E93, // gris
  0xFFFF375F, // rose
  0xFFBF5AF2, // violet
  0xFFFFD60A, // jaune
  0xFF64D2FF, // ciel
];

/// Catégories de démonstration. Les `id` des 3 racines reprennent les anciens
/// noms d'énumération (`part`/`accessory`/`service`) → migration **sans perte**
/// des produits existants. Quelques sous-catégories illustrent la hiérarchie.
const List<ProductCategoryNode> seedProductCategories = [
  // Racines (ex-énumération).
  ProductCategoryNode(
      id: 'part', name: 'Pièce', iconKey: 'part', colorHex: 0xFF5E5CE6, order: 0),
  ProductCategoryNode(
      id: 'accessory',
      name: 'Accessoire',
      iconKey: 'accessory',
      colorHex: 0xFF30B0C7,
      order: 1),
  ProductCategoryNode(
      id: 'service',
      name: 'Service',
      iconKey: 'service',
      colorHex: 0xFFFF9500,
      order: 2),
  // Sous-catégories de « Pièce ».
  ProductCategoryNode(
      id: 'part-screen',
      name: 'Écrans',
      parentId: 'part',
      iconKey: 'screen',
      colorHex: 0xFF5E5CE6),
  ProductCategoryNode(
      id: 'part-battery',
      name: 'Batteries',
      parentId: 'part',
      iconKey: 'battery',
      colorHex: 0xFF34C759),
  ProductCategoryNode(
      id: 'part-connector',
      name: 'Connecteurs',
      parentId: 'part',
      iconKey: 'connector',
      colorHex: 0xFF0A84FF),
  // Sous-catégories d'« Accessoire ».
  ProductCategoryNode(
      id: 'accessory-case',
      name: 'Coques',
      parentId: 'accessory',
      iconKey: 'case',
      colorHex: 0xFF30B0C7),
  ProductCategoryNode(
      id: 'accessory-charger',
      name: 'Chargeurs',
      parentId: 'accessory',
      iconKey: 'charger',
      colorHex: 0xFFFF9500),
];
