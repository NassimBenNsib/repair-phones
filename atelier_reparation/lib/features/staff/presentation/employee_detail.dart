import 'package:atelier_reparation/core/format/app_formats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_avatar.dart';
import '../../../shared/widgets/apple/apple_badge.dart';
import '../../../shared/widgets/apple/apple_button.dart';
import '../../../shared/widgets/apple/apple_card.dart';
import '../../../shared/widgets/apple/apple_list_row.dart';
import '../../../shared/widgets/apple/apple_list_section.dart';
import '../../../shared/widgets/apple/apple_text_field.dart';
import '../../../shared/widgets/apple/contact_info_card.dart';
import '../../../shared/widgets/apple/section_header.dart';
import '../../repairs/application/repairs_controller.dart';
import '../../repairs/domain/repair.dart';
import '../../repairs/presentation/repair_detail.dart';
import '../application/employees_controller.dart';
import '../domain/employee.dart';

/// Placeholder du volet (deux colonnes, rien de sélectionné).
class EmployeeDetailEmpty extends StatelessWidget {
  const EmployeeDetailEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    return ColoredBox(
      color: colors.groupedBackground,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.badge_outlined, size: 64, color: colors.tertiaryLabel),
            const SizedBox(height: 16),
            Text(l.staffEmpty,
                style: AppleTypography.title3.copyWith(color: colors.label)),
          ],
        ),
      ),
    );
  }
}

/// Écran de détail employé (page poussée).
class EmployeeDetailScreen extends StatelessWidget {
  const EmployeeDetailScreen({super.key, required this.employee});

  final Employee employee;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    return Scaffold(
      backgroundColor: colors.groupedBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(context.backIcon, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(employee.name),
      ),
      body: EmployeeDetailView(employeeId: employee.id),
    );
  }
}

/// Contenu réutilisable (volet ou écran) — vue + édition inline.
class EmployeeDetailView extends ConsumerStatefulWidget {
  const EmployeeDetailView({super.key, required this.employeeId, this.onClose});

  final String employeeId;
  final VoidCallback? onClose;

  @override
  ConsumerState<EmployeeDetailView> createState() => _EmployeeDetailViewState();
}

class _EmployeeDetailViewState extends ConsumerState<EmployeeDetailView> {
  bool _editing = false;
  late Map<String, TextEditingController> _c;
  DateTime? _hireDate;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    _c = {
      for (final k in const ['name', 'job', 'phone', 'email', 'commission'])
        k: TextEditingController(),
    };
    final e = _current();
    if (e != null) _fill(e);
  }

  Employee? _current() {
    for (final e in ref.read(employeesProvider)) {
      if (e.id == widget.employeeId) return e;
    }
    return null;
  }

  void _fill(Employee e) {
    _c['name']!.text = e.name;
    _c['job']!.text = e.jobTitle ?? '';
    _c['phone']!.text = e.phone;
    _c['email']!.text = e.email ?? '';
    _c['commission']!.text = (e.commissionRate * 100).toStringAsFixed(0);
    _hireDate = e.hireDate;
    _active = e.active;
  }

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  String? _opt(String k) => _c[k]!.text.trim().isEmpty ? null : _c[k]!.text.trim();

  void _save() {
    final e = _current();
    if (e == null) return;
    final pct = double.tryParse(_c['commission']!.text.trim().replaceAll(',', '.')) ?? 0;
    ref.read(employeesProvider.notifier).update(e.copyWith(
          name: _c['name']!.text.trim(),
          jobTitle: _opt('job'),
          phone: _c['phone']!.text.trim(),
          email: _opt('email'),
          hireDate: _hireDate,
          commissionRate: (pct / 100).clamp(0, 1),
          active: _active,
        ));
    setState(() => _editing = false);
  }

  void _cancel() {
    final e = _current();
    if (e != null) _fill(e);
    setState(() => _editing = false);
  }

  Future<void> _pickHireDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _hireDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _hireDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final e = _current();
    if (e == null) return const EmployeeDetailEmpty();

    final assigned = ref
        .watch(repairsProvider)
        .where((r) => r.assignedTechId != null
            ? r.assignedTechId == e.id
            : r.assignedTech == e.name)
        .toList();
    final df = AppFormats.dateFormat;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        // Barre d'actions.
        Row(
          children: [
            if (widget.onClose != null)
              IconButton(
                  onPressed: widget.onClose,
                  icon: Icon(Icons.close, color: colors.secondaryLabel)),
            const Spacer(),
            if (_editing) ...[
              AppleButton(
                  label: l.commonCancel,
                  style: AppleButtonStyle.gray,
                  onPressed: _cancel),
              const SizedBox(width: 8),
              AppleButton(label: l.commonSave, onPressed: _save),
            ] else
              AppleButton(
                  label: l.actionEdit,
                  icon: Icons.edit_outlined,
                  style: AppleButtonStyle.tinted,
                  onPressed: () => setState(() => _editing = true)),
          ],
        ),

        // En-tête.
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              AppleAvatar(name: e.name, size: 72),
              const SizedBox(height: 12),
              if (_editing)
                AppleTextField(controller: _c['name']!, label: l.fieldName)
              else ...[
                Text(e.name,
                    textAlign: TextAlign.center,
                    style: AppleTypography.title2.copyWith(color: colors.label)),
                const SizedBox(height: 4),
                if (e.jobTitle != null)
                  Text(e.jobTitle!,
                      style: AppleTypography.subheadline
                          .copyWith(color: colors.secondaryLabel)),
                const SizedBox(height: 6),
                AppleBadge(
                  label: e.active ? l.staffActive : l.staffInactive,
                  color: e.active ? colors.green : colors.secondaryLabel,
                ),
              ],
            ],
          ),
        ),

        // Coordonnées.
        SectionHeader(
            title: l.clientSectionContact,
            padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 8)),
        if (_editing)
          AppleCard(
            child: Column(
              children: [
                AppleTextField(controller: _c['phone']!, label: l.fieldPhone),
                const SizedBox(height: 12),
                AppleTextField(controller: _c['email']!, label: l.fieldEmail),
              ],
            ),
          )
        else
          ContactInfoCard(phone: e.phone, email: e.email),

        // Emploi.
        SectionHeader(
            title: l.staffSectionEmployment,
            padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 8)),
        AppleCard(
          child: _editing
              ? Column(
                  children: [
                    AppleTextField(controller: _c['job']!, label: l.staffJobTitle),
                    const SizedBox(height: 12),
                    AppleTextField(
                        controller: _c['commission']!,
                        label: l.staffCommission,
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 6),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l.staffHireDate,
                          style: AppleTypography.body
                              .copyWith(color: colors.label)),
                      trailing: Text(
                          _hireDate == null ? l.notProvided : df.format(_hireDate!),
                          style: AppleTypography.body
                              .copyWith(color: context.accentColor)),
                      onTap: _pickHireDate,
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: Text(l.staffActive,
                                style: AppleTypography.body
                                    .copyWith(color: colors.label))),
                        Switch.adaptive(
                            value: _active,
                            onChanged: (v) => setState(() => _active = v)),
                      ],
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _kv(l.staffJobTitle, e.jobTitle, colors, l),
                    _kv(l.staffHireDate,
                        e.hireDate == null ? null : df.format(e.hireDate!),
                        colors, l),
                    _kv(l.staffCommission,
                        '${(e.commissionRate * 100).toStringAsFixed(0)} %',
                        colors, l),
                  ],
                ),
        ),

        // Réparations assignées.
        if (!_editing) ...[
          SectionHeader(
              title: l.staffAssignedRepairs,
              padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 8)),
          if (assigned.isEmpty)
            AppleCard(
              child: Text(l.dashboardNoRepairs,
                  style: AppleTypography.body
                      .copyWith(color: colors.secondaryLabel)),
            )
          else
            AppleListSection(
              children: [
                for (final r in assigned)
                  AppleListRow(
                    leadingIcon: r.kind.icon,
                    leadingTint: r.status.color(colors),
                    title: r.device,
                    subtitle: '${r.reference} · ${r.status.label(l)}',
                    showChevron: true,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            RepairDetailScreen(reference: r.reference),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ],
    );
  }

  Widget _kv(String label, String? value, AppleColors colors, AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: AppleTypography.subheadline
                    .copyWith(color: colors.secondaryLabel)),
          ),
          Expanded(
            child: Text(value ?? l.notProvided,
                style: AppleTypography.body.copyWith(color: colors.label)),
          ),
        ],
      ),
    );
  }
}
