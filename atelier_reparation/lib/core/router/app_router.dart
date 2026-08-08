import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/accounting/presentation/accounting_screen.dart';
import '../../features/catalog/presentation/catalog_screen.dart';
import '../../features/cheques/presentation/cheques_screen.dart';
import '../../features/clients/presentation/clients_screen.dart';
import '../../features/devices/presentation/devices_screen.dart';
import '../../features/suppliers/presentation/suppliers_screen.dart';
import '../../features/assistant/presentation/assistant_screen.dart';
import '../../features/auth/application/session_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/dev/component_gallery.dart';
import '../../features/inventory/presentation/inventory_screen.dart';
import '../../features/invoices/presentation/invoices_screen.dart';
import '../../features/orders/presentation/orders_screen.dart';
import '../../features/payments/presentation/payments_screen.dart';
import '../../features/payments/presentation/refunds_screen.dart';
import '../../features/planning/presentation/planning_screen.dart';
import '../../features/prestations/presentation/services_screen.dart';
import '../../features/quotes/presentation/quotes_screen.dart';
import '../../features/placeholder/placeholder_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/repairs/presentation/repair_detail.dart';
import '../../features/repairs/presentation/repairs_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/staff/presentation/employees_screen.dart';
import '../../features/users/presentation/users_screen.dart';
import '../../shared/widgets/app_shell.dart';
import '../navigation/app_sections.dart';

/// Fournit la configuration [GoRouter] de l'application.
final appRouterProvider = Provider<GoRouter>((ref) {
  final loggedIn = ref.watch(sessionControllerProvider) != null;
  return GoRouter(
    initialLocation: DashboardScreen.routePath,
    redirect: (context, state) {
      final atLogin = state.uri.path == LoginScreen.routePath;
      if (!loggedIn && !atLogin) return LoginScreen.routePath;
      if (loggedIn && atLogin) return DashboardScreen.routePath;
      // Autorisation appliquée (pas seulement masquée dans la navigation) :
      // une section protégée est inaccessible sans la permission requise.
      if (loggedIn) {
        final need = requiredPermissionFor(state.uri.path);
        if (need != null &&
            !ref.read(sessionControllerProvider.notifier).can(need)) {
          return DashboardScreen.routePath;
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: LoginScreen.routePath,
        name: LoginScreen.routeName,
        builder: (context, state) => const LoginScreen(),
      ),
      // Coquille commune (barre de navigation adaptative) autour des écrans.
      ShellRoute(
        builder: (context, state, child) => AppShell(state: state, child: child),
        routes: [
          GoRoute(
            path: DashboardScreen.routePath,
            name: DashboardScreen.routeName,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: RepairsScreen.routePath,
            name: RepairsScreen.routeName,
            builder: (context, state) => const RepairsScreen(),
            routes: [
              // Détail profond-liable (`/repairs/:ref`) : sert au scan QR et aux
              // liens directs. La référence (`#R-2026-0001`) est décodée par
              // go_router avant d'arriver ici.
              GoRoute(
                path: ':ref',
                name: 'repair-detail',
                builder: (context, state) => RepairDetailScreen(
                  reference: state.pathParameters['ref']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: ClientsScreen.routePath,
            name: ClientsScreen.routeName,
            builder: (context, state) => const ClientsScreen(),
          ),
          GoRoute(
            path: SettingsScreen.routePath,
            name: SettingsScreen.routeName,
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: CatalogScreen.routePath,
            name: CatalogScreen.routeName,
            builder: (context, state) => const CatalogScreen(),
          ),
          GoRoute(
            path: ServicesScreen.routePath,
            name: ServicesScreen.routeName,
            builder: (context, state) => const ServicesScreen(),
          ),
          GoRoute(
            path: SuppliersScreen.routePath,
            name: SuppliersScreen.routeName,
            builder: (context, state) => const SuppliersScreen(),
          ),
          GoRoute(
            path: EmployeesScreen.routePath,
            name: EmployeesScreen.routeName,
            builder: (context, state) => const EmployeesScreen(),
          ),
          GoRoute(
            path: UsersScreen.routePath,
            name: UsersScreen.routeName,
            builder: (context, state) => const UsersScreen(),
          ),
          GoRoute(
            path: OrdersScreen.routePath,
            name: OrdersScreen.routeName,
            builder: (context, state) => const OrdersScreen(),
          ),
          GoRoute(
            path: QuotesScreen.routePath,
            name: QuotesScreen.routeName,
            builder: (context, state) => const QuotesScreen(),
          ),
          GoRoute(
            path: InvoicesScreen.routePath,
            name: InvoicesScreen.routeName,
            builder: (context, state) => const InvoicesScreen(),
          ),
          GoRoute(
            path: ReportsScreen.routePath,
            name: ReportsScreen.routeName,
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: PaymentsScreen.routePath,
            name: PaymentsScreen.routeName,
            builder: (context, state) => const PaymentsScreen(),
          ),
          GoRoute(
            path: ChequesScreen.routePath,
            name: ChequesScreen.routeName,
            builder: (context, state) => const ChequesScreen(),
          ),
          GoRoute(
            path: RefundsScreen.routePath,
            name: RefundsScreen.routeName,
            builder: (context, state) => const RefundsScreen(),
          ),
          GoRoute(
            path: InventoryScreen.routePath,
            name: InventoryScreen.routeName,
            builder: (context, state) => const InventoryScreen(),
          ),
          GoRoute(
            path: PlanningScreen.routePath,
            name: PlanningScreen.routeName,
            builder: (context, state) => const PlanningScreen(),
          ),
          GoRoute(
            path: AccountingScreen.routePath,
            name: AccountingScreen.routeName,
            builder: (context, state) => const AccountingScreen(),
          ),
          GoRoute(
            path: DevicesScreen.routePath,
            name: DevicesScreen.routeName,
            builder: (context, state) => const DevicesScreen(),
          ),
          GoRoute(
            path: AssistantScreen.routePath,
            name: AssistantScreen.routeName,
            builder: (context, state) => const AssistantScreen(),
          ),
          GoRoute(
            path: SearchScreen.routePath,
            name: SearchScreen.routeName,
            builder: (context, state) => const SearchScreen(),
          ),
          // Sections non encore implémentées → écran générique.
          for (final section in placeholderSections)
            GoRoute(
              path: section.path,
              name: section.name,
              builder: (context, state) => PlaceholderScreen(section: section),
            ),
        ],
      ),
      // Outil de QA visuelle (hors coquille de navigation).
      GoRoute(
        path: ComponentGallery.routePath,
        name: ComponentGallery.routeName,
        builder: (context, state) => const ComponentGallery(),
      ),
    ],
  );
});
