// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Taller de Reparación';

  @override
  String get navDashboard => 'Panel';

  @override
  String get navRepairs => 'Reparaciones';

  @override
  String get navClients => 'Clientes';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get dashboardTitle => 'Panel';

  @override
  String get dashboardOverview => 'Resumen';

  @override
  String get dashboardRecentRepairs => 'Reparaciones recientes';

  @override
  String get dashboardActivity => 'Actividad';

  @override
  String get dashboardQuickActions => 'Acciones rápidas';

  @override
  String get dashboardNoRepairs => 'Sin reparaciones';

  @override
  String get dashboardNoRepairsSubtitle =>
      'Los nuevos tickets aparecerán aquí.';

  @override
  String get dashboardNotifications => 'Notificaciones';

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get notificationsRecent => 'Actividad reciente';

  @override
  String get statInProgress => 'En curso';

  @override
  String get statAwaitingParts => 'Esperando piezas';

  @override
  String get statCompleted => 'Completadas';

  @override
  String get statClients => 'Clientes';

  @override
  String get statRevenue => 'Ingresos';

  @override
  String get statUnpaid => 'Sin pagar';

  @override
  String get statAwaitingPartsShort => 'Piezas';

  @override
  String get reportsFinance => 'Finanzas';

  @override
  String get reportsCollected => 'Cobrado';

  @override
  String get reportsAcceptanceRate => 'Tasa de aceptación';

  @override
  String get reportsEmpty => 'Aún no hay datos';

  @override
  String get companyName => 'Nombre del establecimiento';

  @override
  String get companyPostalCode => 'Código postal';

  @override
  String get companySiret => 'ID fiscal';

  @override
  String get companyLogo => 'Logo';

  @override
  String get companyLogoAdd => 'Añadir un logo';

  @override
  String get companyLogoRemove => 'Quitar logo';

  @override
  String get paymentsEmpty => 'Sin pagos';

  @override
  String get paymentsEmptySubtitle => 'Los pagos registrados aparecerán aquí.';

  @override
  String get paymentsTotalCollected => 'Total cobrado';

  @override
  String get cashRegister => 'Caja';

  @override
  String get cashOpen => 'Abrir caja';

  @override
  String get cashClose => 'Cerrar caja';

  @override
  String get cashOpeningFloat => 'Fondo de caja';

  @override
  String get cashExpected => 'Efectivo esperado';

  @override
  String get cashCounted => 'Efectivo contado';

  @override
  String get cashVariance => 'Diferencia';

  @override
  String get cashClosed => 'Caja cerrada';

  @override
  String cashSince(Object time) {
    return 'Abierta desde $time';
  }

  @override
  String get inventoryOut => 'Sin stock';

  @override
  String get inventoryLow => 'Stock bajo';

  @override
  String get inventoryOk => 'En stock';

  @override
  String get inventoryEmpty => 'Sin artículos';

  @override
  String get inventoryEmptySubtitle => 'Añade productos al catálogo.';

  @override
  String get inventoryAlerts => 'Alertas de stock';

  @override
  String get planningOverdue => 'Atrasadas';

  @override
  String get planningToday => 'Hoy';

  @override
  String get planningTomorrow => 'Mañana';

  @override
  String get planningThisWeek => 'Esta semana';

  @override
  String get planningLater => 'Más tarde';

  @override
  String get planningNoDate => 'Sin fecha';

  @override
  String get planningEmpty => 'Nada programado';

  @override
  String get planningEmptySubtitle =>
      'Las reparaciones con fecha aparecerán aquí.';

  @override
  String get accountingHt => 'Base';

  @override
  String get accountingVat => 'IVA';

  @override
  String get accountingTtc => 'Total';

  @override
  String get accountingVatCollected => 'IVA repercutido';

  @override
  String get accountingVatDeductible => 'IVA soportado';

  @override
  String get accountingVatNet => 'IVA neto a pagar';

  @override
  String get vatBasisAccrual => 'Devengo';

  @override
  String get vatBasisCash => 'Caja';

  @override
  String get accountingPurchases => 'Compras (sin IVA)';

  @override
  String get accountingSupplierPaid => 'Pagado a proveedores';

  @override
  String get accountingSupplierPayable => 'Adeudado a proveedores';

  @override
  String get accountingMargin => 'Margen bruto';

  @override
  String get accountingResult => 'Resultado neto';

  @override
  String get expenses => 'Gastos';

  @override
  String get expenseNew => 'Nuevo gasto';

  @override
  String get expenseLabel => 'Concepto';

  @override
  String get expenseAmountHt => 'Importe sin IVA';

  @override
  String get expensesEmpty => 'Sin gastos';

  @override
  String get expenseCatRent => 'Alquiler';

  @override
  String get expenseCatUtilities => 'Suministros';

  @override
  String get expenseCatSupplies => 'Materiales';

  @override
  String get expenseCatMarketing => 'Marketing';

  @override
  String get expenseCatTransport => 'Transporte';

  @override
  String get expenseCatSalaries => 'Salarios';

  @override
  String get expenseCatTax => 'Impuestos';

  @override
  String get expenseCatOther => 'Otro';

  @override
  String get accountingVatSection => 'IVA y compras';

  @override
  String get accountingEmpty => 'Sin facturas emitidas';

  @override
  String get settingsBackup => 'Copia y exportación';

  @override
  String get settingsBackupSubtitle => 'Exporta o restaura tus datos';

  @override
  String get backupExport => 'Exportar datos (JSON)';

  @override
  String get backupImport => 'Importar una copia';

  @override
  String get backupExportCsvAccounting => 'Exportar contabilidad (CSV)';

  @override
  String get backupExportCsvClients => 'Exportar clientes (CSV)';

  @override
  String get backupDone => 'Datos exportados';

  @override
  String get backupImported => 'Datos importados';

  @override
  String get backupFailed => 'Operación fallida';

  @override
  String get devicesSearch => 'Buscar un dispositivo';

  @override
  String get devicesEmpty => 'Sin dispositivos';

  @override
  String get devicesEmptySubtitle =>
      'Los dispositivos de las reparaciones aparecerán aquí.';

  @override
  String get deviceRepairs => 'Reparaciones';

  @override
  String get deviceIdentity => 'Identidad';

  @override
  String get deviceOwner => 'Propietario';

  @override
  String get deviceSerial => 'IMEI / N.º de serie';

  @override
  String get deviceWarranty => 'Garantía';

  @override
  String get deviceHistory => 'Historial';

  @override
  String get assistantPlaceholder => 'Haz una pregunta sobre tu taller…';

  @override
  String get assistantNoKey =>
      'Añade tu clave API de Anthropic para activar el asistente.';

  @override
  String get assistantApiKey => 'Clave API de Anthropic';

  @override
  String get assistantModel => 'Modelo';

  @override
  String get assistantThinking => 'Pensando…';

  @override
  String get assistantError =>
      'La solicitud falló. Verifica la clave y la conexión.';

  @override
  String get assistantConfig => 'Ajustes del asistente';

  @override
  String get assistantIntro =>
      '¡Hola! Pregúntame sobre tus reparaciones, facturas o stock.';

  @override
  String get settingsStorage => 'Almacenamiento';

  @override
  String get settingsStorageLocal => 'Local · servidor pronto';

  @override
  String get navSearch => 'Buscar';

  @override
  String get searchPlaceholder => 'Buscar en todo…';

  @override
  String get searchHint => 'Clientes, reparaciones, facturas, presupuestos';

  @override
  String get searchEmpty => 'Sin resultados';

  @override
  String get greetingMorning => 'Buenos días';

  @override
  String get greetingAfternoon => 'Buenas tardes';

  @override
  String get greetingEvening => 'Buenas noches';

  @override
  String get periodYear => 'Año';

  @override
  String get dashboardVsPrevious => 'vs período ant.';

  @override
  String get dashboardRevenueTrend => 'Ingresos';

  @override
  String get dashboardStatusMix => 'Reparaciones';

  @override
  String get dashboardNeedsAttention => 'Requiere atención';

  @override
  String get quickNewRepair => 'Reparación';

  @override
  String get quickNewQuote => 'Presupuesto';

  @override
  String get quickNewInvoice => 'Factura';

  @override
  String get alertOverdueInvoices => 'Facturas vencidas';

  @override
  String get alertLowStock => 'Stock bajo';

  @override
  String get alertUnassigned => 'Sin asignar';

  @override
  String get alertOverdueDeliveries => 'Entregas atrasadas';

  @override
  String get alertOverduePayables => 'Proveedores por pagar';

  @override
  String get dashboardPriorities => 'Prioridades';

  @override
  String dashboardOverdueBy(Object days) {
    return '$days d de retraso';
  }

  @override
  String get alertDueToday => 'Vencen hoy';

  @override
  String get alertAwaitingParts => 'Esperando piezas';

  @override
  String get dashboardActiveRepairs => 'En curso';

  @override
  String get dashboardCompleted => 'Completadas';

  @override
  String get dashboardCollected => 'Cobrado';

  @override
  String get dashboardAllClear => 'Todo al día';

  @override
  String trendSince(String value) {
    return '$value vs período anterior';
  }

  @override
  String get periodDay => 'Día';

  @override
  String get periodWeek => 'Semana';

  @override
  String get periodMonth => 'Mes';

  @override
  String get repairsTitle => 'Reparaciones';

  @override
  String get repairsNew => 'Nueva reparación';

  @override
  String get repairsSearch => 'Buscar una reparación';

  @override
  String get repairsEmpty => 'Sin reparaciones registradas';

  @override
  String get repairsEmptySubtitle => 'Crea un ticket para seguir un trabajo.';

  @override
  String repairsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reparaciones',
      one: '1 reparación',
      zero: 'Sin reparaciones',
    );
    return '$_temp0';
  }

  @override
  String get statusInProgress => 'En curso';

  @override
  String get statusAwaitingParts => 'Esperando';

  @override
  String get statusCompleted => 'Completada';

  @override
  String get statusReceived => 'Recibida';

  @override
  String get statusDiagnosing => 'Diagnóstico';

  @override
  String get statusDelivered => 'Entregada';

  @override
  String get statusCancelled => 'Cancelada';

  @override
  String repairEventStatus(Object status) {
    return 'Estado: $status';
  }

  @override
  String repairEventTech(Object tech) {
    return 'Asignada a $tech';
  }

  @override
  String get repairEventTechCleared => 'Técnico eliminado';

  @override
  String repairEventPayment(Object status) {
    return 'Pago: $status';
  }

  @override
  String get repairTimeline => 'Seguimiento';

  @override
  String get repairNotify => 'Notificar al cliente';

  @override
  String get notifyTemplate => 'Plantilla';

  @override
  String get notifyMessage => 'Mensaje';

  @override
  String get notifySend => 'Enviar';

  @override
  String get notifyNoContact => 'Sin contacto para este canal';

  @override
  String get repairSectionComms => 'Comunicaciones';

  @override
  String get repairAdvance => 'Avanzar';

  @override
  String get clientsTitle => 'Clientes';

  @override
  String get clientsNew => 'Nuevo cliente';

  @override
  String get clientsSearch => 'Buscar un cliente';

  @override
  String get clientsEmpty => 'Sin clientes registrados';

  @override
  String get clientsEmptySubtitle => 'Añade un cliente para empezar.';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsThemeMode => 'Tema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsAccent => 'Color de acento';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsWorkshopInfo => 'Información del taller';

  @override
  String get settingsWorkshopInfoSubtitle => 'Nombre, dirección, contacto';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get settingsAboutDescription =>
      'Aplicación de gestión para taller de reparación.';

  @override
  String get languageSystem => 'Automático';

  @override
  String get languageFrench => 'Francés';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageArabic => 'Árabe';

  @override
  String get languageSpanish => 'Español';

  @override
  String get accentBlue => 'Azul';

  @override
  String get accentGreen => 'Verde';

  @override
  String get accentOrange => 'Naranja';

  @override
  String get accentRed => 'Rojo';

  @override
  String get accentIndigo => 'Índigo';

  @override
  String get accentPurple => 'Morado';

  @override
  String get accentTeal => 'Turquesa';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonDone => 'Hecho';

  @override
  String get commonSeeAll => 'Ver todo';

  @override
  String get commonShowLess => 'Ver menos';

  @override
  String get commonSearch => 'Buscar';

  @override
  String get repairsFilterAll => 'Todas';

  @override
  String get repairPriority => 'Prioridad';

  @override
  String get repairPriorityLow => 'Baja';

  @override
  String get repairPriorityNormal => 'Normal';

  @override
  String get repairPriorityHigh => 'Alta';

  @override
  String repairUpdated(String when) {
    return 'Actualizado $when';
  }

  @override
  String get repairDetailSelectTitle => 'Ninguna reparación seleccionada';

  @override
  String get repairDetailSelectSubtitle =>
      'Selecciona una reparación para ver los detalles.';

  @override
  String get repairSectionClient => 'Cliente';

  @override
  String get repairSectionProgress => 'Progreso';

  @override
  String get repairSectionTimeline => 'Seguimiento';

  @override
  String get repairSectionParts => 'Piezas';

  @override
  String get repairSectionNotes => 'Notas';

  @override
  String get repairCost => 'Costo estimado';

  @override
  String get repairMarkComplete => 'Marcar como completada';

  @override
  String get repairContactClient => 'Contactar al cliente';

  @override
  String get repairEventCreated => 'Ticket creado';

  @override
  String get repairEventDiagnosed => 'Diagnóstico hecho';

  @override
  String get repairEventInRepair => 'Reparación en curso';

  @override
  String get repairEventCompleted => 'Reparación completada';

  @override
  String get repairNoParts => 'Sin piezas registradas';

  @override
  String get repairNoNotes => 'Sin notas';

  @override
  String get repairSort => 'Ordenar';

  @override
  String get repairSortRecent => 'Reciente';

  @override
  String get repairSortPriority => 'Prioridad';

  @override
  String get repairSortCost => 'Costo';

  @override
  String get repairFilters => 'Filtros';

  @override
  String get repairFilterDeviceTitle => 'Tipo de dispositivo';

  @override
  String get repairFilterAny => 'Todos';

  @override
  String get repairActiveOnly => 'Solo activas';

  @override
  String get repairFiltersReset => 'Restablecer';

  @override
  String get repairFiltersApply => 'Aplicar';

  @override
  String get deviceKindPhone => 'Teléfono';

  @override
  String get deviceKindLaptop => 'Portátil';

  @override
  String get deviceKindTablet => 'Tableta';

  @override
  String get deviceKindWatch => 'Reloj';

  @override
  String get deviceKindOther => 'Otro';

  @override
  String get navDevices => 'Dispositivos';

  @override
  String get navPlanning => 'Agenda';

  @override
  String get navQuotes => 'Presupuestos';

  @override
  String get navInvoices => 'Facturas';

  @override
  String get navPayments => 'Pagos';

  @override
  String get navAccounting => 'Contabilidad';

  @override
  String get navInventory => 'Inventario';

  @override
  String get navCatalog => 'Catálogo';

  @override
  String get navSuppliers => 'Proveedores';

  @override
  String get navOrders => 'Pedidos';

  @override
  String get navStaff => 'Personal';

  @override
  String get navUsers => 'Usuarios';

  @override
  String get navReports => 'Informes';

  @override
  String get navAssistant => 'Asistente IA';

  @override
  String get navGroupMain => 'Principal';

  @override
  String get navGroupFinance => 'Finanzas';

  @override
  String get navGroupStock => 'Stock';

  @override
  String get navGroupManagement => 'Gestión';

  @override
  String get navGroupSystem => 'Sistema';

  @override
  String get navMore => 'Más';

  @override
  String get comingSoonTitle => 'Próximamente';

  @override
  String get comingSoonSubtitle => 'Esta sección está en construcción.';

  @override
  String get catalogSearch => 'Buscar un producto';

  @override
  String get catalogEmpty => 'Sin productos';

  @override
  String get catalogEmptySubtitle =>
      'Añade tus piezas, accesorios y servicios.';

  @override
  String get variantsLabel => 'Variantes';

  @override
  String get productNew => 'Nuevo producto';

  @override
  String get productName => 'Nombre del producto';

  @override
  String get productBrand => 'Marca';

  @override
  String get productCategory => 'Categoría';

  @override
  String get productVariants => 'Variantes';

  @override
  String get priceLabel => 'Precio';

  @override
  String get stockLabel => 'Stock';

  @override
  String get skuLabel => 'Ref.';

  @override
  String get categoryPart => 'Pieza';

  @override
  String get categoryAccessory => 'Accesorio';

  @override
  String get categoryService => 'Servicio';

  @override
  String get serviceCatDiagnostic => 'Diagnóstico';

  @override
  String get serviceCatScreen => 'Pantalla';

  @override
  String get serviceCatBattery => 'Batería';

  @override
  String get serviceCatSoftware => 'Software';

  @override
  String get serviceCatData => 'Datos';

  @override
  String get serviceCatOther => 'Otro';

  @override
  String get navServices => 'Servicios';

  @override
  String get servicesSearch => 'Buscar servicio';

  @override
  String get servicesEmpty => 'Sin servicios';

  @override
  String get servicesEmptySubtitle => 'Añade tus servicios y sus tarifas.';

  @override
  String get serviceCategoryHeader => 'Categoría';

  @override
  String get serviceDurationLabel => 'Duración';

  @override
  String get serviceMargin => 'Margen';

  @override
  String get serviceNew => 'Nuevo servicio';

  @override
  String get serviceEdit => 'Editar servicio';

  @override
  String get serviceDescription => 'Descripción';

  @override
  String get serviceCost => 'Coste';

  @override
  String get serviceDelete => 'Eliminar servicio';

  @override
  String get serviceDeleteConfirm => '¿Eliminar este servicio?';

  @override
  String get serviceAddToCatalog => 'Añadir al catálogo';

  @override
  String get navCategories => 'Categorías';

  @override
  String get categoryNew => 'Nueva categoría';

  @override
  String get categorySubNew => 'Nueva subcategoría';

  @override
  String get categoryIcon => 'Icono';

  @override
  String get categoryColor => 'Color';

  @override
  String get categoryDelete => 'Eliminar categoría';

  @override
  String get categoryDeleteConfirm => '¿Eliminar esta categoría?';

  @override
  String get categoryReassign => 'Mover servicios a';

  @override
  String get categoryAddSub => 'Añadir subcategoría';

  @override
  String get categoryMoveServices => 'Mover servicios';

  @override
  String get categoryMoveProducts => 'Mover productos';

  @override
  String get categoryReassignProducts => 'Mover productos a';

  @override
  String get productEdit => 'Editar producto';

  @override
  String get categorySelect => 'Elegir una categoría';

  @override
  String get taxonomyRoot => 'Raíz';

  @override
  String get taxonomyCode => 'Código';

  @override
  String get taxonomyDescription => 'Descripción';

  @override
  String get taxonomyParent => 'Categoría padre';

  @override
  String get taxonomyReassign => 'Mover elementos a';

  @override
  String get taxonomyMergeInto => 'Combinar con…';

  @override
  String get taxonomyMoveItems => 'Mover elementos';

  @override
  String get taxonomyCodeTaken => 'Este código ya está en uso';

  @override
  String get taxonomyShowArchived => 'Mostrar archivadas';

  @override
  String get taxonomyEmpty => 'Sin categorías';

  @override
  String get taxonomySearch => 'Buscar categoría';

  @override
  String get taxonomyExpandAll => 'Expandir todo';

  @override
  String get taxonomyCollapseAll => 'Contraer todo';

  @override
  String get supplierProducts => 'Productos suministrados';

  @override
  String get supplierOrderedProducts => 'Pedidos anteriores (sin vincular)';

  @override
  String get supplierLinkProduct => 'Vincular';

  @override
  String get inventoryReorder => 'Pedir';

  @override
  String get inventoryNoSupplier =>
      'Ningún proveedor vinculado a este producto';

  @override
  String get supplierInUse =>
      'Proveedor referenciado (productos o pedidos) — no se puede eliminar';

  @override
  String get supplierDeleteConfirm => '¿Eliminar este proveedor?';

  @override
  String get commonOk => 'OK';

  @override
  String get sourcingPurchasePrice => 'Precio de compra';

  @override
  String get sourcingPreferred => 'Preferido';

  @override
  String get sourcingBestPrice => 'Mejor precio';

  @override
  String get productFacets => 'Facetas';

  @override
  String get smartViews => 'Selecciones';

  @override
  String get smartViewNew => 'Nueva selección';

  @override
  String get smartRule => 'Regla';

  @override
  String get smartStock => 'Stock';

  @override
  String get smartPriceMax => 'Precio máx.';

  @override
  String get smartPriceMin => 'Precio mín.';

  @override
  String get smartAny => 'Cualquiera';

  @override
  String get catalogManage => 'Gestionar';

  @override
  String get serviceDuplicate => 'Duplicar';

  @override
  String get serviceCopySuffix => '(copia)';

  @override
  String get variantNew => 'Nueva variante';

  @override
  String get variantLabel => 'Etiqueta (p. ej. Negro · OEM)';

  @override
  String variantCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count variantes',
      one: '1 variante',
      zero: 'Sin variantes',
    );
    return '$_temp0';
  }

  @override
  String stockUnits(int count) {
    return '$count en stock';
  }

  @override
  String get addLabel => 'Añadir';

  @override
  String get repairSectionServices => 'Servicios';

  @override
  String get repairNoServices => 'Sin servicios';

  @override
  String get repairServicesTotal => 'Total servicios';

  @override
  String get repairSectionObservations => 'Observaciones';

  @override
  String get repairNoObservations => 'Sin observaciones';

  @override
  String get paymentUnpaid => 'Sin pagar';

  @override
  String get paymentPartial => 'Parcial';

  @override
  String get paymentPaid => 'Pagado';

  @override
  String get repairSectionProblem => 'Problema';

  @override
  String get repairReported => 'Avería informada';

  @override
  String get repairDiagnosis => 'Diagnóstico';

  @override
  String get repairWorkDone => 'Trabajo realizado';

  @override
  String get repairSectionDevice => 'Dispositivo';

  @override
  String get deviceModel => 'Modelo';

  @override
  String get deviceColor => 'Color';

  @override
  String get deviceStorage => 'Almacenamiento';

  @override
  String get deviceAccessories => 'Accesorios';

  @override
  String get repairIntakeCondition => 'Estado a la recepción';

  @override
  String get devicePasscode => 'Código de desbloqueo';

  @override
  String get backupConsent => 'Consentimiento de copia';

  @override
  String get repairSectionFinance => 'Finanzas';

  @override
  String get financeLabour => 'Mano de obra';

  @override
  String get financeDiscount => 'Descuento';

  @override
  String get financeTax => 'IVA';

  @override
  String get financeSubtotal => 'Subtotal';

  @override
  String get financeTotal => 'Total';

  @override
  String get financeDeposit => 'Anticipo';

  @override
  String get financeBalance => 'Saldo pendiente';

  @override
  String get repairSectionLogistics => 'Seguimiento y logística';

  @override
  String get repairAssignedTech => 'Técnico';

  @override
  String get repairCreatedBy => 'Recibido por';

  @override
  String get repairLocation => 'Ubicación';

  @override
  String get repairWarranty => 'Garantía';

  @override
  String get repairUnderWarranty => 'En garantía';

  @override
  String get repairWarrantyExpired => 'Garantía vencida';

  @override
  String repairWarrantyUntil(Object date) {
    return 'Hasta $date';
  }

  @override
  String warrantyDuration(int count) {
    return '$count meses';
  }

  @override
  String get repairDue => 'Vencimiento';

  @override
  String get repairOverdue => 'Vencido';

  @override
  String get repairPhotos => 'Fotos';

  @override
  String get repairPhotoAdded => 'Foto añadida';

  @override
  String get repairPhotoRemove => '¿Eliminar esta foto?';

  @override
  String get repairEventPhoto => 'Foto añadida';

  @override
  String get actionCall => 'Llamar';

  @override
  String get actionSms => 'SMS';

  @override
  String get actionWhatsapp => 'WhatsApp';

  @override
  String get actionEmail => 'Correo';

  @override
  String get actionEdit => 'Editar';

  @override
  String get editMode => 'Modo edición';

  @override
  String get actionReopen => 'Reabrir';

  @override
  String get actionAssign => 'Asignar un técnico';

  @override
  String get actionAddPhoto => 'Añadir una foto';

  @override
  String get actionPrintLabel => 'Imprimir etiqueta';

  @override
  String get repairPrintChoose => 'Imprimir';

  @override
  String get repairSheetTitle => 'Ficha de reparación';

  @override
  String get repairTicketTitle => 'Tique';

  @override
  String get repairSignatureClient => 'Firma del cliente';

  @override
  String get repairSignatureTech => 'Firma del técnico';

  @override
  String get repairTicketFooter =>
      'Presente este tique para recoger el dispositivo.';

  @override
  String get unitMonths => 'meses';

  @override
  String get repairScan => 'Escanear';

  @override
  String get repairScanHint =>
      'Coloque el QR de la reparación dentro del marco';

  @override
  String get repairScanManual => 'Introducir referencia';

  @override
  String get repairScanReference => 'Referencia';

  @override
  String get repairScanOpen => 'Abrir';

  @override
  String get repairScanNotFound => 'Reparación no encontrada';

  @override
  String get repairScanUnavailable =>
      'El escaneo por cámara no está disponible en esta plataforma';

  @override
  String get repairScanFromImage => 'Decodificar desde imagen';

  @override
  String get repairScanError => 'No se pudo decodificar el QR';

  @override
  String get repairScanCameraError =>
      'Cámara no disponible (¿permiso denegado?)';

  @override
  String get actionGenerateInvoice => 'Generar factura';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get statusLabel => 'Estado';

  @override
  String get qtyShort => 'Cant.';

  @override
  String get unitPriceShort => 'PU';

  @override
  String get addPrestation => 'Añadir un servicio';

  @override
  String get addPart => 'Añadir una pieza';

  @override
  String get unassigned => 'Sin asignar';

  @override
  String get notProvided => 'No indicado';

  @override
  String get clientSectionContact => 'Datos de contacto';

  @override
  String get supplierNew => 'Nuevo proveedor';

  @override
  String get supplierSearch => 'Buscar un proveedor';

  @override
  String get supplierEmpty => 'Sin proveedores';

  @override
  String get supplierEmptySubtitle => 'Añade un proveedor para empezar.';

  @override
  String get supplierType => 'Tipo';

  @override
  String get supplierTypeCompany => 'Empresa';

  @override
  String get supplierTypeIndividual => 'Particular';

  @override
  String get supplierName => 'Nombre / Empresa';

  @override
  String get supplierContactName => 'Persona de contacto';

  @override
  String get supplierVat => 'N.º de IVA';

  @override
  String get supplierCity => 'Ciudad';

  @override
  String get supplierTerms => 'Condiciones de pago';

  @override
  String get supplierSectionCompany => 'Empresa';

  @override
  String get fieldName => 'Nombre';

  @override
  String get clientTypeIndividual => 'Particular';

  @override
  String get clientTypeCompany => 'Empresa';

  @override
  String get clientCompanyName => 'Razón social';

  @override
  String get clientVat => 'N.º de IVA';

  @override
  String get clientCity => 'Ciudad';

  @override
  String get clientSectionCompany => 'Empresa';

  @override
  String get clientSectionHistory => 'Historial de reparaciones';

  @override
  String get staffNew => 'Nuevo empleado';

  @override
  String get staffSearch => 'Buscar un empleado';

  @override
  String get staffEmpty => 'Sin empleados';

  @override
  String get staffEmptySubtitle => 'Añade un empleado para empezar.';

  @override
  String get staffJobTitle => 'Puesto';

  @override
  String get staffHireDate => 'Fecha de contratación';

  @override
  String get staffCommission => 'Comisión (%)';

  @override
  String get staffActive => 'Activo';

  @override
  String get staffInactive => 'Inactivo';

  @override
  String get staffSectionEmployment => 'Empleo';

  @override
  String get staffAssignedRepairs => 'Reparaciones asignadas';

  @override
  String get authLoginTitle => 'Iniciar sesión';

  @override
  String get authPassword => 'Contraseña';

  @override
  String get authPin => 'Código PIN';

  @override
  String get authSignIn => 'Iniciar sesión';

  @override
  String get authLogout => 'Cerrar sesión';

  @override
  String get authError => 'Credenciales incorrectas';

  @override
  String get authModeEmail => 'Correo';

  @override
  String get authModePin => 'PIN';

  @override
  String get userNew => 'Nuevo usuario';

  @override
  String get userSearch => 'Buscar un usuario';

  @override
  String get userEmpty => 'Sin usuarios';

  @override
  String get userEmptySubtitle => 'Añade una cuenta para empezar.';

  @override
  String get listNoResults => 'Sin resultados';

  @override
  String get listNoResultsSubtitle => 'Ajusta la búsqueda o los filtros.';

  @override
  String get navProfile => 'Perfil';

  @override
  String get profileSubtitle => 'Tu cuenta y seguridad';

  @override
  String get profileAccount => 'Cuenta';

  @override
  String get profileSecurity => 'Seguridad';

  @override
  String get profileLinkedEmployee => 'Empleado vinculado';

  @override
  String get profileChangePassword => 'Cambiar contraseña';

  @override
  String get profileChangePin => 'Cambiar PIN';

  @override
  String get profileCurrentPassword => 'Contraseña actual';

  @override
  String get profileNewPassword => 'Nueva contraseña';

  @override
  String get profileConfirm => 'Confirmar';

  @override
  String get profileNewPin => 'Nuevo PIN';

  @override
  String get profilePasswordChanged => 'Contraseña cambiada';

  @override
  String get profilePinChanged => 'PIN cambiado';

  @override
  String get profileWrongPassword => 'La contraseña actual es incorrecta';

  @override
  String get profilePasswordMismatch => 'Las contraseñas no coinciden';

  @override
  String get accountEmailTaken => 'Este correo ya está en uso';

  @override
  String get accountPinTaken => 'Este PIN ya está en uso';

  @override
  String get accountLastAdmin => 'Se requiere al menos un administrador activo';

  @override
  String get accountEventLogin => 'Inicio de sesión';

  @override
  String get accountEventLogout => 'Cierre de sesión';

  @override
  String get accountEventFailedLogin => 'Inicio fallido';

  @override
  String get accountEventCreated => 'Cuenta creada';

  @override
  String get accountEventUpdated => 'Cuenta actualizada';

  @override
  String get accountEventRoleChanged => 'Rol cambiado';

  @override
  String get accountEventDeactivated => 'Cuenta desactivada';

  @override
  String get accountEventReactivated => 'Cuenta reactivada';

  @override
  String get accountEventPasswordReset => 'Contraseña restablecida';

  @override
  String get accountEventPinReset => 'PIN restablecido';

  @override
  String get accountEventInvited => 'Invitación enviada';

  @override
  String get accountEventDeleted => 'Cuenta eliminada';

  @override
  String get accountActivity => 'Actividad';

  @override
  String get accountLog => 'Registro de cuentas';

  @override
  String get accountCreatedAt => 'Creado';

  @override
  String get accountLastLogin => 'Último inicio';

  @override
  String get accountNeverLoggedIn => 'Nunca inició sesión';

  @override
  String get accountActionsTitle => 'Acciones';

  @override
  String get accountResetPassword => 'Restablecer contraseña';

  @override
  String get accountResetPin => 'Restablecer PIN';

  @override
  String get accountInvite => 'Invitar (demo)';

  @override
  String get accountDelete => 'Eliminar cuenta';

  @override
  String get accountDeleteConfirm => '¿Eliminar permanentemente esta cuenta?';

  @override
  String get accountTempSecret => 'Secreto temporal (demo)';

  @override
  String get accountInvitePending => 'Invitación pendiente';

  @override
  String get navIntegrations => 'Integraciones';

  @override
  String get integrationsSubtitle => 'Pagos, correo, mensajería…';

  @override
  String get integrationsSummary => 'Servicios conectados';

  @override
  String get integrationsSearch => 'Buscar integración';

  @override
  String get integrationEnable => 'Activar';

  @override
  String get integrationTest => 'Probar';

  @override
  String get integrationComingSoon => 'Conexión en directo próximamente';

  @override
  String get integrationConnectAccount => 'Conectar cuenta';

  @override
  String get integrationConnected => 'Cuenta vinculada';

  @override
  String get integrationDisconnect => 'Desconectar';

  @override
  String get integrationValid => 'Configuración válida';

  @override
  String get integrationCheckNotConnected => 'Cuenta no vinculada';

  @override
  String get integrationCheckEmail => 'Correo electrónico no válido';

  @override
  String integrationCheckMissing(Object field) {
    return 'Falta un campo obligatorio: $field';
  }

  @override
  String integrationCheckUrl(Object field) {
    return 'URL no válida: $field';
  }

  @override
  String integrationCheckShort(Object field) {
    return 'Valor demasiado corto: $field';
  }

  @override
  String get integrationCatPayments => 'Pagos';

  @override
  String get integrationCatMessaging => 'Mensajería';

  @override
  String get integrationCatCloud => 'Nube y correo';

  @override
  String get integrationCatAutomation => 'Automatización';

  @override
  String get integrationDescOutlook => 'Enviar facturas por Outlook';

  @override
  String get integrationDescOnedrive => 'Copia en OneDrive';

  @override
  String get integrationDescTelegram => 'Notificaciones vía un bot de Telegram';

  @override
  String get integrationDescTeams => 'Alertas en un canal de Teams';

  @override
  String get integrationDescSlack => 'Alertas en un canal de Slack';

  @override
  String get integrationDescZapier => 'Automatiza vía un webhook de Zapier';

  @override
  String get integrationFieldBotToken => 'Token del bot';

  @override
  String get integrationFieldChatId => 'ID de chat';

  @override
  String get integrationFieldWebhookUrl => 'URL del webhook';

  @override
  String get integrationDescApplepay => 'Pagos con Apple Pay';

  @override
  String get integrationDescIcloud => 'Copia en iCloud';

  @override
  String get integrationDescApplemsg => 'Mensajes para Empresas (iMessage)';

  @override
  String get integrationFieldMerchantId => 'ID de comercio Apple';

  @override
  String get integrationFieldBusinessId => 'ID de Apple Business';

  @override
  String get integrationStatusActive => 'Activo';

  @override
  String get integrationStatusDisabled => 'Desactivado';

  @override
  String get integrationStatusNotConfigured => 'Sin configurar';

  @override
  String get integrationDescFlouci =>
      'Pago con billetera y tarjetas (CIB/Visa/MC)';

  @override
  String get integrationDescKonnect => 'Pago con tarjeta en línea';

  @override
  String get integrationDescClictopay => 'Pago con tarjeta bancaria (SMT)';

  @override
  String get integrationDescStripe => 'Tarjetas internacionales';

  @override
  String get integrationDescDrive => 'Copia en la nube';

  @override
  String get integrationDescGmail => 'Enviar facturas por correo';

  @override
  String get integrationDescWhatsapp => 'Mensajes de WhatsApp automáticos';

  @override
  String get integrationDescMessenger => 'Chatear por Messenger';

  @override
  String get integrationDescSms => 'Notificaciones por SMS';

  @override
  String get integrationFieldApiKey => 'Clave API';

  @override
  String get integrationFieldSecretKey => 'Clave secreta';

  @override
  String get integrationFieldPrivateToken => 'Token privado';

  @override
  String get integrationFieldAppId => 'ID de app';

  @override
  String get integrationFieldWalletId => 'ID de billetera';

  @override
  String get integrationFieldMerchantUser => 'Usuario comercio';

  @override
  String get integrationFieldMerchantPassword => 'Contraseña comercio';

  @override
  String get integrationFieldAppPassword => 'Contraseña de aplicación';

  @override
  String get integrationFieldPhoneId => 'ID del número';

  @override
  String get integrationFieldAccessToken => 'Token de acceso';

  @override
  String get integrationFieldPageLink => 'Enlace de la página';

  @override
  String get integrationFieldSender => 'Remitente';

  @override
  String get userRole => 'Rol';

  @override
  String get userLinkedEmployee => 'Empleado vinculado';

  @override
  String get userNoEmployee => 'Ninguno';

  @override
  String get userNewPassword => 'Nueva contraseña';

  @override
  String get userNewPin => 'Nuevo PIN';

  @override
  String get roleAdmin => 'Administrador';

  @override
  String get roleTechnician => 'Técnico';

  @override
  String get roleCashier => 'Caja';

  @override
  String get orderNew => 'Nuevo pedido';

  @override
  String get orderSearch => 'Buscar un pedido';

  @override
  String get orderEmpty => 'Sin pedidos';

  @override
  String get orderEmptySubtitle => 'Crea un pedido de proveedor.';

  @override
  String get orderStatusDraft => 'Borrador';

  @override
  String get orderStatusOrdered => 'Pedido';

  @override
  String get orderStatusReceived => 'Recibido';

  @override
  String get orderStatusCancelled => 'Cancelado';

  @override
  String get orderSupplier => 'Proveedor';

  @override
  String get orderExpectedDate => 'Entrega prevista';

  @override
  String get orderReceive => 'Recibir';

  @override
  String get orderPaid => 'Pagado';

  @override
  String get orderBalanceDue => 'Saldo pendiente';

  @override
  String get orderAddPayment => 'Registrar pago';

  @override
  String get orderAddLine => 'Añadir un artículo';

  @override
  String get orderSectionLines => 'Artículos';

  @override
  String get orderNoLines => 'Sin artículos';

  @override
  String get orderSubtotal => 'Subtotal';

  @override
  String get orderTax => 'IVA';

  @override
  String get orderTotal => 'Total';

  @override
  String get productPickTitle => 'Elegir un producto';

  @override
  String get quoteNew => 'Nuevo presupuesto';

  @override
  String get quoteSearch => 'Buscar un presupuesto';

  @override
  String get quoteEmpty => 'Sin presupuestos';

  @override
  String get quoteEmptySubtitle => 'Crea un presupuesto de cliente.';

  @override
  String get quoteStatusDraft => 'Borrador';

  @override
  String get quoteStatusSent => 'Enviado';

  @override
  String get quoteStatusAccepted => 'Aceptado';

  @override
  String get quoteStatusRefused => 'Rechazado';

  @override
  String get quoteStatusExpired => 'Expirado';

  @override
  String get quoteValidUntil => 'Válido hasta';

  @override
  String get quoteAddService => 'Añadir un servicio';

  @override
  String get quoteAddPart => 'Añadir una pieza';

  @override
  String get quoteSectionLines => 'Detalle';

  @override
  String get quoteExportPdf => 'Exportar a PDF';

  @override
  String get quoteSend => 'Enviar';

  @override
  String get quoteAccept => 'Aceptar';

  @override
  String get quoteRefuse => 'Rechazar';

  @override
  String get colDesignation => 'Descripción';

  @override
  String get colQty => 'Cant.';

  @override
  String get colUnitPrice => 'P. unitario';

  @override
  String get colLineTotal => 'Total';

  @override
  String get invoiceNew => 'Nueva factura';

  @override
  String get invoiceSearch => 'Buscar una factura';

  @override
  String get invoiceEmpty => 'Sin facturas';

  @override
  String get invoiceEmptySubtitle => 'Crea una factura.';

  @override
  String get invoiceStatusDraft => 'Borrador';

  @override
  String get invoiceStatusIssued => 'Emitida';

  @override
  String get invoiceStatusPartial => 'Parcial';

  @override
  String get invoiceStatusPaid => 'Pagada';

  @override
  String get invoiceStatusOverdue => 'Vencida';

  @override
  String get invoiceStatusCancelled => 'Cancelada';

  @override
  String get invoiceIssue => 'Emitir';

  @override
  String get creditNote => 'Abono';

  @override
  String get creditNotes => 'Abonos';

  @override
  String get creditNoteNew => 'Crear abono';

  @override
  String get creditNoteIssue => 'Emitir abono';

  @override
  String get creditNoteReason => 'Motivo';

  @override
  String get creditNoteEmpty => 'Sin abonos';

  @override
  String get invoiceDueDate => 'Vencimiento';

  @override
  String get invoiceDeposit => 'Anticipo';

  @override
  String get invoiceBalance => 'Saldo pendiente';

  @override
  String get invoiceSectionPayments => 'Pagos';

  @override
  String get invoiceRecordPayment => 'Registrar un pago';

  @override
  String get invoiceNoPayments => 'Sin pagos';

  @override
  String get invoiceAmount => 'Importe';

  @override
  String get paymentMethodCash => 'Efectivo';

  @override
  String get paymentMethodCard => 'Tarjeta';

  @override
  String get paymentMethodTransfer => 'Transferencia';

  @override
  String get paymentMethodCheck => 'Cheque';

  @override
  String get paymentMethodCredit => 'Saldo a favor';

  @override
  String get quoteConvertInvoice => 'Convertir en factura';

  @override
  String get invoiceFromRepair => 'Generar factura';

  @override
  String get fieldPhone => 'Teléfono';

  @override
  String get fieldEmail => 'Correo';

  @override
  String get fieldAddress => 'Dirección';

  @override
  String get fieldWhatsapp => 'WhatsApp';

  @override
  String get fieldTelegram => 'Telegram';

  @override
  String get fieldSecondaryPhone => 'Teléfono secundario';

  @override
  String get fieldWebsite => 'Sitio web';

  @override
  String get fieldInstagram => 'Instagram';

  @override
  String get clientSectionSocial => 'Web y redes';

  @override
  String get actionWebsite => 'Abrir sitio web';

  @override
  String get actionInstagram => 'Abrir Instagram';

  @override
  String get contactKindTitle => 'Tipo de contacto';

  @override
  String get contactKindMobile => 'Móvil';

  @override
  String get contactKindLandline => 'Fijo';

  @override
  String get contactKindWhatsapp => 'WhatsApp';

  @override
  String get contactKindTelegram => 'Telegram';

  @override
  String get contactKindEmail => 'Correo';

  @override
  String get contactKindWebsite => 'Sitio web';

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
  String get contactKindOther => 'Otro';

  @override
  String get clientAddContact => 'Añadir un contacto';

  @override
  String get clientOtherContacts => 'Otros contactos';

  @override
  String get clientOtherAddresses => 'Otras direcciones';

  @override
  String get clientSectionAddresses => 'Direcciones';

  @override
  String get addressMain => 'Dirección principal';

  @override
  String get clientAddAddress => 'Añadir una dirección';

  @override
  String get addressKindTitle => 'Tipo de dirección';

  @override
  String get addressKindHome => 'Domicilio';

  @override
  String get addressKindWork => 'Trabajo';

  @override
  String get addressKindBilling => 'Facturación';

  @override
  String get addressKindShipping => 'Envío';

  @override
  String get addressKindOther => 'Otro';

  @override
  String get clientStatInvoiced => 'Facturado';

  @override
  String get clientStatOutstanding => 'Sin pagar';

  @override
  String get clientStatRepairs => 'Reparaciones';

  @override
  String get clientSectionInvoices => 'Facturas';

  @override
  String get clientSectionQuotes => 'Presupuestos';

  @override
  String get clientLastActivity => 'Última actividad';

  @override
  String get clientNoDocuments => 'Sin documentos';

  @override
  String get clientNoActivity => 'Sin actividad todavía';

  @override
  String get clientNoInvoices => 'Sin facturas';

  @override
  String get clientNoQuotes => 'Sin presupuestos';

  @override
  String get clientSettleAll => 'Cobrar todo';

  @override
  String get clientCredit => 'Crédito disponible';

  @override
  String get clientNetBalance => 'Saldo neto';

  @override
  String get clientStatementPdf => 'Estado de cuenta (PDF)';

  @override
  String get statementTitle => 'Estado de cuenta';

  @override
  String get statementDate => 'Fecha';

  @override
  String get statementDetail => 'Detalle';

  @override
  String get statementDebit => 'Debe';

  @override
  String get statementCredit => 'Haber';

  @override
  String get statementBalance => 'Saldo';

  @override
  String get statementOpening => 'Saldo inicial';

  @override
  String get statementClosing => 'Saldo final';

  @override
  String get statementInvoice => 'Factura';

  @override
  String get statementDeposit => 'Anticipo';

  @override
  String get statementPayment => 'Pago';

  @override
  String get colNumber => 'N.º';

  @override
  String get supplierStatementPdf => 'Estado del proveedor (PDF)';

  @override
  String get supplierStatementTitle => 'Estado del proveedor';

  @override
  String get supplierPurchased => 'Recibido';

  @override
  String get supplierOnOrder => 'En pedido';

  @override
  String get supplierOverdue => 'Vencido';

  @override
  String get supplierPayable => 'Por pagar';

  @override
  String get poAgeNotDue => 'No vencido';

  @override
  String get poAge1to30 => '1–30 d';

  @override
  String get poAge31to60 => '31–60 d';

  @override
  String get poAge60plus => '60+ d';

  @override
  String get clientAddDeposit => 'Añadir un anticipo';

  @override
  String get clientApplyCredit => 'Aplicar crédito';

  @override
  String get clientRefund => 'Reembolsar';

  @override
  String get chequeAdd => 'Añadir un cheque';

  @override
  String get navRefunds => 'Reembolsos';

  @override
  String get refundsTotal => 'Total reembolsado';

  @override
  String get refundsEmpty => 'Sin reembolsos';

  @override
  String get refundsEmptySubtitle =>
      'Los reembolsos a clientes aparecerán aquí.';

  @override
  String get financePeriodAll => 'Todo';

  @override
  String get financePeriodMonth => 'Mes';

  @override
  String get financePeriodQuarter => 'Trimestre';

  @override
  String get financePeriodYear => 'Año';

  @override
  String get financePeriodCustom => 'Personalizado';

  @override
  String get filterAllClients => 'Todos los clientes';

  @override
  String get paymentKindInvoice => 'Factura';

  @override
  String get paymentKindDeposit => 'Anticipo';

  @override
  String get paymentKindApplication => 'Crédito aplicado';

  @override
  String get paymentKindRefund => 'Reembolso';

  @override
  String get financeBreakdown => 'Desglose';

  @override
  String get navCheques => 'Cheques';

  @override
  String get chequeNumber => 'N.º de cheque';

  @override
  String get chequeBank => 'Banco';

  @override
  String get chequeDrawer => 'Emisor';

  @override
  String get chequeDueDate => 'Vencimiento';

  @override
  String get chequeStatusPending => 'Por depositar';

  @override
  String get chequeStatusDeposited => 'Depositado';

  @override
  String get chequeStatusCleared => 'Cobrado';

  @override
  String get chequeStatusBounced => 'Devuelto';

  @override
  String get chequesToCollect => 'Cheques por cobrar';

  @override
  String get chequesEmpty => 'Sin cheques';

  @override
  String get chequesEmptySubtitle => 'Los cheques recibidos aparecerán aquí.';

  @override
  String get chequeMarkDeposited => 'Marcar depositado';

  @override
  String get chequeMarkCleared => 'Marcar cobrado';

  @override
  String get chequeBounceAction => 'Devolver';

  @override
  String get clientSince => 'Cliente desde';

  @override
  String get clientTags => 'Etiquetas';

  @override
  String get clientTagsHint => 'Separa con comas';

  @override
  String get clientConsent => 'Consentimiento de marketing';

  @override
  String get clientBillingContact => 'Contacto de facturación';

  @override
  String get clientPaymentTerms => 'Condiciones de pago';

  @override
  String get clientDiscount => 'Descuento habitual';

  @override
  String get clientCreditLimit => 'Límite de crédito';

  @override
  String clientDuplicateWarning(String name) {
    return 'Ya existe un cliente similar: $name. ¿Crear de todos modos?';
  }

  @override
  String get actionTelegram => 'Telegram';

  @override
  String get actionDirections => 'Cómo llegar';

  @override
  String get clientSelect => 'Seleccionar un cliente';

  @override
  String get settingsSectionLayout => 'Disposición';

  @override
  String get settingsContentWidth => 'Ancho del contenido';

  @override
  String get contentNormal => 'Normal';

  @override
  String get contentStretch => 'Ancho completo';

  @override
  String get settingsSidebar => 'Barra lateral';

  @override
  String get sidebarAdaptive => 'Adaptable';

  @override
  String get sidebarExpanded => 'Expandida';

  @override
  String get settingsDetailView => 'Vista de detalles';

  @override
  String get settingsClientsView => 'Vista de directorios';

  @override
  String get settingsRegional => 'Regional';

  @override
  String get settingsCurrency => 'Moneda';

  @override
  String get settingsDateFormat => 'Formato de fecha';

  @override
  String get clientsViewList => 'Lista';

  @override
  String get clientsViewGrid => 'Cuadrícula';

  @override
  String get clientsViewTable => 'Tabla';

  @override
  String get fieldType => 'Tipo';

  @override
  String get clientSegmentDebtors => 'Deudores';

  @override
  String get clientSegmentCredit => 'Con crédito';

  @override
  String get clientSegmentInactive => 'Inactivos';

  @override
  String get clientSegmentBusiness => 'Empresas';

  @override
  String get clientSegmentRecent => 'Nuevos';

  @override
  String get detailAdaptive => 'Adaptable';

  @override
  String get detailPane => 'Panel lateral';

  @override
  String get detailPage => 'Página separada';

  @override
  String get prestationPickTitle => 'Elegir un servicio';

  @override
  String get prestationSearch => 'Buscar un servicio';

  @override
  String get prestationManual => 'Entrada manual';
}
