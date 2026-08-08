import 'package:flutter/material.dart';

import '../../features/clients/presentation/clients_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/repairs/presentation/repairs_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../l10n/app_localizations.dart';
import '../auth/permissions.dart';

/// Regroupement des sections dans la navigation.
enum NavGroup { main, finance, stock, management, system }

extension NavGroupX on NavGroup {
  String label(AppLocalizations l) => switch (this) {
        NavGroup.main => l.navGroupMain,
        NavGroup.finance => l.navGroupFinance,
        NavGroup.stock => l.navGroupStock,
        NavGroup.management => l.navGroupManagement,
        NavGroup.system => l.navGroupSystem,
      };
}

/// Définition d'une section de premier niveau de l'application.
class AppSection {
  const AppSection({
    required this.path,
    required this.name,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.group,
    this.placeholder = false,
    this.primary = false,
    this.permission,
  });

  final String path;
  final String name;
  final IconData icon;
  final IconData selectedIcon;
  final String Function(AppLocalizations) label;
  final NavGroup group;

  /// `true` → écran générique « bientôt disponible » (pas encore implémenté).
  final bool placeholder;

  /// `true` → affichée directement dans la barre inférieure mobile.
  final bool primary;

  /// Permission requise pour voir la section (`null` = visible par tous).
  final Permission? permission;

  bool matches(String location) =>
      path == '/' ? location == '/' : location == path || location.startsWith('$path/');
}

/// Source unique de vérité de la navigation (ordre = ordre d'affichage).
final List<AppSection> appSections = [
  // Principal.
  AppSection(
    path: DashboardScreen.routePath,
    name: 'dashboard',
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
    label: (l) => l.navDashboard,
    group: NavGroup.main,
    primary: true,
  ),
  AppSection(
    path: RepairsScreen.routePath,
    name: 'repairs',
    icon: Icons.build_outlined,
    selectedIcon: Icons.build,
    label: (l) => l.navRepairs,
    group: NavGroup.main,
    primary: true,
  ),
  AppSection(
    path: '/devices',
    name: 'devices',
    icon: Icons.devices_outlined,
    selectedIcon: Icons.devices,
    label: (l) => l.navDevices,
    group: NavGroup.main,
  ),
  AppSection(
    path: ClientsScreen.routePath,
    name: 'clients',
    icon: Icons.people_outline,
    selectedIcon: Icons.people,
    label: (l) => l.navClients,
    group: NavGroup.main,
    primary: true,
  ),
  AppSection(
    path: '/planning',
    name: 'planning',
    icon: Icons.event_outlined,
    selectedIcon: Icons.event,
    label: (l) => l.navPlanning,
    group: NavGroup.main,
  ),
  AppSection(
    path: '/search',
    name: 'search',
    icon: Icons.search_outlined,
    selectedIcon: Icons.search,
    label: (l) => l.navSearch,
    group: NavGroup.main,
  ),
  // Finances.
  AppSection(
    path: '/quotes',
    name: 'quotes',
    icon: Icons.description_outlined,
    selectedIcon: Icons.description,
    label: (l) => l.navQuotes,
    group: NavGroup.finance,
  ),
  AppSection(
    path: '/invoices',
    name: 'invoices',
    icon: Icons.receipt_long_outlined,
    selectedIcon: Icons.receipt_long,
    label: (l) => l.navInvoices,
    group: NavGroup.finance,
    permission: Permission.createInvoice,
  ),
  AppSection(
    path: '/payments',
    name: 'payments',
    icon: Icons.payments_outlined,
    selectedIcon: Icons.payments,
    label: (l) => l.navPayments,
    group: NavGroup.finance,
    permission: Permission.recordPayment,
  ),
  AppSection(
    path: '/cheques',
    name: 'cheques',
    icon: Icons.account_balance_wallet_outlined,
    selectedIcon: Icons.account_balance_wallet,
    label: (l) => l.navCheques,
    group: NavGroup.finance,
    permission: Permission.recordPayment,
  ),
  AppSection(
    path: '/refunds',
    name: 'refunds',
    icon: Icons.undo_outlined,
    selectedIcon: Icons.undo,
    label: (l) => l.navRefunds,
    group: NavGroup.finance,
    permission: Permission.recordPayment,
  ),
  AppSection(
    path: '/accounting',
    name: 'accounting',
    icon: Icons.account_balance_outlined,
    selectedIcon: Icons.account_balance,
    label: (l) => l.navAccounting,
    group: NavGroup.finance,
    permission: Permission.viewReports,
  ),
  // Stock.
  AppSection(
    path: '/inventory',
    name: 'inventory',
    icon: Icons.inventory_2_outlined,
    selectedIcon: Icons.inventory_2,
    label: (l) => l.navInventory,
    group: NavGroup.stock,
    permission: Permission.manageCatalog,
  ),
  AppSection(
    path: '/catalog',
    name: 'catalog',
    icon: Icons.menu_book_outlined,
    selectedIcon: Icons.menu_book,
    label: (l) => l.navCatalog,
    group: NavGroup.stock,
  ),
  AppSection(
    path: '/services',
    name: 'services',
    icon: Icons.handyman_outlined,
    selectedIcon: Icons.handyman,
    label: (l) => l.navServices,
    group: NavGroup.stock,
    permission: Permission.manageCatalog,
  ),
  AppSection(
    path: '/suppliers',
    name: 'suppliers',
    icon: Icons.local_shipping_outlined,
    selectedIcon: Icons.local_shipping,
    label: (l) => l.navSuppliers,
    group: NavGroup.stock,
    permission: Permission.manageSuppliers,
  ),
  AppSection(
    path: '/orders',
    name: 'orders',
    icon: Icons.shopping_cart_outlined,
    selectedIcon: Icons.shopping_cart,
    label: (l) => l.navOrders,
    group: NavGroup.stock,
  ),
  // Gestion.
  AppSection(
    path: '/staff',
    name: 'staff',
    icon: Icons.badge_outlined,
    selectedIcon: Icons.badge,
    label: (l) => l.navStaff,
    group: NavGroup.management,
    permission: Permission.manageStaff,
  ),
  AppSection(
    path: '/users',
    name: 'users',
    icon: Icons.manage_accounts_outlined,
    selectedIcon: Icons.manage_accounts,
    label: (l) => l.navUsers,
    group: NavGroup.management,
    permission: Permission.manageUsers,
  ),
  AppSection(
    path: '/reports',
    name: 'reports',
    icon: Icons.analytics_outlined,
    selectedIcon: Icons.analytics,
    label: (l) => l.navReports,
    group: NavGroup.management,
    permission: Permission.viewReports,
  ),
  AppSection(
    path: '/assistant',
    name: 'assistant',
    icon: Icons.auto_awesome_outlined,
    selectedIcon: Icons.auto_awesome,
    label: (l) => l.navAssistant,
    group: NavGroup.management,
  ),
  // Système.
  AppSection(
    path: SettingsScreen.routePath,
    name: 'settings',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    label: (l) => l.navSettings,
    group: NavGroup.system,
  ),
];

/// Sections affichées directement dans la barre inférieure mobile.
List<AppSection> get primarySections =>
    appSections.where((s) => s.primary).toList();

/// Sections placeholder (écran générique).
List<AppSection> get placeholderSections =>
    appSections.where((s) => s.placeholder).toList();

/// Index de la section correspondant à [location] (0 par défaut).
int sectionIndexFor(String location) {
  final i = appSections.indexWhere((s) => s.matches(location));
  return i < 0 ? 0 : i;
}

/// Permission requise pour accéder à [location], ou `null` si elle est ouverte.
/// Utilisée par le routeur pour **appliquer** l'autorisation (pas seulement
/// masquer la section dans la navigation).
Permission? requiredPermissionFor(String location) {
  for (final s in appSections) {
    if (s.permission != null && s.matches(location)) return s.permission;
  }
  return null;
}
