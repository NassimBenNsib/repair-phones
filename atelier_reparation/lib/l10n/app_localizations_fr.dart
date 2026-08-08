// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Atelier Réparation';

  @override
  String get navDashboard => 'Tableau de bord';

  @override
  String get navRepairs => 'Réparations';

  @override
  String get navClients => 'Clients';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get dashboardTitle => 'Tableau de bord';

  @override
  String get dashboardOverview => 'Aperçu';

  @override
  String get dashboardRecentRepairs => 'Réparations récentes';

  @override
  String get dashboardActivity => 'Activité';

  @override
  String get dashboardQuickActions => 'Actions rapides';

  @override
  String get dashboardNoRepairs => 'Aucune réparation';

  @override
  String get dashboardNoRepairsSubtitle =>
      'Les nouvelles fiches apparaîtront ici.';

  @override
  String get dashboardNotifications => 'Notifications';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsRecent => 'Activité récente';

  @override
  String get statInProgress => 'En cours';

  @override
  String get statAwaitingParts => 'En attente de pièces';

  @override
  String get statCompleted => 'Terminées';

  @override
  String get statClients => 'Clients';

  @override
  String get statRevenue => 'Chiffre d\'affaires';

  @override
  String get statUnpaid => 'Impayés';

  @override
  String get statAwaitingPartsShort => 'Pièces';

  @override
  String get reportsFinance => 'Finances';

  @override
  String get reportsCollected => 'Encaissé';

  @override
  String get reportsAcceptanceRate => 'Taux d\'acceptation';

  @override
  String get reportsEmpty => 'Pas encore de données';

  @override
  String get companyName => 'Nom de l\'établissement';

  @override
  String get companyPostalCode => 'Code postal';

  @override
  String get companySiret => 'SIRET';

  @override
  String get companyLogo => 'Logo';

  @override
  String get companyLogoAdd => 'Ajouter un logo';

  @override
  String get companyLogoRemove => 'Retirer le logo';

  @override
  String get paymentsEmpty => 'Aucun paiement';

  @override
  String get paymentsEmptySubtitle =>
      'Les encaissements enregistrés apparaîtront ici.';

  @override
  String get paymentsTotalCollected => 'Total encaissé';

  @override
  String get cashRegister => 'Caisse';

  @override
  String get cashOpen => 'Ouvrir la caisse';

  @override
  String get cashClose => 'Clôturer la caisse';

  @override
  String get cashOpeningFloat => 'Fond de caisse';

  @override
  String get cashExpected => 'Espèces attendues';

  @override
  String get cashCounted => 'Espèces comptées';

  @override
  String get cashVariance => 'Écart';

  @override
  String get cashClosed => 'Caisse fermée';

  @override
  String cashSince(Object time) {
    return 'Ouverte depuis $time';
  }

  @override
  String get inventoryOut => 'Rupture';

  @override
  String get inventoryLow => 'Stock bas';

  @override
  String get inventoryOk => 'En stock';

  @override
  String get inventoryEmpty => 'Aucun article';

  @override
  String get inventoryEmptySubtitle => 'Ajoutez des produits au catalogue.';

  @override
  String get inventoryAlerts => 'Alertes de stock';

  @override
  String get planningOverdue => 'En retard';

  @override
  String get planningToday => 'Aujourd\'hui';

  @override
  String get planningTomorrow => 'Demain';

  @override
  String get planningThisWeek => 'Cette semaine';

  @override
  String get planningLater => 'Plus tard';

  @override
  String get planningNoDate => 'Sans échéance';

  @override
  String get planningEmpty => 'Rien de planifié';

  @override
  String get planningEmptySubtitle =>
      'Les réparations avec une échéance apparaîtront ici.';

  @override
  String get accountingHt => 'HT';

  @override
  String get accountingVat => 'TVA';

  @override
  String get accountingTtc => 'TTC';

  @override
  String get accountingVatCollected => 'TVA collectée';

  @override
  String get accountingVatDeductible => 'TVA déductible';

  @override
  String get accountingVatNet => 'TVA nette due';

  @override
  String get vatBasisAccrual => 'Débits';

  @override
  String get vatBasisCash => 'Encaissements';

  @override
  String get accountingPurchases => 'Achats (HT)';

  @override
  String get accountingSupplierPaid => 'Réglé fournisseurs';

  @override
  String get accountingSupplierPayable => 'Dû fournisseurs';

  @override
  String get accountingMargin => 'Marge brute';

  @override
  String get accountingResult => 'Résultat net';

  @override
  String get expenses => 'Dépenses';

  @override
  String get expenseNew => 'Nouvelle dépense';

  @override
  String get expenseLabel => 'Libellé';

  @override
  String get expenseAmountHt => 'Montant HT';

  @override
  String get expensesEmpty => 'Aucune dépense';

  @override
  String get expenseCatRent => 'Loyer';

  @override
  String get expenseCatUtilities => 'Énergie & fluides';

  @override
  String get expenseCatSupplies => 'Fournitures';

  @override
  String get expenseCatMarketing => 'Marketing';

  @override
  String get expenseCatTransport => 'Transport';

  @override
  String get expenseCatSalaries => 'Salaires';

  @override
  String get expenseCatTax => 'Taxes & impôts';

  @override
  String get expenseCatOther => 'Autre';

  @override
  String get accountingVatSection => 'TVA & achats';

  @override
  String get accountingEmpty => 'Aucune facture émise';

  @override
  String get settingsBackup => 'Sauvegarde & export';

  @override
  String get settingsBackupSubtitle => 'Exporter ou restaurer vos données';

  @override
  String get backupExport => 'Exporter les données (JSON)';

  @override
  String get backupImport => 'Importer une sauvegarde';

  @override
  String get backupExportCsvAccounting => 'Exporter la comptabilité (CSV)';

  @override
  String get backupExportCsvClients => 'Exporter les clients (CSV)';

  @override
  String get backupDone => 'Données exportées';

  @override
  String get backupImported => 'Données importées';

  @override
  String get backupFailed => 'Opération impossible';

  @override
  String get devicesSearch => 'Rechercher un appareil';

  @override
  String get devicesEmpty => 'Aucun appareil';

  @override
  String get devicesEmptySubtitle =>
      'Les appareils des réparations apparaîtront ici.';

  @override
  String get deviceRepairs => 'Réparations';

  @override
  String get deviceIdentity => 'Identité';

  @override
  String get deviceOwner => 'Propriétaire';

  @override
  String get deviceSerial => 'IMEI / N° série';

  @override
  String get deviceWarranty => 'Garantie';

  @override
  String get deviceHistory => 'Historique';

  @override
  String get assistantPlaceholder => 'Posez une question sur votre atelier…';

  @override
  String get assistantNoKey =>
      'Ajoutez votre clé API Anthropic pour activer l\'assistant.';

  @override
  String get assistantApiKey => 'Clé API Anthropic';

  @override
  String get assistantModel => 'Modèle';

  @override
  String get assistantThinking => 'Réflexion…';

  @override
  String get assistantError =>
      'La requête a échoué. Vérifiez la clé et la connexion.';

  @override
  String get assistantConfig => 'Configuration de l\'assistant';

  @override
  String get assistantIntro =>
      'Bonjour ! Posez-moi une question sur vos réparations, factures ou stock.';

  @override
  String get settingsStorage => 'Stockage';

  @override
  String get settingsStorageLocal => 'Local · serveur bientôt';

  @override
  String get navSearch => 'Recherche';

  @override
  String get searchPlaceholder => 'Rechercher partout…';

  @override
  String get searchHint => 'Clients, réparations, factures, devis';

  @override
  String get searchEmpty => 'Aucun résultat';

  @override
  String get greetingMorning => 'Bonjour';

  @override
  String get greetingAfternoon => 'Bon après-midi';

  @override
  String get greetingEvening => 'Bonsoir';

  @override
  String get periodYear => 'Année';

  @override
  String get dashboardVsPrevious => 'vs période préc.';

  @override
  String get dashboardRevenueTrend => 'Chiffre d\'affaires';

  @override
  String get dashboardStatusMix => 'Réparations';

  @override
  String get dashboardNeedsAttention => 'À traiter';

  @override
  String get quickNewRepair => 'Réparation';

  @override
  String get quickNewQuote => 'Devis';

  @override
  String get quickNewInvoice => 'Facture';

  @override
  String get alertOverdueInvoices => 'Factures en retard';

  @override
  String get alertLowStock => 'Stock bas';

  @override
  String get alertUnassigned => 'Non assignées';

  @override
  String get alertOverdueDeliveries => 'Livraisons en retard';

  @override
  String get alertOverduePayables => 'Fournisseurs à payer';

  @override
  String get dashboardPriorities => 'Priorités';

  @override
  String dashboardOverdueBy(Object days) {
    return 'En retard de $days j';
  }

  @override
  String get alertDueToday => 'Échéances du jour';

  @override
  String get alertAwaitingParts => 'En attente de pièces';

  @override
  String get dashboardActiveRepairs => 'En cours';

  @override
  String get dashboardCompleted => 'Terminées';

  @override
  String get dashboardCollected => 'Encaissé';

  @override
  String get dashboardAllClear => 'Tout est à jour';

  @override
  String trendSince(String value) {
    return '$value vs période précédente';
  }

  @override
  String get periodDay => 'Jour';

  @override
  String get periodWeek => 'Semaine';

  @override
  String get periodMonth => 'Mois';

  @override
  String get repairsTitle => 'Réparations';

  @override
  String get repairsNew => 'Nouvelle réparation';

  @override
  String get repairsSearch => 'Rechercher une réparation';

  @override
  String get repairsEmpty => 'Aucune réparation enregistrée';

  @override
  String get repairsEmptySubtitle =>
      'Créez une fiche pour suivre une intervention.';

  @override
  String repairsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count réparations',
      one: '1 réparation',
      zero: 'Aucune réparation',
    );
    return '$_temp0';
  }

  @override
  String get statusInProgress => 'En cours';

  @override
  String get statusAwaitingParts => 'En attente';

  @override
  String get statusCompleted => 'Terminée';

  @override
  String get statusReceived => 'Reçue';

  @override
  String get statusDiagnosing => 'Diagnostic';

  @override
  String get statusDelivered => 'Livrée';

  @override
  String get statusCancelled => 'Annulée';

  @override
  String repairEventStatus(Object status) {
    return 'Statut : $status';
  }

  @override
  String repairEventTech(Object tech) {
    return 'Assignée à $tech';
  }

  @override
  String get repairEventTechCleared => 'Technicien retiré';

  @override
  String repairEventPayment(Object status) {
    return 'Paiement : $status';
  }

  @override
  String get repairTimeline => 'Suivi';

  @override
  String get repairNotify => 'Notifier le client';

  @override
  String get notifyTemplate => 'Modèle';

  @override
  String get notifyMessage => 'Message';

  @override
  String get notifySend => 'Envoyer';

  @override
  String get notifyNoContact => 'Aucun contact pour ce canal';

  @override
  String get repairSectionComms => 'Communications';

  @override
  String get repairAdvance => 'Faire avancer';

  @override
  String get clientsTitle => 'Clients';

  @override
  String get clientsNew => 'Nouveau client';

  @override
  String get clientsSearch => 'Rechercher un client';

  @override
  String get clientsEmpty => 'Aucun client enregistré';

  @override
  String get clientsEmptySubtitle => 'Ajoutez un client pour commencer.';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsThemeMode => 'Thème';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsThemeSystem => 'Système';

  @override
  String get settingsAccent => 'Couleur d\'accent';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsGeneral => 'Général';

  @override
  String get settingsWorkshopInfo => 'Informations de l\'atelier';

  @override
  String get settingsWorkshopInfoSubtitle => 'Nom, adresse, coordonnées';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsAboutDescription =>
      'Application de gestion pour atelier de réparation.';

  @override
  String get languageSystem => 'Automatique';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageArabic => 'Arabe';

  @override
  String get languageSpanish => 'Espagnol';

  @override
  String get accentBlue => 'Bleu';

  @override
  String get accentGreen => 'Vert';

  @override
  String get accentOrange => 'Orange';

  @override
  String get accentRed => 'Rouge';

  @override
  String get accentIndigo => 'Indigo';

  @override
  String get accentPurple => 'Violet';

  @override
  String get accentTeal => 'Turquoise';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonDone => 'Terminé';

  @override
  String get commonSeeAll => 'Voir tout';

  @override
  String get commonShowLess => 'Réduire';

  @override
  String get commonSearch => 'Rechercher';

  @override
  String get repairsFilterAll => 'Toutes';

  @override
  String get repairPriority => 'Priorité';

  @override
  String get repairPriorityLow => 'Basse';

  @override
  String get repairPriorityNormal => 'Normale';

  @override
  String get repairPriorityHigh => 'Haute';

  @override
  String repairUpdated(String when) {
    return 'Mis à jour $when';
  }

  @override
  String get repairDetailSelectTitle => 'Aucune réparation sélectionnée';

  @override
  String get repairDetailSelectSubtitle =>
      'Sélectionnez une réparation pour voir les détails.';

  @override
  String get repairSectionClient => 'Client';

  @override
  String get repairSectionProgress => 'Progression';

  @override
  String get repairSectionTimeline => 'Suivi';

  @override
  String get repairSectionParts => 'Pièces';

  @override
  String get repairSectionNotes => 'Notes';

  @override
  String get repairCost => 'Coût estimé';

  @override
  String get repairMarkComplete => 'Marquer comme terminée';

  @override
  String get repairContactClient => 'Contacter le client';

  @override
  String get repairEventCreated => 'Fiche créée';

  @override
  String get repairEventDiagnosed => 'Diagnostic effectué';

  @override
  String get repairEventInRepair => 'Réparation en cours';

  @override
  String get repairEventCompleted => 'Réparation terminée';

  @override
  String get repairNoParts => 'Aucune pièce enregistrée';

  @override
  String get repairNoNotes => 'Aucune note';

  @override
  String get repairSort => 'Trier';

  @override
  String get repairSortRecent => 'Récent';

  @override
  String get repairSortPriority => 'Priorité';

  @override
  String get repairSortCost => 'Coût';

  @override
  String get repairFilters => 'Filtres';

  @override
  String get repairFilterDeviceTitle => 'Type d\'appareil';

  @override
  String get repairFilterAny => 'Tous';

  @override
  String get repairActiveOnly => 'Actifs seulement';

  @override
  String get repairFiltersReset => 'Réinitialiser';

  @override
  String get repairFiltersApply => 'Appliquer';

  @override
  String get deviceKindPhone => 'Téléphone';

  @override
  String get deviceKindLaptop => 'Ordinateur';

  @override
  String get deviceKindTablet => 'Tablette';

  @override
  String get deviceKindWatch => 'Montre';

  @override
  String get deviceKindOther => 'Autre';

  @override
  String get navDevices => 'Appareils';

  @override
  String get navPlanning => 'Planning';

  @override
  String get navQuotes => 'Devis';

  @override
  String get navInvoices => 'Factures';

  @override
  String get navPayments => 'Paiements';

  @override
  String get navAccounting => 'Comptabilité';

  @override
  String get navInventory => 'Inventaire';

  @override
  String get navCatalog => 'Catalogue';

  @override
  String get navSuppliers => 'Fournisseurs';

  @override
  String get navOrders => 'Commandes';

  @override
  String get navStaff => 'Employés';

  @override
  String get navUsers => 'Utilisateurs';

  @override
  String get navReports => 'Rapports';

  @override
  String get navAssistant => 'Assistant IA';

  @override
  String get navGroupMain => 'Principal';

  @override
  String get navGroupFinance => 'Finances';

  @override
  String get navGroupStock => 'Stock';

  @override
  String get navGroupManagement => 'Gestion';

  @override
  String get navGroupSystem => 'Système';

  @override
  String get navMore => 'Plus';

  @override
  String get comingSoonTitle => 'Bientôt disponible';

  @override
  String get comingSoonSubtitle =>
      'Cette section est en cours de construction.';

  @override
  String get catalogSearch => 'Rechercher un produit';

  @override
  String get catalogEmpty => 'Aucun produit';

  @override
  String get catalogEmptySubtitle =>
      'Ajoutez vos pièces, accessoires et services.';

  @override
  String get variantsLabel => 'Variantes';

  @override
  String get productNew => 'Nouveau produit';

  @override
  String get productName => 'Nom du produit';

  @override
  String get productBrand => 'Marque';

  @override
  String get productCategory => 'Catégorie';

  @override
  String get productVariants => 'Variantes';

  @override
  String get priceLabel => 'Prix';

  @override
  String get stockLabel => 'Stock';

  @override
  String get skuLabel => 'Réf.';

  @override
  String get categoryPart => 'Pièce';

  @override
  String get categoryAccessory => 'Accessoire';

  @override
  String get categoryService => 'Prestation';

  @override
  String get serviceCatDiagnostic => 'Diagnostic';

  @override
  String get serviceCatScreen => 'Écran';

  @override
  String get serviceCatBattery => 'Batterie';

  @override
  String get serviceCatSoftware => 'Logiciel';

  @override
  String get serviceCatData => 'Données';

  @override
  String get serviceCatOther => 'Autre';

  @override
  String get navServices => 'Prestations';

  @override
  String get servicesSearch => 'Rechercher une prestation';

  @override
  String get servicesEmpty => 'Aucune prestation';

  @override
  String get servicesEmptySubtitle =>
      'Ajoutez vos prestations et leurs tarifs.';

  @override
  String get serviceCategoryHeader => 'Catégorie';

  @override
  String get serviceDurationLabel => 'Durée';

  @override
  String get serviceMargin => 'Marge';

  @override
  String get serviceNew => 'Nouvelle prestation';

  @override
  String get serviceEdit => 'Modifier la prestation';

  @override
  String get serviceDescription => 'Description';

  @override
  String get serviceCost => 'Coût';

  @override
  String get serviceDelete => 'Supprimer la prestation';

  @override
  String get serviceDeleteConfirm => 'Supprimer cette prestation ?';

  @override
  String get serviceAddToCatalog => 'Ajouter au catalogue';

  @override
  String get navCategories => 'Catégories';

  @override
  String get categoryNew => 'Nouvelle catégorie';

  @override
  String get categorySubNew => 'Nouvelle sous-catégorie';

  @override
  String get categoryIcon => 'Icône';

  @override
  String get categoryColor => 'Couleur';

  @override
  String get categoryDelete => 'Supprimer la catégorie';

  @override
  String get categoryDeleteConfirm => 'Supprimer cette catégorie ?';

  @override
  String get categoryReassign => 'Déplacer les prestations vers';

  @override
  String get categoryAddSub => 'Ajouter une sous-catégorie';

  @override
  String get categoryMoveServices => 'Déplacer les prestations';

  @override
  String get categoryMoveProducts => 'Déplacer les produits';

  @override
  String get categoryReassignProducts => 'Déplacer les produits vers';

  @override
  String get productEdit => 'Modifier le produit';

  @override
  String get categorySelect => 'Choisir une catégorie';

  @override
  String get taxonomyRoot => 'Racine';

  @override
  String get taxonomyCode => 'Code';

  @override
  String get taxonomyDescription => 'Description';

  @override
  String get taxonomyParent => 'Catégorie parente';

  @override
  String get taxonomyReassign => 'Déplacer les éléments vers';

  @override
  String get taxonomyMergeInto => 'Fusionner avec…';

  @override
  String get taxonomyMoveItems => 'Déplacer les éléments';

  @override
  String get taxonomyCodeTaken => 'Ce code est déjà utilisé';

  @override
  String get taxonomyShowArchived => 'Afficher les archivées';

  @override
  String get taxonomyEmpty => 'Aucune catégorie';

  @override
  String get taxonomySearch => 'Rechercher une catégorie';

  @override
  String get taxonomyExpandAll => 'Tout déplier';

  @override
  String get taxonomyCollapseAll => 'Tout replier';

  @override
  String get supplierProducts => 'Produits fournis';

  @override
  String get supplierOrderedProducts => 'Déjà commandés (non liés)';

  @override
  String get supplierLinkProduct => 'Lier';

  @override
  String get inventoryReorder => 'Commander';

  @override
  String get inventoryNoSupplier => 'Aucun fournisseur lié à ce produit';

  @override
  String get supplierInUse =>
      'Fournisseur référencé (produits ou commandes) — suppression impossible';

  @override
  String get supplierDeleteConfirm => 'Supprimer ce fournisseur ?';

  @override
  String get commonOk => 'OK';

  @override
  String get sourcingPurchasePrice => 'Prix d\'achat';

  @override
  String get sourcingPreferred => 'Préféré';

  @override
  String get sourcingBestPrice => 'Meilleur prix';

  @override
  String get productFacets => 'Facettes';

  @override
  String get smartViews => 'Sélections';

  @override
  String get smartViewNew => 'Nouvelle sélection';

  @override
  String get smartRule => 'Règle';

  @override
  String get smartStock => 'Stock';

  @override
  String get smartPriceMax => 'Prix max';

  @override
  String get smartPriceMin => 'Prix min';

  @override
  String get smartAny => 'Indifférent';

  @override
  String get catalogManage => 'Gérer';

  @override
  String get serviceDuplicate => 'Dupliquer';

  @override
  String get serviceCopySuffix => '(copie)';

  @override
  String get variantNew => 'Nouvelle variante';

  @override
  String get variantLabel => 'Libellé (ex. Noir · OEM)';

  @override
  String variantCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count variantes',
      one: '1 variante',
      zero: 'Aucune variante',
    );
    return '$_temp0';
  }

  @override
  String stockUnits(int count) {
    return '$count en stock';
  }

  @override
  String get addLabel => 'Ajouter';

  @override
  String get repairSectionServices => 'Prestations';

  @override
  String get repairNoServices => 'Aucune prestation';

  @override
  String get repairServicesTotal => 'Total prestations';

  @override
  String get repairSectionObservations => 'Observations';

  @override
  String get repairNoObservations => 'Aucune observation';

  @override
  String get paymentUnpaid => 'Impayé';

  @override
  String get paymentPartial => 'Partiel';

  @override
  String get paymentPaid => 'Payé';

  @override
  String get repairSectionProblem => 'Problème';

  @override
  String get repairReported => 'Panne signalée';

  @override
  String get repairDiagnosis => 'Diagnostic';

  @override
  String get repairWorkDone => 'Travail effectué';

  @override
  String get repairSectionDevice => 'Appareil';

  @override
  String get deviceModel => 'Modèle';

  @override
  String get deviceColor => 'Couleur';

  @override
  String get deviceStorage => 'Stockage';

  @override
  String get deviceAccessories => 'Accessoires';

  @override
  String get repairIntakeCondition => 'État à la prise en charge';

  @override
  String get devicePasscode => 'Code de déverrouillage';

  @override
  String get backupConsent => 'Consentement sauvegarde';

  @override
  String get repairSectionFinance => 'Finances';

  @override
  String get financeLabour => 'Main-d\'œuvre';

  @override
  String get financeDiscount => 'Remise';

  @override
  String get financeTax => 'TVA';

  @override
  String get financeSubtotal => 'Sous-total';

  @override
  String get financeTotal => 'Total';

  @override
  String get financeDeposit => 'Acompte';

  @override
  String get financeBalance => 'Solde dû';

  @override
  String get repairSectionLogistics => 'Suivi & logistique';

  @override
  String get repairAssignedTech => 'Technicien';

  @override
  String get repairCreatedBy => 'Pris en charge par';

  @override
  String get repairLocation => 'Emplacement';

  @override
  String get repairWarranty => 'Garantie';

  @override
  String get repairUnderWarranty => 'Sous garantie';

  @override
  String get repairWarrantyExpired => 'Garantie expirée';

  @override
  String repairWarrantyUntil(Object date) {
    return 'Jusqu\'au $date';
  }

  @override
  String warrantyDuration(int count) {
    return '$count mois';
  }

  @override
  String get repairDue => 'Échéance';

  @override
  String get repairOverdue => 'En retard';

  @override
  String get repairPhotos => 'Photos';

  @override
  String get repairPhotoAdded => 'Photo ajoutée';

  @override
  String get repairPhotoRemove => 'Supprimer cette photo ?';

  @override
  String get repairEventPhoto => 'Photo ajoutée';

  @override
  String get actionCall => 'Appeler';

  @override
  String get actionSms => 'SMS';

  @override
  String get actionWhatsapp => 'WhatsApp';

  @override
  String get actionEmail => 'E-mail';

  @override
  String get actionEdit => 'Modifier';

  @override
  String get editMode => 'Mode édition';

  @override
  String get actionReopen => 'Rouvrir';

  @override
  String get actionAssign => 'Assigner un technicien';

  @override
  String get actionAddPhoto => 'Ajouter une photo';

  @override
  String get actionPrintLabel => 'Imprimer l\'étiquette';

  @override
  String get repairPrintChoose => 'Imprimer';

  @override
  String get repairSheetTitle => 'Fiche de réparation';

  @override
  String get repairTicketTitle => 'Ticket';

  @override
  String get repairSignatureClient => 'Signature du client';

  @override
  String get repairSignatureTech => 'Signature du technicien';

  @override
  String get repairTicketFooter =>
      'Présentez ce ticket pour récupérer l\'appareil.';

  @override
  String get unitMonths => 'mois';

  @override
  String get repairScan => 'Scanner';

  @override
  String get repairScanHint => 'Placez le QR de la réparation dans le cadre';

  @override
  String get repairScanManual => 'Saisir la référence';

  @override
  String get repairScanReference => 'Référence';

  @override
  String get repairScanOpen => 'Ouvrir';

  @override
  String get repairScanNotFound => 'Réparation introuvable';

  @override
  String get repairScanUnavailable =>
      'Scan par caméra indisponible sur cette plateforme';

  @override
  String get repairScanFromImage => 'Décoder depuis une image';

  @override
  String get repairScanError => 'Impossible de décoder le QR';

  @override
  String get repairScanCameraError =>
      'Caméra indisponible (autorisation refusée ?)';

  @override
  String get actionGenerateInvoice => 'Générer une facture';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get statusLabel => 'Statut';

  @override
  String get qtyShort => 'Qté';

  @override
  String get unitPriceShort => 'PU';

  @override
  String get addPrestation => 'Ajouter une prestation';

  @override
  String get addPart => 'Ajouter une pièce';

  @override
  String get unassigned => 'Non assigné';

  @override
  String get notProvided => 'Non renseigné';

  @override
  String get clientSectionContact => 'Coordonnées';

  @override
  String get supplierNew => 'Nouveau fournisseur';

  @override
  String get supplierSearch => 'Rechercher un fournisseur';

  @override
  String get supplierEmpty => 'Aucun fournisseur';

  @override
  String get supplierEmptySubtitle => 'Ajoutez un fournisseur pour commencer.';

  @override
  String get supplierType => 'Type';

  @override
  String get supplierTypeCompany => 'Société';

  @override
  String get supplierTypeIndividual => 'Particulier';

  @override
  String get supplierName => 'Nom / Raison sociale';

  @override
  String get supplierContactName => 'Interlocuteur';

  @override
  String get supplierVat => 'N° TVA';

  @override
  String get supplierCity => 'Ville';

  @override
  String get supplierTerms => 'Conditions de paiement';

  @override
  String get supplierSectionCompany => 'Société';

  @override
  String get fieldName => 'Nom';

  @override
  String get clientTypeIndividual => 'Particulier';

  @override
  String get clientTypeCompany => 'Entreprise';

  @override
  String get clientCompanyName => 'Raison sociale';

  @override
  String get clientVat => 'N° TVA';

  @override
  String get clientCity => 'Ville';

  @override
  String get clientSectionCompany => 'Entreprise';

  @override
  String get clientSectionHistory => 'Historique des réparations';

  @override
  String get staffNew => 'Nouvel employé';

  @override
  String get staffSearch => 'Rechercher un employé';

  @override
  String get staffEmpty => 'Aucun employé';

  @override
  String get staffEmptySubtitle => 'Ajoutez un employé pour commencer.';

  @override
  String get staffJobTitle => 'Poste';

  @override
  String get staffHireDate => 'Date d\'embauche';

  @override
  String get staffCommission => 'Commission (%)';

  @override
  String get staffActive => 'Actif';

  @override
  String get staffInactive => 'Inactif';

  @override
  String get staffSectionEmployment => 'Emploi';

  @override
  String get staffAssignedRepairs => 'Réparations assignées';

  @override
  String get authLoginTitle => 'Connexion';

  @override
  String get authPassword => 'Mot de passe';

  @override
  String get authPin => 'Code PIN';

  @override
  String get authSignIn => 'Se connecter';

  @override
  String get authLogout => 'Déconnexion';

  @override
  String get authError => 'Identifiants incorrects';

  @override
  String get authModeEmail => 'E-mail';

  @override
  String get authModePin => 'PIN';

  @override
  String get userNew => 'Nouvel utilisateur';

  @override
  String get userSearch => 'Rechercher un utilisateur';

  @override
  String get userEmpty => 'Aucun utilisateur';

  @override
  String get userEmptySubtitle => 'Ajoutez un compte pour commencer.';

  @override
  String get listNoResults => 'Aucun résultat';

  @override
  String get listNoResultsSubtitle => 'Ajustez la recherche ou les filtres.';

  @override
  String get navProfile => 'Profil';

  @override
  String get profileSubtitle => 'Votre compte et votre sécurité';

  @override
  String get profileAccount => 'Compte';

  @override
  String get profileSecurity => 'Sécurité';

  @override
  String get profileLinkedEmployee => 'Employé lié';

  @override
  String get profileChangePassword => 'Changer le mot de passe';

  @override
  String get profileChangePin => 'Changer le code PIN';

  @override
  String get profileCurrentPassword => 'Mot de passe actuel';

  @override
  String get profileNewPassword => 'Nouveau mot de passe';

  @override
  String get profileConfirm => 'Confirmer';

  @override
  String get profileNewPin => 'Nouveau code PIN';

  @override
  String get profilePasswordChanged => 'Mot de passe modifié';

  @override
  String get profilePinChanged => 'Code PIN modifié';

  @override
  String get profileWrongPassword => 'Mot de passe actuel incorrect';

  @override
  String get profilePasswordMismatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get accountEmailTaken => 'Cet e-mail est déjà utilisé';

  @override
  String get accountPinTaken => 'Ce code PIN est déjà utilisé';

  @override
  String get accountLastAdmin => 'Au moins un administrateur actif est requis';

  @override
  String get accountEventLogin => 'Connexion';

  @override
  String get accountEventLogout => 'Déconnexion';

  @override
  String get accountEventFailedLogin => 'Échec de connexion';

  @override
  String get accountEventCreated => 'Compte créé';

  @override
  String get accountEventUpdated => 'Compte modifié';

  @override
  String get accountEventRoleChanged => 'Rôle modifié';

  @override
  String get accountEventDeactivated => 'Compte désactivé';

  @override
  String get accountEventReactivated => 'Compte réactivé';

  @override
  String get accountEventPasswordReset => 'Mot de passe réinitialisé';

  @override
  String get accountEventPinReset => 'PIN réinitialisé';

  @override
  String get accountEventInvited => 'Invitation envoyée';

  @override
  String get accountEventDeleted => 'Compte supprimé';

  @override
  String get accountActivity => 'Activité';

  @override
  String get accountLog => 'Journal des comptes';

  @override
  String get accountCreatedAt => 'Créé le';

  @override
  String get accountLastLogin => 'Dernière connexion';

  @override
  String get accountNeverLoggedIn => 'Jamais connecté';

  @override
  String get accountActionsTitle => 'Actions';

  @override
  String get accountResetPassword => 'Réinitialiser le mot de passe';

  @override
  String get accountResetPin => 'Réinitialiser le PIN';

  @override
  String get accountInvite => 'Inviter (démo)';

  @override
  String get accountDelete => 'Supprimer le compte';

  @override
  String get accountDeleteConfirm => 'Supprimer définitivement ce compte ?';

  @override
  String get accountTempSecret => 'Secret temporaire (démo)';

  @override
  String get accountInvitePending => 'Invitation en attente';

  @override
  String get navIntegrations => 'Intégrations';

  @override
  String get integrationsSubtitle => 'Paiements, e-mail, messagerie…';

  @override
  String get integrationsSummary => 'Services connectés';

  @override
  String get integrationsSearch => 'Rechercher une intégration';

  @override
  String get integrationEnable => 'Activer';

  @override
  String get integrationTest => 'Tester';

  @override
  String get integrationComingSoon => 'Connexion en direct bientôt disponible';

  @override
  String get integrationConnectAccount => 'Connecter le compte';

  @override
  String get integrationConnected => 'Compte lié';

  @override
  String get integrationDisconnect => 'Déconnecter';

  @override
  String get integrationValid => 'Configuration valide';

  @override
  String get integrationCheckNotConnected => 'Compte non lié';

  @override
  String get integrationCheckEmail => 'Adresse e-mail invalide';

  @override
  String integrationCheckMissing(Object field) {
    return 'Champ requis manquant : $field';
  }

  @override
  String integrationCheckUrl(Object field) {
    return 'URL invalide : $field';
  }

  @override
  String integrationCheckShort(Object field) {
    return 'Valeur trop courte : $field';
  }

  @override
  String get integrationCatPayments => 'Paiements';

  @override
  String get integrationCatMessaging => 'Messagerie';

  @override
  String get integrationCatCloud => 'Cloud & e-mail';

  @override
  String get integrationCatAutomation => 'Automatisation';

  @override
  String get integrationDescOutlook => 'Envoi des factures via Outlook';

  @override
  String get integrationDescOnedrive => 'Sauvegarde sur OneDrive';

  @override
  String get integrationDescTelegram => 'Notifications via un bot Telegram';

  @override
  String get integrationDescTeams => 'Alertes dans un canal Teams';

  @override
  String get integrationDescSlack => 'Alertes dans un canal Slack';

  @override
  String get integrationDescZapier => 'Automatisez via un webhook Zapier';

  @override
  String get integrationFieldBotToken => 'Jeton du bot';

  @override
  String get integrationFieldChatId => 'ID de discussion';

  @override
  String get integrationFieldWebhookUrl => 'URL du webhook';

  @override
  String get integrationDescApplepay => 'Paiement Apple Pay';

  @override
  String get integrationDescIcloud => 'Sauvegarde iCloud';

  @override
  String get integrationDescApplemsg =>
      'Messages pour les entreprises (iMessage)';

  @override
  String get integrationFieldMerchantId => 'ID marchand Apple';

  @override
  String get integrationFieldBusinessId => 'ID Apple Business';

  @override
  String get integrationStatusActive => 'Actif';

  @override
  String get integrationStatusDisabled => 'Désactivé';

  @override
  String get integrationStatusNotConfigured => 'Non configuré';

  @override
  String get integrationDescFlouci => 'Paiement wallet & cartes (CIB/Visa/MC)';

  @override
  String get integrationDescKonnect => 'Paiement en ligne par carte';

  @override
  String get integrationDescClictopay => 'Paiement carte bancaire (SMT)';

  @override
  String get integrationDescStripe => 'Cartes internationales';

  @override
  String get integrationDescDrive => 'Sauvegarde dans le cloud';

  @override
  String get integrationDescGmail => 'Envoi des factures par e-mail';

  @override
  String get integrationDescWhatsapp => 'Messages WhatsApp automatisés';

  @override
  String get integrationDescMessenger => 'Discuter via Messenger';

  @override
  String get integrationDescSms => 'Notifications par SMS';

  @override
  String get integrationFieldApiKey => 'Clé API';

  @override
  String get integrationFieldSecretKey => 'Clé secrète';

  @override
  String get integrationFieldPrivateToken => 'Jeton privé';

  @override
  String get integrationFieldAppId => 'ID application';

  @override
  String get integrationFieldWalletId => 'ID portefeuille';

  @override
  String get integrationFieldMerchantUser => 'Identifiant marchand';

  @override
  String get integrationFieldMerchantPassword => 'Mot de passe marchand';

  @override
  String get integrationFieldAppPassword => 'Mot de passe d\'application';

  @override
  String get integrationFieldPhoneId => 'ID du numéro';

  @override
  String get integrationFieldAccessToken => 'Jeton d\'accès';

  @override
  String get integrationFieldPageLink => 'Lien de la page';

  @override
  String get integrationFieldSender => 'Expéditeur';

  @override
  String get userRole => 'Rôle';

  @override
  String get userLinkedEmployee => 'Employé lié';

  @override
  String get userNoEmployee => 'Aucun';

  @override
  String get userNewPassword => 'Nouveau mot de passe';

  @override
  String get userNewPin => 'Nouveau PIN';

  @override
  String get roleAdmin => 'Administrateur';

  @override
  String get roleTechnician => 'Technicien';

  @override
  String get roleCashier => 'Caisse';

  @override
  String get orderNew => 'Nouvelle commande';

  @override
  String get orderSearch => 'Rechercher une commande';

  @override
  String get orderEmpty => 'Aucune commande';

  @override
  String get orderEmptySubtitle => 'Créez une commande fournisseur.';

  @override
  String get orderStatusDraft => 'Brouillon';

  @override
  String get orderStatusOrdered => 'Commandée';

  @override
  String get orderStatusReceived => 'Reçue';

  @override
  String get orderStatusCancelled => 'Annulée';

  @override
  String get orderSupplier => 'Fournisseur';

  @override
  String get orderExpectedDate => 'Livraison prévue';

  @override
  String get orderReceive => 'Réceptionner';

  @override
  String get orderPaid => 'Réglé';

  @override
  String get orderBalanceDue => 'Reste à payer';

  @override
  String get orderAddPayment => 'Enregistrer un règlement';

  @override
  String get orderAddLine => 'Ajouter un article';

  @override
  String get orderSectionLines => 'Articles';

  @override
  String get orderNoLines => 'Aucun article';

  @override
  String get orderSubtotal => 'Sous-total HT';

  @override
  String get orderTax => 'TVA';

  @override
  String get orderTotal => 'Total TTC';

  @override
  String get productPickTitle => 'Choisir un produit';

  @override
  String get quoteNew => 'Nouveau devis';

  @override
  String get quoteSearch => 'Rechercher un devis';

  @override
  String get quoteEmpty => 'Aucun devis';

  @override
  String get quoteEmptySubtitle => 'Créez un devis client.';

  @override
  String get quoteStatusDraft => 'Brouillon';

  @override
  String get quoteStatusSent => 'Envoyé';

  @override
  String get quoteStatusAccepted => 'Accepté';

  @override
  String get quoteStatusRefused => 'Refusé';

  @override
  String get quoteStatusExpired => 'Expiré';

  @override
  String get quoteValidUntil => 'Valable jusqu\'au';

  @override
  String get quoteAddService => 'Ajouter une prestation';

  @override
  String get quoteAddPart => 'Ajouter une pièce';

  @override
  String get quoteSectionLines => 'Détail';

  @override
  String get quoteExportPdf => 'Exporter en PDF';

  @override
  String get quoteSend => 'Envoyer';

  @override
  String get quoteAccept => 'Accepter';

  @override
  String get quoteRefuse => 'Refuser';

  @override
  String get colDesignation => 'Désignation';

  @override
  String get colQty => 'Qté';

  @override
  String get colUnitPrice => 'P.U.';

  @override
  String get colLineTotal => 'Total';

  @override
  String get invoiceNew => 'Nouvelle facture';

  @override
  String get invoiceSearch => 'Rechercher une facture';

  @override
  String get invoiceEmpty => 'Aucune facture';

  @override
  String get invoiceEmptySubtitle => 'Créez une facture.';

  @override
  String get invoiceStatusDraft => 'Brouillon';

  @override
  String get invoiceStatusIssued => 'Émise';

  @override
  String get invoiceStatusPartial => 'Partielle';

  @override
  String get invoiceStatusPaid => 'Payée';

  @override
  String get invoiceStatusOverdue => 'En retard';

  @override
  String get invoiceStatusCancelled => 'Annulée';

  @override
  String get invoiceIssue => 'Émettre';

  @override
  String get creditNote => 'Avoir';

  @override
  String get creditNotes => 'Avoirs';

  @override
  String get creditNoteNew => 'Créer un avoir';

  @override
  String get creditNoteIssue => 'Émettre l\'avoir';

  @override
  String get creditNoteReason => 'Motif';

  @override
  String get creditNoteEmpty => 'Aucun avoir';

  @override
  String get invoiceDueDate => 'Échéance';

  @override
  String get invoiceDeposit => 'Acompte';

  @override
  String get invoiceBalance => 'Solde dû';

  @override
  String get invoiceSectionPayments => 'Paiements';

  @override
  String get invoiceRecordPayment => 'Enregistrer un paiement';

  @override
  String get invoiceNoPayments => 'Aucun paiement';

  @override
  String get invoiceAmount => 'Montant';

  @override
  String get paymentMethodCash => 'Espèces';

  @override
  String get paymentMethodCard => 'Carte';

  @override
  String get paymentMethodTransfer => 'Virement';

  @override
  String get paymentMethodCheck => 'Chèque';

  @override
  String get paymentMethodCredit => 'Avoir';

  @override
  String get quoteConvertInvoice => 'Convertir en facture';

  @override
  String get invoiceFromRepair => 'Générer la facture';

  @override
  String get fieldPhone => 'Téléphone';

  @override
  String get fieldEmail => 'E-mail';

  @override
  String get fieldAddress => 'Adresse';

  @override
  String get fieldWhatsapp => 'WhatsApp';

  @override
  String get fieldTelegram => 'Telegram';

  @override
  String get fieldSecondaryPhone => 'Téléphone secondaire';

  @override
  String get fieldWebsite => 'Site web';

  @override
  String get fieldInstagram => 'Instagram';

  @override
  String get clientSectionSocial => 'Web & réseaux';

  @override
  String get actionWebsite => 'Ouvrir le site';

  @override
  String get actionInstagram => 'Ouvrir Instagram';

  @override
  String get contactKindTitle => 'Type de contact';

  @override
  String get contactKindMobile => 'Mobile';

  @override
  String get contactKindLandline => 'Fixe';

  @override
  String get contactKindWhatsapp => 'WhatsApp';

  @override
  String get contactKindTelegram => 'Telegram';

  @override
  String get contactKindEmail => 'E-mail';

  @override
  String get contactKindWebsite => 'Site web';

  @override
  String get contactKindInstagram => 'Instagram';

  @override
  String get contactKindFacebook => 'Facebook';

  @override
  String get contactKindLinkedin => 'LinkedIn';

  @override
  String get contactKindX => 'X (Twitter)';

  @override
  String get contactKindSnapchat => 'Snapchat';

  @override
  String get contactKindTiktok => 'TikTok';

  @override
  String get contactKindSignal => 'Signal';

  @override
  String get contactKindWechat => 'WeChat';

  @override
  String get contactKindMessenger => 'Messenger';

  @override
  String get contactKindViber => 'Viber';

  @override
  String get contactKindLine => 'LINE';

  @override
  String get contactKindFax => 'Fax';

  @override
  String get contactKindYoutube => 'YouTube';

  @override
  String get contactKindTeams => 'Teams';

  @override
  String get contactKindOther => 'Autre';

  @override
  String get clientAddContact => 'Ajouter un contact';

  @override
  String get clientOtherContacts => 'Autres coordonnées';

  @override
  String get clientOtherAddresses => 'Autres adresses';

  @override
  String get clientSectionAddresses => 'Adresses';

  @override
  String get addressMain => 'Adresse principale';

  @override
  String get clientAddAddress => 'Ajouter une adresse';

  @override
  String get addressKindTitle => 'Type d\'adresse';

  @override
  String get addressKindHome => 'Domicile';

  @override
  String get addressKindWork => 'Travail';

  @override
  String get addressKindBilling => 'Facturation';

  @override
  String get addressKindShipping => 'Livraison';

  @override
  String get addressKindOther => 'Autre';

  @override
  String get clientStatInvoiced => 'Facturé';

  @override
  String get clientStatOutstanding => 'Impayé';

  @override
  String get clientStatRepairs => 'Réparations';

  @override
  String get clientSectionInvoices => 'Factures';

  @override
  String get clientSectionQuotes => 'Devis';

  @override
  String get clientLastActivity => 'Dernière activité';

  @override
  String get clientNoDocuments => 'Aucun document';

  @override
  String get clientNoActivity => 'Aucune activité pour l\'instant';

  @override
  String get clientNoInvoices => 'Aucune facture';

  @override
  String get clientNoQuotes => 'Aucun devis';

  @override
  String get clientSettleAll => 'Encaisser tout';

  @override
  String get clientCredit => 'Crédit disponible';

  @override
  String get clientNetBalance => 'Solde net';

  @override
  String get clientStatementPdf => 'Relevé de compte (PDF)';

  @override
  String get statementTitle => 'Relevé de compte';

  @override
  String get statementDate => 'Date';

  @override
  String get statementDetail => 'Détail';

  @override
  String get statementDebit => 'Débit';

  @override
  String get statementCredit => 'Crédit';

  @override
  String get statementBalance => 'Solde';

  @override
  String get statementOpening => 'Solde d\'ouverture';

  @override
  String get statementClosing => 'Solde de clôture';

  @override
  String get statementInvoice => 'Facture';

  @override
  String get statementDeposit => 'Acompte';

  @override
  String get statementPayment => 'Règlement';

  @override
  String get colNumber => 'N°';

  @override
  String get supplierStatementPdf => 'Relevé fournisseur (PDF)';

  @override
  String get supplierStatementTitle => 'Relevé fournisseur';

  @override
  String get supplierPurchased => 'Achats reçus';

  @override
  String get supplierOnOrder => 'En commande';

  @override
  String get supplierOverdue => 'En retard';

  @override
  String get supplierPayable => 'Impayés';

  @override
  String get poAgeNotDue => 'Non échu';

  @override
  String get poAge1to30 => '1–30 j';

  @override
  String get poAge31to60 => '31–60 j';

  @override
  String get poAge60plus => '60+ j';

  @override
  String get clientAddDeposit => 'Ajouter un acompte';

  @override
  String get clientApplyCredit => 'Appliquer le crédit';

  @override
  String get clientRefund => 'Rembourser';

  @override
  String get chequeAdd => 'Ajouter un chèque';

  @override
  String get navRefunds => 'Remboursements';

  @override
  String get refundsTotal => 'Total remboursé';

  @override
  String get refundsEmpty => 'Aucun remboursement';

  @override
  String get refundsEmptySubtitle =>
      'Les remboursements aux clients apparaîtront ici.';

  @override
  String get financePeriodAll => 'Tout';

  @override
  String get financePeriodMonth => 'Mois';

  @override
  String get financePeriodQuarter => 'Trimestre';

  @override
  String get financePeriodYear => 'Année';

  @override
  String get financePeriodCustom => 'Perso';

  @override
  String get filterAllClients => 'Tous les clients';

  @override
  String get paymentKindInvoice => 'Facture';

  @override
  String get paymentKindDeposit => 'Acompte';

  @override
  String get paymentKindApplication => 'Avoir appliqué';

  @override
  String get paymentKindRefund => 'Remboursement';

  @override
  String get financeBreakdown => 'Ventilation';

  @override
  String get navCheques => 'Chèques';

  @override
  String get chequeNumber => 'N° de chèque';

  @override
  String get chequeBank => 'Banque';

  @override
  String get chequeDrawer => 'Émetteur';

  @override
  String get chequeDueDate => 'Échéance';

  @override
  String get chequeStatusPending => 'À encaisser';

  @override
  String get chequeStatusDeposited => 'Déposé';

  @override
  String get chequeStatusCleared => 'Encaissé';

  @override
  String get chequeStatusBounced => 'Rejeté';

  @override
  String get chequesToCollect => 'Chèques à encaisser';

  @override
  String get chequesEmpty => 'Aucun chèque';

  @override
  String get chequesEmptySubtitle => 'Les chèques reçus apparaîtront ici.';

  @override
  String get chequeMarkDeposited => 'Marquer déposé';

  @override
  String get chequeMarkCleared => 'Marquer encaissé';

  @override
  String get chequeBounceAction => 'Rejeter';

  @override
  String get clientSince => 'Client depuis';

  @override
  String get clientTags => 'Étiquettes';

  @override
  String get clientTagsHint => 'Séparez par des virgules';

  @override
  String get clientConsent => 'Consentement marketing';

  @override
  String get clientBillingContact => 'Contact facturation';

  @override
  String get clientPaymentTerms => 'Conditions de paiement';

  @override
  String get clientDiscount => 'Remise habituelle';

  @override
  String get clientCreditLimit => 'Plafond de crédit';

  @override
  String clientDuplicateWarning(String name) {
    return 'Un client similaire existe déjà : $name. Créer quand même ?';
  }

  @override
  String get actionTelegram => 'Telegram';

  @override
  String get actionDirections => 'Itinéraire';

  @override
  String get clientSelect => 'Sélectionner un client';

  @override
  String get settingsSectionLayout => 'Disposition';

  @override
  String get settingsContentWidth => 'Largeur du contenu';

  @override
  String get contentNormal => 'Normale';

  @override
  String get contentStretch => 'Pleine largeur';

  @override
  String get settingsSidebar => 'Barre latérale';

  @override
  String get sidebarAdaptive => 'Adaptative';

  @override
  String get sidebarExpanded => 'Étendue';

  @override
  String get settingsDetailView => 'Affichage des détails';

  @override
  String get settingsClientsView => 'Affichage des répertoires';

  @override
  String get settingsRegional => 'Régional';

  @override
  String get settingsCurrency => 'Devise';

  @override
  String get settingsDateFormat => 'Format de date';

  @override
  String get clientsViewList => 'Liste';

  @override
  String get clientsViewGrid => 'Grille';

  @override
  String get clientsViewTable => 'Tableau';

  @override
  String get fieldType => 'Type';

  @override
  String get clientSegmentDebtors => 'Débiteurs';

  @override
  String get clientSegmentCredit => 'Avec crédit';

  @override
  String get clientSegmentInactive => 'Inactifs';

  @override
  String get clientSegmentBusiness => 'Professionnels';

  @override
  String get clientSegmentRecent => 'Nouveaux';

  @override
  String get detailAdaptive => 'Adaptatif';

  @override
  String get detailPane => 'Panneau';

  @override
  String get detailPage => 'Page';

  @override
  String get prestationPickTitle => 'Choisir une prestation';

  @override
  String get prestationSearch => 'Rechercher une prestation';

  @override
  String get prestationManual => 'Saisie manuelle';
}
