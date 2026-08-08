// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Repair Workshop';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navRepairs => 'Repairs';

  @override
  String get navClients => 'Clients';

  @override
  String get navSettings => 'Settings';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get dashboardOverview => 'Overview';

  @override
  String get dashboardRecentRepairs => 'Recent repairs';

  @override
  String get dashboardActivity => 'Activity';

  @override
  String get dashboardQuickActions => 'Quick actions';

  @override
  String get dashboardNoRepairs => 'No repairs';

  @override
  String get dashboardNoRepairsSubtitle => 'New tickets will appear here.';

  @override
  String get dashboardNotifications => 'Notifications';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsRecent => 'Recent activity';

  @override
  String get statInProgress => 'In progress';

  @override
  String get statAwaitingParts => 'Awaiting parts';

  @override
  String get statCompleted => 'Completed';

  @override
  String get statClients => 'Clients';

  @override
  String get statRevenue => 'Revenue';

  @override
  String get statUnpaid => 'Unpaid';

  @override
  String get statAwaitingPartsShort => 'Parts';

  @override
  String get reportsFinance => 'Finances';

  @override
  String get reportsCollected => 'Collected';

  @override
  String get reportsAcceptanceRate => 'Acceptance rate';

  @override
  String get reportsEmpty => 'No data yet';

  @override
  String get companyName => 'Business name';

  @override
  String get companyPostalCode => 'Postal code';

  @override
  String get companySiret => 'Company ID';

  @override
  String get companyLogo => 'Logo';

  @override
  String get companyLogoAdd => 'Add a logo';

  @override
  String get companyLogoRemove => 'Remove logo';

  @override
  String get paymentsEmpty => 'No payments';

  @override
  String get paymentsEmptySubtitle => 'Recorded payments will appear here.';

  @override
  String get paymentsTotalCollected => 'Total collected';

  @override
  String get cashRegister => 'Cash register';

  @override
  String get cashOpen => 'Open register';

  @override
  String get cashClose => 'Close register';

  @override
  String get cashOpeningFloat => 'Opening float';

  @override
  String get cashExpected => 'Expected cash';

  @override
  String get cashCounted => 'Counted cash';

  @override
  String get cashVariance => 'Variance';

  @override
  String get cashClosed => 'Register closed';

  @override
  String cashSince(Object time) {
    return 'Open since $time';
  }

  @override
  String get inventoryOut => 'Out of stock';

  @override
  String get inventoryLow => 'Low stock';

  @override
  String get inventoryOk => 'In stock';

  @override
  String get inventoryEmpty => 'No items';

  @override
  String get inventoryEmptySubtitle => 'Add products to the catalog.';

  @override
  String get inventoryAlerts => 'Stock alerts';

  @override
  String get planningOverdue => 'Overdue';

  @override
  String get planningToday => 'Today';

  @override
  String get planningTomorrow => 'Tomorrow';

  @override
  String get planningThisWeek => 'This week';

  @override
  String get planningLater => 'Later';

  @override
  String get planningNoDate => 'No due date';

  @override
  String get planningEmpty => 'Nothing scheduled';

  @override
  String get planningEmptySubtitle =>
      'Repairs with a due date will appear here.';

  @override
  String get accountingHt => 'Net';

  @override
  String get accountingVat => 'VAT';

  @override
  String get accountingTtc => 'Gross';

  @override
  String get accountingVatCollected => 'VAT collected';

  @override
  String get accountingVatDeductible => 'VAT deductible';

  @override
  String get accountingVatNet => 'Net VAT due';

  @override
  String get vatBasisAccrual => 'Accrual';

  @override
  String get vatBasisCash => 'Cash basis';

  @override
  String get accountingPurchases => 'Purchases (excl. tax)';

  @override
  String get accountingSupplierPaid => 'Paid to suppliers';

  @override
  String get accountingSupplierPayable => 'Owed to suppliers';

  @override
  String get accountingMargin => 'Gross margin';

  @override
  String get accountingResult => 'Net result';

  @override
  String get expenses => 'Expenses';

  @override
  String get expenseNew => 'New expense';

  @override
  String get expenseLabel => 'Label';

  @override
  String get expenseAmountHt => 'Amount (excl. tax)';

  @override
  String get expensesEmpty => 'No expenses';

  @override
  String get expenseCatRent => 'Rent';

  @override
  String get expenseCatUtilities => 'Utilities';

  @override
  String get expenseCatSupplies => 'Supplies';

  @override
  String get expenseCatMarketing => 'Marketing';

  @override
  String get expenseCatTransport => 'Transport';

  @override
  String get expenseCatSalaries => 'Salaries';

  @override
  String get expenseCatTax => 'Taxes';

  @override
  String get expenseCatOther => 'Other';

  @override
  String get accountingVatSection => 'VAT & purchases';

  @override
  String get accountingEmpty => 'No issued invoices';

  @override
  String get settingsBackup => 'Backup & export';

  @override
  String get settingsBackupSubtitle => 'Export or restore your data';

  @override
  String get backupExport => 'Export data (JSON)';

  @override
  String get backupImport => 'Import a backup';

  @override
  String get backupExportCsvAccounting => 'Export accounting (CSV)';

  @override
  String get backupExportCsvClients => 'Export clients (CSV)';

  @override
  String get backupDone => 'Data exported';

  @override
  String get backupImported => 'Data imported';

  @override
  String get backupFailed => 'Operation failed';

  @override
  String get devicesSearch => 'Search a device';

  @override
  String get devicesEmpty => 'No devices';

  @override
  String get devicesEmptySubtitle => 'Devices from repairs will appear here.';

  @override
  String get deviceRepairs => 'Repairs';

  @override
  String get deviceIdentity => 'Identity';

  @override
  String get deviceOwner => 'Owner';

  @override
  String get deviceSerial => 'IMEI / Serial';

  @override
  String get deviceWarranty => 'Warranty';

  @override
  String get deviceHistory => 'History';

  @override
  String get assistantPlaceholder => 'Ask a question about your shop…';

  @override
  String get assistantNoKey =>
      'Add your Anthropic API key to enable the assistant.';

  @override
  String get assistantApiKey => 'Anthropic API key';

  @override
  String get assistantModel => 'Model';

  @override
  String get assistantThinking => 'Thinking…';

  @override
  String get assistantError =>
      'Request failed. Check the key and your connection.';

  @override
  String get assistantConfig => 'Assistant settings';

  @override
  String get assistantIntro =>
      'Hi! Ask me anything about your repairs, invoices or stock.';

  @override
  String get settingsStorage => 'Storage';

  @override
  String get settingsStorageLocal => 'Local · server soon';

  @override
  String get navSearch => 'Search';

  @override
  String get searchPlaceholder => 'Search everything…';

  @override
  String get searchHint => 'Clients, repairs, invoices, quotes';

  @override
  String get searchEmpty => 'No results';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get periodYear => 'Year';

  @override
  String get dashboardVsPrevious => 'vs prev. period';

  @override
  String get dashboardRevenueTrend => 'Revenue';

  @override
  String get dashboardStatusMix => 'Repairs';

  @override
  String get dashboardNeedsAttention => 'Needs attention';

  @override
  String get quickNewRepair => 'Repair';

  @override
  String get quickNewQuote => 'Quote';

  @override
  String get quickNewInvoice => 'Invoice';

  @override
  String get alertOverdueInvoices => 'Overdue invoices';

  @override
  String get alertLowStock => 'Low stock';

  @override
  String get alertUnassigned => 'Unassigned';

  @override
  String get alertOverdueDeliveries => 'Late deliveries';

  @override
  String get alertOverduePayables => 'Suppliers to pay';

  @override
  String get dashboardPriorities => 'Priorities';

  @override
  String dashboardOverdueBy(Object days) {
    return '$days d overdue';
  }

  @override
  String get alertDueToday => 'Due today';

  @override
  String get alertAwaitingParts => 'Awaiting parts';

  @override
  String get dashboardActiveRepairs => 'In progress';

  @override
  String get dashboardCompleted => 'Completed';

  @override
  String get dashboardCollected => 'Collected';

  @override
  String get dashboardAllClear => 'All caught up';

  @override
  String trendSince(String value) {
    return '$value vs previous period';
  }

  @override
  String get periodDay => 'Day';

  @override
  String get periodWeek => 'Week';

  @override
  String get periodMonth => 'Month';

  @override
  String get repairsTitle => 'Repairs';

  @override
  String get repairsNew => 'New repair';

  @override
  String get repairsSearch => 'Search a repair';

  @override
  String get repairsEmpty => 'No repairs recorded';

  @override
  String get repairsEmptySubtitle => 'Create a ticket to track a job.';

  @override
  String repairsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count repairs',
      one: '1 repair',
      zero: 'No repairs',
    );
    return '$_temp0';
  }

  @override
  String get statusInProgress => 'In progress';

  @override
  String get statusAwaitingParts => 'Awaiting';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusReceived => 'Received';

  @override
  String get statusDiagnosing => 'Diagnosing';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String repairEventStatus(Object status) {
    return 'Status: $status';
  }

  @override
  String repairEventTech(Object tech) {
    return 'Assigned to $tech';
  }

  @override
  String get repairEventTechCleared => 'Technician removed';

  @override
  String repairEventPayment(Object status) {
    return 'Payment: $status';
  }

  @override
  String get repairTimeline => 'Timeline';

  @override
  String get repairNotify => 'Notify client';

  @override
  String get notifyTemplate => 'Template';

  @override
  String get notifyMessage => 'Message';

  @override
  String get notifySend => 'Send';

  @override
  String get notifyNoContact => 'No contact for this channel';

  @override
  String get repairSectionComms => 'Communications';

  @override
  String get repairAdvance => 'Advance';

  @override
  String get clientsTitle => 'Clients';

  @override
  String get clientsNew => 'New client';

  @override
  String get clientsSearch => 'Search a client';

  @override
  String get clientsEmpty => 'No clients recorded';

  @override
  String get clientsEmptySubtitle => 'Add a client to get started.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsThemeMode => 'Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsAccent => 'Accent color';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsWorkshopInfo => 'Workshop information';

  @override
  String get settingsWorkshopInfoSubtitle => 'Name, address, contact';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAboutDescription =>
      'Management app for a repair workshop.';

  @override
  String get languageSystem => 'Automatic';

  @override
  String get languageFrench => 'French';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get accentBlue => 'Blue';

  @override
  String get accentGreen => 'Green';

  @override
  String get accentOrange => 'Orange';

  @override
  String get accentRed => 'Red';

  @override
  String get accentIndigo => 'Indigo';

  @override
  String get accentPurple => 'Purple';

  @override
  String get accentTeal => 'Teal';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDone => 'Done';

  @override
  String get commonSeeAll => 'See all';

  @override
  String get commonShowLess => 'Show less';

  @override
  String get commonSearch => 'Search';

  @override
  String get repairsFilterAll => 'All';

  @override
  String get repairPriority => 'Priority';

  @override
  String get repairPriorityLow => 'Low';

  @override
  String get repairPriorityNormal => 'Normal';

  @override
  String get repairPriorityHigh => 'High';

  @override
  String repairUpdated(String when) {
    return 'Updated $when';
  }

  @override
  String get repairDetailSelectTitle => 'No repair selected';

  @override
  String get repairDetailSelectSubtitle =>
      'Select a repair to see the details.';

  @override
  String get repairSectionClient => 'Client';

  @override
  String get repairSectionProgress => 'Progress';

  @override
  String get repairSectionTimeline => 'Timeline';

  @override
  String get repairSectionParts => 'Parts';

  @override
  String get repairSectionNotes => 'Notes';

  @override
  String get repairCost => 'Estimated cost';

  @override
  String get repairMarkComplete => 'Mark as completed';

  @override
  String get repairContactClient => 'Contact client';

  @override
  String get repairEventCreated => 'Ticket created';

  @override
  String get repairEventDiagnosed => 'Diagnosis done';

  @override
  String get repairEventInRepair => 'Repair in progress';

  @override
  String get repairEventCompleted => 'Repair completed';

  @override
  String get repairNoParts => 'No parts recorded';

  @override
  String get repairNoNotes => 'No notes';

  @override
  String get repairSort => 'Sort';

  @override
  String get repairSortRecent => 'Recent';

  @override
  String get repairSortPriority => 'Priority';

  @override
  String get repairSortCost => 'Cost';

  @override
  String get repairFilters => 'Filters';

  @override
  String get repairFilterDeviceTitle => 'Device type';

  @override
  String get repairFilterAny => 'All';

  @override
  String get repairActiveOnly => 'Active only';

  @override
  String get repairFiltersReset => 'Reset';

  @override
  String get repairFiltersApply => 'Apply';

  @override
  String get deviceKindPhone => 'Phone';

  @override
  String get deviceKindLaptop => 'Laptop';

  @override
  String get deviceKindTablet => 'Tablet';

  @override
  String get deviceKindWatch => 'Watch';

  @override
  String get deviceKindOther => 'Other';

  @override
  String get navDevices => 'Devices';

  @override
  String get navPlanning => 'Schedule';

  @override
  String get navQuotes => 'Quotes';

  @override
  String get navInvoices => 'Invoices';

  @override
  String get navPayments => 'Payments';

  @override
  String get navAccounting => 'Accounting';

  @override
  String get navInventory => 'Inventory';

  @override
  String get navCatalog => 'Catalog';

  @override
  String get navSuppliers => 'Suppliers';

  @override
  String get navOrders => 'Orders';

  @override
  String get navStaff => 'Staff';

  @override
  String get navUsers => 'Users';

  @override
  String get navReports => 'Reports';

  @override
  String get navAssistant => 'AI Assistant';

  @override
  String get navGroupMain => 'Main';

  @override
  String get navGroupFinance => 'Finance';

  @override
  String get navGroupStock => 'Stock';

  @override
  String get navGroupManagement => 'Management';

  @override
  String get navGroupSystem => 'System';

  @override
  String get navMore => 'More';

  @override
  String get comingSoonTitle => 'Coming soon';

  @override
  String get comingSoonSubtitle => 'This section is under construction.';

  @override
  String get catalogSearch => 'Search a product';

  @override
  String get catalogEmpty => 'No products';

  @override
  String get catalogEmptySubtitle =>
      'Add your parts, accessories and services.';

  @override
  String get variantsLabel => 'Variants';

  @override
  String get productNew => 'New product';

  @override
  String get productName => 'Product name';

  @override
  String get productBrand => 'Brand';

  @override
  String get productCategory => 'Category';

  @override
  String get productVariants => 'Variants';

  @override
  String get priceLabel => 'Price';

  @override
  String get stockLabel => 'Stock';

  @override
  String get skuLabel => 'Ref.';

  @override
  String get categoryPart => 'Part';

  @override
  String get categoryAccessory => 'Accessory';

  @override
  String get categoryService => 'Service';

  @override
  String get serviceCatDiagnostic => 'Diagnostic';

  @override
  String get serviceCatScreen => 'Screen';

  @override
  String get serviceCatBattery => 'Battery';

  @override
  String get serviceCatSoftware => 'Software';

  @override
  String get serviceCatData => 'Data';

  @override
  String get serviceCatOther => 'Other';

  @override
  String get navServices => 'Services';

  @override
  String get servicesSearch => 'Search services';

  @override
  String get servicesEmpty => 'No services';

  @override
  String get servicesEmptySubtitle => 'Add your services and their prices.';

  @override
  String get serviceCategoryHeader => 'Category';

  @override
  String get serviceDurationLabel => 'Duration';

  @override
  String get serviceMargin => 'Margin';

  @override
  String get serviceNew => 'New service';

  @override
  String get serviceEdit => 'Edit service';

  @override
  String get serviceDescription => 'Description';

  @override
  String get serviceCost => 'Cost';

  @override
  String get serviceDelete => 'Delete service';

  @override
  String get serviceDeleteConfirm => 'Delete this service?';

  @override
  String get serviceAddToCatalog => 'Add to catalog';

  @override
  String get navCategories => 'Categories';

  @override
  String get categoryNew => 'New category';

  @override
  String get categorySubNew => 'New sub-category';

  @override
  String get categoryIcon => 'Icon';

  @override
  String get categoryColor => 'Color';

  @override
  String get categoryDelete => 'Delete category';

  @override
  String get categoryDeleteConfirm => 'Delete this category?';

  @override
  String get categoryReassign => 'Move services to';

  @override
  String get categoryAddSub => 'Add sub-category';

  @override
  String get categoryMoveServices => 'Move services';

  @override
  String get categoryMoveProducts => 'Move products';

  @override
  String get categoryReassignProducts => 'Move products to';

  @override
  String get productEdit => 'Edit product';

  @override
  String get categorySelect => 'Choose a category';

  @override
  String get taxonomyRoot => 'Root';

  @override
  String get taxonomyCode => 'Code';

  @override
  String get taxonomyDescription => 'Description';

  @override
  String get taxonomyParent => 'Parent category';

  @override
  String get taxonomyReassign => 'Move items to';

  @override
  String get taxonomyMergeInto => 'Merge into…';

  @override
  String get taxonomyMoveItems => 'Move items';

  @override
  String get taxonomyCodeTaken => 'This code is already used';

  @override
  String get taxonomyShowArchived => 'Show archived';

  @override
  String get taxonomyEmpty => 'No categories';

  @override
  String get taxonomySearch => 'Search a category';

  @override
  String get taxonomyExpandAll => 'Expand all';

  @override
  String get taxonomyCollapseAll => 'Collapse all';

  @override
  String get supplierProducts => 'Supplied products';

  @override
  String get supplierOrderedProducts => 'Previously ordered (unlinked)';

  @override
  String get supplierLinkProduct => 'Link';

  @override
  String get inventoryReorder => 'Order';

  @override
  String get inventoryNoSupplier => 'No supplier linked to this product';

  @override
  String get supplierInUse =>
      'Supplier is referenced (products or orders) — cannot delete';

  @override
  String get supplierDeleteConfirm => 'Delete this supplier?';

  @override
  String get commonOk => 'OK';

  @override
  String get sourcingPurchasePrice => 'Purchase price';

  @override
  String get sourcingPreferred => 'Preferred';

  @override
  String get sourcingBestPrice => 'Best price';

  @override
  String get productFacets => 'Facets';

  @override
  String get smartViews => 'Smart lists';

  @override
  String get smartViewNew => 'New smart list';

  @override
  String get smartRule => 'Rule';

  @override
  String get smartStock => 'Stock';

  @override
  String get smartPriceMax => 'Max price';

  @override
  String get smartPriceMin => 'Min price';

  @override
  String get smartAny => 'Any';

  @override
  String get catalogManage => 'Manage';

  @override
  String get serviceDuplicate => 'Duplicate';

  @override
  String get serviceCopySuffix => '(copy)';

  @override
  String get variantNew => 'New variant';

  @override
  String get variantLabel => 'Label (e.g. Black · OEM)';

  @override
  String variantCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count variants',
      one: '1 variant',
      zero: 'No variants',
    );
    return '$_temp0';
  }

  @override
  String stockUnits(int count) {
    return '$count in stock';
  }

  @override
  String get addLabel => 'Add';

  @override
  String get repairSectionServices => 'Services';

  @override
  String get repairNoServices => 'No services';

  @override
  String get repairServicesTotal => 'Services total';

  @override
  String get repairSectionObservations => 'Observations';

  @override
  String get repairNoObservations => 'No observations';

  @override
  String get paymentUnpaid => 'Unpaid';

  @override
  String get paymentPartial => 'Partial';

  @override
  String get paymentPaid => 'Paid';

  @override
  String get repairSectionProblem => 'Problem';

  @override
  String get repairReported => 'Reported issue';

  @override
  String get repairDiagnosis => 'Diagnosis';

  @override
  String get repairWorkDone => 'Work done';

  @override
  String get repairSectionDevice => 'Device';

  @override
  String get deviceModel => 'Model';

  @override
  String get deviceColor => 'Color';

  @override
  String get deviceStorage => 'Storage';

  @override
  String get deviceAccessories => 'Accessories';

  @override
  String get repairIntakeCondition => 'Condition at intake';

  @override
  String get devicePasscode => 'Unlock code';

  @override
  String get backupConsent => 'Backup consent';

  @override
  String get repairSectionFinance => 'Finances';

  @override
  String get financeLabour => 'Labour';

  @override
  String get financeDiscount => 'Discount';

  @override
  String get financeTax => 'VAT';

  @override
  String get financeSubtotal => 'Subtotal';

  @override
  String get financeTotal => 'Total';

  @override
  String get financeDeposit => 'Deposit';

  @override
  String get financeBalance => 'Balance due';

  @override
  String get repairSectionLogistics => 'Tracking & logistics';

  @override
  String get repairAssignedTech => 'Technician';

  @override
  String get repairCreatedBy => 'Taken in by';

  @override
  String get repairLocation => 'Location';

  @override
  String get repairWarranty => 'Warranty';

  @override
  String get repairUnderWarranty => 'Under warranty';

  @override
  String get repairWarrantyExpired => 'Warranty expired';

  @override
  String repairWarrantyUntil(Object date) {
    return 'Until $date';
  }

  @override
  String warrantyDuration(int count) {
    return '$count months';
  }

  @override
  String get repairDue => 'Due';

  @override
  String get repairOverdue => 'Overdue';

  @override
  String get repairPhotos => 'Photos';

  @override
  String get repairPhotoAdded => 'Photo added';

  @override
  String get repairPhotoRemove => 'Remove this photo?';

  @override
  String get repairEventPhoto => 'Photo added';

  @override
  String get actionCall => 'Call';

  @override
  String get actionSms => 'SMS';

  @override
  String get actionWhatsapp => 'WhatsApp';

  @override
  String get actionEmail => 'Email';

  @override
  String get actionEdit => 'Edit';

  @override
  String get editMode => 'Editing';

  @override
  String get actionReopen => 'Reopen';

  @override
  String get actionAssign => 'Assign a technician';

  @override
  String get actionAddPhoto => 'Add a photo';

  @override
  String get actionPrintLabel => 'Print label';

  @override
  String get repairPrintChoose => 'Print';

  @override
  String get repairSheetTitle => 'Repair sheet';

  @override
  String get repairTicketTitle => 'Ticket';

  @override
  String get repairSignatureClient => 'Client signature';

  @override
  String get repairSignatureTech => 'Technician signature';

  @override
  String get repairTicketFooter => 'Present this ticket to collect the device.';

  @override
  String get unitMonths => 'months';

  @override
  String get repairScan => 'Scan';

  @override
  String get repairScanHint => 'Place the repair QR inside the frame';

  @override
  String get repairScanManual => 'Enter reference';

  @override
  String get repairScanReference => 'Reference';

  @override
  String get repairScanOpen => 'Open';

  @override
  String get repairScanNotFound => 'Repair not found';

  @override
  String get repairScanUnavailable =>
      'Camera scanning is unavailable on this platform';

  @override
  String get repairScanFromImage => 'Decode from image';

  @override
  String get repairScanError => 'Could not decode the QR';

  @override
  String get repairScanCameraError => 'Camera unavailable (permission denied?)';

  @override
  String get actionGenerateInvoice => 'Generate invoice';

  @override
  String get actionDelete => 'Delete';

  @override
  String get statusLabel => 'Status';

  @override
  String get qtyShort => 'Qty';

  @override
  String get unitPriceShort => 'Unit';

  @override
  String get addPrestation => 'Add a service';

  @override
  String get addPart => 'Add a part';

  @override
  String get unassigned => 'Unassigned';

  @override
  String get notProvided => 'Not provided';

  @override
  String get clientSectionContact => 'Contact details';

  @override
  String get supplierNew => 'New supplier';

  @override
  String get supplierSearch => 'Search a supplier';

  @override
  String get supplierEmpty => 'No suppliers';

  @override
  String get supplierEmptySubtitle => 'Add a supplier to get started.';

  @override
  String get supplierType => 'Type';

  @override
  String get supplierTypeCompany => 'Company';

  @override
  String get supplierTypeIndividual => 'Individual';

  @override
  String get supplierName => 'Name / Company';

  @override
  String get supplierContactName => 'Contact person';

  @override
  String get supplierVat => 'VAT number';

  @override
  String get supplierCity => 'City';

  @override
  String get supplierTerms => 'Payment terms';

  @override
  String get supplierSectionCompany => 'Company';

  @override
  String get fieldName => 'Name';

  @override
  String get clientTypeIndividual => 'Individual';

  @override
  String get clientTypeCompany => 'Company';

  @override
  String get clientCompanyName => 'Company name';

  @override
  String get clientVat => 'VAT number';

  @override
  String get clientCity => 'City';

  @override
  String get clientSectionCompany => 'Company';

  @override
  String get clientSectionHistory => 'Repair history';

  @override
  String get staffNew => 'New employee';

  @override
  String get staffSearch => 'Search an employee';

  @override
  String get staffEmpty => 'No employees';

  @override
  String get staffEmptySubtitle => 'Add an employee to get started.';

  @override
  String get staffJobTitle => 'Job title';

  @override
  String get staffHireDate => 'Hire date';

  @override
  String get staffCommission => 'Commission (%)';

  @override
  String get staffActive => 'Active';

  @override
  String get staffInactive => 'Inactive';

  @override
  String get staffSectionEmployment => 'Employment';

  @override
  String get staffAssignedRepairs => 'Assigned repairs';

  @override
  String get authLoginTitle => 'Sign in';

  @override
  String get authPassword => 'Password';

  @override
  String get authPin => 'PIN code';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authLogout => 'Log out';

  @override
  String get authError => 'Incorrect credentials';

  @override
  String get authModeEmail => 'Email';

  @override
  String get authModePin => 'PIN';

  @override
  String get userNew => 'New user';

  @override
  String get userSearch => 'Search a user';

  @override
  String get userEmpty => 'No users';

  @override
  String get userEmptySubtitle => 'Add an account to get started.';

  @override
  String get listNoResults => 'No results';

  @override
  String get listNoResultsSubtitle => 'Adjust your search or filters.';

  @override
  String get navProfile => 'Profile';

  @override
  String get profileSubtitle => 'Your account and security';

  @override
  String get profileAccount => 'Account';

  @override
  String get profileSecurity => 'Security';

  @override
  String get profileLinkedEmployee => 'Linked employee';

  @override
  String get profileChangePassword => 'Change password';

  @override
  String get profileChangePin => 'Change PIN';

  @override
  String get profileCurrentPassword => 'Current password';

  @override
  String get profileNewPassword => 'New password';

  @override
  String get profileConfirm => 'Confirm';

  @override
  String get profileNewPin => 'New PIN';

  @override
  String get profilePasswordChanged => 'Password changed';

  @override
  String get profilePinChanged => 'PIN changed';

  @override
  String get profileWrongPassword => 'Current password is incorrect';

  @override
  String get profilePasswordMismatch => 'Passwords don\'t match';

  @override
  String get accountEmailTaken => 'This email is already in use';

  @override
  String get accountPinTaken => 'This PIN is already in use';

  @override
  String get accountLastAdmin =>
      'At least one active administrator is required';

  @override
  String get accountEventLogin => 'Signed in';

  @override
  String get accountEventLogout => 'Signed out';

  @override
  String get accountEventFailedLogin => 'Failed sign-in';

  @override
  String get accountEventCreated => 'Account created';

  @override
  String get accountEventUpdated => 'Account updated';

  @override
  String get accountEventRoleChanged => 'Role changed';

  @override
  String get accountEventDeactivated => 'Account deactivated';

  @override
  String get accountEventReactivated => 'Account reactivated';

  @override
  String get accountEventPasswordReset => 'Password reset';

  @override
  String get accountEventPinReset => 'PIN reset';

  @override
  String get accountEventInvited => 'Invitation sent';

  @override
  String get accountEventDeleted => 'Account deleted';

  @override
  String get accountActivity => 'Activity';

  @override
  String get accountLog => 'Account log';

  @override
  String get accountCreatedAt => 'Created';

  @override
  String get accountLastLogin => 'Last sign-in';

  @override
  String get accountNeverLoggedIn => 'Never signed in';

  @override
  String get accountActionsTitle => 'Actions';

  @override
  String get accountResetPassword => 'Reset password';

  @override
  String get accountResetPin => 'Reset PIN';

  @override
  String get accountInvite => 'Invite (demo)';

  @override
  String get accountDelete => 'Delete account';

  @override
  String get accountDeleteConfirm => 'Permanently delete this account?';

  @override
  String get accountTempSecret => 'Temporary secret (demo)';

  @override
  String get accountInvitePending => 'Invitation pending';

  @override
  String get navIntegrations => 'Integrations';

  @override
  String get integrationsSubtitle => 'Payments, email, messaging…';

  @override
  String get integrationsSummary => 'Connected services';

  @override
  String get integrationsSearch => 'Search integrations';

  @override
  String get integrationEnable => 'Enable';

  @override
  String get integrationTest => 'Test';

  @override
  String get integrationComingSoon => 'Live connection coming soon';

  @override
  String get integrationConnectAccount => 'Connect account';

  @override
  String get integrationConnected => 'Account linked';

  @override
  String get integrationDisconnect => 'Disconnect';

  @override
  String get integrationValid => 'Configuration valid';

  @override
  String get integrationCheckNotConnected => 'Account not linked';

  @override
  String get integrationCheckEmail => 'Invalid email address';

  @override
  String integrationCheckMissing(Object field) {
    return 'Required field missing: $field';
  }

  @override
  String integrationCheckUrl(Object field) {
    return 'Invalid URL: $field';
  }

  @override
  String integrationCheckShort(Object field) {
    return 'Value too short: $field';
  }

  @override
  String get integrationCatPayments => 'Payments';

  @override
  String get integrationCatMessaging => 'Messaging';

  @override
  String get integrationCatCloud => 'Cloud & email';

  @override
  String get integrationCatAutomation => 'Automation';

  @override
  String get integrationDescOutlook => 'Email invoices via Outlook';

  @override
  String get integrationDescOnedrive => 'Back up to OneDrive';

  @override
  String get integrationDescTelegram => 'Notifications via a Telegram bot';

  @override
  String get integrationDescTeams => 'Alerts to a Teams channel';

  @override
  String get integrationDescSlack => 'Alerts to a Slack channel';

  @override
  String get integrationDescZapier => 'Automate via a Zapier webhook';

  @override
  String get integrationFieldBotToken => 'Bot token';

  @override
  String get integrationFieldChatId => 'Chat ID';

  @override
  String get integrationFieldWebhookUrl => 'Webhook URL';

  @override
  String get integrationDescApplepay => 'Apple Pay payments';

  @override
  String get integrationDescIcloud => 'iCloud backup';

  @override
  String get integrationDescApplemsg => 'Messages for Business (iMessage)';

  @override
  String get integrationFieldMerchantId => 'Apple merchant ID';

  @override
  String get integrationFieldBusinessId => 'Apple Business ID';

  @override
  String get integrationStatusActive => 'Active';

  @override
  String get integrationStatusDisabled => 'Disabled';

  @override
  String get integrationStatusNotConfigured => 'Not configured';

  @override
  String get integrationDescFlouci => 'Wallet & card payments (CIB/Visa/MC)';

  @override
  String get integrationDescKonnect => 'Online card payments';

  @override
  String get integrationDescClictopay => 'Bank card payments (SMT)';

  @override
  String get integrationDescStripe => 'International cards';

  @override
  String get integrationDescDrive => 'Cloud backup';

  @override
  String get integrationDescGmail => 'Email invoices';

  @override
  String get integrationDescWhatsapp => 'Automated WhatsApp messages';

  @override
  String get integrationDescMessenger => 'Chat via Messenger';

  @override
  String get integrationDescSms => 'SMS notifications';

  @override
  String get integrationFieldApiKey => 'API key';

  @override
  String get integrationFieldSecretKey => 'Secret key';

  @override
  String get integrationFieldPrivateToken => 'Private token';

  @override
  String get integrationFieldAppId => 'App ID';

  @override
  String get integrationFieldWalletId => 'Wallet ID';

  @override
  String get integrationFieldMerchantUser => 'Merchant username';

  @override
  String get integrationFieldMerchantPassword => 'Merchant password';

  @override
  String get integrationFieldAppPassword => 'App password';

  @override
  String get integrationFieldPhoneId => 'Phone number ID';

  @override
  String get integrationFieldAccessToken => 'Access token';

  @override
  String get integrationFieldPageLink => 'Page link';

  @override
  String get integrationFieldSender => 'Sender';

  @override
  String get userRole => 'Role';

  @override
  String get userLinkedEmployee => 'Linked employee';

  @override
  String get userNoEmployee => 'None';

  @override
  String get userNewPassword => 'New password';

  @override
  String get userNewPin => 'New PIN';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get roleTechnician => 'Technician';

  @override
  String get roleCashier => 'Cashier';

  @override
  String get orderNew => 'New order';

  @override
  String get orderSearch => 'Search an order';

  @override
  String get orderEmpty => 'No orders';

  @override
  String get orderEmptySubtitle => 'Create a supplier order.';

  @override
  String get orderStatusDraft => 'Draft';

  @override
  String get orderStatusOrdered => 'Ordered';

  @override
  String get orderStatusReceived => 'Received';

  @override
  String get orderStatusCancelled => 'Cancelled';

  @override
  String get orderSupplier => 'Supplier';

  @override
  String get orderExpectedDate => 'Expected delivery';

  @override
  String get orderReceive => 'Receive';

  @override
  String get orderPaid => 'Paid';

  @override
  String get orderBalanceDue => 'Balance due';

  @override
  String get orderAddPayment => 'Record payment';

  @override
  String get orderAddLine => 'Add an item';

  @override
  String get orderSectionLines => 'Items';

  @override
  String get orderNoLines => 'No items';

  @override
  String get orderSubtotal => 'Subtotal';

  @override
  String get orderTax => 'VAT';

  @override
  String get orderTotal => 'Total';

  @override
  String get productPickTitle => 'Choose a product';

  @override
  String get quoteNew => 'New quote';

  @override
  String get quoteSearch => 'Search a quote';

  @override
  String get quoteEmpty => 'No quotes';

  @override
  String get quoteEmptySubtitle => 'Create a client quote.';

  @override
  String get quoteStatusDraft => 'Draft';

  @override
  String get quoteStatusSent => 'Sent';

  @override
  String get quoteStatusAccepted => 'Accepted';

  @override
  String get quoteStatusRefused => 'Refused';

  @override
  String get quoteStatusExpired => 'Expired';

  @override
  String get quoteValidUntil => 'Valid until';

  @override
  String get quoteAddService => 'Add a service';

  @override
  String get quoteAddPart => 'Add a part';

  @override
  String get quoteSectionLines => 'Details';

  @override
  String get quoteExportPdf => 'Export to PDF';

  @override
  String get quoteSend => 'Send';

  @override
  String get quoteAccept => 'Accept';

  @override
  String get quoteRefuse => 'Refuse';

  @override
  String get colDesignation => 'Description';

  @override
  String get colQty => 'Qty';

  @override
  String get colUnitPrice => 'Unit price';

  @override
  String get colLineTotal => 'Total';

  @override
  String get invoiceNew => 'New invoice';

  @override
  String get invoiceSearch => 'Search an invoice';

  @override
  String get invoiceEmpty => 'No invoices';

  @override
  String get invoiceEmptySubtitle => 'Create an invoice.';

  @override
  String get invoiceStatusDraft => 'Draft';

  @override
  String get invoiceStatusIssued => 'Issued';

  @override
  String get invoiceStatusPartial => 'Partial';

  @override
  String get invoiceStatusPaid => 'Paid';

  @override
  String get invoiceStatusOverdue => 'Overdue';

  @override
  String get invoiceStatusCancelled => 'Cancelled';

  @override
  String get invoiceIssue => 'Issue';

  @override
  String get creditNote => 'Credit note';

  @override
  String get creditNotes => 'Credit notes';

  @override
  String get creditNoteNew => 'Create credit note';

  @override
  String get creditNoteIssue => 'Issue credit note';

  @override
  String get creditNoteReason => 'Reason';

  @override
  String get creditNoteEmpty => 'No credit notes';

  @override
  String get invoiceDueDate => 'Due date';

  @override
  String get invoiceDeposit => 'Deposit';

  @override
  String get invoiceBalance => 'Balance due';

  @override
  String get invoiceSectionPayments => 'Payments';

  @override
  String get invoiceRecordPayment => 'Record a payment';

  @override
  String get invoiceNoPayments => 'No payments';

  @override
  String get invoiceAmount => 'Amount';

  @override
  String get paymentMethodCash => 'Cash';

  @override
  String get paymentMethodCard => 'Card';

  @override
  String get paymentMethodTransfer => 'Transfer';

  @override
  String get paymentMethodCheck => 'Check';

  @override
  String get paymentMethodCredit => 'Credit';

  @override
  String get quoteConvertInvoice => 'Convert to invoice';

  @override
  String get invoiceFromRepair => 'Generate invoice';

  @override
  String get fieldPhone => 'Phone';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldAddress => 'Address';

  @override
  String get fieldWhatsapp => 'WhatsApp';

  @override
  String get fieldTelegram => 'Telegram';

  @override
  String get fieldSecondaryPhone => 'Secondary phone';

  @override
  String get fieldWebsite => 'Website';

  @override
  String get fieldInstagram => 'Instagram';

  @override
  String get clientSectionSocial => 'Web & social';

  @override
  String get actionWebsite => 'Open website';

  @override
  String get actionInstagram => 'Open Instagram';

  @override
  String get contactKindTitle => 'Contact type';

  @override
  String get contactKindMobile => 'Mobile';

  @override
  String get contactKindLandline => 'Landline';

  @override
  String get contactKindWhatsapp => 'WhatsApp';

  @override
  String get contactKindTelegram => 'Telegram';

  @override
  String get contactKindEmail => 'Email';

  @override
  String get contactKindWebsite => 'Website';

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
  String get contactKindOther => 'Other';

  @override
  String get clientAddContact => 'Add a contact';

  @override
  String get clientOtherContacts => 'Other contacts';

  @override
  String get clientOtherAddresses => 'Other addresses';

  @override
  String get clientSectionAddresses => 'Addresses';

  @override
  String get addressMain => 'Main address';

  @override
  String get clientAddAddress => 'Add an address';

  @override
  String get addressKindTitle => 'Address type';

  @override
  String get addressKindHome => 'Home';

  @override
  String get addressKindWork => 'Work';

  @override
  String get addressKindBilling => 'Billing';

  @override
  String get addressKindShipping => 'Shipping';

  @override
  String get addressKindOther => 'Other';

  @override
  String get clientStatInvoiced => 'Invoiced';

  @override
  String get clientStatOutstanding => 'Unpaid';

  @override
  String get clientStatRepairs => 'Repairs';

  @override
  String get clientSectionInvoices => 'Invoices';

  @override
  String get clientSectionQuotes => 'Quotes';

  @override
  String get clientLastActivity => 'Last activity';

  @override
  String get clientNoDocuments => 'No documents';

  @override
  String get clientNoActivity => 'No activity yet';

  @override
  String get clientNoInvoices => 'No invoices';

  @override
  String get clientNoQuotes => 'No quotes';

  @override
  String get clientSettleAll => 'Settle all';

  @override
  String get clientCredit => 'Available credit';

  @override
  String get clientNetBalance => 'Net balance';

  @override
  String get clientStatementPdf => 'Account statement (PDF)';

  @override
  String get statementTitle => 'Account statement';

  @override
  String get statementDate => 'Date';

  @override
  String get statementDetail => 'Detail';

  @override
  String get statementDebit => 'Debit';

  @override
  String get statementCredit => 'Credit';

  @override
  String get statementBalance => 'Balance';

  @override
  String get statementOpening => 'Opening balance';

  @override
  String get statementClosing => 'Closing balance';

  @override
  String get statementInvoice => 'Invoice';

  @override
  String get statementDeposit => 'Deposit';

  @override
  String get statementPayment => 'Payment';

  @override
  String get colNumber => 'No.';

  @override
  String get supplierStatementPdf => 'Supplier statement (PDF)';

  @override
  String get supplierStatementTitle => 'Supplier statement';

  @override
  String get supplierPurchased => 'Received';

  @override
  String get supplierOnOrder => 'On order';

  @override
  String get supplierOverdue => 'Overdue';

  @override
  String get supplierPayable => 'Payable';

  @override
  String get poAgeNotDue => 'Not due';

  @override
  String get poAge1to30 => '1–30 d';

  @override
  String get poAge31to60 => '31–60 d';

  @override
  String get poAge60plus => '60+ d';

  @override
  String get clientAddDeposit => 'Add a deposit';

  @override
  String get clientApplyCredit => 'Apply credit';

  @override
  String get clientRefund => 'Refund';

  @override
  String get chequeAdd => 'Add a cheque';

  @override
  String get navRefunds => 'Refunds';

  @override
  String get refundsTotal => 'Total refunded';

  @override
  String get refundsEmpty => 'No refunds';

  @override
  String get refundsEmptySubtitle => 'Refunds to clients will appear here.';

  @override
  String get financePeriodAll => 'All';

  @override
  String get financePeriodMonth => 'Month';

  @override
  String get financePeriodQuarter => 'Quarter';

  @override
  String get financePeriodYear => 'Year';

  @override
  String get financePeriodCustom => 'Custom';

  @override
  String get filterAllClients => 'All clients';

  @override
  String get paymentKindInvoice => 'Invoice';

  @override
  String get paymentKindDeposit => 'Deposit';

  @override
  String get paymentKindApplication => 'Credit applied';

  @override
  String get paymentKindRefund => 'Refund';

  @override
  String get financeBreakdown => 'Breakdown';

  @override
  String get navCheques => 'Cheques';

  @override
  String get chequeNumber => 'Cheque no.';

  @override
  String get chequeBank => 'Bank';

  @override
  String get chequeDrawer => 'Drawer';

  @override
  String get chequeDueDate => 'Due date';

  @override
  String get chequeStatusPending => 'To deposit';

  @override
  String get chequeStatusDeposited => 'Deposited';

  @override
  String get chequeStatusCleared => 'Cleared';

  @override
  String get chequeStatusBounced => 'Bounced';

  @override
  String get chequesToCollect => 'Cheques to collect';

  @override
  String get chequesEmpty => 'No cheques';

  @override
  String get chequesEmptySubtitle => 'Received cheques will appear here.';

  @override
  String get chequeMarkDeposited => 'Mark deposited';

  @override
  String get chequeMarkCleared => 'Mark cleared';

  @override
  String get chequeBounceAction => 'Bounce';

  @override
  String get clientSince => 'Client since';

  @override
  String get clientTags => 'Tags';

  @override
  String get clientTagsHint => 'Separate with commas';

  @override
  String get clientConsent => 'Marketing consent';

  @override
  String get clientBillingContact => 'Billing contact';

  @override
  String get clientPaymentTerms => 'Payment terms';

  @override
  String get clientDiscount => 'Standard discount';

  @override
  String get clientCreditLimit => 'Credit limit';

  @override
  String clientDuplicateWarning(String name) {
    return 'A similar client already exists: $name. Create anyway?';
  }

  @override
  String get actionTelegram => 'Telegram';

  @override
  String get actionDirections => 'Directions';

  @override
  String get clientSelect => 'Select a client';

  @override
  String get settingsSectionLayout => 'Layout';

  @override
  String get settingsContentWidth => 'Content width';

  @override
  String get contentNormal => 'Normal';

  @override
  String get contentStretch => 'Full width';

  @override
  String get settingsSidebar => 'Sidebar';

  @override
  String get sidebarAdaptive => 'Adaptive';

  @override
  String get sidebarExpanded => 'Expanded';

  @override
  String get settingsDetailView => 'Detail view';

  @override
  String get settingsClientsView => 'Directory view';

  @override
  String get settingsRegional => 'Regional';

  @override
  String get settingsCurrency => 'Currency';

  @override
  String get settingsDateFormat => 'Date format';

  @override
  String get clientsViewList => 'List';

  @override
  String get clientsViewGrid => 'Grid';

  @override
  String get clientsViewTable => 'Table';

  @override
  String get fieldType => 'Type';

  @override
  String get clientSegmentDebtors => 'Debtors';

  @override
  String get clientSegmentCredit => 'With credit';

  @override
  String get clientSegmentInactive => 'Inactive';

  @override
  String get clientSegmentBusiness => 'Business';

  @override
  String get clientSegmentRecent => 'New';

  @override
  String get detailAdaptive => 'Adaptive';

  @override
  String get detailPane => 'Side panel';

  @override
  String get detailPage => 'Separate page';

  @override
  String get prestationPickTitle => 'Choose a service';

  @override
  String get prestationSearch => 'Search a service';

  @override
  String get prestationManual => 'Manual entry';
}
