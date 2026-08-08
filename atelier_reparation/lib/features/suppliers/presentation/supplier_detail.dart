import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../core/format/app_formats.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_avatar.dart';
import '../../../shared/widgets/apple/apple_badge.dart';
import '../../../shared/widgets/apple/apple_button.dart';
import '../../../shared/widgets/apple/apple_card.dart';
import '../../../shared/widgets/apple/apple_chip.dart';
import '../../../shared/widgets/apple/apple_list_section.dart';
import '../../../shared/widgets/apple/apple_segmented_control.dart';
import '../../../shared/widgets/apple/apple_text_field.dart';
import '../../../shared/widgets/apple/contact_info_card.dart';
import '../../../shared/widgets/apple/section_header.dart';
import '../../../core/pdf/supplier_statement_pdf.dart';
import '../../catalog/application/catalog_controller.dart';
import '../../catalog/application/product_categories_controller.dart';
import '../../catalog/domain/product.dart';
import '../../catalog/domain/product_category_node.dart';
import '../../catalog/presentation/product_detail_screen.dart';
import '../../company/application/company_controller.dart';
import '../../orders/application/orders_controller.dart';
import '../../orders/domain/purchase_order.dart';
import '../../orders/presentation/order_detail.dart';
import '../application/supplier_statement.dart';
import '../application/suppliers_controller.dart';
import '../domain/supplier.dart';

/// Placeholder du volet (deux colonnes, rien de sélectionné).
class SupplierDetailEmpty extends StatelessWidget {
  const SupplierDetailEmpty({super.key});

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
            Icon(Icons.local_shipping_outlined,
                size: 64, color: colors.tertiaryLabel),
            const SizedBox(height: 16),
            Text(l.supplierEmpty,
                style: AppleTypography.title3.copyWith(color: colors.label)),
          ],
        ),
      ),
    );
  }
}

/// Écran de détail (page poussée).
class SupplierDetailScreen extends StatelessWidget {
  const SupplierDetailScreen({super.key, required this.supplier});

  final Supplier supplier;

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
        title: Text(supplier.name),
      ),
      body: SupplierDetailView(supplierId: supplier.id),
    );
  }
}

/// Contenu réutilisable (volet ou écran) — vue + édition inline.
class SupplierDetailView extends ConsumerStatefulWidget {
  const SupplierDetailView({super.key, required this.supplierId, this.onClose});

  final String supplierId;
  final VoidCallback? onClose;

  @override
  ConsumerState<SupplierDetailView> createState() => _SupplierDetailViewState();
}

class _SupplierDetailViewState extends ConsumerState<SupplierDetailView> {
  bool _editing = false;
  late Map<String, TextEditingController> _c;
  late SupplierType _type;

  @override
  void initState() {
    super.initState();
    final s = _current();
    _type = s?.type ?? SupplierType.company;
    _c = {
      for (final k in const [
        'name', 'contact', 'phone', 'email', 'address', 'city', 'vat', 'terms', 'notes'
      ])
        k: TextEditingController(),
    };
    if (s != null) _fill(s);
  }

  Supplier? _current() {
    for (final s in ref.read(suppliersProvider)) {
      if (s.id == widget.supplierId) return s;
    }
    return null;
  }

  void _fill(Supplier s) {
    _c['name']!.text = s.name;
    _c['contact']!.text = s.contactName ?? '';
    _c['phone']!.text = s.phone;
    _c['email']!.text = s.email ?? '';
    _c['address']!.text = s.address ?? '';
    _c['city']!.text = s.city ?? '';
    _c['vat']!.text = s.vatNumber ?? '';
    _c['terms']!.text = s.paymentTerms ?? '';
    _c['notes']!.text = s.notes ?? '';
    _type = s.type;
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
    final s = _current();
    if (s == null) return;
    ref.read(suppliersProvider.notifier).update(s.copyWith(
          type: _type,
          name: _c['name']!.text.trim(),
          contactName: _opt('contact'),
          phone: _c['phone']!.text.trim(),
          email: _opt('email'),
          address: _opt('address'),
          city: _opt('city'),
          vatNumber: _opt('vat'),
          paymentTerms: _opt('terms'),
          notes: _opt('notes'),
        ));
    setState(() => _editing = false);
  }

  void _cancel() {
    final s = _current();
    if (s != null) _fill(s);
    setState(() => _editing = false);
  }

  /// Supprime le fournisseur, sauf s'il est référencé par des produits ou des
  /// commandes (garde-fou anti-orphelin).
  Future<void> _delete(Supplier s) async {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final referenced =
        ref.read(catalogProvider).any((p) => p.supplierIds.contains(s.id)) ||
            ref.read(ordersProvider).any((o) => o.supplierId == s.id);
    if (referenced) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: colors.secondaryGroupedBackground,
          content: Text(l.supplierInUse),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l.commonOk)),
          ],
        ),
      );
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: colors.secondaryGroupedBackground,
        content: Text(l.supplierDeleteConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l.commonCancel)),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l.actionDelete)),
        ],
      ),
    );
    if (ok != true) return;
    ref.read(suppliersProvider.notifier).remove(s.id);
    if (!mounted) return;
    if (widget.onClose != null) {
      widget.onClose!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final s = _current();
    if (s == null) return const SupplierDetailEmpty();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        // Barre d'actions.
        Row(
          children: [
            if (widget.onClose != null)
              IconButton(
                onPressed: widget.onClose,
                icon: Icon(Icons.close, color: colors.secondaryLabel),
              ),
            const Spacer(),
            if (_editing) ...[
              AppleButton(
                  label: l.commonCancel,
                  style: AppleButtonStyle.gray,
                  onPressed: _cancel),
              const SizedBox(width: 8),
              AppleButton(label: l.commonSave, onPressed: _save),
            ] else ...[
              IconButton(
                onPressed: () => _delete(s),
                icon: Icon(Icons.delete_outline, color: colors.red),
                tooltip: l.actionDelete,
              ),
              const SizedBox(width: 4),
              AppleButton(
                label: l.actionEdit,
                icon: Icons.edit_outlined,
                style: AppleButtonStyle.tinted,
                onPressed: () => setState(() => _editing = true),
              ),
            ],
          ],
        ),

        // En-tête.
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              AppleAvatar(name: s.name, size: 72),
              const SizedBox(height: 12),
              if (_editing)
                AppleTextField(controller: _c['name']!, label: l.supplierName)
              else
                Text(s.name,
                    textAlign: TextAlign.center,
                    style:
                        AppleTypography.title2.copyWith(color: colors.label)),
              const SizedBox(height: 8),
              if (_editing)
                AppleSegmentedControl<SupplierType>(
                  value: _type,
                  onChanged: (t) => setState(() => _type = t),
                  segments: {
                    for (final t in SupplierType.values) t: t.label(l),
                  },
                )
              else
                AppleBadge(label: s.type.label(l), color: context.accentColor),
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
                const SizedBox(height: 12),
                AppleTextField(
                    controller: _c['address']!, label: l.fieldAddress),
              ],
            ),
          )
        else
          ContactInfoCard(phone: s.phone, email: s.email, address: s.address),

        // Société.
        SectionHeader(
            title: l.supplierSectionCompany,
            padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 8)),
        AppleCard(
          child: _editing
              ? Column(
                  children: [
                    AppleTextField(
                        controller: _c['contact']!, label: l.supplierContactName),
                    const SizedBox(height: 12),
                    AppleTextField(controller: _c['vat']!, label: l.supplierVat),
                    const SizedBox(height: 12),
                    AppleTextField(
                        controller: _c['city']!, label: l.supplierCity),
                    const SizedBox(height: 12),
                    AppleTextField(
                        controller: _c['terms']!, label: l.supplierTerms),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _kv(l.supplierContactName, s.contactName, colors, l),
                    _kv(l.supplierVat, s.vatNumber, colors, l),
                    _kv(l.supplierCity, s.city, colors, l),
                    _kv(l.supplierTerms, s.paymentTerms, colors, l),
                  ],
                ),
        ),

        // Notes.
        SectionHeader(
            title: l.repairSectionNotes,
            padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 8)),
        AppleCard(
          child: _editing
              ? AppleTextField(
                  controller: _c['notes']!, minLines: 2, maxLines: 4)
              : Text(s.notes ?? l.notProvided,
                  style: AppleTypography.body
                      .copyWith(color: colors.secondaryLabel)),
        ),

        // Catalogue fourni + commandes (masqués en édition).
        if (!_editing) ...[
          _SupplierProducts(supplierId: s.id),
          _SupplierOrders(supplierId: s.id),
        ],
      ],
    );
  }

  Widget _kv(String label, String? value, AppleColors colors, AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
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

/// Produits fournis par ce fournisseur, groupés par catégorie racine ; plus les
/// produits déjà commandés (via l'historique) mais non encore liés.
class _SupplierProducts extends ConsumerWidget {
  const _SupplierProducts({required this.supplierId});
  final String supplierId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final cats = ref.watch(productCategoriesProvider.notifier);
    ref.watch(productCategoriesProvider);
    final all = ref.watch(catalogProvider);
    final linked = all.where((p) => p.supplierIds.contains(supplierId)).toList();

    // Dérivé (D) : produits commandés à ce fournisseur mais non liés.
    final linkedIds = linked.map((p) => p.id).toSet();
    final orderedIds = <String>{};
    for (final o in ref.watch(ordersProvider)) {
      if (o.supplierId != supplierId) continue;
      for (final line in o.lines) {
        if (line.productId != null) orderedIds.add(line.productId!);
      }
    }
    final derived = all
        .where((p) => orderedIds.contains(p.id) && !linkedIds.contains(p.id))
        .toList();

    // Regroupement par catégorie racine.
    final byRoot = <String, List<Product>>{};
    for (final p in linked) {
      final chain = cats.pathNodes(p.categoryId);
      final root = chain.isEmpty ? '—' : chain.first.name;
      byRoot.putIfAbsent(root, () => []).add(p);
    }

    IconData iconOf(Product p) =>
        cats.byId(p.categoryId)?.icon ?? Icons.inventory_2_outlined;
    Color tintOf(Product p) =>
        cats.byId(p.categoryId)?.color ?? colors.secondaryLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
            title: '${l.supplierProducts}  ·  ${linked.length}',
            padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 8)),
        if (linked.isEmpty && derived.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(l.notProvided,
                style: AppleTypography.subheadline
                    .copyWith(color: colors.secondaryLabel)),
          ),
        for (final entry in byRoot.entries) ...[
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(4, 8, 4, 6),
            child: Text(entry.key,
                style: AppleTypography.footnote
                    .copyWith(color: colors.secondaryLabel)),
          ),
          AppleListSection(children: [
            for (final p in entry.value)
              _ProductLine(
                icon: iconOf(p),
                tint: tintOf(p),
                title: p.name,
                subtitle: cats.path(p.categoryId),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(productId: p.id))),
              ),
          ]),
        ],
        if (derived.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(4, 12, 4, 6),
            child: Text(l.supplierOrderedProducts,
                style: AppleTypography.footnote
                    .copyWith(color: colors.secondaryLabel)),
          ),
          AppleListSection(children: [
            for (final p in derived)
              _ProductLine(
                icon: iconOf(p),
                tint: tintOf(p),
                title: p.name,
                subtitle: cats.path(p.categoryId),
                trailing: AppleButton(
                  label: l.supplierLinkProduct,
                  style: AppleButtonStyle.tinted,
                  onPressed: () => ref.read(catalogProvider.notifier).updateProduct(
                        p.id,
                        sourcing: [
                          ...p.sourcing,
                          ProductSourcing(supplierId: supplierId),
                        ],
                      ),
                ),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(productId: p.id))),
              ),
          ]),
        ],
      ],
    );
  }
}

/// Commandes fournisseur passées à ce fournisseur, + « Nouvelle commande ».
class _SupplierOrders extends ConsumerWidget {
  const _SupplierOrders({required this.supplierId});
  final String supplierId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final allOrders = ref.watch(ordersProvider);
    final orders = allOrders
        .where((o) => o.supplierId == supplierId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final statement = computeSupplierStatement(supplierId, allOrders);

    void open(String id) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: id)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 8),
          child: Row(children: [
            Expanded(child: SectionHeader(title: l.navOrders)),
            GestureDetector(
              onTap: () {
                final po = ref.read(ordersProvider.notifier).create(supplierId);
                open(po.id);
              },
              child: Text(l.orderNew,
                  style: AppleTypography.subheadline
                      .copyWith(color: context.accentColor)),
            ),
          ]),
        ),
        if (orders.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(l.notProvided,
                style: AppleTypography.subheadline
                    .copyWith(color: colors.secondaryLabel)),
          )
        else ...[
          _SupplierSummaryCard(statement: statement),
          const SizedBox(height: 8),
          AppleListSection(children: [
            for (final o in orders)
              _OrderLine(order: o, onTap: () => open(o.id)),
          ]),
          const SizedBox(height: 12),
          AppleButton(
            label: l.supplierStatementPdf,
            icon: Icons.description_outlined,
            style: AppleButtonStyle.gray,
            expand: true,
            onPressed: () => _exportSupplierStatement(context, ref, l),
          ),
        ],
        const SizedBox(height: 8),
      ],
    );
  }

  Future<void> _exportSupplierStatement(
      BuildContext context, WidgetRef ref, AppLocalizations l) async {
    Supplier? supplier;
    for (final s in ref.read(suppliersProvider)) {
      if (s.id == supplierId) {
        supplier = s;
        break;
      }
    }
    if (supplier == null) return;
    final statement = computeSupplierStatement(supplierId, ref.read(ordersProvider));
    final company = ref.read(companyProvider);
    await printSupplierStatement(
      appName: company.name.isNotEmpty ? company.name : l.appTitle,
      partyName: supplier.name,
      dateLabel: AppFormats.dateFormat.format(DateTime.now()),
      statement: statement,
      statusLabel: (s) => s.label(l),
      sellerDetails: company.headerLines,
      logo: company.hasLogo ? base64Decode(company.logo) : null,
      rtl: context.isRtl,
      labels: (
        title: l.supplierStatementTitle,
        date: l.statementDate,
        number: l.colNumber,
        status: l.statusLabel,
        amount: l.invoiceAmount,
        purchased: l.supplierPurchased,
        onOrder: l.supplierOnOrder,
        overdue: l.supplierOverdue,
        paid: l.orderPaid,
        payable: l.supplierPayable,
        bucketNotDue: l.poAgeNotDue,
        bucket1to30: l.poAge1to30,
        bucket31to60: l.poAge31to60,
        bucket60plus: l.poAge60plus,
      ),
    );
  }
}

/// Carte de synthèse achats : reçus, en commande, et vieillissement.
class _SupplierSummaryCard extends StatelessWidget {
  const _SupplierSummaryCard({required this.statement});
  final SupplierStatement statement;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;

    Widget metric(String label, double v, Color color) => Expanded(
          child: Column(children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(AppFormats.money(v, decimals: 0),
                  style: AppleTypography.title3
                      .copyWith(color: color, fontWeight: FontWeight.w600)),
            ),
            Text(label,
                textAlign: TextAlign.center,
                style: AppleTypography.caption1
                    .copyWith(color: colors.secondaryLabel)),
          ]),
        );

    String bucketLabel(PoAgeBucket b) => switch (b) {
          PoAgeBucket.notDue => l.poAgeNotDue,
          PoAgeBucket.d1to30 => l.poAge1to30,
          PoAgeBucket.d31to60 => l.poAge31to60,
          PoAgeBucket.d60plus => l.poAge60plus,
        };

    Color bucketColor(PoAgeBucket b) => switch (b) {
          PoAgeBucket.notDue => colors.secondaryLabel,
          PoAgeBucket.d1to30 => colors.orange,
          PoAgeBucket.d31to60 => colors.orange,
          PoAgeBucket.d60plus => colors.red,
        };

    List<Widget> chipsFor(Map<PoAgeBucket, double> m) => [
          for (final b in PoAgeBucket.values)
            if ((m[b] ?? 0) > 0.005)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 6, top: 6),
                child: AppleChip(
                  label:
                      '${bucketLabel(b)} · ${AppFormats.money(m[b]!, decimals: 0)}',
                  selected: false,
                  selectedColor: bucketColor(b),
                  onTap: () {},
                ),
              ),
        ];

    final deliveryChips = chipsFor(statement.aging);
    final payableChips = chipsFor(statement.payableAging);
    final hasPayable = statement.payableTtc > 0.005;

    return AppleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            metric(l.supplierPurchased, statement.purchasedTtc, colors.green),
            metric(l.supplierOnOrder, statement.onOrderTtc, colors.blue),
            if (hasPayable)
              metric(l.supplierPayable, statement.payableTtc, colors.orange),
          ]),
          if (deliveryChips.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(l.supplierOnOrder,
                style: AppleTypography.caption2
                    .copyWith(color: colors.tertiaryLabel)),
            Wrap(children: deliveryChips),
          ],
          if (payableChips.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(l.supplierPayable,
                style: AppleTypography.caption2
                    .copyWith(color: colors.tertiaryLabel)),
            Wrap(children: payableChips),
          ],
        ],
      ),
    );
  }
}

class _ProductLine extends StatelessWidget {
  const _ProductLine({
    required this.icon,
    required this.tint,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final Color tint;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 16, vertical: 10),
          child: Row(children: [
            Container(
              width: 32,
              height: 32,
              decoration: ShapeDecoration(
                color: tint.withValues(alpha: 0.16),
                shape: AppleRadii.shape(AppleRadii.sm),
              ),
              child: Icon(icon, size: 17, color: tint),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppleTypography.body.copyWith(color: colors.label)),
                  Text(subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppleTypography.footnote
                          .copyWith(color: colors.secondaryLabel)),
                ],
              ),
            ),
            if (trailing != null) trailing! else
              Icon(context.chevronForward,
                  size: 20, color: colors.tertiaryLabel),
          ]),
        ),
      ),
    );
  }
}

class _OrderLine extends StatelessWidget {
  const _OrderLine({required this.order, required this.onTap});
  final PurchaseOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 16, vertical: 10),
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.number,
                      style: AppleTypography.body.copyWith(color: colors.label)),
                  Text(AppFormats.date(order.date),
                      style: AppleTypography.footnote
                          .copyWith(color: colors.secondaryLabel)),
                ],
              ),
            ),
            AppleBadge(
                label: order.status.label(l), color: order.status.color(colors)),
            const SizedBox(width: 10),
            Text(AppFormats.money(order.totals.total),
                style: AppleTypography.subheadline
                    .copyWith(color: colors.label, fontWeight: FontWeight.w600)),
            const SizedBox(width: 6),
            Icon(context.chevronForward, size: 20, color: colors.tertiaryLabel),
          ]),
        ),
      ),
    );
  }
}
