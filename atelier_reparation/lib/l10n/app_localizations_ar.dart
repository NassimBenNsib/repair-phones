// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'ورشة الإصلاح';

  @override
  String get navDashboard => 'لوحة التحكم';

  @override
  String get navRepairs => 'الإصلاحات';

  @override
  String get navClients => 'العملاء';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get dashboardTitle => 'لوحة التحكم';

  @override
  String get dashboardOverview => 'نظرة عامة';

  @override
  String get dashboardRecentRepairs => 'الإصلاحات الأخيرة';

  @override
  String get dashboardActivity => 'النشاط';

  @override
  String get dashboardQuickActions => 'إجراءات سريعة';

  @override
  String get dashboardNoRepairs => 'لا توجد إصلاحات';

  @override
  String get dashboardNoRepairsSubtitle => 'ستظهر التذاكر الجديدة هنا.';

  @override
  String get dashboardNotifications => 'الإشعارات';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get notificationsRecent => 'النشاط الأخير';

  @override
  String get statInProgress => 'قيد التنفيذ';

  @override
  String get statAwaitingParts => 'بانتظار القطع';

  @override
  String get statCompleted => 'مكتملة';

  @override
  String get statClients => 'العملاء';

  @override
  String get statRevenue => 'الإيرادات';

  @override
  String get statUnpaid => 'غير مدفوع';

  @override
  String get statAwaitingPartsShort => 'قطع';

  @override
  String get reportsFinance => 'المالية';

  @override
  String get reportsCollected => 'المحصّل';

  @override
  String get reportsAcceptanceRate => 'معدل القبول';

  @override
  String get reportsEmpty => 'لا توجد بيانات بعد';

  @override
  String get companyName => 'اسم المنشأة';

  @override
  String get companyPostalCode => 'الرمز البريدي';

  @override
  String get companySiret => 'المعرّف الضريبي';

  @override
  String get companyLogo => 'الشعار';

  @override
  String get companyLogoAdd => 'إضافة شعار';

  @override
  String get companyLogoRemove => 'إزالة الشعار';

  @override
  String get paymentsEmpty => 'لا مدفوعات';

  @override
  String get paymentsEmptySubtitle => 'ستظهر هنا المدفوعات المسجّلة.';

  @override
  String get paymentsTotalCollected => 'إجمالي المحصّل';

  @override
  String get cashRegister => 'الصندوق';

  @override
  String get cashOpen => 'فتح الصندوق';

  @override
  String get cashClose => 'إغلاق الصندوق';

  @override
  String get cashOpeningFloat => 'رصيد افتتاحي';

  @override
  String get cashExpected => 'النقد المتوقع';

  @override
  String get cashCounted => 'النقد المعدود';

  @override
  String get cashVariance => 'الفرق';

  @override
  String get cashClosed => 'الصندوق مغلق';

  @override
  String cashSince(Object time) {
    return 'مفتوح منذ $time';
  }

  @override
  String get inventoryOut => 'نفد المخزون';

  @override
  String get inventoryLow => 'مخزون منخفض';

  @override
  String get inventoryOk => 'متوفر';

  @override
  String get inventoryEmpty => 'لا توجد عناصر';

  @override
  String get inventoryEmptySubtitle => 'أضف منتجات إلى الكتالوج.';

  @override
  String get inventoryAlerts => 'تنبيهات المخزون';

  @override
  String get planningOverdue => 'متأخرة';

  @override
  String get planningToday => 'اليوم';

  @override
  String get planningTomorrow => 'غدًا';

  @override
  String get planningThisWeek => 'هذا الأسبوع';

  @override
  String get planningLater => 'لاحقًا';

  @override
  String get planningNoDate => 'بدون موعد';

  @override
  String get planningEmpty => 'لا شيء مجدول';

  @override
  String get planningEmptySubtitle => 'ستظهر هنا الإصلاحات ذات الموعد.';

  @override
  String get accountingHt => 'الصافي';

  @override
  String get accountingVat => 'ض.ق.م';

  @override
  String get accountingTtc => 'الإجمالي';

  @override
  String get accountingVatCollected => 'ض.ق.م المحصّلة';

  @override
  String get accountingVatDeductible => 'ض.ق.م القابلة للخصم';

  @override
  String get accountingVatNet => 'صافي ض.ق.م المستحقة';

  @override
  String get vatBasisAccrual => 'على أساس الفوترة';

  @override
  String get vatBasisCash => 'على أساس التحصيل';

  @override
  String get accountingPurchases => 'المشتريات (دون ضريبة)';

  @override
  String get accountingSupplierPaid => 'المدفوع للموردين';

  @override
  String get accountingSupplierPayable => 'المستحق للموردين';

  @override
  String get accountingMargin => 'الهامش الإجمالي';

  @override
  String get accountingResult => 'النتيجة الصافية';

  @override
  String get expenses => 'المصروفات';

  @override
  String get expenseNew => 'مصروف جديد';

  @override
  String get expenseLabel => 'الوصف';

  @override
  String get expenseAmountHt => 'المبلغ دون ضريبة';

  @override
  String get expensesEmpty => 'لا توجد مصروفات';

  @override
  String get expenseCatRent => 'إيجار';

  @override
  String get expenseCatUtilities => 'المرافق';

  @override
  String get expenseCatSupplies => 'لوازم';

  @override
  String get expenseCatMarketing => 'تسويق';

  @override
  String get expenseCatTransport => 'نقل';

  @override
  String get expenseCatSalaries => 'رواتب';

  @override
  String get expenseCatTax => 'ضرائب';

  @override
  String get expenseCatOther => 'أخرى';

  @override
  String get accountingVatSection => 'الضريبة والمشتريات';

  @override
  String get accountingEmpty => 'لا فواتير صادرة';

  @override
  String get settingsBackup => 'النسخ الاحتياطي والتصدير';

  @override
  String get settingsBackupSubtitle => 'صدّر بياناتك أو استعدها';

  @override
  String get backupExport => 'تصدير البيانات (JSON)';

  @override
  String get backupImport => 'استيراد نسخة احتياطية';

  @override
  String get backupExportCsvAccounting => 'تصدير المحاسبة (CSV)';

  @override
  String get backupExportCsvClients => 'تصدير العملاء (CSV)';

  @override
  String get backupDone => 'تم تصدير البيانات';

  @override
  String get backupImported => 'تم استيراد البيانات';

  @override
  String get backupFailed => 'تعذّرت العملية';

  @override
  String get devicesSearch => 'ابحث عن جهاز';

  @override
  String get devicesEmpty => 'لا أجهزة';

  @override
  String get devicesEmptySubtitle => 'ستظهر هنا أجهزة الإصلاحات.';

  @override
  String get deviceRepairs => 'الإصلاحات';

  @override
  String get deviceIdentity => 'الهوية';

  @override
  String get deviceOwner => 'المالك';

  @override
  String get deviceSerial => 'IMEI / الرقم التسلسلي';

  @override
  String get deviceWarranty => 'الضمان';

  @override
  String get deviceHistory => 'السجل';

  @override
  String get assistantPlaceholder => 'اطرح سؤالاً عن متجرك…';

  @override
  String get assistantNoKey => 'أضف مفتاح Anthropic API لتفعيل المساعد.';

  @override
  String get assistantApiKey => 'مفتاح Anthropic API';

  @override
  String get assistantModel => 'النموذج';

  @override
  String get assistantThinking => 'يفكّر…';

  @override
  String get assistantError => 'فشل الطلب. تحقّق من المفتاح والاتصال.';

  @override
  String get assistantConfig => 'إعدادات المساعد';

  @override
  String get assistantIntro =>
      'مرحبًا! اسألني عن إصلاحاتك أو فواتيرك أو مخزونك.';

  @override
  String get settingsStorage => 'التخزين';

  @override
  String get settingsStorageLocal => 'محلي · الخادم قريبًا';

  @override
  String get navSearch => 'بحث';

  @override
  String get searchPlaceholder => 'ابحث في كل شيء…';

  @override
  String get searchHint => 'العملاء، الإصلاحات، الفواتير، عروض الأسعار';

  @override
  String get searchEmpty => 'لا نتائج';

  @override
  String get greetingMorning => 'صباح الخير';

  @override
  String get greetingAfternoon => 'مساء الخير';

  @override
  String get greetingEvening => 'مساء الخير';

  @override
  String get periodYear => 'السنة';

  @override
  String get dashboardVsPrevious => 'مقارنة بالفترة السابقة';

  @override
  String get dashboardRevenueTrend => 'الإيرادات';

  @override
  String get dashboardStatusMix => 'الإصلاحات';

  @override
  String get dashboardNeedsAttention => 'يتطلب المتابعة';

  @override
  String get quickNewRepair => 'إصلاح';

  @override
  String get quickNewQuote => 'عرض سعر';

  @override
  String get quickNewInvoice => 'فاتورة';

  @override
  String get alertOverdueInvoices => 'فواتير متأخرة';

  @override
  String get alertLowStock => 'مخزون منخفض';

  @override
  String get alertUnassigned => 'غير مُسندة';

  @override
  String get alertOverdueDeliveries => 'تسليمات متأخرة';

  @override
  String get alertOverduePayables => 'مورّدون بانتظار الدفع';

  @override
  String get dashboardPriorities => 'الأولويات';

  @override
  String dashboardOverdueBy(Object days) {
    return 'متأخرة $days يوم';
  }

  @override
  String get alertDueToday => 'مواعيد اليوم';

  @override
  String get alertAwaitingParts => 'بانتظار القطع';

  @override
  String get dashboardActiveRepairs => 'قيد التنفيذ';

  @override
  String get dashboardCompleted => 'منجزة';

  @override
  String get dashboardCollected => 'المحصّل';

  @override
  String get dashboardAllClear => 'كل شيء محدّث';

  @override
  String trendSince(String value) {
    return '$value مقارنة بالفترة السابقة';
  }

  @override
  String get periodDay => 'يوم';

  @override
  String get periodWeek => 'أسبوع';

  @override
  String get periodMonth => 'شهر';

  @override
  String get repairsTitle => 'الإصلاحات';

  @override
  String get repairsNew => 'إصلاح جديد';

  @override
  String get repairsSearch => 'ابحث عن إصلاح';

  @override
  String get repairsEmpty => 'لا توجد إصلاحات مسجلة';

  @override
  String get repairsEmptySubtitle => 'أنشئ تذكرة لمتابعة مهمة.';

  @override
  String repairsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count إصلاح',
      many: '$count إصلاحًا',
      few: '$count إصلاحات',
      two: 'إصلاحان',
      one: 'إصلاح واحد',
      zero: 'لا توجد إصلاحات',
    );
    return '$_temp0';
  }

  @override
  String get statusInProgress => 'قيد التنفيذ';

  @override
  String get statusAwaitingParts => 'بالانتظار';

  @override
  String get statusCompleted => 'مكتملة';

  @override
  String get statusReceived => 'مُستلمة';

  @override
  String get statusDiagnosing => 'تشخيص';

  @override
  String get statusDelivered => 'مُسلّمة';

  @override
  String get statusCancelled => 'ملغاة';

  @override
  String repairEventStatus(Object status) {
    return 'الحالة: $status';
  }

  @override
  String repairEventTech(Object tech) {
    return 'أُسندت إلى $tech';
  }

  @override
  String get repairEventTechCleared => 'أُزيل الفني';

  @override
  String repairEventPayment(Object status) {
    return 'الدفع: $status';
  }

  @override
  String get repairTimeline => 'المتابعة';

  @override
  String get repairNotify => 'إشعار العميل';

  @override
  String get notifyTemplate => 'قالب';

  @override
  String get notifyMessage => 'رسالة';

  @override
  String get notifySend => 'إرسال';

  @override
  String get notifyNoContact => 'لا توجد جهة اتصال لهذه القناة';

  @override
  String get repairSectionComms => 'المراسلات';

  @override
  String get repairAdvance => 'تقديم';

  @override
  String get clientsTitle => 'العملاء';

  @override
  String get clientsNew => 'عميل جديد';

  @override
  String get clientsSearch => 'ابحث عن عميل';

  @override
  String get clientsEmpty => 'لا يوجد عملاء مسجلون';

  @override
  String get clientsEmptySubtitle => 'أضف عميلاً للبدء.';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsAppearance => 'المظهر';

  @override
  String get settingsThemeMode => 'السمة';

  @override
  String get settingsThemeLight => 'فاتح';

  @override
  String get settingsThemeDark => 'داكن';

  @override
  String get settingsThemeSystem => 'النظام';

  @override
  String get settingsAccent => 'لون التمييز';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsGeneral => 'عام';

  @override
  String get settingsWorkshopInfo => 'معلومات الورشة';

  @override
  String get settingsWorkshopInfoSubtitle => 'الاسم، العنوان، بيانات الاتصال';

  @override
  String get settingsAbout => 'حول';

  @override
  String get settingsAboutDescription => 'تطبيق إدارة لورشة الإصلاح.';

  @override
  String get languageSystem => 'تلقائي';

  @override
  String get languageFrench => 'الفرنسية';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageSpanish => 'الإسبانية';

  @override
  String get accentBlue => 'أزرق';

  @override
  String get accentGreen => 'أخضر';

  @override
  String get accentOrange => 'برتقالي';

  @override
  String get accentRed => 'أحمر';

  @override
  String get accentIndigo => 'نيلي';

  @override
  String get accentPurple => 'بنفسجي';

  @override
  String get accentTeal => 'فيروزي';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonDone => 'تم';

  @override
  String get commonSeeAll => 'عرض الكل';

  @override
  String get commonShowLess => 'عرض أقل';

  @override
  String get commonSearch => 'بحث';

  @override
  String get repairsFilterAll => 'الكل';

  @override
  String get repairPriority => 'الأولوية';

  @override
  String get repairPriorityLow => 'منخفضة';

  @override
  String get repairPriorityNormal => 'عادية';

  @override
  String get repairPriorityHigh => 'عالية';

  @override
  String repairUpdated(String when) {
    return 'آخر تحديث $when';
  }

  @override
  String get repairDetailSelectTitle => 'لم يتم تحديد إصلاح';

  @override
  String get repairDetailSelectSubtitle => 'اختر إصلاحًا لعرض التفاصيل.';

  @override
  String get repairSectionClient => 'العميل';

  @override
  String get repairSectionProgress => 'التقدم';

  @override
  String get repairSectionTimeline => 'المتابعة';

  @override
  String get repairSectionParts => 'القطع';

  @override
  String get repairSectionNotes => 'ملاحظات';

  @override
  String get repairCost => 'التكلفة التقديرية';

  @override
  String get repairMarkComplete => 'وضع علامة مكتمل';

  @override
  String get repairContactClient => 'الاتصال بالعميل';

  @override
  String get repairEventCreated => 'تم إنشاء التذكرة';

  @override
  String get repairEventDiagnosed => 'تم التشخيص';

  @override
  String get repairEventInRepair => 'الإصلاح قيد التنفيذ';

  @override
  String get repairEventCompleted => 'اكتمل الإصلاح';

  @override
  String get repairNoParts => 'لا توجد قطع مسجلة';

  @override
  String get repairNoNotes => 'لا توجد ملاحظات';

  @override
  String get repairSort => 'ترتيب';

  @override
  String get repairSortRecent => 'الأحدث';

  @override
  String get repairSortPriority => 'الأولوية';

  @override
  String get repairSortCost => 'التكلفة';

  @override
  String get repairFilters => 'عوامل التصفية';

  @override
  String get repairFilterDeviceTitle => 'نوع الجهاز';

  @override
  String get repairFilterAny => 'الكل';

  @override
  String get repairActiveOnly => 'النشطة فقط';

  @override
  String get repairFiltersReset => 'إعادة تعيين';

  @override
  String get repairFiltersApply => 'تطبيق';

  @override
  String get deviceKindPhone => 'هاتف';

  @override
  String get deviceKindLaptop => 'حاسوب محمول';

  @override
  String get deviceKindTablet => 'جهاز لوحي';

  @override
  String get deviceKindWatch => 'ساعة';

  @override
  String get deviceKindOther => 'أخرى';

  @override
  String get navDevices => 'الأجهزة';

  @override
  String get navPlanning => 'الجدولة';

  @override
  String get navQuotes => 'عروض الأسعار';

  @override
  String get navInvoices => 'الفواتير';

  @override
  String get navPayments => 'المدفوعات';

  @override
  String get navAccounting => 'المحاسبة';

  @override
  String get navInventory => 'المخزون';

  @override
  String get navCatalog => 'الكتالوج';

  @override
  String get navSuppliers => 'الموردون';

  @override
  String get navOrders => 'الطلبات';

  @override
  String get navStaff => 'الموظفون';

  @override
  String get navUsers => 'المستخدمون';

  @override
  String get navReports => 'التقارير';

  @override
  String get navAssistant => 'المساعد الذكي';

  @override
  String get navGroupMain => 'الرئيسية';

  @override
  String get navGroupFinance => 'المالية';

  @override
  String get navGroupStock => 'المخزون';

  @override
  String get navGroupManagement => 'الإدارة';

  @override
  String get navGroupSystem => 'النظام';

  @override
  String get navMore => 'المزيد';

  @override
  String get comingSoonTitle => 'قريبًا';

  @override
  String get comingSoonSubtitle => 'هذا القسم قيد الإنشاء.';

  @override
  String get catalogSearch => 'ابحث عن منتج';

  @override
  String get catalogEmpty => 'لا توجد منتجات';

  @override
  String get catalogEmptySubtitle => 'أضف قطع الغيار والملحقات والخدمات.';

  @override
  String get variantsLabel => 'المتغيرات';

  @override
  String get productNew => 'منتج جديد';

  @override
  String get productName => 'اسم المنتج';

  @override
  String get productBrand => 'العلامة التجارية';

  @override
  String get productCategory => 'الفئة';

  @override
  String get productVariants => 'المتغيرات';

  @override
  String get priceLabel => 'السعر';

  @override
  String get stockLabel => 'المخزون';

  @override
  String get skuLabel => 'المرجع';

  @override
  String get categoryPart => 'قطعة';

  @override
  String get categoryAccessory => 'ملحق';

  @override
  String get categoryService => 'خدمة';

  @override
  String get serviceCatDiagnostic => 'تشخيص';

  @override
  String get serviceCatScreen => 'شاشة';

  @override
  String get serviceCatBattery => 'بطارية';

  @override
  String get serviceCatSoftware => 'برمجيات';

  @override
  String get serviceCatData => 'بيانات';

  @override
  String get serviceCatOther => 'أخرى';

  @override
  String get navServices => 'الخدمات';

  @override
  String get servicesSearch => 'ابحث عن خدمة';

  @override
  String get servicesEmpty => 'لا توجد خدمات';

  @override
  String get servicesEmptySubtitle => 'أضف خدماتك وأسعارها.';

  @override
  String get serviceCategoryHeader => 'الفئة';

  @override
  String get serviceDurationLabel => 'المدة';

  @override
  String get serviceMargin => 'الهامش';

  @override
  String get serviceNew => 'خدمة جديدة';

  @override
  String get serviceEdit => 'تعديل الخدمة';

  @override
  String get serviceDescription => 'الوصف';

  @override
  String get serviceCost => 'التكلفة';

  @override
  String get serviceDelete => 'حذف الخدمة';

  @override
  String get serviceDeleteConfirm => 'حذف هذه الخدمة؟';

  @override
  String get serviceAddToCatalog => 'أضف إلى الكتالوج';

  @override
  String get navCategories => 'الفئات';

  @override
  String get categoryNew => 'فئة جديدة';

  @override
  String get categorySubNew => 'فئة فرعية جديدة';

  @override
  String get categoryIcon => 'أيقونة';

  @override
  String get categoryColor => 'لون';

  @override
  String get categoryDelete => 'حذف الفئة';

  @override
  String get categoryDeleteConfirm => 'حذف هذه الفئة؟';

  @override
  String get categoryReassign => 'نقل الخدمات إلى';

  @override
  String get categoryAddSub => 'إضافة فئة فرعية';

  @override
  String get categoryMoveServices => 'نقل الخدمات';

  @override
  String get categoryMoveProducts => 'نقل المنتجات';

  @override
  String get categoryReassignProducts => 'نقل المنتجات إلى';

  @override
  String get productEdit => 'تعديل المنتج';

  @override
  String get categorySelect => 'اختر فئة';

  @override
  String get taxonomyRoot => 'الجذر';

  @override
  String get taxonomyCode => 'رمز';

  @override
  String get taxonomyDescription => 'وصف';

  @override
  String get taxonomyParent => 'الفئة الأصل';

  @override
  String get taxonomyReassign => 'نقل العناصر إلى';

  @override
  String get taxonomyMergeInto => 'دمج مع…';

  @override
  String get taxonomyMoveItems => 'نقل العناصر';

  @override
  String get taxonomyCodeTaken => 'هذا الرمز مستخدم بالفعل';

  @override
  String get taxonomyShowArchived => 'إظهار المؤرشفة';

  @override
  String get taxonomyEmpty => 'لا توجد فئات';

  @override
  String get taxonomySearch => 'ابحث عن فئة';

  @override
  String get taxonomyExpandAll => 'توسيع الكل';

  @override
  String get taxonomyCollapseAll => 'طي الكل';

  @override
  String get supplierProducts => 'المنتجات المورّدة';

  @override
  String get supplierOrderedProducts => 'طُلبت سابقًا (غير مرتبطة)';

  @override
  String get supplierLinkProduct => 'ربط';

  @override
  String get inventoryReorder => 'طلب';

  @override
  String get inventoryNoSupplier => 'لا يوجد مورّد مرتبط بهذا المنتج';

  @override
  String get supplierInUse =>
      'المورّد مُشار إليه (منتجات أو طلبات) — لا يمكن الحذف';

  @override
  String get supplierDeleteConfirm => 'حذف هذا المورّد؟';

  @override
  String get commonOk => 'حسنًا';

  @override
  String get sourcingPurchasePrice => 'سعر الشراء';

  @override
  String get sourcingPreferred => 'مفضّل';

  @override
  String get sourcingBestPrice => 'أفضل سعر';

  @override
  String get productFacets => 'السمات';

  @override
  String get smartViews => 'قوائم ذكية';

  @override
  String get smartViewNew => 'قائمة ذكية جديدة';

  @override
  String get smartRule => 'قاعدة';

  @override
  String get smartStock => 'المخزون';

  @override
  String get smartPriceMax => 'السعر الأقصى';

  @override
  String get smartPriceMin => 'السعر الأدنى';

  @override
  String get smartAny => 'الكل';

  @override
  String get catalogManage => 'إدارة';

  @override
  String get serviceDuplicate => 'تكرار';

  @override
  String get serviceCopySuffix => '(نسخة)';

  @override
  String get variantNew => 'متغير جديد';

  @override
  String get variantLabel => 'التسمية (مثل: أسود · أصلي)';

  @override
  String variantCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count متغير',
      many: '$count متغيرًا',
      few: '$count متغيرات',
      two: 'متغيران',
      one: 'متغير واحد',
      zero: 'لا متغيرات',
    );
    return '$_temp0';
  }

  @override
  String stockUnits(int count) {
    return '$count في المخزون';
  }

  @override
  String get addLabel => 'إضافة';

  @override
  String get repairSectionServices => 'الخدمات';

  @override
  String get repairNoServices => 'لا توجد خدمات';

  @override
  String get repairServicesTotal => 'إجمالي الخدمات';

  @override
  String get repairSectionObservations => 'المعاينة';

  @override
  String get repairNoObservations => 'لا توجد معاينة';

  @override
  String get paymentUnpaid => 'غير مدفوع';

  @override
  String get paymentPartial => 'جزئي';

  @override
  String get paymentPaid => 'مدفوع';

  @override
  String get repairSectionProblem => 'المشكلة';

  @override
  String get repairReported => 'العطل المبلّغ عنه';

  @override
  String get repairDiagnosis => 'التشخيص';

  @override
  String get repairWorkDone => 'العمل المنجز';

  @override
  String get repairSectionDevice => 'الجهاز';

  @override
  String get deviceModel => 'الطراز';

  @override
  String get deviceColor => 'اللون';

  @override
  String get deviceStorage => 'السعة التخزينية';

  @override
  String get deviceAccessories => 'الملحقات';

  @override
  String get repairIntakeCondition => 'الحالة عند الاستلام';

  @override
  String get devicePasscode => 'رمز الفتح';

  @override
  String get backupConsent => 'الموافقة على النسخ الاحتياطي';

  @override
  String get repairSectionFinance => 'المالية';

  @override
  String get financeLabour => 'أجرة العمل';

  @override
  String get financeDiscount => 'الخصم';

  @override
  String get financeTax => 'الضريبة';

  @override
  String get financeSubtotal => 'المجموع الفرعي';

  @override
  String get financeTotal => 'الإجمالي';

  @override
  String get financeDeposit => 'العربون';

  @override
  String get financeBalance => 'المبلغ المتبقي';

  @override
  String get repairSectionLogistics => 'المتابعة واللوجستيك';

  @override
  String get repairAssignedTech => 'الفني';

  @override
  String get repairCreatedBy => 'استلمها';

  @override
  String get repairLocation => 'الموقع';

  @override
  String get repairWarranty => 'الضمان';

  @override
  String get repairUnderWarranty => 'تحت الضمان';

  @override
  String get repairWarrantyExpired => 'انتهى الضمان';

  @override
  String repairWarrantyUntil(Object date) {
    return 'حتى $date';
  }

  @override
  String warrantyDuration(int count) {
    return '$count أشهر';
  }

  @override
  String get repairDue => 'الاستحقاق';

  @override
  String get repairOverdue => 'متأخر';

  @override
  String get repairPhotos => 'الصور';

  @override
  String get repairPhotoAdded => 'تمت إضافة الصورة';

  @override
  String get repairPhotoRemove => 'حذف هذه الصورة؟';

  @override
  String get repairEventPhoto => 'تمت إضافة صورة';

  @override
  String get actionCall => 'اتصال';

  @override
  String get actionSms => 'رسالة';

  @override
  String get actionWhatsapp => 'واتساب';

  @override
  String get actionEmail => 'بريد';

  @override
  String get actionEdit => 'تعديل';

  @override
  String get editMode => 'وضع التعديل';

  @override
  String get actionReopen => 'إعادة فتح';

  @override
  String get actionAssign => 'تعيين فني';

  @override
  String get actionAddPhoto => 'إضافة صورة';

  @override
  String get actionPrintLabel => 'طباعة الملصق';

  @override
  String get repairPrintChoose => 'طباعة';

  @override
  String get repairSheetTitle => 'بطاقة الإصلاح';

  @override
  String get repairTicketTitle => 'تذكرة';

  @override
  String get repairSignatureClient => 'توقيع العميل';

  @override
  String get repairSignatureTech => 'توقيع الفني';

  @override
  String get repairTicketFooter => 'قدّم هذه التذكرة لاستلام الجهاز.';

  @override
  String get unitMonths => 'أشهر';

  @override
  String get repairScan => 'مسح';

  @override
  String get repairScanHint => 'ضع رمز QR الخاص بالإصلاح داخل الإطار';

  @override
  String get repairScanManual => 'إدخال المرجع';

  @override
  String get repairScanReference => 'المرجع';

  @override
  String get repairScanOpen => 'فتح';

  @override
  String get repairScanNotFound => 'الإصلاح غير موجود';

  @override
  String get repairScanUnavailable => 'المسح بالكاميرا غير متاح على هذه المنصة';

  @override
  String get repairScanFromImage => 'فك الترميز من صورة';

  @override
  String get repairScanError => 'تعذّر فك ترميز رمز QR';

  @override
  String get repairScanCameraError => 'الكاميرا غير متاحة (تم رفض الإذن؟)';

  @override
  String get actionGenerateInvoice => 'إنشاء فاتورة';

  @override
  String get actionDelete => 'حذف';

  @override
  String get statusLabel => 'الحالة';

  @override
  String get qtyShort => 'الكمية';

  @override
  String get unitPriceShort => 'سعر الوحدة';

  @override
  String get addPrestation => 'إضافة خدمة';

  @override
  String get addPart => 'إضافة قطعة';

  @override
  String get unassigned => 'غير معيّن';

  @override
  String get notProvided => 'غير محدد';

  @override
  String get clientSectionContact => 'معلومات الاتصال';

  @override
  String get supplierNew => 'مورد جديد';

  @override
  String get supplierSearch => 'ابحث عن مورد';

  @override
  String get supplierEmpty => 'لا يوجد موردون';

  @override
  String get supplierEmptySubtitle => 'أضف موردًا للبدء.';

  @override
  String get supplierType => 'النوع';

  @override
  String get supplierTypeCompany => 'شركة';

  @override
  String get supplierTypeIndividual => 'فرد';

  @override
  String get supplierName => 'الاسم / الشركة';

  @override
  String get supplierContactName => 'جهة الاتصال';

  @override
  String get supplierVat => 'الرقم الضريبي';

  @override
  String get supplierCity => 'المدينة';

  @override
  String get supplierTerms => 'شروط الدفع';

  @override
  String get supplierSectionCompany => 'الشركة';

  @override
  String get fieldName => 'الاسم';

  @override
  String get clientTypeIndividual => 'فرد';

  @override
  String get clientTypeCompany => 'شركة';

  @override
  String get clientCompanyName => 'اسم الشركة';

  @override
  String get clientVat => 'الرقم الضريبي';

  @override
  String get clientCity => 'المدينة';

  @override
  String get clientSectionCompany => 'الشركة';

  @override
  String get clientSectionHistory => 'سجل الإصلاحات';

  @override
  String get staffNew => 'موظف جديد';

  @override
  String get staffSearch => 'ابحث عن موظف';

  @override
  String get staffEmpty => 'لا يوجد موظفون';

  @override
  String get staffEmptySubtitle => 'أضف موظفًا للبدء.';

  @override
  String get staffJobTitle => 'المنصب';

  @override
  String get staffHireDate => 'تاريخ التوظيف';

  @override
  String get staffCommission => 'العمولة (%)';

  @override
  String get staffActive => 'نشط';

  @override
  String get staffInactive => 'غير نشط';

  @override
  String get staffSectionEmployment => 'التوظيف';

  @override
  String get staffAssignedRepairs => 'الإصلاحات المسندة';

  @override
  String get authLoginTitle => 'تسجيل الدخول';

  @override
  String get authPassword => 'كلمة المرور';

  @override
  String get authPin => 'رمز PIN';

  @override
  String get authSignIn => 'تسجيل الدخول';

  @override
  String get authLogout => 'تسجيل الخروج';

  @override
  String get authError => 'بيانات اعتماد غير صحيحة';

  @override
  String get authModeEmail => 'البريد';

  @override
  String get authModePin => 'PIN';

  @override
  String get userNew => 'مستخدم جديد';

  @override
  String get userSearch => 'ابحث عن مستخدم';

  @override
  String get userEmpty => 'لا يوجد مستخدمون';

  @override
  String get userEmptySubtitle => 'أضف حسابًا للبدء.';

  @override
  String get listNoResults => 'لا نتائج';

  @override
  String get listNoResultsSubtitle => 'عدّل البحث أو عوامل التصفية.';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get profileSubtitle => 'حسابك وأمانك';

  @override
  String get profileAccount => 'الحساب';

  @override
  String get profileSecurity => 'الأمان';

  @override
  String get profileLinkedEmployee => 'الموظف المرتبط';

  @override
  String get profileChangePassword => 'تغيير كلمة المرور';

  @override
  String get profileChangePin => 'تغيير رمز PIN';

  @override
  String get profileCurrentPassword => 'كلمة المرور الحالية';

  @override
  String get profileNewPassword => 'كلمة مرور جديدة';

  @override
  String get profileConfirm => 'تأكيد';

  @override
  String get profileNewPin => 'رمز PIN جديد';

  @override
  String get profilePasswordChanged => 'تم تغيير كلمة المرور';

  @override
  String get profilePinChanged => 'تم تغيير رمز PIN';

  @override
  String get profileWrongPassword => 'كلمة المرور الحالية غير صحيحة';

  @override
  String get profilePasswordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get accountEmailTaken => 'هذا البريد الإلكتروني مستخدم بالفعل';

  @override
  String get accountPinTaken => 'رمز PIN هذا مستخدم بالفعل';

  @override
  String get accountLastAdmin => 'يلزم وجود مسؤول نشط واحد على الأقل';

  @override
  String get accountEventLogin => 'تسجيل الدخول';

  @override
  String get accountEventLogout => 'تسجيل الخروج';

  @override
  String get accountEventFailedLogin => 'فشل تسجيل الدخول';

  @override
  String get accountEventCreated => 'تم إنشاء الحساب';

  @override
  String get accountEventUpdated => 'تم تعديل الحساب';

  @override
  String get accountEventRoleChanged => 'تم تغيير الدور';

  @override
  String get accountEventDeactivated => 'تم تعطيل الحساب';

  @override
  String get accountEventReactivated => 'تمت إعادة تفعيل الحساب';

  @override
  String get accountEventPasswordReset => 'إعادة تعيين كلمة المرور';

  @override
  String get accountEventPinReset => 'إعادة تعيين PIN';

  @override
  String get accountEventInvited => 'تم إرسال الدعوة';

  @override
  String get accountEventDeleted => 'تم حذف الحساب';

  @override
  String get accountActivity => 'النشاط';

  @override
  String get accountLog => 'سجل الحسابات';

  @override
  String get accountCreatedAt => 'أُنشئ في';

  @override
  String get accountLastLogin => 'آخر تسجيل دخول';

  @override
  String get accountNeverLoggedIn => 'لم يسجّل الدخول قط';

  @override
  String get accountActionsTitle => 'إجراءات';

  @override
  String get accountResetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get accountResetPin => 'إعادة تعيين PIN';

  @override
  String get accountInvite => 'دعوة (تجريبي)';

  @override
  String get accountDelete => 'حذف الحساب';

  @override
  String get accountDeleteConfirm => 'حذف هذا الحساب نهائيًا؟';

  @override
  String get accountTempSecret => 'سر مؤقت (تجريبي)';

  @override
  String get accountInvitePending => 'دعوة قيد الانتظار';

  @override
  String get navIntegrations => 'التكاملات';

  @override
  String get integrationsSubtitle => 'المدفوعات، البريد، المراسلة…';

  @override
  String get integrationsSummary => 'الخدمات المتصلة';

  @override
  String get integrationsSearch => 'ابحث عن تكامل';

  @override
  String get integrationEnable => 'تفعيل';

  @override
  String get integrationTest => 'اختبار';

  @override
  String get integrationComingSoon => 'الاتصال المباشر قريبًا';

  @override
  String get integrationConnectAccount => 'ربط الحساب';

  @override
  String get integrationConnected => 'تم ربط الحساب';

  @override
  String get integrationDisconnect => 'إلغاء الربط';

  @override
  String get integrationValid => 'الإعداد صالح';

  @override
  String get integrationCheckNotConnected => 'الحساب غير مربوط';

  @override
  String get integrationCheckEmail => 'عنوان بريد إلكتروني غير صالح';

  @override
  String integrationCheckMissing(Object field) {
    return 'حقل مطلوب مفقود: $field';
  }

  @override
  String integrationCheckUrl(Object field) {
    return 'رابط غير صالح: $field';
  }

  @override
  String integrationCheckShort(Object field) {
    return 'القيمة قصيرة جدًا: $field';
  }

  @override
  String get integrationCatPayments => 'المدفوعات';

  @override
  String get integrationCatMessaging => 'المراسلة';

  @override
  String get integrationCatCloud => 'السحابة والبريد';

  @override
  String get integrationCatAutomation => 'الأتمتة';

  @override
  String get integrationDescOutlook => 'إرسال الفواتير عبر Outlook';

  @override
  String get integrationDescOnedrive => 'نسخ احتياطي إلى OneDrive';

  @override
  String get integrationDescTelegram => 'إشعارات عبر بوت تيليجرام';

  @override
  String get integrationDescTeams => 'تنبيهات في قناة Teams';

  @override
  String get integrationDescSlack => 'تنبيهات في قناة Slack';

  @override
  String get integrationDescZapier => 'الأتمتة عبر webhook من Zapier';

  @override
  String get integrationFieldBotToken => 'رمز البوت';

  @override
  String get integrationFieldChatId => 'معرّف المحادثة';

  @override
  String get integrationFieldWebhookUrl => 'رابط webhook';

  @override
  String get integrationDescApplepay => 'الدفع عبر Apple Pay';

  @override
  String get integrationDescIcloud => 'نسخ احتياطي على iCloud';

  @override
  String get integrationDescApplemsg => 'الرسائل للأعمال (iMessage)';

  @override
  String get integrationFieldMerchantId => 'معرّف تاجر Apple';

  @override
  String get integrationFieldBusinessId => 'معرّف Apple Business';

  @override
  String get integrationStatusActive => 'نشط';

  @override
  String get integrationStatusDisabled => 'معطّل';

  @override
  String get integrationStatusNotConfigured => 'غير مُهيّأ';

  @override
  String get integrationDescFlouci => 'دفع بالمحفظة والبطاقات (CIB/Visa/MC)';

  @override
  String get integrationDescKonnect => 'دفع بالبطاقة عبر الإنترنت';

  @override
  String get integrationDescClictopay => 'دفع بالبطاقة البنكية (SMT)';

  @override
  String get integrationDescStripe => 'بطاقات دولية';

  @override
  String get integrationDescDrive => 'نسخ احتياطي سحابي';

  @override
  String get integrationDescGmail => 'إرسال الفواتير بالبريد';

  @override
  String get integrationDescWhatsapp => 'رسائل واتساب آلية';

  @override
  String get integrationDescMessenger => 'الدردشة عبر ماسنجر';

  @override
  String get integrationDescSms => 'إشعارات SMS';

  @override
  String get integrationFieldApiKey => 'مفتاح API';

  @override
  String get integrationFieldSecretKey => 'المفتاح السري';

  @override
  String get integrationFieldPrivateToken => 'الرمز الخاص';

  @override
  String get integrationFieldAppId => 'معرّف التطبيق';

  @override
  String get integrationFieldWalletId => 'معرّف المحفظة';

  @override
  String get integrationFieldMerchantUser => 'معرّف التاجر';

  @override
  String get integrationFieldMerchantPassword => 'كلمة مرور التاجر';

  @override
  String get integrationFieldAppPassword => 'كلمة مرور التطبيق';

  @override
  String get integrationFieldPhoneId => 'معرّف الرقم';

  @override
  String get integrationFieldAccessToken => 'رمز الوصول';

  @override
  String get integrationFieldPageLink => 'رابط الصفحة';

  @override
  String get integrationFieldSender => 'المُرسِل';

  @override
  String get userRole => 'الدور';

  @override
  String get userLinkedEmployee => 'الموظف المرتبط';

  @override
  String get userNoEmployee => 'لا أحد';

  @override
  String get userNewPassword => 'كلمة مرور جديدة';

  @override
  String get userNewPin => 'رمز PIN جديد';

  @override
  String get roleAdmin => 'مدير';

  @override
  String get roleTechnician => 'فني';

  @override
  String get roleCashier => 'الصندوق';

  @override
  String get orderNew => 'طلب جديد';

  @override
  String get orderSearch => 'ابحث عن طلب';

  @override
  String get orderEmpty => 'لا توجد طلبات';

  @override
  String get orderEmptySubtitle => 'أنشئ طلب مورد.';

  @override
  String get orderStatusDraft => 'مسودة';

  @override
  String get orderStatusOrdered => 'تم الطلب';

  @override
  String get orderStatusReceived => 'تم الاستلام';

  @override
  String get orderStatusCancelled => 'ملغى';

  @override
  String get orderSupplier => 'المورد';

  @override
  String get orderExpectedDate => 'التسليم المتوقع';

  @override
  String get orderReceive => 'استلام';

  @override
  String get orderPaid => 'المدفوع';

  @override
  String get orderBalanceDue => 'المتبقّي';

  @override
  String get orderAddPayment => 'تسجيل دفعة';

  @override
  String get orderAddLine => 'إضافة عنصر';

  @override
  String get orderSectionLines => 'العناصر';

  @override
  String get orderNoLines => 'لا توجد عناصر';

  @override
  String get orderSubtotal => 'المجموع الفرعي';

  @override
  String get orderTax => 'ضريبة';

  @override
  String get orderTotal => 'الإجمالي';

  @override
  String get productPickTitle => 'اختر منتجًا';

  @override
  String get quoteNew => 'عرض سعر جديد';

  @override
  String get quoteSearch => 'ابحث عن عرض سعر';

  @override
  String get quoteEmpty => 'لا توجد عروض أسعار';

  @override
  String get quoteEmptySubtitle => 'أنشئ عرض سعر للعميل.';

  @override
  String get quoteStatusDraft => 'مسودة';

  @override
  String get quoteStatusSent => 'مُرسل';

  @override
  String get quoteStatusAccepted => 'مقبول';

  @override
  String get quoteStatusRefused => 'مرفوض';

  @override
  String get quoteStatusExpired => 'منتهٍ';

  @override
  String get quoteValidUntil => 'صالح حتى';

  @override
  String get quoteAddService => 'إضافة خدمة';

  @override
  String get quoteAddPart => 'إضافة قطعة';

  @override
  String get quoteSectionLines => 'التفاصيل';

  @override
  String get quoteExportPdf => 'تصدير PDF';

  @override
  String get quoteSend => 'إرسال';

  @override
  String get quoteAccept => 'قبول';

  @override
  String get quoteRefuse => 'رفض';

  @override
  String get colDesignation => 'الوصف';

  @override
  String get colQty => 'الكمية';

  @override
  String get colUnitPrice => 'سعر الوحدة';

  @override
  String get colLineTotal => 'المجموع';

  @override
  String get invoiceNew => 'فاتورة جديدة';

  @override
  String get invoiceSearch => 'ابحث عن فاتورة';

  @override
  String get invoiceEmpty => 'لا توجد فواتير';

  @override
  String get invoiceEmptySubtitle => 'أنشئ فاتورة.';

  @override
  String get invoiceStatusDraft => 'مسودة';

  @override
  String get invoiceStatusIssued => 'صادرة';

  @override
  String get invoiceStatusPartial => 'جزئية';

  @override
  String get invoiceStatusPaid => 'مدفوعة';

  @override
  String get invoiceStatusOverdue => 'متأخرة';

  @override
  String get invoiceStatusCancelled => 'ملغاة';

  @override
  String get invoiceIssue => 'إصدار';

  @override
  String get creditNote => 'إشعار دائن';

  @override
  String get creditNotes => 'إشعارات دائنة';

  @override
  String get creditNoteNew => 'إنشاء إشعار دائن';

  @override
  String get creditNoteIssue => 'إصدار الإشعار';

  @override
  String get creditNoteReason => 'السبب';

  @override
  String get creditNoteEmpty => 'لا توجد إشعارات';

  @override
  String get invoiceDueDate => 'تاريخ الاستحقاق';

  @override
  String get invoiceDeposit => 'عربون';

  @override
  String get invoiceBalance => 'الرصيد المستحق';

  @override
  String get invoiceSectionPayments => 'المدفوعات';

  @override
  String get invoiceRecordPayment => 'تسجيل دفعة';

  @override
  String get invoiceNoPayments => 'لا مدفوعات';

  @override
  String get invoiceAmount => 'المبلغ';

  @override
  String get paymentMethodCash => 'نقدًا';

  @override
  String get paymentMethodCard => 'بطاقة';

  @override
  String get paymentMethodTransfer => 'تحويل';

  @override
  String get paymentMethodCheck => 'شيك';

  @override
  String get paymentMethodCredit => 'رصيد';

  @override
  String get quoteConvertInvoice => 'تحويل إلى فاتورة';

  @override
  String get invoiceFromRepair => 'إنشاء فاتورة';

  @override
  String get fieldPhone => 'الهاتف';

  @override
  String get fieldEmail => 'البريد الإلكتروني';

  @override
  String get fieldAddress => 'العنوان';

  @override
  String get fieldWhatsapp => 'واتساب';

  @override
  String get fieldTelegram => 'تيليجرام';

  @override
  String get fieldSecondaryPhone => 'هاتف ثانوي';

  @override
  String get fieldWebsite => 'الموقع الإلكتروني';

  @override
  String get fieldInstagram => 'إنستغرام';

  @override
  String get clientSectionSocial => 'الويب والتواصل';

  @override
  String get actionWebsite => 'فتح الموقع';

  @override
  String get actionInstagram => 'فتح إنستغرام';

  @override
  String get contactKindTitle => 'نوع جهة الاتصال';

  @override
  String get contactKindMobile => 'جوال';

  @override
  String get contactKindLandline => 'هاتف ثابت';

  @override
  String get contactKindWhatsapp => 'واتساب';

  @override
  String get contactKindTelegram => 'تيليجرام';

  @override
  String get contactKindEmail => 'بريد إلكتروني';

  @override
  String get contactKindWebsite => 'موقع إلكتروني';

  @override
  String get contactKindInstagram => 'إنستغرام';

  @override
  String get contactKindFacebook => 'فيسبوك';

  @override
  String get contactKindLinkedin => 'لينكدإن';

  @override
  String get contactKindX => 'إكس (تويتر)';

  @override
  String get contactKindSnapchat => 'سناب شات';

  @override
  String get contactKindTiktok => 'تيك توك';

  @override
  String get contactKindSignal => 'سيغنال';

  @override
  String get contactKindWechat => 'وي شات';

  @override
  String get contactKindMessenger => 'ماسنجر';

  @override
  String get contactKindViber => 'فايبر';

  @override
  String get contactKindLine => 'لاين';

  @override
  String get contactKindFax => 'فاكس';

  @override
  String get contactKindYoutube => 'يوتيوب';

  @override
  String get contactKindTeams => 'تيمز';

  @override
  String get contactKindOther => 'أخرى';

  @override
  String get clientAddContact => 'إضافة جهة اتصال';

  @override
  String get clientOtherContacts => 'جهات اتصال أخرى';

  @override
  String get clientOtherAddresses => 'عناوين أخرى';

  @override
  String get clientSectionAddresses => 'العناوين';

  @override
  String get addressMain => 'العنوان الرئيسي';

  @override
  String get clientAddAddress => 'إضافة عنوان';

  @override
  String get addressKindTitle => 'نوع العنوان';

  @override
  String get addressKindHome => 'المنزل';

  @override
  String get addressKindWork => 'العمل';

  @override
  String get addressKindBilling => 'الفوترة';

  @override
  String get addressKindShipping => 'الشحن';

  @override
  String get addressKindOther => 'أخرى';

  @override
  String get clientStatInvoiced => 'مفوتر';

  @override
  String get clientStatOutstanding => 'غير مدفوع';

  @override
  String get clientStatRepairs => 'الإصلاحات';

  @override
  String get clientSectionInvoices => 'الفواتير';

  @override
  String get clientSectionQuotes => 'عروض الأسعار';

  @override
  String get clientLastActivity => 'آخر نشاط';

  @override
  String get clientNoDocuments => 'لا مستندات';

  @override
  String get clientNoActivity => 'لا يوجد نشاط بعد';

  @override
  String get clientNoInvoices => 'لا توجد فواتير';

  @override
  String get clientNoQuotes => 'لا توجد عروض أسعار';

  @override
  String get clientSettleAll => 'تحصيل الكل';

  @override
  String get clientCredit => 'الرصيد المتاح';

  @override
  String get clientNetBalance => 'الرصيد الصافي';

  @override
  String get clientStatementPdf => 'كشف حساب (PDF)';

  @override
  String get statementTitle => 'كشف حساب';

  @override
  String get statementDate => 'التاريخ';

  @override
  String get statementDetail => 'التفاصيل';

  @override
  String get statementDebit => 'مدين';

  @override
  String get statementCredit => 'دائن';

  @override
  String get statementBalance => 'الرصيد';

  @override
  String get statementOpening => 'الرصيد الافتتاحي';

  @override
  String get statementClosing => 'الرصيد الختامي';

  @override
  String get statementInvoice => 'فاتورة';

  @override
  String get statementDeposit => 'دفعة مقدمة';

  @override
  String get statementPayment => 'تسديد';

  @override
  String get colNumber => 'رقم';

  @override
  String get supplierStatementPdf => 'كشف حساب المورّد (PDF)';

  @override
  String get supplierStatementTitle => 'كشف حساب المورّد';

  @override
  String get supplierPurchased => 'المستلَم';

  @override
  String get supplierOnOrder => 'قيد الطلب';

  @override
  String get supplierOverdue => 'متأخر';

  @override
  String get supplierPayable => 'مستحقات';

  @override
  String get poAgeNotDue => 'غير مستحق';

  @override
  String get poAge1to30 => '1–30 يوم';

  @override
  String get poAge31to60 => '31–60 يوم';

  @override
  String get poAge60plus => '60+ يوم';

  @override
  String get clientAddDeposit => 'إضافة عربون';

  @override
  String get clientApplyCredit => 'تطبيق الرصيد';

  @override
  String get clientRefund => 'استرداد';

  @override
  String get chequeAdd => 'إضافة شيك';

  @override
  String get navRefunds => 'المستردات';

  @override
  String get refundsTotal => 'إجمالي المسترد';

  @override
  String get refundsEmpty => 'لا مستردات';

  @override
  String get refundsEmptySubtitle => 'ستظهر هنا المبالغ المستردة للعملاء.';

  @override
  String get financePeriodAll => 'الكل';

  @override
  String get financePeriodMonth => 'شهر';

  @override
  String get financePeriodQuarter => 'ربع';

  @override
  String get financePeriodYear => 'سنة';

  @override
  String get financePeriodCustom => 'مخصّص';

  @override
  String get filterAllClients => 'كل العملاء';

  @override
  String get paymentKindInvoice => 'فاتورة';

  @override
  String get paymentKindDeposit => 'عربون';

  @override
  String get paymentKindApplication => 'رصيد مُطبَّق';

  @override
  String get paymentKindRefund => 'استرداد';

  @override
  String get financeBreakdown => 'التوزيع';

  @override
  String get navCheques => 'الشيكات';

  @override
  String get chequeNumber => 'رقم الشيك';

  @override
  String get chequeBank => 'البنك';

  @override
  String get chequeDrawer => 'الساحب';

  @override
  String get chequeDueDate => 'تاريخ الاستحقاق';

  @override
  String get chequeStatusPending => 'للإيداع';

  @override
  String get chequeStatusDeposited => 'مودع';

  @override
  String get chequeStatusCleared => 'محصّل';

  @override
  String get chequeStatusBounced => 'مرتجع';

  @override
  String get chequesToCollect => 'شيكات للتحصيل';

  @override
  String get chequesEmpty => 'لا شيكات';

  @override
  String get chequesEmptySubtitle => 'ستظهر هنا الشيكات المستلمة.';

  @override
  String get chequeMarkDeposited => 'وضع كمودع';

  @override
  String get chequeMarkCleared => 'وضع كمحصّل';

  @override
  String get chequeBounceAction => 'رفض';

  @override
  String get clientSince => 'عميل منذ';

  @override
  String get clientTags => 'الوسوم';

  @override
  String get clientTagsHint => 'افصل بينها بفواصل';

  @override
  String get clientConsent => 'الموافقة التسويقية';

  @override
  String get clientBillingContact => 'جهة اتصال الفوترة';

  @override
  String get clientPaymentTerms => 'شروط الدفع';

  @override
  String get clientDiscount => 'الخصم المعتاد';

  @override
  String get clientCreditLimit => 'حد الائتمان';

  @override
  String clientDuplicateWarning(String name) {
    return 'يوجد عميل مشابه بالفعل: $name. الإنشاء على أي حال؟';
  }

  @override
  String get actionTelegram => 'تيليجرام';

  @override
  String get actionDirections => 'الاتجاهات';

  @override
  String get clientSelect => 'اختر عميلاً';

  @override
  String get settingsSectionLayout => 'التخطيط';

  @override
  String get settingsContentWidth => 'عرض المحتوى';

  @override
  String get contentNormal => 'عادي';

  @override
  String get contentStretch => 'كامل العرض';

  @override
  String get settingsSidebar => 'الشريط الجانبي';

  @override
  String get sidebarAdaptive => 'تكيّفي';

  @override
  String get sidebarExpanded => 'موسّع';

  @override
  String get settingsDetailView => 'عرض التفاصيل';

  @override
  String get settingsClientsView => 'عرض القوائم';

  @override
  String get settingsRegional => 'الإقليمي';

  @override
  String get settingsCurrency => 'العملة';

  @override
  String get settingsDateFormat => 'تنسيق التاريخ';

  @override
  String get clientsViewList => 'قائمة';

  @override
  String get clientsViewGrid => 'شبكة';

  @override
  String get clientsViewTable => 'جدول';

  @override
  String get fieldType => 'النوع';

  @override
  String get clientSegmentDebtors => 'المدينون';

  @override
  String get clientSegmentCredit => 'لديهم رصيد';

  @override
  String get clientSegmentInactive => 'غير نشطين';

  @override
  String get clientSegmentBusiness => 'شركات';

  @override
  String get clientSegmentRecent => 'جدد';

  @override
  String get detailAdaptive => 'تكيّفي';

  @override
  String get detailPane => 'لوحة جانبية';

  @override
  String get detailPage => 'صفحة منفصلة';

  @override
  String get prestationPickTitle => 'اختر خدمة';

  @override
  String get prestationSearch => 'ابحث عن خدمة';

  @override
  String get prestationManual => 'إدخال يدوي';
}
