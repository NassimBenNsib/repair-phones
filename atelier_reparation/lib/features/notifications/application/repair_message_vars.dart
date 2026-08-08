import '../../../core/format/app_formats.dart';
import '../../../l10n/app_localizations.dart';
import '../../company/domain/company_profile.dart';
import '../../repairs/domain/repair.dart';

/// Construit les variables de gabarit pour une réparation donnée.
Map<String, String> repairMessageVars(
    Repair r, CompanyProfile company, AppLocalizations l) {
  return {
    'client': r.client.isNotEmpty ? r.client : '',
    'device': r.device,
    'ref': r.reference,
    'status': r.status.label(l),
    'total': AppFormats.money(r.total),
    'balance': AppFormats.money(r.balanceDue),
    'deposit': AppFormats.money(r.deposit),
    'shop': company.name.isNotEmpty ? company.name : l.appTitle,
    'phone': company.phone,
  };
}

/// Modèle suggéré selon le statut courant (pour un pré-remplissage malin).
String? suggestedTemplateId(RepairStatus status) => switch (status) {
      RepairStatus.received => 'tpl-received',
      RepairStatus.diagnosing => 'tpl-quote',
      RepairStatus.awaitingParts => 'tpl-parts',
      RepairStatus.completed => 'tpl-ready',
      _ => null,
    };
