import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'Atelier Réparation'**
  String get appTitle;

  /// No description provided for @navDashboard.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord'**
  String get navDashboard;

  /// No description provided for @navRepairs.
  ///
  /// In fr, this message translates to:
  /// **'Réparations'**
  String get navRepairs;

  /// No description provided for @navClients.
  ///
  /// In fr, this message translates to:
  /// **'Clients'**
  String get navClients;

  /// No description provided for @navSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get navSettings;

  /// No description provided for @dashboardTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord'**
  String get dashboardTitle;

  /// No description provided for @dashboardOverview.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu'**
  String get dashboardOverview;

  /// No description provided for @dashboardRecentRepairs.
  ///
  /// In fr, this message translates to:
  /// **'Réparations récentes'**
  String get dashboardRecentRepairs;

  /// No description provided for @dashboardActivity.
  ///
  /// In fr, this message translates to:
  /// **'Activité'**
  String get dashboardActivity;

  /// No description provided for @dashboardQuickActions.
  ///
  /// In fr, this message translates to:
  /// **'Actions rapides'**
  String get dashboardQuickActions;

  /// No description provided for @dashboardNoRepairs.
  ///
  /// In fr, this message translates to:
  /// **'Aucune réparation'**
  String get dashboardNoRepairs;

  /// No description provided for @dashboardNoRepairsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Les nouvelles fiches apparaîtront ici.'**
  String get dashboardNoRepairsSubtitle;

  /// No description provided for @dashboardNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get dashboardNotifications;

  /// No description provided for @notificationsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsRecent.
  ///
  /// In fr, this message translates to:
  /// **'Activité récente'**
  String get notificationsRecent;

  /// No description provided for @statInProgress.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get statInProgress;

  /// No description provided for @statAwaitingParts.
  ///
  /// In fr, this message translates to:
  /// **'En attente de pièces'**
  String get statAwaitingParts;

  /// No description provided for @statCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Terminées'**
  String get statCompleted;

  /// No description provided for @statClients.
  ///
  /// In fr, this message translates to:
  /// **'Clients'**
  String get statClients;

  /// No description provided for @statRevenue.
  ///
  /// In fr, this message translates to:
  /// **'Chiffre d\'affaires'**
  String get statRevenue;

  /// No description provided for @statUnpaid.
  ///
  /// In fr, this message translates to:
  /// **'Impayés'**
  String get statUnpaid;

  /// No description provided for @statAwaitingPartsShort.
  ///
  /// In fr, this message translates to:
  /// **'Pièces'**
  String get statAwaitingPartsShort;

  /// No description provided for @reportsFinance.
  ///
  /// In fr, this message translates to:
  /// **'Finances'**
  String get reportsFinance;

  /// No description provided for @reportsCollected.
  ///
  /// In fr, this message translates to:
  /// **'Encaissé'**
  String get reportsCollected;

  /// No description provided for @reportsAcceptanceRate.
  ///
  /// In fr, this message translates to:
  /// **'Taux d\'acceptation'**
  String get reportsAcceptanceRate;

  /// No description provided for @reportsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de données'**
  String get reportsEmpty;

  /// No description provided for @companyName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'établissement'**
  String get companyName;

  /// No description provided for @companyPostalCode.
  ///
  /// In fr, this message translates to:
  /// **'Code postal'**
  String get companyPostalCode;

  /// No description provided for @companySiret.
  ///
  /// In fr, this message translates to:
  /// **'SIRET'**
  String get companySiret;

  /// No description provided for @companyLogo.
  ///
  /// In fr, this message translates to:
  /// **'Logo'**
  String get companyLogo;

  /// No description provided for @companyLogoAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un logo'**
  String get companyLogoAdd;

  /// No description provided for @companyLogoRemove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer le logo'**
  String get companyLogoRemove;

  /// No description provided for @paymentsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun paiement'**
  String get paymentsEmpty;

  /// No description provided for @paymentsEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Les encaissements enregistrés apparaîtront ici.'**
  String get paymentsEmptySubtitle;

  /// No description provided for @paymentsTotalCollected.
  ///
  /// In fr, this message translates to:
  /// **'Total encaissé'**
  String get paymentsTotalCollected;

  /// No description provided for @cashRegister.
  ///
  /// In fr, this message translates to:
  /// **'Caisse'**
  String get cashRegister;

  /// No description provided for @cashOpen.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir la caisse'**
  String get cashOpen;

  /// No description provided for @cashClose.
  ///
  /// In fr, this message translates to:
  /// **'Clôturer la caisse'**
  String get cashClose;

  /// No description provided for @cashOpeningFloat.
  ///
  /// In fr, this message translates to:
  /// **'Fond de caisse'**
  String get cashOpeningFloat;

  /// No description provided for @cashExpected.
  ///
  /// In fr, this message translates to:
  /// **'Espèces attendues'**
  String get cashExpected;

  /// No description provided for @cashCounted.
  ///
  /// In fr, this message translates to:
  /// **'Espèces comptées'**
  String get cashCounted;

  /// No description provided for @cashVariance.
  ///
  /// In fr, this message translates to:
  /// **'Écart'**
  String get cashVariance;

  /// No description provided for @cashClosed.
  ///
  /// In fr, this message translates to:
  /// **'Caisse fermée'**
  String get cashClosed;

  /// No description provided for @cashSince.
  ///
  /// In fr, this message translates to:
  /// **'Ouverte depuis {time}'**
  String cashSince(Object time);

  /// No description provided for @inventoryOut.
  ///
  /// In fr, this message translates to:
  /// **'Rupture'**
  String get inventoryOut;

  /// No description provided for @inventoryLow.
  ///
  /// In fr, this message translates to:
  /// **'Stock bas'**
  String get inventoryLow;

  /// No description provided for @inventoryOk.
  ///
  /// In fr, this message translates to:
  /// **'En stock'**
  String get inventoryOk;

  /// No description provided for @inventoryEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun article'**
  String get inventoryEmpty;

  /// No description provided for @inventoryEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez des produits au catalogue.'**
  String get inventoryEmptySubtitle;

  /// No description provided for @inventoryAlerts.
  ///
  /// In fr, this message translates to:
  /// **'Alertes de stock'**
  String get inventoryAlerts;

  /// No description provided for @planningOverdue.
  ///
  /// In fr, this message translates to:
  /// **'En retard'**
  String get planningOverdue;

  /// No description provided for @planningToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get planningToday;

  /// No description provided for @planningTomorrow.
  ///
  /// In fr, this message translates to:
  /// **'Demain'**
  String get planningTomorrow;

  /// No description provided for @planningThisWeek.
  ///
  /// In fr, this message translates to:
  /// **'Cette semaine'**
  String get planningThisWeek;

  /// No description provided for @planningLater.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get planningLater;

  /// No description provided for @planningNoDate.
  ///
  /// In fr, this message translates to:
  /// **'Sans échéance'**
  String get planningNoDate;

  /// No description provided for @planningEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Rien de planifié'**
  String get planningEmpty;

  /// No description provided for @planningEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Les réparations avec une échéance apparaîtront ici.'**
  String get planningEmptySubtitle;

  /// No description provided for @accountingHt.
  ///
  /// In fr, this message translates to:
  /// **'HT'**
  String get accountingHt;

  /// No description provided for @accountingVat.
  ///
  /// In fr, this message translates to:
  /// **'TVA'**
  String get accountingVat;

  /// No description provided for @accountingTtc.
  ///
  /// In fr, this message translates to:
  /// **'TTC'**
  String get accountingTtc;

  /// No description provided for @accountingVatCollected.
  ///
  /// In fr, this message translates to:
  /// **'TVA collectée'**
  String get accountingVatCollected;

  /// No description provided for @accountingVatDeductible.
  ///
  /// In fr, this message translates to:
  /// **'TVA déductible'**
  String get accountingVatDeductible;

  /// No description provided for @accountingVatNet.
  ///
  /// In fr, this message translates to:
  /// **'TVA nette due'**
  String get accountingVatNet;

  /// No description provided for @vatBasisAccrual.
  ///
  /// In fr, this message translates to:
  /// **'Débits'**
  String get vatBasisAccrual;

  /// No description provided for @vatBasisCash.
  ///
  /// In fr, this message translates to:
  /// **'Encaissements'**
  String get vatBasisCash;

  /// No description provided for @accountingPurchases.
  ///
  /// In fr, this message translates to:
  /// **'Achats (HT)'**
  String get accountingPurchases;

  /// No description provided for @accountingSupplierPaid.
  ///
  /// In fr, this message translates to:
  /// **'Réglé fournisseurs'**
  String get accountingSupplierPaid;

  /// No description provided for @accountingSupplierPayable.
  ///
  /// In fr, this message translates to:
  /// **'Dû fournisseurs'**
  String get accountingSupplierPayable;

  /// No description provided for @accountingMargin.
  ///
  /// In fr, this message translates to:
  /// **'Marge brute'**
  String get accountingMargin;

  /// No description provided for @accountingResult.
  ///
  /// In fr, this message translates to:
  /// **'Résultat net'**
  String get accountingResult;

  /// No description provided for @expenses.
  ///
  /// In fr, this message translates to:
  /// **'Dépenses'**
  String get expenses;

  /// No description provided for @expenseNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle dépense'**
  String get expenseNew;

  /// No description provided for @expenseLabel.
  ///
  /// In fr, this message translates to:
  /// **'Libellé'**
  String get expenseLabel;

  /// No description provided for @expenseAmountHt.
  ///
  /// In fr, this message translates to:
  /// **'Montant HT'**
  String get expenseAmountHt;

  /// No description provided for @expensesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune dépense'**
  String get expensesEmpty;

  /// No description provided for @expenseCatRent.
  ///
  /// In fr, this message translates to:
  /// **'Loyer'**
  String get expenseCatRent;

  /// No description provided for @expenseCatUtilities.
  ///
  /// In fr, this message translates to:
  /// **'Énergie & fluides'**
  String get expenseCatUtilities;

  /// No description provided for @expenseCatSupplies.
  ///
  /// In fr, this message translates to:
  /// **'Fournitures'**
  String get expenseCatSupplies;

  /// No description provided for @expenseCatMarketing.
  ///
  /// In fr, this message translates to:
  /// **'Marketing'**
  String get expenseCatMarketing;

  /// No description provided for @expenseCatTransport.
  ///
  /// In fr, this message translates to:
  /// **'Transport'**
  String get expenseCatTransport;

  /// No description provided for @expenseCatSalaries.
  ///
  /// In fr, this message translates to:
  /// **'Salaires'**
  String get expenseCatSalaries;

  /// No description provided for @expenseCatTax.
  ///
  /// In fr, this message translates to:
  /// **'Taxes & impôts'**
  String get expenseCatTax;

  /// No description provided for @expenseCatOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get expenseCatOther;

  /// No description provided for @accountingVatSection.
  ///
  /// In fr, this message translates to:
  /// **'TVA & achats'**
  String get accountingVatSection;

  /// No description provided for @accountingEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune facture émise'**
  String get accountingEmpty;

  /// No description provided for @settingsBackup.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde & export'**
  String get settingsBackup;

  /// No description provided for @settingsBackupSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Exporter ou restaurer vos données'**
  String get settingsBackupSubtitle;

  /// No description provided for @backupExport.
  ///
  /// In fr, this message translates to:
  /// **'Exporter les données (JSON)'**
  String get backupExport;

  /// No description provided for @backupImport.
  ///
  /// In fr, this message translates to:
  /// **'Importer une sauvegarde'**
  String get backupImport;

  /// No description provided for @backupExportCsvAccounting.
  ///
  /// In fr, this message translates to:
  /// **'Exporter la comptabilité (CSV)'**
  String get backupExportCsvAccounting;

  /// No description provided for @backupExportCsvClients.
  ///
  /// In fr, this message translates to:
  /// **'Exporter les clients (CSV)'**
  String get backupExportCsvClients;

  /// No description provided for @backupDone.
  ///
  /// In fr, this message translates to:
  /// **'Données exportées'**
  String get backupDone;

  /// No description provided for @backupImported.
  ///
  /// In fr, this message translates to:
  /// **'Données importées'**
  String get backupImported;

  /// No description provided for @backupFailed.
  ///
  /// In fr, this message translates to:
  /// **'Opération impossible'**
  String get backupFailed;

  /// No description provided for @devicesSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un appareil'**
  String get devicesSearch;

  /// No description provided for @devicesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun appareil'**
  String get devicesEmpty;

  /// No description provided for @devicesEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Les appareils des réparations apparaîtront ici.'**
  String get devicesEmptySubtitle;

  /// No description provided for @deviceRepairs.
  ///
  /// In fr, this message translates to:
  /// **'Réparations'**
  String get deviceRepairs;

  /// No description provided for @deviceIdentity.
  ///
  /// In fr, this message translates to:
  /// **'Identité'**
  String get deviceIdentity;

  /// No description provided for @deviceOwner.
  ///
  /// In fr, this message translates to:
  /// **'Propriétaire'**
  String get deviceOwner;

  /// No description provided for @deviceSerial.
  ///
  /// In fr, this message translates to:
  /// **'IMEI / N° série'**
  String get deviceSerial;

  /// No description provided for @deviceWarranty.
  ///
  /// In fr, this message translates to:
  /// **'Garantie'**
  String get deviceWarranty;

  /// No description provided for @deviceHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get deviceHistory;

  /// No description provided for @assistantPlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'Posez une question sur votre atelier…'**
  String get assistantPlaceholder;

  /// No description provided for @assistantNoKey.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez votre clé API Anthropic pour activer l\'assistant.'**
  String get assistantNoKey;

  /// No description provided for @assistantApiKey.
  ///
  /// In fr, this message translates to:
  /// **'Clé API Anthropic'**
  String get assistantApiKey;

  /// No description provided for @assistantModel.
  ///
  /// In fr, this message translates to:
  /// **'Modèle'**
  String get assistantModel;

  /// No description provided for @assistantThinking.
  ///
  /// In fr, this message translates to:
  /// **'Réflexion…'**
  String get assistantThinking;

  /// No description provided for @assistantError.
  ///
  /// In fr, this message translates to:
  /// **'La requête a échoué. Vérifiez la clé et la connexion.'**
  String get assistantError;

  /// No description provided for @assistantConfig.
  ///
  /// In fr, this message translates to:
  /// **'Configuration de l\'assistant'**
  String get assistantConfig;

  /// No description provided for @assistantIntro.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour ! Posez-moi une question sur vos réparations, factures ou stock.'**
  String get assistantIntro;

  /// No description provided for @settingsStorage.
  ///
  /// In fr, this message translates to:
  /// **'Stockage'**
  String get settingsStorage;

  /// No description provided for @settingsStorageLocal.
  ///
  /// In fr, this message translates to:
  /// **'Local · serveur bientôt'**
  String get settingsStorageLocal;

  /// No description provided for @navSearch.
  ///
  /// In fr, this message translates to:
  /// **'Recherche'**
  String get navSearch;

  /// No description provided for @searchPlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher partout…'**
  String get searchPlaceholder;

  /// No description provided for @searchHint.
  ///
  /// In fr, this message translates to:
  /// **'Clients, réparations, factures, devis'**
  String get searchHint;

  /// No description provided for @searchEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat'**
  String get searchEmpty;

  /// No description provided for @greetingMorning.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In fr, this message translates to:
  /// **'Bon après-midi'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In fr, this message translates to:
  /// **'Bonsoir'**
  String get greetingEvening;

  /// No description provided for @periodYear.
  ///
  /// In fr, this message translates to:
  /// **'Année'**
  String get periodYear;

  /// No description provided for @dashboardVsPrevious.
  ///
  /// In fr, this message translates to:
  /// **'vs période préc.'**
  String get dashboardVsPrevious;

  /// No description provided for @dashboardRevenueTrend.
  ///
  /// In fr, this message translates to:
  /// **'Chiffre d\'affaires'**
  String get dashboardRevenueTrend;

  /// No description provided for @dashboardStatusMix.
  ///
  /// In fr, this message translates to:
  /// **'Réparations'**
  String get dashboardStatusMix;

  /// No description provided for @dashboardNeedsAttention.
  ///
  /// In fr, this message translates to:
  /// **'À traiter'**
  String get dashboardNeedsAttention;

  /// No description provided for @quickNewRepair.
  ///
  /// In fr, this message translates to:
  /// **'Réparation'**
  String get quickNewRepair;

  /// No description provided for @quickNewQuote.
  ///
  /// In fr, this message translates to:
  /// **'Devis'**
  String get quickNewQuote;

  /// No description provided for @quickNewInvoice.
  ///
  /// In fr, this message translates to:
  /// **'Facture'**
  String get quickNewInvoice;

  /// No description provided for @alertOverdueInvoices.
  ///
  /// In fr, this message translates to:
  /// **'Factures en retard'**
  String get alertOverdueInvoices;

  /// No description provided for @alertLowStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock bas'**
  String get alertLowStock;

  /// No description provided for @alertUnassigned.
  ///
  /// In fr, this message translates to:
  /// **'Non assignées'**
  String get alertUnassigned;

  /// No description provided for @alertOverdueDeliveries.
  ///
  /// In fr, this message translates to:
  /// **'Livraisons en retard'**
  String get alertOverdueDeliveries;

  /// No description provided for @alertOverduePayables.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseurs à payer'**
  String get alertOverduePayables;

  /// No description provided for @dashboardPriorities.
  ///
  /// In fr, this message translates to:
  /// **'Priorités'**
  String get dashboardPriorities;

  /// No description provided for @dashboardOverdueBy.
  ///
  /// In fr, this message translates to:
  /// **'En retard de {days} j'**
  String dashboardOverdueBy(Object days);

  /// No description provided for @alertDueToday.
  ///
  /// In fr, this message translates to:
  /// **'Échéances du jour'**
  String get alertDueToday;

  /// No description provided for @alertAwaitingParts.
  ///
  /// In fr, this message translates to:
  /// **'En attente de pièces'**
  String get alertAwaitingParts;

  /// No description provided for @dashboardActiveRepairs.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get dashboardActiveRepairs;

  /// No description provided for @dashboardCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Terminées'**
  String get dashboardCompleted;

  /// No description provided for @dashboardCollected.
  ///
  /// In fr, this message translates to:
  /// **'Encaissé'**
  String get dashboardCollected;

  /// No description provided for @dashboardAllClear.
  ///
  /// In fr, this message translates to:
  /// **'Tout est à jour'**
  String get dashboardAllClear;

  /// No description provided for @trendSince.
  ///
  /// In fr, this message translates to:
  /// **'{value} vs période précédente'**
  String trendSince(String value);

  /// No description provided for @periodDay.
  ///
  /// In fr, this message translates to:
  /// **'Jour'**
  String get periodDay;

  /// No description provided for @periodWeek.
  ///
  /// In fr, this message translates to:
  /// **'Semaine'**
  String get periodWeek;

  /// No description provided for @periodMonth.
  ///
  /// In fr, this message translates to:
  /// **'Mois'**
  String get periodMonth;

  /// No description provided for @repairsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réparations'**
  String get repairsTitle;

  /// No description provided for @repairsNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle réparation'**
  String get repairsNew;

  /// No description provided for @repairsSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une réparation'**
  String get repairsSearch;

  /// No description provided for @repairsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune réparation enregistrée'**
  String get repairsEmpty;

  /// No description provided for @repairsEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Créez une fiche pour suivre une intervention.'**
  String get repairsEmptySubtitle;

  /// No description provided for @repairsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune réparation} =1{1 réparation} other{{count} réparations}}'**
  String repairsCount(int count);

  /// No description provided for @statusInProgress.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get statusInProgress;

  /// No description provided for @statusAwaitingParts.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get statusAwaitingParts;

  /// No description provided for @statusCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Terminée'**
  String get statusCompleted;

  /// No description provided for @statusReceived.
  ///
  /// In fr, this message translates to:
  /// **'Reçue'**
  String get statusReceived;

  /// No description provided for @statusDiagnosing.
  ///
  /// In fr, this message translates to:
  /// **'Diagnostic'**
  String get statusDiagnosing;

  /// No description provided for @statusDelivered.
  ///
  /// In fr, this message translates to:
  /// **'Livrée'**
  String get statusDelivered;

  /// No description provided for @statusCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulée'**
  String get statusCancelled;

  /// No description provided for @repairEventStatus.
  ///
  /// In fr, this message translates to:
  /// **'Statut : {status}'**
  String repairEventStatus(Object status);

  /// No description provided for @repairEventTech.
  ///
  /// In fr, this message translates to:
  /// **'Assignée à {tech}'**
  String repairEventTech(Object tech);

  /// No description provided for @repairEventTechCleared.
  ///
  /// In fr, this message translates to:
  /// **'Technicien retiré'**
  String get repairEventTechCleared;

  /// No description provided for @repairEventPayment.
  ///
  /// In fr, this message translates to:
  /// **'Paiement : {status}'**
  String repairEventPayment(Object status);

  /// No description provided for @repairTimeline.
  ///
  /// In fr, this message translates to:
  /// **'Suivi'**
  String get repairTimeline;

  /// No description provided for @repairNotify.
  ///
  /// In fr, this message translates to:
  /// **'Notifier le client'**
  String get repairNotify;

  /// No description provided for @notifyTemplate.
  ///
  /// In fr, this message translates to:
  /// **'Modèle'**
  String get notifyTemplate;

  /// No description provided for @notifyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Message'**
  String get notifyMessage;

  /// No description provided for @notifySend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get notifySend;

  /// No description provided for @notifyNoContact.
  ///
  /// In fr, this message translates to:
  /// **'Aucun contact pour ce canal'**
  String get notifyNoContact;

  /// No description provided for @repairSectionComms.
  ///
  /// In fr, this message translates to:
  /// **'Communications'**
  String get repairSectionComms;

  /// No description provided for @repairAdvance.
  ///
  /// In fr, this message translates to:
  /// **'Faire avancer'**
  String get repairAdvance;

  /// No description provided for @clientsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Clients'**
  String get clientsTitle;

  /// No description provided for @clientsNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau client'**
  String get clientsNew;

  /// No description provided for @clientsSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un client'**
  String get clientsSearch;

  /// No description provided for @clientsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun client enregistré'**
  String get clientsEmpty;

  /// No description provided for @clientsEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez un client pour commencer.'**
  String get clientsEmptySubtitle;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In fr, this message translates to:
  /// **'Apparence'**
  String get settingsAppearance;

  /// No description provided for @settingsThemeMode.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get settingsThemeMode;

  /// No description provided for @settingsThemeLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get settingsThemeSystem;

  /// No description provided for @settingsAccent.
  ///
  /// In fr, this message translates to:
  /// **'Couleur d\'accent'**
  String get settingsAccent;

  /// No description provided for @settingsLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settingsLanguage;

  /// No description provided for @settingsGeneral.
  ///
  /// In fr, this message translates to:
  /// **'Général'**
  String get settingsGeneral;

  /// No description provided for @settingsWorkshopInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations de l\'atelier'**
  String get settingsWorkshopInfo;

  /// No description provided for @settingsWorkshopInfoSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Nom, adresse, coordonnées'**
  String get settingsWorkshopInfoSubtitle;

  /// No description provided for @settingsAbout.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get settingsAbout;

  /// No description provided for @settingsAboutDescription.
  ///
  /// In fr, this message translates to:
  /// **'Application de gestion pour atelier de réparation.'**
  String get settingsAboutDescription;

  /// No description provided for @languageSystem.
  ///
  /// In fr, this message translates to:
  /// **'Automatique'**
  String get languageSystem;

  /// No description provided for @languageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageEnglish.
  ///
  /// In fr, this message translates to:
  /// **'Anglais'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In fr, this message translates to:
  /// **'Arabe'**
  String get languageArabic;

  /// No description provided for @languageSpanish.
  ///
  /// In fr, this message translates to:
  /// **'Espagnol'**
  String get languageSpanish;

  /// No description provided for @accentBlue.
  ///
  /// In fr, this message translates to:
  /// **'Bleu'**
  String get accentBlue;

  /// No description provided for @accentGreen.
  ///
  /// In fr, this message translates to:
  /// **'Vert'**
  String get accentGreen;

  /// No description provided for @accentOrange.
  ///
  /// In fr, this message translates to:
  /// **'Orange'**
  String get accentOrange;

  /// No description provided for @accentRed.
  ///
  /// In fr, this message translates to:
  /// **'Rouge'**
  String get accentRed;

  /// No description provided for @accentIndigo.
  ///
  /// In fr, this message translates to:
  /// **'Indigo'**
  String get accentIndigo;

  /// No description provided for @accentPurple.
  ///
  /// In fr, this message translates to:
  /// **'Violet'**
  String get accentPurple;

  /// No description provided for @accentTeal.
  ///
  /// In fr, this message translates to:
  /// **'Turquoise'**
  String get accentTeal;

  /// No description provided for @commonCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get commonSave;

  /// No description provided for @commonDone.
  ///
  /// In fr, this message translates to:
  /// **'Terminé'**
  String get commonDone;

  /// No description provided for @commonSeeAll.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get commonSeeAll;

  /// No description provided for @commonShowLess.
  ///
  /// In fr, this message translates to:
  /// **'Réduire'**
  String get commonShowLess;

  /// No description provided for @commonSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get commonSearch;

  /// No description provided for @repairsFilterAll.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get repairsFilterAll;

  /// No description provided for @repairPriority.
  ///
  /// In fr, this message translates to:
  /// **'Priorité'**
  String get repairPriority;

  /// No description provided for @repairPriorityLow.
  ///
  /// In fr, this message translates to:
  /// **'Basse'**
  String get repairPriorityLow;

  /// No description provided for @repairPriorityNormal.
  ///
  /// In fr, this message translates to:
  /// **'Normale'**
  String get repairPriorityNormal;

  /// No description provided for @repairPriorityHigh.
  ///
  /// In fr, this message translates to:
  /// **'Haute'**
  String get repairPriorityHigh;

  /// No description provided for @repairUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Mis à jour {when}'**
  String repairUpdated(String when);

  /// No description provided for @repairDetailSelectTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune réparation sélectionnée'**
  String get repairDetailSelectTitle;

  /// No description provided for @repairDetailSelectSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez une réparation pour voir les détails.'**
  String get repairDetailSelectSubtitle;

  /// No description provided for @repairSectionClient.
  ///
  /// In fr, this message translates to:
  /// **'Client'**
  String get repairSectionClient;

  /// No description provided for @repairSectionProgress.
  ///
  /// In fr, this message translates to:
  /// **'Progression'**
  String get repairSectionProgress;

  /// No description provided for @repairSectionTimeline.
  ///
  /// In fr, this message translates to:
  /// **'Suivi'**
  String get repairSectionTimeline;

  /// No description provided for @repairSectionParts.
  ///
  /// In fr, this message translates to:
  /// **'Pièces'**
  String get repairSectionParts;

  /// No description provided for @repairSectionNotes.
  ///
  /// In fr, this message translates to:
  /// **'Notes'**
  String get repairSectionNotes;

  /// No description provided for @repairCost.
  ///
  /// In fr, this message translates to:
  /// **'Coût estimé'**
  String get repairCost;

  /// No description provided for @repairMarkComplete.
  ///
  /// In fr, this message translates to:
  /// **'Marquer comme terminée'**
  String get repairMarkComplete;

  /// No description provided for @repairContactClient.
  ///
  /// In fr, this message translates to:
  /// **'Contacter le client'**
  String get repairContactClient;

  /// No description provided for @repairEventCreated.
  ///
  /// In fr, this message translates to:
  /// **'Fiche créée'**
  String get repairEventCreated;

  /// No description provided for @repairEventDiagnosed.
  ///
  /// In fr, this message translates to:
  /// **'Diagnostic effectué'**
  String get repairEventDiagnosed;

  /// No description provided for @repairEventInRepair.
  ///
  /// In fr, this message translates to:
  /// **'Réparation en cours'**
  String get repairEventInRepair;

  /// No description provided for @repairEventCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Réparation terminée'**
  String get repairEventCompleted;

  /// No description provided for @repairNoParts.
  ///
  /// In fr, this message translates to:
  /// **'Aucune pièce enregistrée'**
  String get repairNoParts;

  /// No description provided for @repairNoNotes.
  ///
  /// In fr, this message translates to:
  /// **'Aucune note'**
  String get repairNoNotes;

  /// No description provided for @repairSort.
  ///
  /// In fr, this message translates to:
  /// **'Trier'**
  String get repairSort;

  /// No description provided for @repairSortRecent.
  ///
  /// In fr, this message translates to:
  /// **'Récent'**
  String get repairSortRecent;

  /// No description provided for @repairSortPriority.
  ///
  /// In fr, this message translates to:
  /// **'Priorité'**
  String get repairSortPriority;

  /// No description provided for @repairSortCost.
  ///
  /// In fr, this message translates to:
  /// **'Coût'**
  String get repairSortCost;

  /// No description provided for @repairFilters.
  ///
  /// In fr, this message translates to:
  /// **'Filtres'**
  String get repairFilters;

  /// No description provided for @repairFilterDeviceTitle.
  ///
  /// In fr, this message translates to:
  /// **'Type d\'appareil'**
  String get repairFilterDeviceTitle;

  /// No description provided for @repairFilterAny.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get repairFilterAny;

  /// No description provided for @repairActiveOnly.
  ///
  /// In fr, this message translates to:
  /// **'Actifs seulement'**
  String get repairActiveOnly;

  /// No description provided for @repairFiltersReset.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get repairFiltersReset;

  /// No description provided for @repairFiltersApply.
  ///
  /// In fr, this message translates to:
  /// **'Appliquer'**
  String get repairFiltersApply;

  /// No description provided for @deviceKindPhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get deviceKindPhone;

  /// No description provided for @deviceKindLaptop.
  ///
  /// In fr, this message translates to:
  /// **'Ordinateur'**
  String get deviceKindLaptop;

  /// No description provided for @deviceKindTablet.
  ///
  /// In fr, this message translates to:
  /// **'Tablette'**
  String get deviceKindTablet;

  /// No description provided for @deviceKindWatch.
  ///
  /// In fr, this message translates to:
  /// **'Montre'**
  String get deviceKindWatch;

  /// No description provided for @deviceKindOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get deviceKindOther;

  /// No description provided for @navDevices.
  ///
  /// In fr, this message translates to:
  /// **'Appareils'**
  String get navDevices;

  /// No description provided for @navPlanning.
  ///
  /// In fr, this message translates to:
  /// **'Planning'**
  String get navPlanning;

  /// No description provided for @navQuotes.
  ///
  /// In fr, this message translates to:
  /// **'Devis'**
  String get navQuotes;

  /// No description provided for @navInvoices.
  ///
  /// In fr, this message translates to:
  /// **'Factures'**
  String get navInvoices;

  /// No description provided for @navPayments.
  ///
  /// In fr, this message translates to:
  /// **'Paiements'**
  String get navPayments;

  /// No description provided for @navAccounting.
  ///
  /// In fr, this message translates to:
  /// **'Comptabilité'**
  String get navAccounting;

  /// No description provided for @navInventory.
  ///
  /// In fr, this message translates to:
  /// **'Inventaire'**
  String get navInventory;

  /// No description provided for @navCatalog.
  ///
  /// In fr, this message translates to:
  /// **'Catalogue'**
  String get navCatalog;

  /// No description provided for @navSuppliers.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseurs'**
  String get navSuppliers;

  /// No description provided for @navOrders.
  ///
  /// In fr, this message translates to:
  /// **'Commandes'**
  String get navOrders;

  /// No description provided for @navStaff.
  ///
  /// In fr, this message translates to:
  /// **'Employés'**
  String get navStaff;

  /// No description provided for @navUsers.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateurs'**
  String get navUsers;

  /// No description provided for @navReports.
  ///
  /// In fr, this message translates to:
  /// **'Rapports'**
  String get navReports;

  /// No description provided for @navAssistant.
  ///
  /// In fr, this message translates to:
  /// **'Assistant IA'**
  String get navAssistant;

  /// No description provided for @navGroupMain.
  ///
  /// In fr, this message translates to:
  /// **'Principal'**
  String get navGroupMain;

  /// No description provided for @navGroupFinance.
  ///
  /// In fr, this message translates to:
  /// **'Finances'**
  String get navGroupFinance;

  /// No description provided for @navGroupStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock'**
  String get navGroupStock;

  /// No description provided for @navGroupManagement.
  ///
  /// In fr, this message translates to:
  /// **'Gestion'**
  String get navGroupManagement;

  /// No description provided for @navGroupSystem.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get navGroupSystem;

  /// No description provided for @navMore.
  ///
  /// In fr, this message translates to:
  /// **'Plus'**
  String get navMore;

  /// No description provided for @comingSoonTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bientôt disponible'**
  String get comingSoonTitle;

  /// No description provided for @comingSoonSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Cette section est en cours de construction.'**
  String get comingSoonSubtitle;

  /// No description provided for @catalogSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un produit'**
  String get catalogSearch;

  /// No description provided for @catalogEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun produit'**
  String get catalogEmpty;

  /// No description provided for @catalogEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez vos pièces, accessoires et services.'**
  String get catalogEmptySubtitle;

  /// No description provided for @variantsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Variantes'**
  String get variantsLabel;

  /// No description provided for @productNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau produit'**
  String get productNew;

  /// No description provided for @productName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du produit'**
  String get productName;

  /// No description provided for @productBrand.
  ///
  /// In fr, this message translates to:
  /// **'Marque'**
  String get productBrand;

  /// No description provided for @productCategory.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get productCategory;

  /// No description provided for @productVariants.
  ///
  /// In fr, this message translates to:
  /// **'Variantes'**
  String get productVariants;

  /// No description provided for @priceLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prix'**
  String get priceLabel;

  /// No description provided for @stockLabel.
  ///
  /// In fr, this message translates to:
  /// **'Stock'**
  String get stockLabel;

  /// No description provided for @skuLabel.
  ///
  /// In fr, this message translates to:
  /// **'Réf.'**
  String get skuLabel;

  /// No description provided for @categoryPart.
  ///
  /// In fr, this message translates to:
  /// **'Pièce'**
  String get categoryPart;

  /// No description provided for @categoryAccessory.
  ///
  /// In fr, this message translates to:
  /// **'Accessoire'**
  String get categoryAccessory;

  /// No description provided for @categoryService.
  ///
  /// In fr, this message translates to:
  /// **'Prestation'**
  String get categoryService;

  /// No description provided for @serviceCatDiagnostic.
  ///
  /// In fr, this message translates to:
  /// **'Diagnostic'**
  String get serviceCatDiagnostic;

  /// No description provided for @serviceCatScreen.
  ///
  /// In fr, this message translates to:
  /// **'Écran'**
  String get serviceCatScreen;

  /// No description provided for @serviceCatBattery.
  ///
  /// In fr, this message translates to:
  /// **'Batterie'**
  String get serviceCatBattery;

  /// No description provided for @serviceCatSoftware.
  ///
  /// In fr, this message translates to:
  /// **'Logiciel'**
  String get serviceCatSoftware;

  /// No description provided for @serviceCatData.
  ///
  /// In fr, this message translates to:
  /// **'Données'**
  String get serviceCatData;

  /// No description provided for @serviceCatOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get serviceCatOther;

  /// No description provided for @navServices.
  ///
  /// In fr, this message translates to:
  /// **'Prestations'**
  String get navServices;

  /// No description provided for @servicesSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une prestation'**
  String get servicesSearch;

  /// No description provided for @servicesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune prestation'**
  String get servicesEmpty;

  /// No description provided for @servicesEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez vos prestations et leurs tarifs.'**
  String get servicesEmptySubtitle;

  /// No description provided for @serviceCategoryHeader.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get serviceCategoryHeader;

  /// No description provided for @serviceDurationLabel.
  ///
  /// In fr, this message translates to:
  /// **'Durée'**
  String get serviceDurationLabel;

  /// No description provided for @serviceMargin.
  ///
  /// In fr, this message translates to:
  /// **'Marge'**
  String get serviceMargin;

  /// No description provided for @serviceNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle prestation'**
  String get serviceNew;

  /// No description provided for @serviceEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la prestation'**
  String get serviceEdit;

  /// No description provided for @serviceDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get serviceDescription;

  /// No description provided for @serviceCost.
  ///
  /// In fr, this message translates to:
  /// **'Coût'**
  String get serviceCost;

  /// No description provided for @serviceDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la prestation'**
  String get serviceDelete;

  /// No description provided for @serviceDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette prestation ?'**
  String get serviceDeleteConfirm;

  /// No description provided for @serviceAddToCatalog.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter au catalogue'**
  String get serviceAddToCatalog;

  /// No description provided for @navCategories.
  ///
  /// In fr, this message translates to:
  /// **'Catégories'**
  String get navCategories;

  /// No description provided for @categoryNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle catégorie'**
  String get categoryNew;

  /// No description provided for @categorySubNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle sous-catégorie'**
  String get categorySubNew;

  /// No description provided for @categoryIcon.
  ///
  /// In fr, this message translates to:
  /// **'Icône'**
  String get categoryIcon;

  /// No description provided for @categoryColor.
  ///
  /// In fr, this message translates to:
  /// **'Couleur'**
  String get categoryColor;

  /// No description provided for @categoryDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la catégorie'**
  String get categoryDelete;

  /// No description provided for @categoryDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette catégorie ?'**
  String get categoryDeleteConfirm;

  /// No description provided for @categoryReassign.
  ///
  /// In fr, this message translates to:
  /// **'Déplacer les prestations vers'**
  String get categoryReassign;

  /// No description provided for @categoryAddSub.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une sous-catégorie'**
  String get categoryAddSub;

  /// No description provided for @categoryMoveServices.
  ///
  /// In fr, this message translates to:
  /// **'Déplacer les prestations'**
  String get categoryMoveServices;

  /// No description provided for @categoryMoveProducts.
  ///
  /// In fr, this message translates to:
  /// **'Déplacer les produits'**
  String get categoryMoveProducts;

  /// No description provided for @categoryReassignProducts.
  ///
  /// In fr, this message translates to:
  /// **'Déplacer les produits vers'**
  String get categoryReassignProducts;

  /// No description provided for @productEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le produit'**
  String get productEdit;

  /// No description provided for @categorySelect.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une catégorie'**
  String get categorySelect;

  /// No description provided for @taxonomyRoot.
  ///
  /// In fr, this message translates to:
  /// **'Racine'**
  String get taxonomyRoot;

  /// No description provided for @taxonomyCode.
  ///
  /// In fr, this message translates to:
  /// **'Code'**
  String get taxonomyCode;

  /// No description provided for @taxonomyDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get taxonomyDescription;

  /// No description provided for @taxonomyParent.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie parente'**
  String get taxonomyParent;

  /// No description provided for @taxonomyReassign.
  ///
  /// In fr, this message translates to:
  /// **'Déplacer les éléments vers'**
  String get taxonomyReassign;

  /// No description provided for @taxonomyMergeInto.
  ///
  /// In fr, this message translates to:
  /// **'Fusionner avec…'**
  String get taxonomyMergeInto;

  /// No description provided for @taxonomyMoveItems.
  ///
  /// In fr, this message translates to:
  /// **'Déplacer les éléments'**
  String get taxonomyMoveItems;

  /// No description provided for @taxonomyCodeTaken.
  ///
  /// In fr, this message translates to:
  /// **'Ce code est déjà utilisé'**
  String get taxonomyCodeTaken;

  /// No description provided for @taxonomyShowArchived.
  ///
  /// In fr, this message translates to:
  /// **'Afficher les archivées'**
  String get taxonomyShowArchived;

  /// No description provided for @taxonomyEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune catégorie'**
  String get taxonomyEmpty;

  /// No description provided for @taxonomySearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une catégorie'**
  String get taxonomySearch;

  /// No description provided for @taxonomyExpandAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout déplier'**
  String get taxonomyExpandAll;

  /// No description provided for @taxonomyCollapseAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout replier'**
  String get taxonomyCollapseAll;

  /// No description provided for @supplierProducts.
  ///
  /// In fr, this message translates to:
  /// **'Produits fournis'**
  String get supplierProducts;

  /// No description provided for @supplierOrderedProducts.
  ///
  /// In fr, this message translates to:
  /// **'Déjà commandés (non liés)'**
  String get supplierOrderedProducts;

  /// No description provided for @supplierLinkProduct.
  ///
  /// In fr, this message translates to:
  /// **'Lier'**
  String get supplierLinkProduct;

  /// No description provided for @inventoryReorder.
  ///
  /// In fr, this message translates to:
  /// **'Commander'**
  String get inventoryReorder;

  /// No description provided for @inventoryNoSupplier.
  ///
  /// In fr, this message translates to:
  /// **'Aucun fournisseur lié à ce produit'**
  String get inventoryNoSupplier;

  /// No description provided for @supplierInUse.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseur référencé (produits ou commandes) — suppression impossible'**
  String get supplierInUse;

  /// No description provided for @supplierDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ce fournisseur ?'**
  String get supplierDeleteConfirm;

  /// No description provided for @commonOk.
  ///
  /// In fr, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @sourcingPurchasePrice.
  ///
  /// In fr, this message translates to:
  /// **'Prix d\'achat'**
  String get sourcingPurchasePrice;

  /// No description provided for @sourcingPreferred.
  ///
  /// In fr, this message translates to:
  /// **'Préféré'**
  String get sourcingPreferred;

  /// No description provided for @sourcingBestPrice.
  ///
  /// In fr, this message translates to:
  /// **'Meilleur prix'**
  String get sourcingBestPrice;

  /// No description provided for @productFacets.
  ///
  /// In fr, this message translates to:
  /// **'Facettes'**
  String get productFacets;

  /// No description provided for @smartViews.
  ///
  /// In fr, this message translates to:
  /// **'Sélections'**
  String get smartViews;

  /// No description provided for @smartViewNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle sélection'**
  String get smartViewNew;

  /// No description provided for @smartRule.
  ///
  /// In fr, this message translates to:
  /// **'Règle'**
  String get smartRule;

  /// No description provided for @smartStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock'**
  String get smartStock;

  /// No description provided for @smartPriceMax.
  ///
  /// In fr, this message translates to:
  /// **'Prix max'**
  String get smartPriceMax;

  /// No description provided for @smartPriceMin.
  ///
  /// In fr, this message translates to:
  /// **'Prix min'**
  String get smartPriceMin;

  /// No description provided for @smartAny.
  ///
  /// In fr, this message translates to:
  /// **'Indifférent'**
  String get smartAny;

  /// No description provided for @catalogManage.
  ///
  /// In fr, this message translates to:
  /// **'Gérer'**
  String get catalogManage;

  /// No description provided for @serviceDuplicate.
  ///
  /// In fr, this message translates to:
  /// **'Dupliquer'**
  String get serviceDuplicate;

  /// No description provided for @serviceCopySuffix.
  ///
  /// In fr, this message translates to:
  /// **'(copie)'**
  String get serviceCopySuffix;

  /// No description provided for @variantNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle variante'**
  String get variantNew;

  /// No description provided for @variantLabel.
  ///
  /// In fr, this message translates to:
  /// **'Libellé (ex. Noir · OEM)'**
  String get variantLabel;

  /// No description provided for @variantCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune variante} =1{1 variante} other{{count} variantes}}'**
  String variantCount(int count);

  /// No description provided for @stockUnits.
  ///
  /// In fr, this message translates to:
  /// **'{count} en stock'**
  String stockUnits(int count);

  /// No description provided for @addLabel.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get addLabel;

  /// No description provided for @repairSectionServices.
  ///
  /// In fr, this message translates to:
  /// **'Prestations'**
  String get repairSectionServices;

  /// No description provided for @repairNoServices.
  ///
  /// In fr, this message translates to:
  /// **'Aucune prestation'**
  String get repairNoServices;

  /// No description provided for @repairServicesTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total prestations'**
  String get repairServicesTotal;

  /// No description provided for @repairSectionObservations.
  ///
  /// In fr, this message translates to:
  /// **'Observations'**
  String get repairSectionObservations;

  /// No description provided for @repairNoObservations.
  ///
  /// In fr, this message translates to:
  /// **'Aucune observation'**
  String get repairNoObservations;

  /// No description provided for @paymentUnpaid.
  ///
  /// In fr, this message translates to:
  /// **'Impayé'**
  String get paymentUnpaid;

  /// No description provided for @paymentPartial.
  ///
  /// In fr, this message translates to:
  /// **'Partiel'**
  String get paymentPartial;

  /// No description provided for @paymentPaid.
  ///
  /// In fr, this message translates to:
  /// **'Payé'**
  String get paymentPaid;

  /// No description provided for @repairSectionProblem.
  ///
  /// In fr, this message translates to:
  /// **'Problème'**
  String get repairSectionProblem;

  /// No description provided for @repairReported.
  ///
  /// In fr, this message translates to:
  /// **'Panne signalée'**
  String get repairReported;

  /// No description provided for @repairDiagnosis.
  ///
  /// In fr, this message translates to:
  /// **'Diagnostic'**
  String get repairDiagnosis;

  /// No description provided for @repairWorkDone.
  ///
  /// In fr, this message translates to:
  /// **'Travail effectué'**
  String get repairWorkDone;

  /// No description provided for @repairSectionDevice.
  ///
  /// In fr, this message translates to:
  /// **'Appareil'**
  String get repairSectionDevice;

  /// No description provided for @deviceModel.
  ///
  /// In fr, this message translates to:
  /// **'Modèle'**
  String get deviceModel;

  /// No description provided for @deviceColor.
  ///
  /// In fr, this message translates to:
  /// **'Couleur'**
  String get deviceColor;

  /// No description provided for @deviceStorage.
  ///
  /// In fr, this message translates to:
  /// **'Stockage'**
  String get deviceStorage;

  /// No description provided for @deviceAccessories.
  ///
  /// In fr, this message translates to:
  /// **'Accessoires'**
  String get deviceAccessories;

  /// No description provided for @repairIntakeCondition.
  ///
  /// In fr, this message translates to:
  /// **'État à la prise en charge'**
  String get repairIntakeCondition;

  /// No description provided for @devicePasscode.
  ///
  /// In fr, this message translates to:
  /// **'Code de déverrouillage'**
  String get devicePasscode;

  /// No description provided for @backupConsent.
  ///
  /// In fr, this message translates to:
  /// **'Consentement sauvegarde'**
  String get backupConsent;

  /// No description provided for @repairSectionFinance.
  ///
  /// In fr, this message translates to:
  /// **'Finances'**
  String get repairSectionFinance;

  /// No description provided for @financeLabour.
  ///
  /// In fr, this message translates to:
  /// **'Main-d\'œuvre'**
  String get financeLabour;

  /// No description provided for @financeDiscount.
  ///
  /// In fr, this message translates to:
  /// **'Remise'**
  String get financeDiscount;

  /// No description provided for @financeTax.
  ///
  /// In fr, this message translates to:
  /// **'TVA'**
  String get financeTax;

  /// No description provided for @financeSubtotal.
  ///
  /// In fr, this message translates to:
  /// **'Sous-total'**
  String get financeSubtotal;

  /// No description provided for @financeTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get financeTotal;

  /// No description provided for @financeDeposit.
  ///
  /// In fr, this message translates to:
  /// **'Acompte'**
  String get financeDeposit;

  /// No description provided for @financeBalance.
  ///
  /// In fr, this message translates to:
  /// **'Solde dû'**
  String get financeBalance;

  /// No description provided for @repairSectionLogistics.
  ///
  /// In fr, this message translates to:
  /// **'Suivi & logistique'**
  String get repairSectionLogistics;

  /// No description provided for @repairAssignedTech.
  ///
  /// In fr, this message translates to:
  /// **'Technicien'**
  String get repairAssignedTech;

  /// No description provided for @repairCreatedBy.
  ///
  /// In fr, this message translates to:
  /// **'Pris en charge par'**
  String get repairCreatedBy;

  /// No description provided for @repairLocation.
  ///
  /// In fr, this message translates to:
  /// **'Emplacement'**
  String get repairLocation;

  /// No description provided for @repairWarranty.
  ///
  /// In fr, this message translates to:
  /// **'Garantie'**
  String get repairWarranty;

  /// No description provided for @repairUnderWarranty.
  ///
  /// In fr, this message translates to:
  /// **'Sous garantie'**
  String get repairUnderWarranty;

  /// No description provided for @repairWarrantyExpired.
  ///
  /// In fr, this message translates to:
  /// **'Garantie expirée'**
  String get repairWarrantyExpired;

  /// No description provided for @repairWarrantyUntil.
  ///
  /// In fr, this message translates to:
  /// **'Jusqu\'au {date}'**
  String repairWarrantyUntil(Object date);

  /// No description provided for @warrantyDuration.
  ///
  /// In fr, this message translates to:
  /// **'{count} mois'**
  String warrantyDuration(int count);

  /// No description provided for @repairDue.
  ///
  /// In fr, this message translates to:
  /// **'Échéance'**
  String get repairDue;

  /// No description provided for @repairOverdue.
  ///
  /// In fr, this message translates to:
  /// **'En retard'**
  String get repairOverdue;

  /// No description provided for @repairPhotos.
  ///
  /// In fr, this message translates to:
  /// **'Photos'**
  String get repairPhotos;

  /// No description provided for @repairPhotoAdded.
  ///
  /// In fr, this message translates to:
  /// **'Photo ajoutée'**
  String get repairPhotoAdded;

  /// No description provided for @repairPhotoRemove.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette photo ?'**
  String get repairPhotoRemove;

  /// No description provided for @repairEventPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Photo ajoutée'**
  String get repairEventPhoto;

  /// No description provided for @actionCall.
  ///
  /// In fr, this message translates to:
  /// **'Appeler'**
  String get actionCall;

  /// No description provided for @actionSms.
  ///
  /// In fr, this message translates to:
  /// **'SMS'**
  String get actionSms;

  /// No description provided for @actionWhatsapp.
  ///
  /// In fr, this message translates to:
  /// **'WhatsApp'**
  String get actionWhatsapp;

  /// No description provided for @actionEmail.
  ///
  /// In fr, this message translates to:
  /// **'E-mail'**
  String get actionEmail;

  /// No description provided for @actionEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get actionEdit;

  /// No description provided for @editMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode édition'**
  String get editMode;

  /// No description provided for @actionReopen.
  ///
  /// In fr, this message translates to:
  /// **'Rouvrir'**
  String get actionReopen;

  /// No description provided for @actionAssign.
  ///
  /// In fr, this message translates to:
  /// **'Assigner un technicien'**
  String get actionAssign;

  /// No description provided for @actionAddPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une photo'**
  String get actionAddPhoto;

  /// No description provided for @actionPrintLabel.
  ///
  /// In fr, this message translates to:
  /// **'Imprimer l\'étiquette'**
  String get actionPrintLabel;

  /// No description provided for @repairPrintChoose.
  ///
  /// In fr, this message translates to:
  /// **'Imprimer'**
  String get repairPrintChoose;

  /// No description provided for @repairSheetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Fiche de réparation'**
  String get repairSheetTitle;

  /// No description provided for @repairTicketTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ticket'**
  String get repairTicketTitle;

  /// No description provided for @repairSignatureClient.
  ///
  /// In fr, this message translates to:
  /// **'Signature du client'**
  String get repairSignatureClient;

  /// No description provided for @repairSignatureTech.
  ///
  /// In fr, this message translates to:
  /// **'Signature du technicien'**
  String get repairSignatureTech;

  /// No description provided for @repairTicketFooter.
  ///
  /// In fr, this message translates to:
  /// **'Présentez ce ticket pour récupérer l\'appareil.'**
  String get repairTicketFooter;

  /// No description provided for @unitMonths.
  ///
  /// In fr, this message translates to:
  /// **'mois'**
  String get unitMonths;

  /// No description provided for @repairScan.
  ///
  /// In fr, this message translates to:
  /// **'Scanner'**
  String get repairScan;

  /// No description provided for @repairScanHint.
  ///
  /// In fr, this message translates to:
  /// **'Placez le QR de la réparation dans le cadre'**
  String get repairScanHint;

  /// No description provided for @repairScanManual.
  ///
  /// In fr, this message translates to:
  /// **'Saisir la référence'**
  String get repairScanManual;

  /// No description provided for @repairScanReference.
  ///
  /// In fr, this message translates to:
  /// **'Référence'**
  String get repairScanReference;

  /// No description provided for @repairScanOpen.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir'**
  String get repairScanOpen;

  /// No description provided for @repairScanNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Réparation introuvable'**
  String get repairScanNotFound;

  /// No description provided for @repairScanUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Scan par caméra indisponible sur cette plateforme'**
  String get repairScanUnavailable;

  /// No description provided for @repairScanFromImage.
  ///
  /// In fr, this message translates to:
  /// **'Décoder depuis une image'**
  String get repairScanFromImage;

  /// No description provided for @repairScanError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de décoder le QR'**
  String get repairScanError;

  /// No description provided for @repairScanCameraError.
  ///
  /// In fr, this message translates to:
  /// **'Caméra indisponible (autorisation refusée ?)'**
  String get repairScanCameraError;

  /// No description provided for @actionGenerateInvoice.
  ///
  /// In fr, this message translates to:
  /// **'Générer une facture'**
  String get actionGenerateInvoice;

  /// No description provided for @actionDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get actionDelete;

  /// No description provided for @statusLabel.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get statusLabel;

  /// No description provided for @qtyShort.
  ///
  /// In fr, this message translates to:
  /// **'Qté'**
  String get qtyShort;

  /// No description provided for @unitPriceShort.
  ///
  /// In fr, this message translates to:
  /// **'PU'**
  String get unitPriceShort;

  /// No description provided for @addPrestation.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une prestation'**
  String get addPrestation;

  /// No description provided for @addPart.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une pièce'**
  String get addPart;

  /// No description provided for @unassigned.
  ///
  /// In fr, this message translates to:
  /// **'Non assigné'**
  String get unassigned;

  /// No description provided for @notProvided.
  ///
  /// In fr, this message translates to:
  /// **'Non renseigné'**
  String get notProvided;

  /// No description provided for @clientSectionContact.
  ///
  /// In fr, this message translates to:
  /// **'Coordonnées'**
  String get clientSectionContact;

  /// No description provided for @supplierNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau fournisseur'**
  String get supplierNew;

  /// No description provided for @supplierSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un fournisseur'**
  String get supplierSearch;

  /// No description provided for @supplierEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun fournisseur'**
  String get supplierEmpty;

  /// No description provided for @supplierEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez un fournisseur pour commencer.'**
  String get supplierEmptySubtitle;

  /// No description provided for @supplierType.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get supplierType;

  /// No description provided for @supplierTypeCompany.
  ///
  /// In fr, this message translates to:
  /// **'Société'**
  String get supplierTypeCompany;

  /// No description provided for @supplierTypeIndividual.
  ///
  /// In fr, this message translates to:
  /// **'Particulier'**
  String get supplierTypeIndividual;

  /// No description provided for @supplierName.
  ///
  /// In fr, this message translates to:
  /// **'Nom / Raison sociale'**
  String get supplierName;

  /// No description provided for @supplierContactName.
  ///
  /// In fr, this message translates to:
  /// **'Interlocuteur'**
  String get supplierContactName;

  /// No description provided for @supplierVat.
  ///
  /// In fr, this message translates to:
  /// **'N° TVA'**
  String get supplierVat;

  /// No description provided for @supplierCity.
  ///
  /// In fr, this message translates to:
  /// **'Ville'**
  String get supplierCity;

  /// No description provided for @supplierTerms.
  ///
  /// In fr, this message translates to:
  /// **'Conditions de paiement'**
  String get supplierTerms;

  /// No description provided for @supplierSectionCompany.
  ///
  /// In fr, this message translates to:
  /// **'Société'**
  String get supplierSectionCompany;

  /// No description provided for @fieldName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get fieldName;

  /// No description provided for @clientTypeIndividual.
  ///
  /// In fr, this message translates to:
  /// **'Particulier'**
  String get clientTypeIndividual;

  /// No description provided for @clientTypeCompany.
  ///
  /// In fr, this message translates to:
  /// **'Entreprise'**
  String get clientTypeCompany;

  /// No description provided for @clientCompanyName.
  ///
  /// In fr, this message translates to:
  /// **'Raison sociale'**
  String get clientCompanyName;

  /// No description provided for @clientVat.
  ///
  /// In fr, this message translates to:
  /// **'N° TVA'**
  String get clientVat;

  /// No description provided for @clientCity.
  ///
  /// In fr, this message translates to:
  /// **'Ville'**
  String get clientCity;

  /// No description provided for @clientSectionCompany.
  ///
  /// In fr, this message translates to:
  /// **'Entreprise'**
  String get clientSectionCompany;

  /// No description provided for @clientSectionHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique des réparations'**
  String get clientSectionHistory;

  /// No description provided for @staffNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel employé'**
  String get staffNew;

  /// No description provided for @staffSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un employé'**
  String get staffSearch;

  /// No description provided for @staffEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun employé'**
  String get staffEmpty;

  /// No description provided for @staffEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez un employé pour commencer.'**
  String get staffEmptySubtitle;

  /// No description provided for @staffJobTitle.
  ///
  /// In fr, this message translates to:
  /// **'Poste'**
  String get staffJobTitle;

  /// No description provided for @staffHireDate.
  ///
  /// In fr, this message translates to:
  /// **'Date d\'embauche'**
  String get staffHireDate;

  /// No description provided for @staffCommission.
  ///
  /// In fr, this message translates to:
  /// **'Commission (%)'**
  String get staffCommission;

  /// No description provided for @staffActive.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get staffActive;

  /// No description provided for @staffInactive.
  ///
  /// In fr, this message translates to:
  /// **'Inactif'**
  String get staffInactive;

  /// No description provided for @staffSectionEmployment.
  ///
  /// In fr, this message translates to:
  /// **'Emploi'**
  String get staffSectionEmployment;

  /// No description provided for @staffAssignedRepairs.
  ///
  /// In fr, this message translates to:
  /// **'Réparations assignées'**
  String get staffAssignedRepairs;

  /// No description provided for @authLoginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get authLoginTitle;

  /// No description provided for @authPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get authPassword;

  /// No description provided for @authPin.
  ///
  /// In fr, this message translates to:
  /// **'Code PIN'**
  String get authPin;

  /// No description provided for @authSignIn.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get authSignIn;

  /// No description provided for @authLogout.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get authLogout;

  /// No description provided for @authError.
  ///
  /// In fr, this message translates to:
  /// **'Identifiants incorrects'**
  String get authError;

  /// No description provided for @authModeEmail.
  ///
  /// In fr, this message translates to:
  /// **'E-mail'**
  String get authModeEmail;

  /// No description provided for @authModePin.
  ///
  /// In fr, this message translates to:
  /// **'PIN'**
  String get authModePin;

  /// No description provided for @userNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel utilisateur'**
  String get userNew;

  /// No description provided for @userSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un utilisateur'**
  String get userSearch;

  /// No description provided for @userEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun utilisateur'**
  String get userEmpty;

  /// No description provided for @userEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez un compte pour commencer.'**
  String get userEmptySubtitle;

  /// No description provided for @listNoResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat'**
  String get listNoResults;

  /// No description provided for @listNoResultsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajustez la recherche ou les filtres.'**
  String get listNoResultsSubtitle;

  /// No description provided for @navProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @profileSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre compte et votre sécurité'**
  String get profileSubtitle;

  /// No description provided for @profileAccount.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get profileAccount;

  /// No description provided for @profileSecurity.
  ///
  /// In fr, this message translates to:
  /// **'Sécurité'**
  String get profileSecurity;

  /// No description provided for @profileLinkedEmployee.
  ///
  /// In fr, this message translates to:
  /// **'Employé lié'**
  String get profileLinkedEmployee;

  /// No description provided for @profileChangePassword.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe'**
  String get profileChangePassword;

  /// No description provided for @profileChangePin.
  ///
  /// In fr, this message translates to:
  /// **'Changer le code PIN'**
  String get profileChangePin;

  /// No description provided for @profileCurrentPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe actuel'**
  String get profileCurrentPassword;

  /// No description provided for @profileNewPassword.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get profileNewPassword;

  /// No description provided for @profileConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get profileConfirm;

  /// No description provided for @profileNewPin.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau code PIN'**
  String get profileNewPin;

  /// No description provided for @profilePasswordChanged.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe modifié'**
  String get profilePasswordChanged;

  /// No description provided for @profilePinChanged.
  ///
  /// In fr, this message translates to:
  /// **'Code PIN modifié'**
  String get profilePinChanged;

  /// No description provided for @profileWrongPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe actuel incorrect'**
  String get profileWrongPassword;

  /// No description provided for @profilePasswordMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get profilePasswordMismatch;

  /// No description provided for @accountEmailTaken.
  ///
  /// In fr, this message translates to:
  /// **'Cet e-mail est déjà utilisé'**
  String get accountEmailTaken;

  /// No description provided for @accountPinTaken.
  ///
  /// In fr, this message translates to:
  /// **'Ce code PIN est déjà utilisé'**
  String get accountPinTaken;

  /// No description provided for @accountLastAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Au moins un administrateur actif est requis'**
  String get accountLastAdmin;

  /// No description provided for @accountEventLogin.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get accountEventLogin;

  /// No description provided for @accountEventLogout.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get accountEventLogout;

  /// No description provided for @accountEventFailedLogin.
  ///
  /// In fr, this message translates to:
  /// **'Échec de connexion'**
  String get accountEventFailedLogin;

  /// No description provided for @accountEventCreated.
  ///
  /// In fr, this message translates to:
  /// **'Compte créé'**
  String get accountEventCreated;

  /// No description provided for @accountEventUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Compte modifié'**
  String get accountEventUpdated;

  /// No description provided for @accountEventRoleChanged.
  ///
  /// In fr, this message translates to:
  /// **'Rôle modifié'**
  String get accountEventRoleChanged;

  /// No description provided for @accountEventDeactivated.
  ///
  /// In fr, this message translates to:
  /// **'Compte désactivé'**
  String get accountEventDeactivated;

  /// No description provided for @accountEventReactivated.
  ///
  /// In fr, this message translates to:
  /// **'Compte réactivé'**
  String get accountEventReactivated;

  /// No description provided for @accountEventPasswordReset.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe réinitialisé'**
  String get accountEventPasswordReset;

  /// No description provided for @accountEventPinReset.
  ///
  /// In fr, this message translates to:
  /// **'PIN réinitialisé'**
  String get accountEventPinReset;

  /// No description provided for @accountEventInvited.
  ///
  /// In fr, this message translates to:
  /// **'Invitation envoyée'**
  String get accountEventInvited;

  /// No description provided for @accountEventDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Compte supprimé'**
  String get accountEventDeleted;

  /// No description provided for @accountActivity.
  ///
  /// In fr, this message translates to:
  /// **'Activité'**
  String get accountActivity;

  /// No description provided for @accountLog.
  ///
  /// In fr, this message translates to:
  /// **'Journal des comptes'**
  String get accountLog;

  /// No description provided for @accountCreatedAt.
  ///
  /// In fr, this message translates to:
  /// **'Créé le'**
  String get accountCreatedAt;

  /// No description provided for @accountLastLogin.
  ///
  /// In fr, this message translates to:
  /// **'Dernière connexion'**
  String get accountLastLogin;

  /// No description provided for @accountNeverLoggedIn.
  ///
  /// In fr, this message translates to:
  /// **'Jamais connecté'**
  String get accountNeverLoggedIn;

  /// No description provided for @accountActionsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Actions'**
  String get accountActionsTitle;

  /// No description provided for @accountResetPassword.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser le mot de passe'**
  String get accountResetPassword;

  /// No description provided for @accountResetPin.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser le PIN'**
  String get accountResetPin;

  /// No description provided for @accountInvite.
  ///
  /// In fr, this message translates to:
  /// **'Inviter (démo)'**
  String get accountInvite;

  /// No description provided for @accountDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le compte'**
  String get accountDelete;

  /// No description provided for @accountDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer définitivement ce compte ?'**
  String get accountDeleteConfirm;

  /// No description provided for @accountTempSecret.
  ///
  /// In fr, this message translates to:
  /// **'Secret temporaire (démo)'**
  String get accountTempSecret;

  /// No description provided for @accountInvitePending.
  ///
  /// In fr, this message translates to:
  /// **'Invitation en attente'**
  String get accountInvitePending;

  /// No description provided for @navIntegrations.
  ///
  /// In fr, this message translates to:
  /// **'Intégrations'**
  String get navIntegrations;

  /// No description provided for @integrationsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Paiements, e-mail, messagerie…'**
  String get integrationsSubtitle;

  /// No description provided for @integrationsSummary.
  ///
  /// In fr, this message translates to:
  /// **'Services connectés'**
  String get integrationsSummary;

  /// No description provided for @integrationsSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une intégration'**
  String get integrationsSearch;

  /// No description provided for @integrationEnable.
  ///
  /// In fr, this message translates to:
  /// **'Activer'**
  String get integrationEnable;

  /// No description provided for @integrationTest.
  ///
  /// In fr, this message translates to:
  /// **'Tester'**
  String get integrationTest;

  /// No description provided for @integrationComingSoon.
  ///
  /// In fr, this message translates to:
  /// **'Connexion en direct bientôt disponible'**
  String get integrationComingSoon;

  /// No description provided for @integrationConnectAccount.
  ///
  /// In fr, this message translates to:
  /// **'Connecter le compte'**
  String get integrationConnectAccount;

  /// No description provided for @integrationConnected.
  ///
  /// In fr, this message translates to:
  /// **'Compte lié'**
  String get integrationConnected;

  /// No description provided for @integrationDisconnect.
  ///
  /// In fr, this message translates to:
  /// **'Déconnecter'**
  String get integrationDisconnect;

  /// No description provided for @integrationValid.
  ///
  /// In fr, this message translates to:
  /// **'Configuration valide'**
  String get integrationValid;

  /// No description provided for @integrationCheckNotConnected.
  ///
  /// In fr, this message translates to:
  /// **'Compte non lié'**
  String get integrationCheckNotConnected;

  /// No description provided for @integrationCheckEmail.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail invalide'**
  String get integrationCheckEmail;

  /// No description provided for @integrationCheckMissing.
  ///
  /// In fr, this message translates to:
  /// **'Champ requis manquant : {field}'**
  String integrationCheckMissing(Object field);

  /// No description provided for @integrationCheckUrl.
  ///
  /// In fr, this message translates to:
  /// **'URL invalide : {field}'**
  String integrationCheckUrl(Object field);

  /// No description provided for @integrationCheckShort.
  ///
  /// In fr, this message translates to:
  /// **'Valeur trop courte : {field}'**
  String integrationCheckShort(Object field);

  /// No description provided for @integrationCatPayments.
  ///
  /// In fr, this message translates to:
  /// **'Paiements'**
  String get integrationCatPayments;

  /// No description provided for @integrationCatMessaging.
  ///
  /// In fr, this message translates to:
  /// **'Messagerie'**
  String get integrationCatMessaging;

  /// No description provided for @integrationCatCloud.
  ///
  /// In fr, this message translates to:
  /// **'Cloud & e-mail'**
  String get integrationCatCloud;

  /// No description provided for @integrationCatAutomation.
  ///
  /// In fr, this message translates to:
  /// **'Automatisation'**
  String get integrationCatAutomation;

  /// No description provided for @integrationDescOutlook.
  ///
  /// In fr, this message translates to:
  /// **'Envoi des factures via Outlook'**
  String get integrationDescOutlook;

  /// No description provided for @integrationDescOnedrive.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde sur OneDrive'**
  String get integrationDescOnedrive;

  /// No description provided for @integrationDescTelegram.
  ///
  /// In fr, this message translates to:
  /// **'Notifications via un bot Telegram'**
  String get integrationDescTelegram;

  /// No description provided for @integrationDescTeams.
  ///
  /// In fr, this message translates to:
  /// **'Alertes dans un canal Teams'**
  String get integrationDescTeams;

  /// No description provided for @integrationDescSlack.
  ///
  /// In fr, this message translates to:
  /// **'Alertes dans un canal Slack'**
  String get integrationDescSlack;

  /// No description provided for @integrationDescZapier.
  ///
  /// In fr, this message translates to:
  /// **'Automatisez via un webhook Zapier'**
  String get integrationDescZapier;

  /// No description provided for @integrationFieldBotToken.
  ///
  /// In fr, this message translates to:
  /// **'Jeton du bot'**
  String get integrationFieldBotToken;

  /// No description provided for @integrationFieldChatId.
  ///
  /// In fr, this message translates to:
  /// **'ID de discussion'**
  String get integrationFieldChatId;

  /// No description provided for @integrationFieldWebhookUrl.
  ///
  /// In fr, this message translates to:
  /// **'URL du webhook'**
  String get integrationFieldWebhookUrl;

  /// No description provided for @integrationDescApplepay.
  ///
  /// In fr, this message translates to:
  /// **'Paiement Apple Pay'**
  String get integrationDescApplepay;

  /// No description provided for @integrationDescIcloud.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde iCloud'**
  String get integrationDescIcloud;

  /// No description provided for @integrationDescApplemsg.
  ///
  /// In fr, this message translates to:
  /// **'Messages pour les entreprises (iMessage)'**
  String get integrationDescApplemsg;

  /// No description provided for @integrationFieldMerchantId.
  ///
  /// In fr, this message translates to:
  /// **'ID marchand Apple'**
  String get integrationFieldMerchantId;

  /// No description provided for @integrationFieldBusinessId.
  ///
  /// In fr, this message translates to:
  /// **'ID Apple Business'**
  String get integrationFieldBusinessId;

  /// No description provided for @integrationStatusActive.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get integrationStatusActive;

  /// No description provided for @integrationStatusDisabled.
  ///
  /// In fr, this message translates to:
  /// **'Désactivé'**
  String get integrationStatusDisabled;

  /// No description provided for @integrationStatusNotConfigured.
  ///
  /// In fr, this message translates to:
  /// **'Non configuré'**
  String get integrationStatusNotConfigured;

  /// No description provided for @integrationDescFlouci.
  ///
  /// In fr, this message translates to:
  /// **'Paiement wallet & cartes (CIB/Visa/MC)'**
  String get integrationDescFlouci;

  /// No description provided for @integrationDescKonnect.
  ///
  /// In fr, this message translates to:
  /// **'Paiement en ligne par carte'**
  String get integrationDescKonnect;

  /// No description provided for @integrationDescClictopay.
  ///
  /// In fr, this message translates to:
  /// **'Paiement carte bancaire (SMT)'**
  String get integrationDescClictopay;

  /// No description provided for @integrationDescStripe.
  ///
  /// In fr, this message translates to:
  /// **'Cartes internationales'**
  String get integrationDescStripe;

  /// No description provided for @integrationDescDrive.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde dans le cloud'**
  String get integrationDescDrive;

  /// No description provided for @integrationDescGmail.
  ///
  /// In fr, this message translates to:
  /// **'Envoi des factures par e-mail'**
  String get integrationDescGmail;

  /// No description provided for @integrationDescWhatsapp.
  ///
  /// In fr, this message translates to:
  /// **'Messages WhatsApp automatisés'**
  String get integrationDescWhatsapp;

  /// No description provided for @integrationDescMessenger.
  ///
  /// In fr, this message translates to:
  /// **'Discuter via Messenger'**
  String get integrationDescMessenger;

  /// No description provided for @integrationDescSms.
  ///
  /// In fr, this message translates to:
  /// **'Notifications par SMS'**
  String get integrationDescSms;

  /// No description provided for @integrationFieldApiKey.
  ///
  /// In fr, this message translates to:
  /// **'Clé API'**
  String get integrationFieldApiKey;

  /// No description provided for @integrationFieldSecretKey.
  ///
  /// In fr, this message translates to:
  /// **'Clé secrète'**
  String get integrationFieldSecretKey;

  /// No description provided for @integrationFieldPrivateToken.
  ///
  /// In fr, this message translates to:
  /// **'Jeton privé'**
  String get integrationFieldPrivateToken;

  /// No description provided for @integrationFieldAppId.
  ///
  /// In fr, this message translates to:
  /// **'ID application'**
  String get integrationFieldAppId;

  /// No description provided for @integrationFieldWalletId.
  ///
  /// In fr, this message translates to:
  /// **'ID portefeuille'**
  String get integrationFieldWalletId;

  /// No description provided for @integrationFieldMerchantUser.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant marchand'**
  String get integrationFieldMerchantUser;

  /// No description provided for @integrationFieldMerchantPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe marchand'**
  String get integrationFieldMerchantPassword;

  /// No description provided for @integrationFieldAppPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe d\'application'**
  String get integrationFieldAppPassword;

  /// No description provided for @integrationFieldPhoneId.
  ///
  /// In fr, this message translates to:
  /// **'ID du numéro'**
  String get integrationFieldPhoneId;

  /// No description provided for @integrationFieldAccessToken.
  ///
  /// In fr, this message translates to:
  /// **'Jeton d\'accès'**
  String get integrationFieldAccessToken;

  /// No description provided for @integrationFieldPageLink.
  ///
  /// In fr, this message translates to:
  /// **'Lien de la page'**
  String get integrationFieldPageLink;

  /// No description provided for @integrationFieldSender.
  ///
  /// In fr, this message translates to:
  /// **'Expéditeur'**
  String get integrationFieldSender;

  /// No description provided for @userRole.
  ///
  /// In fr, this message translates to:
  /// **'Rôle'**
  String get userRole;

  /// No description provided for @userLinkedEmployee.
  ///
  /// In fr, this message translates to:
  /// **'Employé lié'**
  String get userLinkedEmployee;

  /// No description provided for @userNoEmployee.
  ///
  /// In fr, this message translates to:
  /// **'Aucun'**
  String get userNoEmployee;

  /// No description provided for @userNewPassword.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get userNewPassword;

  /// No description provided for @userNewPin.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau PIN'**
  String get userNewPin;

  /// No description provided for @roleAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Administrateur'**
  String get roleAdmin;

  /// No description provided for @roleTechnician.
  ///
  /// In fr, this message translates to:
  /// **'Technicien'**
  String get roleTechnician;

  /// No description provided for @roleCashier.
  ///
  /// In fr, this message translates to:
  /// **'Caisse'**
  String get roleCashier;

  /// No description provided for @orderNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle commande'**
  String get orderNew;

  /// No description provided for @orderSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une commande'**
  String get orderSearch;

  /// No description provided for @orderEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune commande'**
  String get orderEmpty;

  /// No description provided for @orderEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Créez une commande fournisseur.'**
  String get orderEmptySubtitle;

  /// No description provided for @orderStatusDraft.
  ///
  /// In fr, this message translates to:
  /// **'Brouillon'**
  String get orderStatusDraft;

  /// No description provided for @orderStatusOrdered.
  ///
  /// In fr, this message translates to:
  /// **'Commandée'**
  String get orderStatusOrdered;

  /// No description provided for @orderStatusReceived.
  ///
  /// In fr, this message translates to:
  /// **'Reçue'**
  String get orderStatusReceived;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulée'**
  String get orderStatusCancelled;

  /// No description provided for @orderSupplier.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseur'**
  String get orderSupplier;

  /// No description provided for @orderExpectedDate.
  ///
  /// In fr, this message translates to:
  /// **'Livraison prévue'**
  String get orderExpectedDate;

  /// No description provided for @orderReceive.
  ///
  /// In fr, this message translates to:
  /// **'Réceptionner'**
  String get orderReceive;

  /// No description provided for @orderPaid.
  ///
  /// In fr, this message translates to:
  /// **'Réglé'**
  String get orderPaid;

  /// No description provided for @orderBalanceDue.
  ///
  /// In fr, this message translates to:
  /// **'Reste à payer'**
  String get orderBalanceDue;

  /// No description provided for @orderAddPayment.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer un règlement'**
  String get orderAddPayment;

  /// No description provided for @orderAddLine.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un article'**
  String get orderAddLine;

  /// No description provided for @orderSectionLines.
  ///
  /// In fr, this message translates to:
  /// **'Articles'**
  String get orderSectionLines;

  /// No description provided for @orderNoLines.
  ///
  /// In fr, this message translates to:
  /// **'Aucun article'**
  String get orderNoLines;

  /// No description provided for @orderSubtotal.
  ///
  /// In fr, this message translates to:
  /// **'Sous-total HT'**
  String get orderSubtotal;

  /// No description provided for @orderTax.
  ///
  /// In fr, this message translates to:
  /// **'TVA'**
  String get orderTax;

  /// No description provided for @orderTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total TTC'**
  String get orderTotal;

  /// No description provided for @productPickTitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un produit'**
  String get productPickTitle;

  /// No description provided for @quoteNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau devis'**
  String get quoteNew;

  /// No description provided for @quoteSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un devis'**
  String get quoteSearch;

  /// No description provided for @quoteEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun devis'**
  String get quoteEmpty;

  /// No description provided for @quoteEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Créez un devis client.'**
  String get quoteEmptySubtitle;

  /// No description provided for @quoteStatusDraft.
  ///
  /// In fr, this message translates to:
  /// **'Brouillon'**
  String get quoteStatusDraft;

  /// No description provided for @quoteStatusSent.
  ///
  /// In fr, this message translates to:
  /// **'Envoyé'**
  String get quoteStatusSent;

  /// No description provided for @quoteStatusAccepted.
  ///
  /// In fr, this message translates to:
  /// **'Accepté'**
  String get quoteStatusAccepted;

  /// No description provided for @quoteStatusRefused.
  ///
  /// In fr, this message translates to:
  /// **'Refusé'**
  String get quoteStatusRefused;

  /// No description provided for @quoteStatusExpired.
  ///
  /// In fr, this message translates to:
  /// **'Expiré'**
  String get quoteStatusExpired;

  /// No description provided for @quoteValidUntil.
  ///
  /// In fr, this message translates to:
  /// **'Valable jusqu\'au'**
  String get quoteValidUntil;

  /// No description provided for @quoteAddService.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une prestation'**
  String get quoteAddService;

  /// No description provided for @quoteAddPart.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une pièce'**
  String get quoteAddPart;

  /// No description provided for @quoteSectionLines.
  ///
  /// In fr, this message translates to:
  /// **'Détail'**
  String get quoteSectionLines;

  /// No description provided for @quoteExportPdf.
  ///
  /// In fr, this message translates to:
  /// **'Exporter en PDF'**
  String get quoteExportPdf;

  /// No description provided for @quoteSend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get quoteSend;

  /// No description provided for @quoteAccept.
  ///
  /// In fr, this message translates to:
  /// **'Accepter'**
  String get quoteAccept;

  /// No description provided for @quoteRefuse.
  ///
  /// In fr, this message translates to:
  /// **'Refuser'**
  String get quoteRefuse;

  /// No description provided for @colDesignation.
  ///
  /// In fr, this message translates to:
  /// **'Désignation'**
  String get colDesignation;

  /// No description provided for @colQty.
  ///
  /// In fr, this message translates to:
  /// **'Qté'**
  String get colQty;

  /// No description provided for @colUnitPrice.
  ///
  /// In fr, this message translates to:
  /// **'P.U.'**
  String get colUnitPrice;

  /// No description provided for @colLineTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get colLineTotal;

  /// No description provided for @invoiceNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle facture'**
  String get invoiceNew;

  /// No description provided for @invoiceSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une facture'**
  String get invoiceSearch;

  /// No description provided for @invoiceEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune facture'**
  String get invoiceEmpty;

  /// No description provided for @invoiceEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Créez une facture.'**
  String get invoiceEmptySubtitle;

  /// No description provided for @invoiceStatusDraft.
  ///
  /// In fr, this message translates to:
  /// **'Brouillon'**
  String get invoiceStatusDraft;

  /// No description provided for @invoiceStatusIssued.
  ///
  /// In fr, this message translates to:
  /// **'Émise'**
  String get invoiceStatusIssued;

  /// No description provided for @invoiceStatusPartial.
  ///
  /// In fr, this message translates to:
  /// **'Partielle'**
  String get invoiceStatusPartial;

  /// No description provided for @invoiceStatusPaid.
  ///
  /// In fr, this message translates to:
  /// **'Payée'**
  String get invoiceStatusPaid;

  /// No description provided for @invoiceStatusOverdue.
  ///
  /// In fr, this message translates to:
  /// **'En retard'**
  String get invoiceStatusOverdue;

  /// No description provided for @invoiceStatusCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulée'**
  String get invoiceStatusCancelled;

  /// No description provided for @invoiceIssue.
  ///
  /// In fr, this message translates to:
  /// **'Émettre'**
  String get invoiceIssue;

  /// No description provided for @creditNote.
  ///
  /// In fr, this message translates to:
  /// **'Avoir'**
  String get creditNote;

  /// No description provided for @creditNotes.
  ///
  /// In fr, this message translates to:
  /// **'Avoirs'**
  String get creditNotes;

  /// No description provided for @creditNoteNew.
  ///
  /// In fr, this message translates to:
  /// **'Créer un avoir'**
  String get creditNoteNew;

  /// No description provided for @creditNoteIssue.
  ///
  /// In fr, this message translates to:
  /// **'Émettre l\'avoir'**
  String get creditNoteIssue;

  /// No description provided for @creditNoteReason.
  ///
  /// In fr, this message translates to:
  /// **'Motif'**
  String get creditNoteReason;

  /// No description provided for @creditNoteEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun avoir'**
  String get creditNoteEmpty;

  /// No description provided for @invoiceDueDate.
  ///
  /// In fr, this message translates to:
  /// **'Échéance'**
  String get invoiceDueDate;

  /// No description provided for @invoiceDeposit.
  ///
  /// In fr, this message translates to:
  /// **'Acompte'**
  String get invoiceDeposit;

  /// No description provided for @invoiceBalance.
  ///
  /// In fr, this message translates to:
  /// **'Solde dû'**
  String get invoiceBalance;

  /// No description provided for @invoiceSectionPayments.
  ///
  /// In fr, this message translates to:
  /// **'Paiements'**
  String get invoiceSectionPayments;

  /// No description provided for @invoiceRecordPayment.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer un paiement'**
  String get invoiceRecordPayment;

  /// No description provided for @invoiceNoPayments.
  ///
  /// In fr, this message translates to:
  /// **'Aucun paiement'**
  String get invoiceNoPayments;

  /// No description provided for @invoiceAmount.
  ///
  /// In fr, this message translates to:
  /// **'Montant'**
  String get invoiceAmount;

  /// No description provided for @paymentMethodCash.
  ///
  /// In fr, this message translates to:
  /// **'Espèces'**
  String get paymentMethodCash;

  /// No description provided for @paymentMethodCard.
  ///
  /// In fr, this message translates to:
  /// **'Carte'**
  String get paymentMethodCard;

  /// No description provided for @paymentMethodTransfer.
  ///
  /// In fr, this message translates to:
  /// **'Virement'**
  String get paymentMethodTransfer;

  /// No description provided for @paymentMethodCheck.
  ///
  /// In fr, this message translates to:
  /// **'Chèque'**
  String get paymentMethodCheck;

  /// No description provided for @paymentMethodCredit.
  ///
  /// In fr, this message translates to:
  /// **'Avoir'**
  String get paymentMethodCredit;

  /// No description provided for @quoteConvertInvoice.
  ///
  /// In fr, this message translates to:
  /// **'Convertir en facture'**
  String get quoteConvertInvoice;

  /// No description provided for @invoiceFromRepair.
  ///
  /// In fr, this message translates to:
  /// **'Générer la facture'**
  String get invoiceFromRepair;

  /// No description provided for @fieldPhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get fieldPhone;

  /// No description provided for @fieldEmail.
  ///
  /// In fr, this message translates to:
  /// **'E-mail'**
  String get fieldEmail;

  /// No description provided for @fieldAddress.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get fieldAddress;

  /// No description provided for @fieldWhatsapp.
  ///
  /// In fr, this message translates to:
  /// **'WhatsApp'**
  String get fieldWhatsapp;

  /// No description provided for @fieldTelegram.
  ///
  /// In fr, this message translates to:
  /// **'Telegram'**
  String get fieldTelegram;

  /// No description provided for @fieldSecondaryPhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone secondaire'**
  String get fieldSecondaryPhone;

  /// No description provided for @fieldWebsite.
  ///
  /// In fr, this message translates to:
  /// **'Site web'**
  String get fieldWebsite;

  /// No description provided for @fieldInstagram.
  ///
  /// In fr, this message translates to:
  /// **'Instagram'**
  String get fieldInstagram;

  /// No description provided for @clientSectionSocial.
  ///
  /// In fr, this message translates to:
  /// **'Web & réseaux'**
  String get clientSectionSocial;

  /// No description provided for @actionWebsite.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir le site'**
  String get actionWebsite;

  /// No description provided for @actionInstagram.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir Instagram'**
  String get actionInstagram;

  /// No description provided for @contactKindTitle.
  ///
  /// In fr, this message translates to:
  /// **'Type de contact'**
  String get contactKindTitle;

  /// No description provided for @contactKindMobile.
  ///
  /// In fr, this message translates to:
  /// **'Mobile'**
  String get contactKindMobile;

  /// No description provided for @contactKindLandline.
  ///
  /// In fr, this message translates to:
  /// **'Fixe'**
  String get contactKindLandline;

  /// No description provided for @contactKindWhatsapp.
  ///
  /// In fr, this message translates to:
  /// **'WhatsApp'**
  String get contactKindWhatsapp;

  /// No description provided for @contactKindTelegram.
  ///
  /// In fr, this message translates to:
  /// **'Telegram'**
  String get contactKindTelegram;

  /// No description provided for @contactKindEmail.
  ///
  /// In fr, this message translates to:
  /// **'E-mail'**
  String get contactKindEmail;

  /// No description provided for @contactKindWebsite.
  ///
  /// In fr, this message translates to:
  /// **'Site web'**
  String get contactKindWebsite;

  /// No description provided for @contactKindInstagram.
  ///
  /// In fr, this message translates to:
  /// **'Instagram'**
  String get contactKindInstagram;

  /// No description provided for @contactKindFacebook.
  ///
  /// In fr, this message translates to:
  /// **'Facebook'**
  String get contactKindFacebook;

  /// No description provided for @contactKindLinkedin.
  ///
  /// In fr, this message translates to:
  /// **'LinkedIn'**
  String get contactKindLinkedin;

  /// No description provided for @contactKindX.
  ///
  /// In fr, this message translates to:
  /// **'X (Twitter)'**
  String get contactKindX;

  /// No description provided for @contactKindSnapchat.
  ///
  /// In fr, this message translates to:
  /// **'Snapchat'**
  String get contactKindSnapchat;

  /// No description provided for @contactKindTiktok.
  ///
  /// In fr, this message translates to:
  /// **'TikTok'**
  String get contactKindTiktok;

  /// No description provided for @contactKindSignal.
  ///
  /// In fr, this message translates to:
  /// **'Signal'**
  String get contactKindSignal;

  /// No description provided for @contactKindWechat.
  ///
  /// In fr, this message translates to:
  /// **'WeChat'**
  String get contactKindWechat;

  /// No description provided for @contactKindMessenger.
  ///
  /// In fr, this message translates to:
  /// **'Messenger'**
  String get contactKindMessenger;

  /// No description provided for @contactKindViber.
  ///
  /// In fr, this message translates to:
  /// **'Viber'**
  String get contactKindViber;

  /// No description provided for @contactKindLine.
  ///
  /// In fr, this message translates to:
  /// **'LINE'**
  String get contactKindLine;

  /// No description provided for @contactKindFax.
  ///
  /// In fr, this message translates to:
  /// **'Fax'**
  String get contactKindFax;

  /// No description provided for @contactKindYoutube.
  ///
  /// In fr, this message translates to:
  /// **'YouTube'**
  String get contactKindYoutube;

  /// No description provided for @contactKindTeams.
  ///
  /// In fr, this message translates to:
  /// **'Teams'**
  String get contactKindTeams;

  /// No description provided for @contactKindOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get contactKindOther;

  /// No description provided for @clientAddContact.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un contact'**
  String get clientAddContact;

  /// No description provided for @clientOtherContacts.
  ///
  /// In fr, this message translates to:
  /// **'Autres coordonnées'**
  String get clientOtherContacts;

  /// No description provided for @clientOtherAddresses.
  ///
  /// In fr, this message translates to:
  /// **'Autres adresses'**
  String get clientOtherAddresses;

  /// No description provided for @clientSectionAddresses.
  ///
  /// In fr, this message translates to:
  /// **'Adresses'**
  String get clientSectionAddresses;

  /// No description provided for @addressMain.
  ///
  /// In fr, this message translates to:
  /// **'Adresse principale'**
  String get addressMain;

  /// No description provided for @clientAddAddress.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une adresse'**
  String get clientAddAddress;

  /// No description provided for @addressKindTitle.
  ///
  /// In fr, this message translates to:
  /// **'Type d\'adresse'**
  String get addressKindTitle;

  /// No description provided for @addressKindHome.
  ///
  /// In fr, this message translates to:
  /// **'Domicile'**
  String get addressKindHome;

  /// No description provided for @addressKindWork.
  ///
  /// In fr, this message translates to:
  /// **'Travail'**
  String get addressKindWork;

  /// No description provided for @addressKindBilling.
  ///
  /// In fr, this message translates to:
  /// **'Facturation'**
  String get addressKindBilling;

  /// No description provided for @addressKindShipping.
  ///
  /// In fr, this message translates to:
  /// **'Livraison'**
  String get addressKindShipping;

  /// No description provided for @addressKindOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get addressKindOther;

  /// No description provided for @clientStatInvoiced.
  ///
  /// In fr, this message translates to:
  /// **'Facturé'**
  String get clientStatInvoiced;

  /// No description provided for @clientStatOutstanding.
  ///
  /// In fr, this message translates to:
  /// **'Impayé'**
  String get clientStatOutstanding;

  /// No description provided for @clientStatRepairs.
  ///
  /// In fr, this message translates to:
  /// **'Réparations'**
  String get clientStatRepairs;

  /// No description provided for @clientSectionInvoices.
  ///
  /// In fr, this message translates to:
  /// **'Factures'**
  String get clientSectionInvoices;

  /// No description provided for @clientSectionQuotes.
  ///
  /// In fr, this message translates to:
  /// **'Devis'**
  String get clientSectionQuotes;

  /// No description provided for @clientLastActivity.
  ///
  /// In fr, this message translates to:
  /// **'Dernière activité'**
  String get clientLastActivity;

  /// No description provided for @clientNoDocuments.
  ///
  /// In fr, this message translates to:
  /// **'Aucun document'**
  String get clientNoDocuments;

  /// No description provided for @clientNoActivity.
  ///
  /// In fr, this message translates to:
  /// **'Aucune activité pour l\'instant'**
  String get clientNoActivity;

  /// No description provided for @clientNoInvoices.
  ///
  /// In fr, this message translates to:
  /// **'Aucune facture'**
  String get clientNoInvoices;

  /// No description provided for @clientNoQuotes.
  ///
  /// In fr, this message translates to:
  /// **'Aucun devis'**
  String get clientNoQuotes;

  /// No description provided for @clientSettleAll.
  ///
  /// In fr, this message translates to:
  /// **'Encaisser tout'**
  String get clientSettleAll;

  /// No description provided for @clientCredit.
  ///
  /// In fr, this message translates to:
  /// **'Crédit disponible'**
  String get clientCredit;

  /// No description provided for @clientNetBalance.
  ///
  /// In fr, this message translates to:
  /// **'Solde net'**
  String get clientNetBalance;

  /// No description provided for @clientStatementPdf.
  ///
  /// In fr, this message translates to:
  /// **'Relevé de compte (PDF)'**
  String get clientStatementPdf;

  /// No description provided for @statementTitle.
  ///
  /// In fr, this message translates to:
  /// **'Relevé de compte'**
  String get statementTitle;

  /// No description provided for @statementDate.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get statementDate;

  /// No description provided for @statementDetail.
  ///
  /// In fr, this message translates to:
  /// **'Détail'**
  String get statementDetail;

  /// No description provided for @statementDebit.
  ///
  /// In fr, this message translates to:
  /// **'Débit'**
  String get statementDebit;

  /// No description provided for @statementCredit.
  ///
  /// In fr, this message translates to:
  /// **'Crédit'**
  String get statementCredit;

  /// No description provided for @statementBalance.
  ///
  /// In fr, this message translates to:
  /// **'Solde'**
  String get statementBalance;

  /// No description provided for @statementOpening.
  ///
  /// In fr, this message translates to:
  /// **'Solde d\'ouverture'**
  String get statementOpening;

  /// No description provided for @statementClosing.
  ///
  /// In fr, this message translates to:
  /// **'Solde de clôture'**
  String get statementClosing;

  /// No description provided for @statementInvoice.
  ///
  /// In fr, this message translates to:
  /// **'Facture'**
  String get statementInvoice;

  /// No description provided for @statementDeposit.
  ///
  /// In fr, this message translates to:
  /// **'Acompte'**
  String get statementDeposit;

  /// No description provided for @statementPayment.
  ///
  /// In fr, this message translates to:
  /// **'Règlement'**
  String get statementPayment;

  /// No description provided for @colNumber.
  ///
  /// In fr, this message translates to:
  /// **'N°'**
  String get colNumber;

  /// No description provided for @supplierStatementPdf.
  ///
  /// In fr, this message translates to:
  /// **'Relevé fournisseur (PDF)'**
  String get supplierStatementPdf;

  /// No description provided for @supplierStatementTitle.
  ///
  /// In fr, this message translates to:
  /// **'Relevé fournisseur'**
  String get supplierStatementTitle;

  /// No description provided for @supplierPurchased.
  ///
  /// In fr, this message translates to:
  /// **'Achats reçus'**
  String get supplierPurchased;

  /// No description provided for @supplierOnOrder.
  ///
  /// In fr, this message translates to:
  /// **'En commande'**
  String get supplierOnOrder;

  /// No description provided for @supplierOverdue.
  ///
  /// In fr, this message translates to:
  /// **'En retard'**
  String get supplierOverdue;

  /// No description provided for @supplierPayable.
  ///
  /// In fr, this message translates to:
  /// **'Impayés'**
  String get supplierPayable;

  /// No description provided for @poAgeNotDue.
  ///
  /// In fr, this message translates to:
  /// **'Non échu'**
  String get poAgeNotDue;

  /// No description provided for @poAge1to30.
  ///
  /// In fr, this message translates to:
  /// **'1–30 j'**
  String get poAge1to30;

  /// No description provided for @poAge31to60.
  ///
  /// In fr, this message translates to:
  /// **'31–60 j'**
  String get poAge31to60;

  /// No description provided for @poAge60plus.
  ///
  /// In fr, this message translates to:
  /// **'60+ j'**
  String get poAge60plus;

  /// No description provided for @clientAddDeposit.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un acompte'**
  String get clientAddDeposit;

  /// No description provided for @clientApplyCredit.
  ///
  /// In fr, this message translates to:
  /// **'Appliquer le crédit'**
  String get clientApplyCredit;

  /// No description provided for @clientRefund.
  ///
  /// In fr, this message translates to:
  /// **'Rembourser'**
  String get clientRefund;

  /// No description provided for @chequeAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un chèque'**
  String get chequeAdd;

  /// No description provided for @navRefunds.
  ///
  /// In fr, this message translates to:
  /// **'Remboursements'**
  String get navRefunds;

  /// No description provided for @refundsTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total remboursé'**
  String get refundsTotal;

  /// No description provided for @refundsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun remboursement'**
  String get refundsEmpty;

  /// No description provided for @refundsEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Les remboursements aux clients apparaîtront ici.'**
  String get refundsEmptySubtitle;

  /// No description provided for @financePeriodAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout'**
  String get financePeriodAll;

  /// No description provided for @financePeriodMonth.
  ///
  /// In fr, this message translates to:
  /// **'Mois'**
  String get financePeriodMonth;

  /// No description provided for @financePeriodQuarter.
  ///
  /// In fr, this message translates to:
  /// **'Trimestre'**
  String get financePeriodQuarter;

  /// No description provided for @financePeriodYear.
  ///
  /// In fr, this message translates to:
  /// **'Année'**
  String get financePeriodYear;

  /// No description provided for @financePeriodCustom.
  ///
  /// In fr, this message translates to:
  /// **'Perso'**
  String get financePeriodCustom;

  /// No description provided for @filterAllClients.
  ///
  /// In fr, this message translates to:
  /// **'Tous les clients'**
  String get filterAllClients;

  /// No description provided for @paymentKindInvoice.
  ///
  /// In fr, this message translates to:
  /// **'Facture'**
  String get paymentKindInvoice;

  /// No description provided for @paymentKindDeposit.
  ///
  /// In fr, this message translates to:
  /// **'Acompte'**
  String get paymentKindDeposit;

  /// No description provided for @paymentKindApplication.
  ///
  /// In fr, this message translates to:
  /// **'Avoir appliqué'**
  String get paymentKindApplication;

  /// No description provided for @paymentKindRefund.
  ///
  /// In fr, this message translates to:
  /// **'Remboursement'**
  String get paymentKindRefund;

  /// No description provided for @financeBreakdown.
  ///
  /// In fr, this message translates to:
  /// **'Ventilation'**
  String get financeBreakdown;

  /// No description provided for @navCheques.
  ///
  /// In fr, this message translates to:
  /// **'Chèques'**
  String get navCheques;

  /// No description provided for @chequeNumber.
  ///
  /// In fr, this message translates to:
  /// **'N° de chèque'**
  String get chequeNumber;

  /// No description provided for @chequeBank.
  ///
  /// In fr, this message translates to:
  /// **'Banque'**
  String get chequeBank;

  /// No description provided for @chequeDrawer.
  ///
  /// In fr, this message translates to:
  /// **'Émetteur'**
  String get chequeDrawer;

  /// No description provided for @chequeDueDate.
  ///
  /// In fr, this message translates to:
  /// **'Échéance'**
  String get chequeDueDate;

  /// No description provided for @chequeStatusPending.
  ///
  /// In fr, this message translates to:
  /// **'À encaisser'**
  String get chequeStatusPending;

  /// No description provided for @chequeStatusDeposited.
  ///
  /// In fr, this message translates to:
  /// **'Déposé'**
  String get chequeStatusDeposited;

  /// No description provided for @chequeStatusCleared.
  ///
  /// In fr, this message translates to:
  /// **'Encaissé'**
  String get chequeStatusCleared;

  /// No description provided for @chequeStatusBounced.
  ///
  /// In fr, this message translates to:
  /// **'Rejeté'**
  String get chequeStatusBounced;

  /// No description provided for @chequesToCollect.
  ///
  /// In fr, this message translates to:
  /// **'Chèques à encaisser'**
  String get chequesToCollect;

  /// No description provided for @chequesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun chèque'**
  String get chequesEmpty;

  /// No description provided for @chequesEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Les chèques reçus apparaîtront ici.'**
  String get chequesEmptySubtitle;

  /// No description provided for @chequeMarkDeposited.
  ///
  /// In fr, this message translates to:
  /// **'Marquer déposé'**
  String get chequeMarkDeposited;

  /// No description provided for @chequeMarkCleared.
  ///
  /// In fr, this message translates to:
  /// **'Marquer encaissé'**
  String get chequeMarkCleared;

  /// No description provided for @chequeBounceAction.
  ///
  /// In fr, this message translates to:
  /// **'Rejeter'**
  String get chequeBounceAction;

  /// No description provided for @clientSince.
  ///
  /// In fr, this message translates to:
  /// **'Client depuis'**
  String get clientSince;

  /// No description provided for @clientTags.
  ///
  /// In fr, this message translates to:
  /// **'Étiquettes'**
  String get clientTags;

  /// No description provided for @clientTagsHint.
  ///
  /// In fr, this message translates to:
  /// **'Séparez par des virgules'**
  String get clientTagsHint;

  /// No description provided for @clientConsent.
  ///
  /// In fr, this message translates to:
  /// **'Consentement marketing'**
  String get clientConsent;

  /// No description provided for @clientBillingContact.
  ///
  /// In fr, this message translates to:
  /// **'Contact facturation'**
  String get clientBillingContact;

  /// No description provided for @clientPaymentTerms.
  ///
  /// In fr, this message translates to:
  /// **'Conditions de paiement'**
  String get clientPaymentTerms;

  /// No description provided for @clientDiscount.
  ///
  /// In fr, this message translates to:
  /// **'Remise habituelle'**
  String get clientDiscount;

  /// No description provided for @clientCreditLimit.
  ///
  /// In fr, this message translates to:
  /// **'Plafond de crédit'**
  String get clientCreditLimit;

  /// No description provided for @clientDuplicateWarning.
  ///
  /// In fr, this message translates to:
  /// **'Un client similaire existe déjà : {name}. Créer quand même ?'**
  String clientDuplicateWarning(String name);

  /// No description provided for @actionTelegram.
  ///
  /// In fr, this message translates to:
  /// **'Telegram'**
  String get actionTelegram;

  /// No description provided for @actionDirections.
  ///
  /// In fr, this message translates to:
  /// **'Itinéraire'**
  String get actionDirections;

  /// No description provided for @clientSelect.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner un client'**
  String get clientSelect;

  /// No description provided for @settingsSectionLayout.
  ///
  /// In fr, this message translates to:
  /// **'Disposition'**
  String get settingsSectionLayout;

  /// No description provided for @settingsContentWidth.
  ///
  /// In fr, this message translates to:
  /// **'Largeur du contenu'**
  String get settingsContentWidth;

  /// No description provided for @contentNormal.
  ///
  /// In fr, this message translates to:
  /// **'Normale'**
  String get contentNormal;

  /// No description provided for @contentStretch.
  ///
  /// In fr, this message translates to:
  /// **'Pleine largeur'**
  String get contentStretch;

  /// No description provided for @settingsSidebar.
  ///
  /// In fr, this message translates to:
  /// **'Barre latérale'**
  String get settingsSidebar;

  /// No description provided for @sidebarAdaptive.
  ///
  /// In fr, this message translates to:
  /// **'Adaptative'**
  String get sidebarAdaptive;

  /// No description provided for @sidebarExpanded.
  ///
  /// In fr, this message translates to:
  /// **'Étendue'**
  String get sidebarExpanded;

  /// No description provided for @settingsDetailView.
  ///
  /// In fr, this message translates to:
  /// **'Affichage des détails'**
  String get settingsDetailView;

  /// No description provided for @settingsClientsView.
  ///
  /// In fr, this message translates to:
  /// **'Affichage des répertoires'**
  String get settingsClientsView;

  /// No description provided for @settingsRegional.
  ///
  /// In fr, this message translates to:
  /// **'Régional'**
  String get settingsRegional;

  /// No description provided for @settingsCurrency.
  ///
  /// In fr, this message translates to:
  /// **'Devise'**
  String get settingsCurrency;

  /// No description provided for @settingsDateFormat.
  ///
  /// In fr, this message translates to:
  /// **'Format de date'**
  String get settingsDateFormat;

  /// No description provided for @clientsViewList.
  ///
  /// In fr, this message translates to:
  /// **'Liste'**
  String get clientsViewList;

  /// No description provided for @clientsViewGrid.
  ///
  /// In fr, this message translates to:
  /// **'Grille'**
  String get clientsViewGrid;

  /// No description provided for @clientsViewTable.
  ///
  /// In fr, this message translates to:
  /// **'Tableau'**
  String get clientsViewTable;

  /// No description provided for @fieldType.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get fieldType;

  /// No description provided for @clientSegmentDebtors.
  ///
  /// In fr, this message translates to:
  /// **'Débiteurs'**
  String get clientSegmentDebtors;

  /// No description provided for @clientSegmentCredit.
  ///
  /// In fr, this message translates to:
  /// **'Avec crédit'**
  String get clientSegmentCredit;

  /// No description provided for @clientSegmentInactive.
  ///
  /// In fr, this message translates to:
  /// **'Inactifs'**
  String get clientSegmentInactive;

  /// No description provided for @clientSegmentBusiness.
  ///
  /// In fr, this message translates to:
  /// **'Professionnels'**
  String get clientSegmentBusiness;

  /// No description provided for @clientSegmentRecent.
  ///
  /// In fr, this message translates to:
  /// **'Nouveaux'**
  String get clientSegmentRecent;

  /// No description provided for @detailAdaptive.
  ///
  /// In fr, this message translates to:
  /// **'Adaptatif'**
  String get detailAdaptive;

  /// No description provided for @detailPane.
  ///
  /// In fr, this message translates to:
  /// **'Panneau'**
  String get detailPane;

  /// No description provided for @detailPage.
  ///
  /// In fr, this message translates to:
  /// **'Page'**
  String get detailPage;

  /// No description provided for @prestationPickTitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une prestation'**
  String get prestationPickTitle;

  /// No description provided for @prestationSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une prestation'**
  String get prestationSearch;

  /// No description provided for @prestationManual.
  ///
  /// In fr, this message translates to:
  /// **'Saisie manuelle'**
  String get prestationManual;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
