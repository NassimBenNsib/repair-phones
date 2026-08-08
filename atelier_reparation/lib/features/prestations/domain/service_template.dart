import 'package:flutter/foundation.dart';

/// Modèle de prestation réutilisable (catalogue) : nom, tarif, et attributs de
/// gestion (catégorie via [categoryId], durée estimée, TVA, coût, activation).
///
/// Sélectionné lors de l'ajout d'une prestation à une réparation / un devis /
/// une facture. La catégorie renvoie à un `ServiceCategoryNode` de la taxonomie.
@immutable
class ServiceTemplate {
  const ServiceTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.categoryId = 'other',
    this.durationMinutes,
    this.vatRate,
    this.cost,
    this.active = true,
    this.createdAt,
  });

  final String id;
  final String name;
  final String description;
  final double price;

  /// Identifiant de la catégorie (ou sous-catégorie) dans la taxonomie.
  final String categoryId;

  /// Durée estimée (minutes).
  final int? durationMinutes;

  /// Taux de TVA (ex. 0.20) — pré-remplissage / information.
  final double? vatRate;

  /// Coût interne (pour la marge).
  final double? cost;

  final bool active;
  final DateTime? createdAt;

  /// Marge (tarif − coût) si le coût est renseigné.
  double? get margin => cost == null ? null : price - cost!;

  ServiceTemplate copyWith({
    String? name,
    String? description,
    double? price,
    String? categoryId,
    int? durationMinutes,
    bool clearDuration = false,
    double? vatRate,
    bool clearVat = false,
    double? cost,
    bool clearCost = false,
    bool? active,
    DateTime? createdAt,
  }) =>
      ServiceTemplate(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        price: price ?? this.price,
        categoryId: categoryId ?? this.categoryId,
        durationMinutes:
            clearDuration ? null : (durationMinutes ?? this.durationMinutes),
        vatRate: clearVat ? null : (vatRate ?? this.vatRate),
        cost: clearCost ? null : (cost ?? this.cost),
        active: active ?? this.active,
        createdAt: createdAt ?? this.createdAt,
      );
}

/// Catalogue de prestations de démonstration.
const List<ServiceTemplate> sampleServiceTemplates = [
  ServiceTemplate(
    id: 's-diag',
    name: 'Diagnostic',
    description: 'Analyse complète de l\'appareil et devis.',
    price: 25,
    categoryId: 'diagnostic',
    durationMinutes: 30,
  ),
  ServiceTemplate(
    id: 's-screen',
    name: 'Remplacement écran',
    description: 'Dépose et pose d\'un écran neuf, calibrage.',
    price: 40,
    categoryId: 'screen',
    durationMinutes: 45,
  ),
  ServiceTemplate(
    id: 's-battery',
    name: 'Remplacement batterie',
    description: 'Changement de la batterie et test de charge.',
    price: 60,
    categoryId: 'battery',
    durationMinutes: 30,
  ),
  ServiceTemplate(
    id: 's-connector',
    name: 'Connecteur de charge',
    description: 'Remplacement du port / de la nappe de charge.',
    price: 45,
    categoryId: 'other',
    durationMinutes: 40,
  ),
  ServiceTemplate(
    id: 's-oxid',
    name: 'Désoxydation',
    description: 'Nettoyage après dégât des eaux, séchage.',
    price: 35,
    categoryId: 'other',
    durationMinutes: 60,
  ),
  ServiceTemplate(
    id: 's-backglass',
    name: 'Remplacement vitre arrière',
    description: 'Retrait au laser et pose d\'une vitre neuve.',
    price: 40,
    categoryId: 'screen',
    durationMinutes: 40,
  ),
  ServiceTemplate(
    id: 's-data',
    name: 'Transfert de données',
    description: 'Sauvegarde et transfert vers un autre appareil.',
    price: 20,
    categoryId: 'data',
    durationMinutes: 20,
  ),
  ServiceTemplate(
    id: 's-unlock',
    name: 'Déblocage',
    description: 'Déblocage opérateur ou réinitialisation.',
    price: 30,
    categoryId: 'software',
    durationMinutes: 15,
  ),
  ServiceTemplate(
    id: 's-software',
    name: 'Mise à jour logicielle',
    description: 'Restauration / mise à jour du système.',
    price: 15,
    categoryId: 'software',
    durationMinutes: 15,
  ),
  ServiceTemplate(
    id: 's-camera',
    name: 'Remplacement caméra',
    description: 'Changement du module caméra avant ou arrière.',
    price: 35,
    categoryId: 'other',
    durationMinutes: 30,
  ),
];
