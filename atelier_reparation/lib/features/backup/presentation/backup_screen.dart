import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/backup/backup_service.dart';
import '../../../core/data/storage.dart';
import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_list_row.dart';
import '../../../shared/widgets/apple/apple_list_section.dart';
import '../../../shared/widgets/apple/apple_scaffold.dart';
import '../../accounting/application/accounting_summary.dart';
import '../../catalog/application/catalog_controller.dart';
import '../../clients/application/clients_controller.dart';
import '../../company/application/company_controller.dart';
import '../../invoices/application/invoices_controller.dart';
import '../../orders/application/orders_controller.dart';
import '../../prestations/application/service_catalog_controller.dart';
import '../../quotes/application/quotes_controller.dart';
import '../../repairs/application/repairs_controller.dart';
import '../../staff/application/employees_controller.dart';
import '../../suppliers/application/suppliers_controller.dart';
import '../../users/application/users_controller.dart';

/// Sauvegarde & export : export JSON de toutes les données, restauration, et
/// exports CSV (comptabilité, clients).
class BackupScreen extends ConsumerWidget {
  const BackupScreen({super.key});

  static const String routeName = 'backup';
  static const String routePath = '/backup';

  /// Recharge tous les contrôleurs depuis le stockage après une restauration.
  void _reloadAll(WidgetRef ref) {
    ref.invalidate(clientsProvider);
    ref.invalidate(repairsProvider);
    ref.invalidate(catalogProvider);
    ref.invalidate(serviceCatalogProvider);
    ref.invalidate(suppliersProvider);
    ref.invalidate(employeesProvider);
    ref.invalidate(usersProvider);
    ref.invalidate(ordersProvider);
    ref.invalidate(quotesProvider);
    ref.invalidate(invoicesProvider);
    ref.invalidate(companyProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;

    return AppleScaffold(
      title: l.settingsBackup,
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(
            child: AppleListSection(
              children: [
                AppleListRow(
                  leadingIcon: Icons.ios_share,
                  leadingTint: colors.blue,
                  title: l.backupExport,
                  showChevron: true,
                  onTap: () => _exportJson(context, ref, l),
                ),
                AppleListRow(
                  leadingIcon: Icons.download,
                  leadingTint: colors.green,
                  title: l.backupImport,
                  showChevron: true,
                  onTap: () => _importJson(context, ref, l),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 0),
          sliver: SliverToBoxAdapter(
            child: AppleListSection(
              children: [
                AppleListRow(
                  leadingIcon: Icons.table_chart_outlined,
                  leadingTint: colors.indigo,
                  title: l.backupExportCsvAccounting,
                  showChevron: true,
                  onTap: () => _exportAccountingCsv(context, ref, l),
                ),
                AppleListRow(
                  leadingIcon: Icons.table_chart_outlined,
                  leadingTint: colors.indigo,
                  title: l.backupExportCsvClients,
                  showChevron: true,
                  onTap: () => _exportClientsCsv(context, ref, l),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _save(String name, String ext, String content) async {
    await FileSaver.instance.saveFile(
      name: name,
      bytes: Uint8List.fromList(utf8.encode(content)),
      fileExtension: ext,
    );
  }

  Future<void> _exportJson(
      BuildContext context, WidgetRef ref, AppLocalizations l) async {
    final m = ScaffoldMessenger.of(context);
    try {
      final content = BackupService(ref.read(localStoreProvider)).exportJson();
      await _save('atelier-backup', 'json', content);
      m.showSnackBar(SnackBar(content: Text(l.backupDone)));
    } catch (_) {
      m.showSnackBar(SnackBar(content: Text(l.backupFailed)));
    }
  }

  Future<void> _importJson(
      BuildContext context, WidgetRef ref, AppLocalizations l) async {
    final m = ScaffoldMessenger.of(context);
    try {
      const group = XTypeGroup(label: 'json', extensions: ['json']);
      final file = await openFile(acceptedTypeGroups: [group]);
      if (file == null) return;
      final json = await file.readAsString();
      BackupService(ref.read(localStoreProvider)).importJson(json);
      _reloadAll(ref);
      m.showSnackBar(SnackBar(content: Text(l.backupImported)));
    } catch (_) {
      m.showSnackBar(SnackBar(content: Text(l.backupFailed)));
    }
  }

  Future<void> _exportAccountingCsv(
      BuildContext context, WidgetRef ref, AppLocalizations l) async {
    final m = ScaffoldMessenger.of(context);
    try {
      final year = DateTime.now().year;
      final s = computeYearSummary(ref.read(invoicesProvider), year);
      final sb = StringBuffer('month,${l.accountingHt},${l.accountingVat},'
          '${l.accountingTtc},count\n');
      for (var i = 0; i < 12; i++) {
        final mo = s.months[i];
        sb.writeln('${i + 1},${mo.ht.toStringAsFixed(2)},'
            '${mo.vat.toStringAsFixed(2)},${mo.ttc.toStringAsFixed(2)},${mo.count}');
      }
      await _save('comptabilite-$year', 'csv', sb.toString());
      m.showSnackBar(SnackBar(content: Text(l.backupDone)));
    } catch (_) {
      m.showSnackBar(SnackBar(content: Text(l.backupFailed)));
    }
  }

  Future<void> _exportClientsCsv(
      BuildContext context, WidgetRef ref, AppLocalizations l) async {
    final m = ScaffoldMessenger.of(context);
    try {
      final clients = ref.read(clientsProvider);
      final sb = StringBuffer('name,type,phone,email,city,vat,channels\n');
      for (final c in clients) {
        final channels =
            c.channels.map((ch) => '${ch.kind.name}:${ch.value}').join('; ');
        sb.writeln([
          c.displayName,
          c.type.name,
          c.phone,
          c.email ?? '',
          c.city ?? '',
          c.vatNumber ?? '',
          channels,
        ].map(_csv).join(','));
      }
      await _save('clients', 'csv', sb.toString());
      m.showSnackBar(SnackBar(content: Text(l.backupDone)));
    } catch (_) {
      m.showSnackBar(SnackBar(content: Text(l.backupFailed)));
    }
  }

  String _csv(String v) => '"${v.replaceAll('"', '""')}"';
}
