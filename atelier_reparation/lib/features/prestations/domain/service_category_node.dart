import 'package:flutter/material.dart';

import '../../../core/taxonomy/taxonomy_node.dart';

/// Une catégorie de prestations est un [TaxonomyNode] du moteur générique.
typedef ServiceCategoryNode = TaxonomyNode;

/// Résolution de l'icône propre aux prestations (le cœur ne connaît que la clé).
extension ServiceCategoryIcon on TaxonomyNode {
  IconData get icon => kServiceCategoryIcons[iconKey] ?? Icons.handyman;
}

/// Icônes disponibles pour une catégorie (clé stable → icône `const`, compatible
/// tree-shaking). Étendue au fil des besoins.
const Map<String, IconData> kServiceCategoryIcons = {
  'diagnostic': Icons.troubleshoot,
  'screen': Icons.smartphone,
  'battery': Icons.battery_charging_full,
  'software': Icons.system_update_alt,
  'data': Icons.sync_alt,
  'other': Icons.handyman,
  'camera': Icons.camera_alt_outlined,
  'water': Icons.water_drop_outlined,
  'lock': Icons.lock_outline,
  'audio': Icons.speaker_outlined,
  'network': Icons.wifi,
  'tools': Icons.build_outlined,
};

/// Palette de couleurs proposées pour une catégorie.
const List<int> kCategoryColors = [
  0xFF0A84FF, // bleu
  0xFF5E5CE6, // indigo
  0xFF34C759, // vert
  0xFFFF9500, // orange
  0xFF30B0C7, // cyan
  0xFF8E8E93, // gris
  0xFFFF375F, // rose
  0xFFBF5AF2, // violet
  0xFFFFD60A, // jaune
  0xFF64D2FF, // ciel
];

/// Catégories de démonstration (miroir de l'ancienne énumération). Les `id`
/// reprennent les anciens noms d'énumération → migration sans perte des
/// prestations existantes.
const List<ServiceCategoryNode> seedServiceCategories = [
  ServiceCategoryNode(
      id: 'diagnostic',
      name: 'Diagnostic',
      iconKey: 'diagnostic',
      colorHex: 0xFF0A84FF,
      order: 0),
  ServiceCategoryNode(
      id: 'screen',
      name: 'Écran',
      iconKey: 'screen',
      colorHex: 0xFF5E5CE6,
      order: 1),
  ServiceCategoryNode(
      id: 'battery',
      name: 'Batterie',
      iconKey: 'battery',
      colorHex: 0xFF34C759,
      order: 2),
  ServiceCategoryNode(
      id: 'software',
      name: 'Logiciel',
      iconKey: 'software',
      colorHex: 0xFFFF9500,
      order: 3),
  ServiceCategoryNode(
      id: 'data',
      name: 'Données',
      iconKey: 'data',
      colorHex: 0xFF30B0C7,
      order: 4),
  ServiceCategoryNode(
      id: 'other',
      name: 'Autre',
      iconKey: 'other',
      colorHex: 0xFF8E8E93,
      order: 5),
];
