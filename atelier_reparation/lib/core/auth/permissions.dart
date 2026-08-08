import '../../l10n/app_localizations.dart';

/// Permissions fonctionnelles gérées par les rôles.
enum Permission {
  manageUsers,
  manageStaff,
  manageCatalog,
  manageSuppliers,
  createRepair,
  createQuote,
  createInvoice,
  recordPayment,
  receiveOrder,
  viewReports,
  changeSettings,
}

/// Rôle applicatif : un ensemble de permissions.
enum AppRole { admin, technician, cashier }

extension AppRoleX on AppRole {
  Set<Permission> get permissions => switch (this) {
        AppRole.admin => Permission.values.toSet(),
        AppRole.technician => {
            Permission.createRepair,
            Permission.createQuote,
            Permission.manageCatalog,
            Permission.receiveOrder,
          },
        AppRole.cashier => {
            Permission.createInvoice,
            Permission.recordPayment,
            Permission.viewReports,
          },
      };

  bool can(Permission p) => permissions.contains(p);

  String label(AppLocalizations l) => switch (this) {
        AppRole.admin => l.roleAdmin,
        AppRole.technician => l.roleTechnician,
        AppRole.cashier => l.roleCashier,
      };
}
