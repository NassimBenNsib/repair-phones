import 'dart:convert';
import 'dart:typed_data';

import 'package:atelier_reparation/core/format/app_formats.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../core/domain/line_item.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_badge.dart';
import '../../../shared/widgets/apple/apple_button.dart';
import '../../../shared/widgets/apple/apple_card.dart';
import '../../../shared/widgets/apple/apple_chip.dart';
import '../../../shared/widgets/apple/apple_list_row.dart';
import '../../../shared/widgets/apple/apple_list_section.dart';
import '../../../shared/widgets/apple/apple_menu_button.dart';
import '../../../shared/widgets/apple/apple_progress_bar.dart';
import '../../../shared/widgets/apple/apple_sheet.dart';
import '../../../shared/widgets/apple/apple_text_field.dart';
import '../../../shared/widgets/apple/contact_info_card.dart';
import '../../../shared/widgets/apple/section_header.dart';
import '../../clients/application/clients_controller.dart';
import '../../clients/domain/client.dart';
import '../../clients/presentation/client_picker_sheet.dart';
import '../../company/application/company_controller.dart';
import '../../staff/application/employees_controller.dart';
import '../../invoices/application/invoices_controller.dart';
import '../../invoices/presentation/invoice_detail.dart';
import '../../notifications/application/notification_log_controller.dart';
import '../../notifications/domain/message_template.dart';
import '../../notifications/presentation/notify_sheet.dart';
import '../../prestations/presentation/service_picker_sheet.dart';
import '../application/repair_pdf.dart';
import '../application/repairs_controller.dart';
import '../domain/repair.dart';

/// Placeholder du volet de détail (deux colonnes, rien de sélectionné).
class RepairDetailEmpty extends StatelessWidget {
  const RepairDetailEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    return ColoredBox(
      color: colors.groupedBackground,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.build_circle_outlined,
                  size: 64, color: colors.tertiaryLabel),
              const SizedBox(height: 16),
              Text(l.repairDetailSelectTitle,
                  textAlign: TextAlign.center,
                  style: AppleTypography.title3.copyWith(color: colors.label)),
              const SizedBox(height: 6),
              Text(l.repairDetailSelectSubtitle,
                  textAlign: TextAlign.center,
                  style: AppleTypography.subheadline
                      .copyWith(color: colors.secondaryLabel)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Écran de détail (navigation poussée sur petit / moyen écran).
class RepairDetailScreen extends StatelessWidget {
  const RepairDetailScreen({super.key, required this.reference});

  final String reference;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appleColors.groupedBackground,
      body: SafeArea(
        child: RepairDetailView(reference: reference, showBack: true),
      ),
    );
  }
}

/// Contenu de détail réutilisable (volet ou écran) : lecture + édition en place
/// + modes d'action.
class RepairDetailView extends ConsumerStatefulWidget {
  const RepairDetailView({
    super.key,
    required this.reference,
    this.onClose,
    this.showBack = false,
  });

  final String reference;
  final VoidCallback? onClose;
  final bool showBack;

  @override
  ConsumerState<RepairDetailView> createState() => _RepairDetailViewState();
}

class _RepairDetailViewState extends ConsumerState<RepairDetailView> {
  bool _editing = false;
  Repair? _draft;
  final Map<String, TextEditingController> _ctrls = {};

  @override
  void dispose() {
    _disposeCtrls();
    super.dispose();
  }

  void _disposeCtrls() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    _ctrls.clear();
  }

  void _initCtrls(Repair r) {
    _disposeCtrls();
    void put(String k, String? v) => _ctrls[k] = TextEditingController(text: v ?? '');
    put('device', r.device);
    put('client', r.client);
    put('clientPhone', r.clientPhone);
    put('clientEmail', r.clientEmail);
    put('reported', r.reportedIssue);
    put('diagnosis', r.diagnosis);
    put('workDone', r.workDone);
    put('brand', r.brand);
    put('model', r.model);
    put('serial', r.serial);
    put('color', r.color);
    put('storage', r.storage);
    put('condition', r.intakeCondition);
    put('passcode', r.passcode);
    put('tech', r.assignedTech);
    put('location', r.location);
    put('observations', r.observations);
    put('note', r.note);
    put('discount', r.discount == 0 ? '' : r.discount.toStringAsFixed(0));
    put('tax', (r.taxRate * 100).toStringAsFixed(0));
    put('deposit', r.deposit == 0 ? '' : r.deposit.toStringAsFixed(0));
  }

  void _startEdit(Repair r) {
    setState(() {
      _draft = r;
      _initCtrls(r);
      _editing = true;
    });
  }

  void _cancel() {
    setState(() {
      _editing = false;
      _draft = null;
      _disposeCtrls();
    });
  }

  void _save() {
    ref.read(repairsProvider.notifier).update(_collect());
    setState(() {
      _editing = false;
      _draft = null;
      _disposeCtrls();
    });
  }

  Repair _collect() {
    String s(String k) => _ctrls[k]!.text.trim();
    double d(String k) =>
        double.tryParse(_ctrls[k]!.text.trim().replaceAll(',', '.')) ?? 0;
    return _draft!.copyWith(
      device: s('device'),
      client: s('client'),
      clientPhone: s('clientPhone'),
      clientEmail: s('clientEmail'),
      reportedIssue: s('reported'),
      diagnosis: s('diagnosis'),
      workDone: s('workDone'),
      brand: s('brand'),
      model: s('model'),
      serial: s('serial'),
      color: s('color'),
      storage: s('storage'),
      intakeCondition: s('condition'),
      passcode: s('passcode'),
      assignedTech: s('tech'),
      location: s('location'),
      observations: s('observations'),
      note: s('note'),
      discount: d('discount'),
      taxRate: d('tax') / 100,
      deposit: d('deposit'),
    );
  }

  // Réparation courante (magasin en lecture, brouillon en édition).
  Repair? _current() {
    for (final r in ref.watch(repairsProvider)) {
      if (r.reference == widget.reference) return r;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final stored = _current();
    if (stored == null) {
      // Référence absente (p. ex. lien profond obsolète) : message + retour.
      return ColoredBox(
        color: colors.groupedBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.showBack)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: IconButton(
                  icon: Icon(context.backIcon, color: colors.label),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            Expanded(
              child: Center(
                child: Text(l.repairScanNotFound,
                    style: AppleTypography.subheadline
                        .copyWith(color: colors.secondaryLabel)),
              ),
            ),
          ],
        ),
      );
    }
    // En édition, les sélecteurs lisent le brouillon ; les textes, les controllers.
    final r = _editing ? _draft! : stored;

    return ColoredBox(
      color: colors.groupedBackground,
      child: Column(
        children: [
          _TopBar(
            reference: r.reference,
            editing: _editing,
            showBack: widget.showBack,
            onClose: widget.onClose,
            onEdit: () => _startEdit(stored),
            onSave: _save,
            onCancel: _cancel,
            overflow: _editing ? const [] : _buildOverflow(l, stored),
          ),
          if (_editing)
            Container(
              width: double.infinity,
              color: context.accentColor.withValues(alpha: 0.12),
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(l.editMode,
                  textAlign: TextAlign.center,
                  style: AppleTypography.footnote
                      .copyWith(color: context.accentColor)),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: _blocks(context, l, colors, r),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Blocs
  // ---------------------------------------------------------------------------

  List<Widget> _blocks(
      BuildContext context, AppLocalizations l, AppleColors colors, Repair r) {
    final tint = r.status.color(colors);
    return [
      _header(context, l, colors, r, tint),
      _client(l, colors, r),
      _problem(l, colors, r),
      if (r.status.isActive) _progress(l, colors, r, tint),
      _device(l, colors, r),
      _finance(l, colors, r),
      _logistics(l, colors, r),
      _servicesBlock(l, colors, r),
      _partsBlock(l, colors, r),
      _observations(l, colors, r),
      _notes(l, colors, r),
      if (!_editing) _comms(l, colors, r),
      if (r.events.isNotEmpty) _timeline(l, colors, r),
      const SizedBox(height: 8),
    ];
  }

  Widget _comms(AppLocalizations l, AppleColors colors, Repair r) {
    final entries = ref
        .watch(notificationLogProvider)
        .where((e) => e.repairRef == r.reference)
        .toList()
      ..sort((a, b) => b.at.compareTo(a.at));
    IconData chIcon(MessageChannel c) => switch (c) {
          MessageChannel.sms => Icons.sms,
          MessageChannel.whatsapp => Icons.chat,
          MessageChannel.email => Icons.mail_outline,
        };
    return _Section(
      title: l.repairSectionComms,
      child: AppleCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppleButton(
              label: l.repairNotify,
              icon: Icons.send,
              style: AppleButtonStyle.tinted,
              expand: true,
              onPressed: () => showNotifySheet(context, r),
            ),
            for (final e in entries) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(chIcon(e.channel),
                      size: 18, color: colors.secondaryLabel),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(e.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppleTypography.footnote
                            .copyWith(color: colors.label)),
                  ),
                  const SizedBox(width: 8),
                  Text(DateFormat('dd/MM HH:mm').format(e.at),
                      style: AppleTypography.caption1
                          .copyWith(color: colors.tertiaryLabel)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, AppLocalizations l, AppleColors colors,
      Repair r, Color tint) {
    final due = r.dueAt;
    return AppleCard(
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: ShapeDecoration(
                  color: tint.withValues(alpha: 0.16),
                  shape: AppleRadii.shape(AppleRadii.lg),
                ),
                child: Icon(r.kind.icon, color: tint, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _editing
                    ? AppleTextField(controller: _ctrls['device']!)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.device,
                              style: AppleTypography.title3
                                  .copyWith(color: colors.label)),
                          const SizedBox(height: 2),
                          Text(r.reference,
                              style: AppleTypography.footnote
                                  .copyWith(color: colors.secondaryLabel)),
                        ],
                      ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusPill(
                repair: r,
                editable: _editing,
                onTap: () => _pickStatus(context, l),
              ),
              // Progression en un tap vers l'étape suivante du flux.
              if (!_editing && r.status.next != null)
                GestureDetector(
                  onTap: () => ref
                      .read(repairsProvider.notifier)
                      .setStatus(r.reference, r.status.next!),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: ShapeDecoration(
                      color: context.accentColor.withValues(alpha: 0.14),
                      shape: AppleRadii.shape(AppleRadii.xl),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.arrow_forward,
                          size: 15, color: context.accentColor),
                      const SizedBox(width: 6),
                      Text('${l.repairAdvance} · ${r.status.next!.label(l)}',
                          style: AppleTypography.subheadline.copyWith(
                              color: context.accentColor,
                              fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              _PriorityPill(
                repair: r,
                editable: _editing,
                onTap: () => _pickPriority(context, l),
              ),
              AppleBadge(
                  label: r.paymentStatus.label(l),
                  color: r.paymentStatus.color(colors),
                  icon: Icons.euro),
              if (r.warrantyUntil != null && !_editing)
                AppleBadge(
                  label: r.isUnderWarranty
                      ? l.repairUnderWarranty
                      : l.repairWarrantyExpired,
                  color: r.isUnderWarranty ? colors.green : colors.secondaryLabel,
                  icon: Icons.verified_user_outlined,
                ),
              if (due != null)
                AppleBadge(
                  label: r.isOverdue
                      ? l.repairOverdue
                      : '${l.repairDue}: ${DateFormat('dd/MM').format(due)}',
                  color: r.isOverdue ? colors.red : colors.secondaryLabel,
                  icon: Icons.event,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _client(AppLocalizations l, AppleColors colors, Repair r) {
    return _Section(
      title: l.repairSectionClient,
      child: _editing
          ? AppleCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppleButton(
                    label: l.clientSelect,
                    icon: Icons.search,
                    style: AppleButtonStyle.gray,
                    expand: true,
                    onPressed: () => _selectClient(context),
                  ),
                  const SizedBox(height: 14),
                  _field(l.repairSectionClient, 'client', r.client,
                      colors: colors),
                  const SizedBox(height: 12),
                  _field(l.fieldPhone, 'clientPhone', r.clientPhone,
                      colors: colors),
                  const SizedBox(height: 12),
                  _field(l.fieldEmail, 'clientEmail', r.clientEmail,
                      colors: colors),
                ],
              ),
            )
          : ContactInfoCard(
              name: r.client,
              phone: r.clientPhone,
              email: r.clientEmail,
            ),
    );
  }

  Future<void> _selectClient(BuildContext context) async {
    final client = await showClientPickerSheet(context);
    if (client == null) return;
    setState(() {
      _ctrls['client']!.text = client.name;
      _ctrls['clientPhone']!.text = client.phone;
      _ctrls['clientEmail']!.text = client.email ?? '';
    });
  }

  Widget _problem(AppLocalizations l, AppleColors colors, Repair r) {
    return _Section(
      title: l.repairSectionProblem,
      child: AppleCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _field(l.repairReported, 'reported', r.reportedIssue,
                colors: colors, multiline: true),
            const SizedBox(height: 12),
            _field(l.repairDiagnosis, 'diagnosis', r.diagnosis,
                colors: colors, multiline: true),
            const SizedBox(height: 12),
            _field(l.repairWorkDone, 'workDone', r.workDone,
                colors: colors, multiline: true),
          ],
        ),
      ),
    );
  }

  Widget _progress(
      AppLocalizations l, AppleColors colors, Repair r, Color tint) {
    return _Section(
      title: l.repairSectionProgress,
      child: AppleCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${(r.progress * 100).round()} %',
                style: AppleTypography.title2.copyWith(color: colors.label)),
            const SizedBox(height: 10),
            AppleProgressBar(value: r.progress, color: tint),
          ],
        ),
      ),
    );
  }

  Widget _device(AppLocalizations l, AppleColors colors, Repair r) {
    return _Section(
      title: l.repairSectionDevice,
      child: AppleCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                  child: _field(l.productBrand, 'brand', r.brand,
                      colors: colors)),
              const SizedBox(width: 12),
              Expanded(
                  child:
                      _field(l.deviceModel, 'model', r.model, colors: colors)),
            ]),
            const SizedBox(height: 12),
            _field(l.deviceSerial, 'serial', r.serial, colors: colors),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: _field(l.deviceColor, 'color', r.color,
                      colors: colors)),
              const SizedBox(width: 12),
              Expanded(
                  child: _field(l.deviceStorage, 'storage', r.storage,
                      colors: colors)),
            ]),
            const SizedBox(height: 12),
            _field(l.repairIntakeCondition, 'condition', r.intakeCondition,
                colors: colors, multiline: true),
            const SizedBox(height: 12),
            _accessories(l, colors, r),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: _field(l.devicePasscode, 'passcode', r.passcode,
                    colors: colors, masked: !_editing),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.backupConsent,
                        style: AppleTypography.footnote
                            .copyWith(color: colors.secondaryLabel)),
                    const SizedBox(height: 6),
                    if (_editing)
                      Switch.adaptive(
                        value: r.backupConsent,
                        onChanged: (v) => setState(
                            () => _draft = _draft!.copyWith(backupConsent: v)),
                      )
                    else
                      Icon(
                        r.backupConsent ? Icons.check_circle : Icons.cancel,
                        color: r.backupConsent ? colors.green : colors.red,
                      ),
                  ],
                ),
              ),
            ]),
            if (r.photos.isNotEmpty) ...[
              const SizedBox(height: 14),
              _photos(l, colors, r),
            ],
          ],
        ),
      ),
    );
  }

  Widget _photos(AppLocalizations l, AppleColors colors, Repair r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.repairPhotos,
            style:
                AppleTypography.footnote.copyWith(color: colors.secondaryLabel)),
        const SizedBox(height: 8),
        SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: r.photos.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              // Dernière tuile : ajout.
              if (i == r.photos.length) {
                return _AddPhotoTile(
                    colors: colors, onTap: () => _addPhoto(l, r));
              }
              return _PhotoTile(
                data: _decodePhoto(r.photos[i]),
                colors: colors,
                onView: () => _viewPhoto(r, i),
                onDelete: () => _confirmRemovePhoto(l, r, i),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Décode une photo base64 ; `null` si la donnée n'est pas une image valide
  /// (tolère d'anciennes valeurs de démonstration).
  Uint8List? _decodePhoto(String data) {
    try {
      return base64Decode(data);
    } catch (_) {
      return null;
    }
  }

  /// Sélectionne une image, l'encode en base64 et l'ajoute à la réparation.
  Future<void> _addPhoto(AppLocalizations l, Repair r) async {
    const group = XTypeGroup(
      label: 'images',
      extensions: ['png', 'jpg', 'jpeg', 'webp', 'heic'],
    );
    final file = await openFile(acceptedTypeGroups: [group]);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    ref.read(repairsProvider.notifier).addPhoto(r.reference, base64Encode(bytes));
    _snack(l.repairPhotoAdded);
  }

  /// Aperçu plein écran d'une photo (fermeture au tap).
  void _viewPhoto(Repair r, int index) {
    final bytes = _decodePhoto(r.photos[index]);
    if (bytes == null) return;
    showDialog<void>(
      context: context,
      barrierColor: Colors.black,
      builder: (ctx) => GestureDetector(
        onTap: () => Navigator.of(ctx).maybePop(),
        child: InteractiveViewer(
          child: Center(child: Image.memory(bytes)),
        ),
      ),
    );
  }

  Future<void> _confirmRemovePhoto(
      AppLocalizations l, Repair r, int index) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.repairPhotoRemove),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l.commonCancel)),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l.actionDelete)),
        ],
      ),
    );
    if (ok != true) return;
    ref.read(repairsProvider.notifier).removePhoto(r.reference, index);
  }

  Widget _finance(AppLocalizations l, AppleColors colors, Repair r) {
    Widget line(String label, String value, {bool bold = false, Color? c}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Text(label,
                  style: (bold
                          ? AppleTypography.headline
                          : AppleTypography.subheadline)
                      .copyWith(color: c ?? colors.secondaryLabel)),
              const Spacer(),
              Text(value,
                  style: (bold
                          ? AppleTypography.headline
                          : AppleTypography.subheadline)
                      .copyWith(
                          color: c ?? colors.label,
                          fontWeight: bold ? FontWeight.w700 : FontWeight.w600)),
            ],
          ),
        );

    return _Section(
      title: l.repairSectionFinance,
      trailing: AppleBadge(
          label: r.paymentStatus.label(l), color: r.paymentStatus.color(colors)),
      child: AppleCard(
        child: Column(
          children: [
            line('${l.repairSectionParts} (${r.parts.length})',
                AppFormats.money(r.partsTotal, decimals: 0)),
            line('${l.financeLabour} (${r.services.length})',
                AppFormats.money(r.servicesTotal, decimals: 0)),
            if (_editing) ...[
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                    child: AppleTextField(
                        controller: _ctrls['discount']!,
                        label: l.financeDiscount,
                        suffix: AppFormats.symbol,
                        keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(
                    child: AppleTextField(
                        controller: _ctrls['tax']!,
                        label: l.financeTax,
                        suffix: '%',
                        keyboardType: TextInputType.number)),
              ]),
              const SizedBox(height: 8),
            ] else ...[
              if (r.discount > 0)
                line(l.financeDiscount, '-${AppFormats.money(r.discount, decimals: 0)}'),
              line('${l.financeTax} (${(r.taxRate * 100).toStringAsFixed(0)}%)',
                  AppFormats.money(r.taxAmount, decimals: 0)),
            ],
            Divider(height: 18, color: colors.separator),
            line(l.financeTotal, AppFormats.money(r.total, decimals: 0),
                bold: true),
            const SizedBox(height: 6),
            if (_editing)
              AppleTextField(
                  controller: _ctrls['deposit']!,
                  label: l.financeDeposit,
                  suffix: AppFormats.symbol,
                  keyboardType: TextInputType.number)
            else
              line(l.financeDeposit, AppFormats.money(r.deposit, decimals: 0)),
            line(l.financeBalance, AppFormats.money(r.balanceDue, decimals: 0),
                c: r.balanceDue > 0 ? colors.red : colors.green),
            if (_editing) ...[
              const SizedBox(height: 10),
              _PaymentPicker(
                value: r.paymentStatus,
                onChanged: (p) =>
                    setState(() => _draft = _draft!.copyWith(paymentStatus: p)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _logistics(AppLocalizations l, AppleColors colors, Repair r) {
    return _Section(
      title: l.repairSectionLogistics,
      child: AppleCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                  child: _field(l.repairAssignedTech, 'tech', r.assignedTech,
                      colors: colors, placeholder: l.unassigned)),
              const SizedBox(width: 12),
              Expanded(
                  child: _field(l.repairLocation, 'location', r.location,
                      colors: colors)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.repairDue,
                        style: AppleTypography.footnote
                            .copyWith(color: colors.secondaryLabel)),
                    const SizedBox(height: 6),
                    if (_editing)
                      _DateField(
                        value: r.dueAt,
                        onPick: (d) =>
                            setState(() => _draft = _draft!.copyWith(dueAt: d)),
                      )
                    else
                      Text(
                        r.dueAt == null
                            ? l.notProvided
                            : AppFormats.dateFormat.format(r.dueAt!),
                        style: AppleTypography.body
                            .copyWith(color: colors.label),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.repairWarranty,
                        style: AppleTypography.footnote
                            .copyWith(color: colors.secondaryLabel)),
                    const SizedBox(height: 6),
                    Text(
                      r.warrantyMonths == null
                          ? l.notProvided
                          : l.warrantyDuration(r.warrantyMonths!),
                      style:
                          AppleTypography.body.copyWith(color: colors.label),
                    ),
                    if (r.warrantyUntil != null)
                      Text(
                        l.repairWarrantyUntil(
                            AppFormats.dateFormat.format(r.warrantyUntil!)),
                        style: AppleTypography.footnote.copyWith(
                            color: r.isUnderWarranty
                                ? colors.green
                                : colors.red),
                      ),
                  ],
                ),
              ),
            ]),
            if (r.createdBy != null && !_editing) ...[
              const SizedBox(height: 12),
              Text('${l.repairCreatedBy}: ${r.createdBy}',
                  style: AppleTypography.footnote
                      .copyWith(color: colors.secondaryLabel)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _servicesBlock(AppLocalizations l, AppleColors colors, Repair r) {
    return _Section(
      title: l.repairSectionServices,
      child: Column(
        children: [
          if (r.services.isEmpty && !_editing)
            _muted(l.repairNoServices, colors)
          else
            AppleListSection(
              children: [
                for (var i = 0; i < r.services.length; i++)
                  AppleListRow(
                    leadingIcon: Icons.handyman,
                    leadingTint: colors.blue,
                    title: r.services[i].label,
                    trailingText: AppFormats.money(r.services[i].price, decimals: 0),
                    onTap: _editing ? () => _removeService(i) : null,
                    showChevron: false,
                  ),
              ],
            ),
          if (_editing)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: AppleButton(
                label: l.addPrestation,
                icon: Icons.add,
                style: AppleButtonStyle.tinted,
                onPressed: () => _addService(context, l),
              ),
            ),
        ],
      ),
    );
  }

  Widget _partsBlock(AppLocalizations l, AppleColors colors, Repair r) {
    return _Section(
      title: l.repairSectionParts,
      child: Column(
        children: [
          if (r.parts.isEmpty && !_editing)
            _muted(l.repairNoParts, colors)
          else
            AppleListSection(
              children: [
                for (var i = 0; i < r.parts.length; i++)
                  AppleListRow(
                    leadingIcon: Icons.memory,
                    leadingTint: colors.indigo,
                    title: r.parts[i].label,
                    subtitle:
                        '${r.parts[i].quantity} × ${AppFormats.money(r.parts[i].unitPrice)}',
                    trailingText: AppFormats.money(r.parts[i].total, decimals: 0),
                    onTap: _editing ? () => _removePart(i) : null,
                  ),
              ],
            ),
          if (_editing)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: AppleButton(
                label: l.addPart,
                icon: Icons.add,
                style: AppleButtonStyle.tinted,
                onPressed: () => _addPart(context, l),
              ),
            ),
        ],
      ),
    );
  }

  Widget _observations(AppLocalizations l, AppleColors colors, Repair r) {
    return _Section(
      title: l.repairSectionObservations,
      child: _editing
          ? AppleCard(
              child: AppleTextField(
                  controller: _ctrls['observations']!, minLines: 2, maxLines: 4))
          : _muted(
              (r.observations?.isNotEmpty ?? false)
                  ? r.observations!
                  : l.repairNoObservations,
              colors),
    );
  }

  Widget _notes(AppLocalizations l, AppleColors colors, Repair r) {
    return _Section(
      title: l.repairSectionNotes,
      child: _editing
          ? AppleCard(
              child: AppleTextField(
                  controller: _ctrls['note']!, minLines: 2, maxLines: 4))
          : _muted(
              (r.note?.isNotEmpty ?? false) ? r.note! : l.repairNoNotes, colors),
    );
  }

  /// Libellé localisé d'un événement de suivi (à partir du type + détail).
  String _eventLabel(AppLocalizations l, RepairEvent e) {
    switch (e.type) {
      case RepairEventType.created:
        return e.label ?? l.repairEventCreated;
      case RepairEventType.status:
        final s = RepairStatus.values
            .firstWhere((v) => v.name == e.detail, orElse: () => RepairStatus.received);
        return l.repairEventStatus(s.label(l));
      case RepairEventType.tech:
        return e.detail == null
            ? l.repairEventTechCleared
            : l.repairEventTech(e.detail!);
      case RepairEventType.payment:
        final p = PaymentStatus.values
            .firstWhere((v) => v.name == e.detail, orElse: () => PaymentStatus.unpaid);
        return l.repairEventPayment(p.label(l));
      case RepairEventType.photo:
        return l.repairEventPhoto;
      case RepairEventType.note:
        return e.label ?? '';
    }
  }

  IconData _eventIcon(RepairEvent e) {
    switch (e.type) {
      case RepairEventType.status:
        return RepairStatus.values
            .firstWhere((v) => v.name == e.detail, orElse: () => RepairStatus.received)
            .icon;
      case RepairEventType.tech:
        return Icons.person_outline;
      case RepairEventType.payment:
        return Icons.payments_outlined;
      case RepairEventType.created:
        return Icons.add_task;
      case RepairEventType.photo:
        return Icons.photo_camera_outlined;
      case RepairEventType.note:
        return e.icon;
    }
  }

  Widget _timeline(AppLocalizations l, AppleColors colors, Repair r) {
    final accent = context.accentColor;
    final events = [...r.events]..sort((a, b) => b.at.compareTo(a.at));
    return _Section(
      title: l.repairSectionTimeline,
      child: AppleCard(
        child: Column(
          children: [
            for (var i = 0; i < events.length; i++)
              Padding(
                padding: EdgeInsets.only(bottom: i == events.length - 1 ? 0 : 14),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.16),
                          shape: BoxShape.circle),
                      child: Icon(_eventIcon(events[i]), size: 15, color: accent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(_eventLabel(l, events[i]),
                            style: AppleTypography.body
                                .copyWith(color: colors.label))),
                    Text(DateFormat('dd/MM HH:mm').format(events[i].at),
                        style: AppleTypography.footnote
                            .copyWith(color: colors.secondaryLabel)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Champ générique (lecture / édition)
  // ---------------------------------------------------------------------------

  Widget _field(
    String label,
    String key,
    String? value, {
    required AppleColors colors,
    bool multiline = false,
    bool masked = false,
    String? placeholder,
  }) {
    if (_editing) {
      return AppleTextField(
        controller: _ctrls[key]!,
        label: label,
        minLines: 1,
        maxLines: multiline ? 4 : 1,
      );
    }
    final has = value != null && value.isNotEmpty;
    final shown = !has
        ? (placeholder ?? _localizedNotProvided(colors))
        : (masked ? '••••' : value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                AppleTypography.footnote.copyWith(color: colors.secondaryLabel)),
        const SizedBox(height: 2),
        Text(shown,
            style: AppleTypography.body
                .copyWith(color: has ? colors.label : colors.tertiaryLabel)),
      ],
    );
  }

  String _localizedNotProvided(AppleColors colors) =>
      AppLocalizations.of(context).notProvided;

  Widget _accessories(AppLocalizations l, AppleColors colors, Repair r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.deviceAccessories,
            style:
                AppleTypography.footnote.copyWith(color: colors.secondaryLabel)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < r.accessories.length; i++)
              _editing
                  ? AppleChip(
                      label: r.accessories[i],
                      selected: false,
                      onTap: () => _removeAccessory(i),
                    )
                  : AppleBadge(
                      label: r.accessories[i], color: colors.secondaryLabel),
            if (_editing)
              AppleChip(
                  label: '＋',
                  selected: true,
                  onTap: () => _addAccessory(context, l)),
            if (r.accessories.isEmpty && !_editing)
              Text(l.notProvided,
                  style: AppleTypography.body
                      .copyWith(color: colors.tertiaryLabel)),
          ],
        ),
      ],
    );
  }

  Widget _muted(String text, AppleColors colors) => AppleCard(
        child: Text(text,
            style:
                AppleTypography.body.copyWith(color: colors.secondaryLabel)),
      );

  // ---------------------------------------------------------------------------
  // Actions / pickers
  // ---------------------------------------------------------------------------

  void _snack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  List<Widget> _buildOverflow(AppLocalizations l, Repair r) {
    return [
      AppleMenuButton<String>(
        label: '',
        icon: Icons.more_horiz,
        value: '',
        options: {
          if (r.status.isActive)
            'complete': l.repairMarkComplete
          else
            'reopen': l.actionReopen,
          'notify': l.repairNotify,
          'assign': l.actionAssign,
          'photo': l.actionAddPhoto,
          'invoice': l.actionGenerateInvoice,
          'print': l.actionPrintLabel,
          'delete': l.actionDelete,
        },
        onSelected: (k) => _onOverflow(k, l, r),
        anchorBuilder: (context, controller) => IconButton(
          icon: Icon(Icons.more_horiz, color: context.appleColors.label),
          onPressed: () =>
              controller.isOpen ? controller.close() : controller.open(),
        ),
      ),
    ];
  }

  void _onOverflow(String key, AppLocalizations l, Repair r) {
    final ctrl = ref.read(repairsProvider.notifier);
    switch (key) {
      case 'complete':
        ctrl.setStatus(r.reference, RepairStatus.completed);
      case 'reopen':
        ctrl.setStatus(r.reference, RepairStatus.inProgress);
      case 'assign':
        _assignTech(l, r);
      case 'notify':
        showNotifySheet(context, r);
      case 'photo':
        _addPhoto(l, r);
      case 'invoice':
        _generateInvoice(r);
      case 'print':
        _printRepair(l, r);
      case 'delete':
        ctrl.remove(r.reference);
        widget.onClose?.call();
        if (widget.showBack) Navigator.of(context).maybePop();
      default:
        _snack(l.comingSoonTitle);
    }
  }

  /// Résout le client d'une réparation (lien fort par id, sinon par libellé).
  Client? _resolveClient(Repair r) {
    for (final c in ref.read(clientsProvider)) {
      if (r.clientId != null ? c.id == r.clientId : c.matchesLabel(r.client)) {
        return c;
      }
    }
    return null;
  }

  /// Propose le format d'impression (fiche Pro A4 / ticket QR) puis génère.
  Future<void> _printRepair(AppLocalizations l, Repair r) async {
    final choice = await showAppleSelectionSheet<String>(
      context: context,
      title: l.repairPrintChoose,
      selected: '',
      options: [
        AppleSheetOption('pro', l.repairSheetTitle,
            leading: const Icon(Icons.description_outlined)),
        AppleSheetOption('ticket', l.repairTicketTitle,
            leading: const Icon(Icons.receipt_long_outlined)),
      ],
    );
    if (choice == null || !mounted) return;
    final client = _resolveClient(r);
    final company = ref.read(companyProvider);
    final rtl = context.isRtl;
    if (choice == 'pro') {
      await printRepairSheet(
          repair: r, client: client, company: company, l: l, rtl: rtl);
    } else {
      await printRepairTicket(
          repair: r, client: client, company: company, l: l, rtl: rtl);
    }
  }

  /// Génère une facture brouillon à partir des prestations et pièces.
  void _generateInvoice(Repair r) {
    // Lien fort par id si présent ; sinon repli par libellé (couvre société).
    String clientId = r.clientId ?? '';
    String clientName = r.client;
    for (final c in ref.read(clientsProvider)) {
      if (clientId.isNotEmpty ? c.id == clientId : c.matchesLabel(r.client)) {
        clientId = c.id;
        clientName = c.displayName;
        break;
      }
    }
    final lines = <LineItem>[
      for (final s in r.services)
        LineItem(
            id: const Uuid().v4(),
            label: s.label,
            unitPrice: s.price,
            taxRate: r.taxRate),
      for (final p in r.parts)
        LineItem(
            id: const Uuid().v4(),
            label: p.label,
            qty: p.quantity.toDouble(),
            unitPrice: p.unitPrice,
            taxRate: r.taxRate),
    ];
    final invoice = ref.read(invoicesProvider.notifier).createFrom(
          clientId: clientId,
          clientName: clientName,
          lines: lines,
          repairId: r.reference,
          discount: r.discount,
          taxRate: r.taxRate,
          deposit: r.deposit,
        );
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => InvoiceDetailScreen(invoiceId: invoice.id)));
  }

  Future<void> _pickStatus(BuildContext context, AppLocalizations l) async {
    final colors = context.appleColors;
    final choice = await showAppleSelectionSheet<RepairStatus>(
      context: context,
      title: l.statusLabel,
      selected: (_editing ? _draft! : _current()!).status,
      options: [
        for (final s in RepairStatus.values)
          AppleSheetOption(s, s.label(l),
              leading: Icon(Icons.circle, size: 14, color: s.color(colors))),
      ],
    );
    if (choice == null) return;
    if (_editing) {
      setState(() => _draft = _draft!.copyWith(status: choice));
    } else {
      ref.read(repairsProvider.notifier).setStatus(widget.reference, choice);
    }
  }

  Future<void> _pickPriority(BuildContext context, AppLocalizations l) async {
    if (!_editing) return;
    final choice = await showAppleSelectionSheet<RepairPriority>(
      context: context,
      title: l.repairPriority,
      selected: _draft!.priority,
      options: [
        for (final p in RepairPriority.values) AppleSheetOption(p, p.label(l)),
      ],
    );
    if (choice != null) {
      setState(() => _draft = _draft!.copyWith(priority: choice));
    }
  }

  Future<void> _assignTech(AppLocalizations l, Repair r) async {
    final controller = TextEditingController(text: r.assignedTech ?? '');
    final name = await showAppleSheet<String>(
      context: context,
      title: l.actionAssign,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppleTextField(controller: controller, label: l.repairAssignedTech),
            const SizedBox(height: 16),
            AppleButton(
              label: l.commonSave,
              expand: true,
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (name != null) {
      // Résout l'id de l'employé par nom pour un lien fort (repli : libellé).
      String? techId;
      if (name.isNotEmpty) {
        for (final e in ref.read(employeesProvider)) {
          if (e.name == name) {
            techId = e.id;
            break;
          }
        }
      }
      ref
          .read(repairsProvider.notifier)
          .assignTech(r.reference, name.isEmpty ? null : name, techId: techId);
    }
  }

  // Ajout / suppression de lignes (édition).
  void _removeService(int i) => setState(() {
        final list = [..._draft!.services]..removeAt(i);
        _draft = _draft!.copyWith(services: list);
      });

  void _removePart(int i) => setState(() {
        final list = [..._draft!.parts]..removeAt(i);
        _draft = _draft!.copyWith(parts: list);
      });

  void _removeAccessory(int i) => setState(() {
        final list = [..._draft!.accessories]..removeAt(i);
        _draft = _draft!.copyWith(accessories: list);
      });

  Future<void> _addService(BuildContext context, AppLocalizations l) async {
    // Sélecteur de prestation (catalogue seedé + saisie manuelle).
    final service = await showServicePickerSheet(context);
    if (service != null) {
      setState(() => _draft = _draft!
          .copyWith(services: [..._draft!.services, service]));
    }
  }

  Future<void> _addPart(BuildContext context, AppLocalizations l) async {
    final res = await _labelPriceSheet(context, l, l.addPart);
    if (res != null) {
      setState(() => _draft = _draft!.copyWith(parts: [
            ..._draft!.parts,
            RepairPart(label: res.$1, unitPrice: res.$2),
          ]));
    }
  }

  Future<void> _addAccessory(BuildContext context, AppLocalizations l) async {
    final controller = TextEditingController();
    final name = await showAppleSheet<String>(
      context: context,
      title: l.deviceAccessories,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppleTextField(controller: controller),
            const SizedBox(height: 16),
            AppleButton(
                label: l.addLabel,
                expand: true,
                onPressed: () =>
                    Navigator.of(context).pop(controller.text.trim())),
          ],
        ),
      ),
    );
    controller.dispose();
    if (name != null && name.isNotEmpty) {
      setState(() => _draft =
          _draft!.copyWith(accessories: [..._draft!.accessories, name]));
    }
  }

  Future<(String, double)?> _labelPriceSheet(
      BuildContext context, AppLocalizations l, String title) {
    final label = TextEditingController();
    final price = TextEditingController();
    return showAppleSheet<(String, double)>(
      context: context,
      title: title,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppleTextField(controller: label, label: l.variantLabel),
            const SizedBox(height: 12),
            AppleTextField(
                controller: price,
                label: '${l.priceLabel} (${AppFormats.symbol})',
                suffix: AppFormats.symbol,
                keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            AppleButton(
              label: l.addLabel,
              expand: true,
              onPressed: () {
                final lbl = label.text.trim();
                final p =
                    double.tryParse(price.text.trim().replaceAll(',', '.')) ?? 0;
                if (lbl.isNotEmpty) Navigator.of(context).pop((lbl, p));
              },
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      label.dispose();
      price.dispose();
    });
  }
}

// -----------------------------------------------------------------------------
// Petits widgets
// -----------------------------------------------------------------------------

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.trailing});
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 8),
          child: Row(
            children: [
              Expanded(child: SectionHeader(title: title, padding: EdgeInsets.zero)),
              ?trailing,
            ],
          ),
        ),
        child,
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.reference,
    required this.editing,
    required this.showBack,
    required this.onClose,
    required this.onEdit,
    required this.onSave,
    required this.onCancel,
    required this.overflow,
  });

  final String reference;
  final bool editing;
  final bool showBack;
  final VoidCallback? onClose;
  final VoidCallback onEdit;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final List<Widget> overflow;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final accent = context.accentColor;

    return Container(
      height: 52,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.separator, width: 0.5)),
      ),
      child: Row(
        children: [
          if (editing)
            TextButton(onPressed: onCancel, child: Text(l.commonCancel))
          else if (showBack)
            IconButton(
                icon: Icon(context.backIcon, size: 20, color: colors.label),
                onPressed: () => Navigator.of(context).maybePop())
          else if (onClose != null)
            IconButton(
                icon: Icon(Icons.close, color: colors.secondaryLabel),
                onPressed: onClose),
          Expanded(
            child: Text(
              editing ? l.actionEdit : reference,
              textAlign: TextAlign.center,
              style: AppleTypography.headline.copyWith(color: colors.label),
            ),
          ),
          if (editing)
            TextButton(
              onPressed: onSave,
              child: Text(l.commonSave,
                  style: TextStyle(color: accent, fontWeight: FontWeight.w600)),
            )
          else ...[
            TextButton(onPressed: onEdit, child: Text(l.actionEdit)),
            ...overflow,
          ],
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill(
      {required this.repair, required this.editable, required this.onTap});
  final Repair repair;
  final bool editable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final c = repair.status.color(colors);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 5),
        decoration: ShapeDecoration(
            color: c.withValues(alpha: 0.15),
            shape: AppleRadii.shape(AppleRadii.sm)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(repair.status.label(l),
                style: AppleTypography.caption1
                    .copyWith(color: c, fontWeight: FontWeight.w600)),
            Icon(Icons.expand_more, size: 15, color: c),
          ],
        ),
      ),
    );
  }
}

class _PriorityPill extends StatelessWidget {
  const _PriorityPill(
      {required this.repair, required this.editable, required this.onTap});
  final Repair repair;
  final bool editable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final c = repair.priority.color(colors);
    final pill = AppleBadge(
        label: '${l.repairPriority}: ${repair.priority.label(l)}', color: c);
    return editable ? GestureDetector(onTap: onTap, child: pill) : pill;
  }
}

class _PaymentPicker extends StatelessWidget {
  const _PaymentPicker({required this.value, required this.onChanged});
  final PaymentStatus value;
  final ValueChanged<PaymentStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    return Wrap(
      spacing: 8,
      children: [
        for (final p in PaymentStatus.values)
          AppleChip(
            label: p.label(l),
            selected: p == value,
            selectedColor: p.color(colors),
            onTap: () => onChanged(p),
          ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.value, required this.onPick});
  final DateTime? value;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: now.subtract(const Duration(days: 365)),
          lastDate: now.add(const Duration(days: 365)),
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding:
            const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 11),
        decoration: ShapeDecoration(
            color: colors.fill, shape: AppleRadii.shape(AppleRadii.md)),
        child: Row(
          children: [
            Icon(Icons.event, size: 18, color: colors.secondaryLabel),
            const SizedBox(width: 8),
            Text(
              value == null
                  ? '—'
                  : AppFormats.dateFormat.format(value!),
              style: AppleTypography.body.copyWith(color: colors.label),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tuile photo : miniature cliquable (aperçu) avec bouton de suppression.
class _PhotoTile extends StatelessWidget {
  const _PhotoTile(
      {required this.data,
      required this.colors,
      required this.onView,
      required this.onDelete});
  final Uint8List? data;
  final AppleColors colors;
  final VoidCallback onView;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data == null ? null : onView,
      child: SizedBox(
        width: 64,
        height: 64,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRSuperellipse(
              borderRadius: BorderRadius.circular(AppleRadii.md),
              child: data == null
                  ? Container(
                      color: colors.fill,
                      child: Icon(Icons.broken_image_outlined,
                          color: colors.tertiaryLabel))
                  : Image.memory(data!, fit: BoxFit.cover),
            ),
            PositionedDirectional(
              top: 2,
              end: 2,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                      color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.close,
                      size: 12, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tuile "ajouter une photo".
class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({required this.colors, required this.onTap});
  final AppleColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: ShapeDecoration(
            color: colors.fill, shape: AppleRadii.shape(AppleRadii.md)),
        child: Icon(Icons.add_a_photo_outlined, color: colors.secondaryLabel),
      ),
    );
  }
}
