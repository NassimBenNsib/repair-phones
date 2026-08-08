import 'package:atelier_reparation/core/format/app_formats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/apple_tokens.dart';
import '../../../core/settings/layout_prefs.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/apple/apple_avatar.dart';
import '../../../shared/widgets/apple/apple_badge.dart';
import '../../../shared/widgets/apple/apple_card.dart';
import '../../../shared/widgets/apple/apple_list_section.dart';
import '../../../shared/widgets/apple/apple_scaffold.dart';
import '../../../shared/widgets/apple/apple_chip.dart';
import '../../../shared/widgets/apple/apple_search_field.dart';
import '../../../shared/widgets/apple/list_empty_state.dart';
import '../../invoices/application/invoices_controller.dart';
import '../../quotes/application/quotes_controller.dart';
import '../../repairs/application/repairs_controller.dart';
import '../application/client_payments_controller.dart';
import '../application/client_stats.dart';
import '../application/clients_controller.dart';
import '../domain/client.dart';
import '../domain/client_payment.dart';
import 'client_detail_screen.dart';
import 'client_picker_sheet.dart';

/// Segments intelligents de la liste des clients (collections utiles).
enum _ClientSegment { all, debtors, credit, inactive, business, recent }

extension _ClientSegmentX on _ClientSegment {
  String label(AppLocalizations l) => switch (this) {
        _ClientSegment.all => l.repairsFilterAll,
        _ClientSegment.debtors => l.clientSegmentDebtors,
        _ClientSegment.credit => l.clientSegmentCredit,
        _ClientSegment.inactive => l.clientSegmentInactive,
        _ClientSegment.business => l.clientSegmentBusiness,
        _ClientSegment.recent => l.clientSegmentRecent,
      };

  /// A besoin des statistiques (encours / dernière activité) pour filtrer.
  bool get needsStats =>
      this == _ClientSegment.debtors || this == _ClientSegment.inactive;

  bool get needsCredit => this == _ClientSegment.credit;
}

/// Répertoire des clients : recherche, liste, et vue maître/détail adaptative.
class ClientsScreen extends ConsumerStatefulWidget {
  const ClientsScreen({super.key});

  static const String routeName = 'clients';
  static const String routePath = '/clients';

  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  String _query = '';
  String? _selectedId;
  String? _tag;
  _ClientSegment _segment = _ClientSegment.all;

  /// Ancienneté au-delà de laquelle un client est considéré « inactif ».
  static const _inactiveAfter = Duration(days: 180);

  List<Client> _filter(List<Client> clients) {
    final q = _query.trim().toLowerCase();
    return clients.where((c) {
      final matchQ = q.isEmpty ||
          c.displayName.toLowerCase().contains(q) ||
          c.phone.contains(q);
      final matchTag = _tag == null || c.tags.contains(_tag);
      return matchQ && matchTag;
    }).toList();
  }

  bool _matchesSegment(
      Client c, ClientStats? stats, double credit, DateTime now) {
    switch (_segment) {
      case _ClientSegment.all:
        return true;
      case _ClientSegment.debtors:
        return (stats?.outstanding ?? 0) > 0.005;
      case _ClientSegment.credit:
        return credit > 0.005;
      case _ClientSegment.inactive:
        final last = stats?.lastActivity;
        return last == null || now.difference(last) > _inactiveAfter;
      case _ClientSegment.business:
        return c.isCompany;
      case _ClientSegment.recent:
        final created = c.createdAt;
        return created != null &&
            created.year == now.year &&
            created.month == now.month;
    }
  }

  /// Applique recherche + étiquette + segment. Ne calcule les statistiques que
  /// si le segment actif (ou le tableau) en a besoin — la liste/grille simple
  /// reste bon marché. Retourne aussi la table de stats pour le mode tableau.
  (List<Client>, Map<String, ClientStats>) _resolve(List<Client> clients,
      {required bool wantTableStats}) {
    final base = _filter(clients);
    final now = DateTime.now();
    final wantStats = wantTableStats || _segment.needsStats;

    final stats = <String, ClientStats>{};
    if (wantStats) {
      final invoices = ref.watch(invoicesProvider);
      final quotes = ref.watch(quotesProvider);
      final repairs = ref.watch(repairsProvider);
      for (final c in base) {
        stats[c.id] = computeClientStats(c,
            invoices: invoices, quotes: quotes, repairs: repairs);
      }
    }

    final credit = <String, double>{};
    if (_segment.needsCredit) {
      final payments = ref.watch(clientPaymentsProvider);
      for (final c in base) {
        credit[c.id] = availableCredit(c.id, payments);
      }
    }

    final results = _segment == _ClientSegment.all
        ? base
        : base
            .where((c) =>
                _matchesSegment(c, stats[c.id], credit[c.id] ?? 0, now))
            .toList();
    return (results, stats);
  }

  /// Barre de segments (collections utiles) : débiteurs, crédit, inactifs, B2B…
  Widget _segmentBar() {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final s in _ClientSegment.values)
            AppleChip(
                label: s.label(l),
                selected: _segment == s,
                onTap: () => setState(() => _segment = s)),
        ],
      ),
    );
  }

  /// Barre de filtres par étiquette (masquée si aucune étiquette n'existe).
  Widget _tagBar(List<Client> clients) {
    final tags = <String>{for (final c in clients) ...c.tags}.toList()..sort();
    if (tags.isEmpty) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          AppleChip(
              label: l.repairsFilterAll,
              selected: _tag == null,
              onTap: () => setState(() => _tag = null)),
          for (final t in tags)
            AppleChip(
                label: t,
                selected: _tag == t,
                onTap: () => setState(() => _tag = _tag == t ? null : t)),
        ],
      ),
    );
  }

  Future<void> _addClient() async {
    final created = await showAddClientSheet(context);
    if (created == null) return;
    // Détection de doublon (même téléphone ou même nom affiché).
    Client? dup;
    for (final c in ref.read(clientsProvider)) {
      final samePhone =
          created.phone.isNotEmpty && c.phone == created.phone;
      final sameName = c.displayName.toLowerCase() ==
          created.displayName.toLowerCase();
      if (samePhone || sameName) {
        dup = c;
        break;
      }
    }
    if (dup != null && mounted) {
      final l = AppLocalizations.of(context);
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: context.appleColors.secondaryGroupedBackground,
          content: Text(l.clientDuplicateWarning(dup!.displayName)),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(l.commonCancel)),
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(l.addLabel)),
          ],
        ),
      );
      if (proceed != true) return;
    }
    ref.read(clientsProvider.notifier).add(created);
  }

  void _openDetail(Client c) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ClientDetailScreen(client: c)),
      );

  /// État vide : CTA de création si le répertoire est vide, sinon « aucun
  /// résultat » (recherche/segment/étiquette actifs).
  Widget _emptyState({required bool collectionEmpty}) {
    final l = AppLocalizations.of(context);
    return collectionEmpty
        ? ListEmptyState(
            icon: Icons.people_outline,
            title: l.clientsEmpty,
            subtitle: l.clientsEmptySubtitle,
            actionLabel: l.clientsNew,
            onAction: _addClient,
          )
        : ListEmptyState(
            icon: Icons.search_off,
            title: l.listNoResults,
            subtitle: l.listNoResultsSubtitle,
          );
  }

  @override
  Widget build(BuildContext context) {
    final detailLayout =
        ref.watch(settingsControllerProvider.select((s) => s.detailLayout));
    final style =
        ref.watch(settingsControllerProvider.select((s) => s.clientsListStyle));
    return LayoutBuilder(
      builder: (context, constraints) {
        // La grille et le tableau sont des modes « pleine largeur » : ils
        // remplacent le maître/détail. Seul le mode liste utilise deux volets.
        final twoPane = style == ClientsListStyle.list &&
            detailLayout.useTwoPane(constraints.maxWidth);
        return twoPane ? _buildTwoPane(context) : _buildSinglePane(context);
      },
    );
  }

  // --- Petit / moyen écran : liste plein écran, détail poussé ---

  Widget _buildSinglePane(BuildContext context) {
    final l = AppLocalizations.of(context);
    final clients = ref.watch(clientsProvider);
    final style =
        ref.watch(settingsControllerProvider.select((s) => s.clientsListStyle));
    final (results, statsMap) =
        _resolve(clients, wantTableStats: style == ClientsListStyle.table);

    return AppleScaffold(
      title: l.clientsTitle,
      actions: [
        _ViewStyleToggle(
          style: style,
          onChanged: (v) =>
              ref.read(settingsControllerProvider.notifier).setClientsListStyle(v),
        ),
        IconButton(
          onPressed: _addClient,
          icon: Icon(Icons.person_add_alt, color: context.accentColor),
          tooltip: l.clientsNew,
        ),
      ],
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
          sliver: SliverToBoxAdapter(
            child: AppleSearchField(
              hintText: l.clientsSearch,
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
        ),
        SliverToBoxAdapter(child: _segmentBar()),
        SliverToBoxAdapter(child: _tagBar(clients)),
        if (results.isEmpty)
          SliverToBoxAdapter(
              child: _emptyState(collectionEmpty: clients.isEmpty))
        else if (style == ClientsListStyle.grid)
          SliverPadding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 24),
            sliver: SliverGrid(
              gridDelegate:
                  const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 240,
                mainAxisExtent: 132,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => _ClientCard(
                    client: results[i], onTap: () => _openDetail(results[i])),
                childCount: results.length,
              ),
            ),
          )
        else if (style == ClientsListStyle.table)
          SliverPadding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 24),
            sliver: SliverToBoxAdapter(
              child: _ClientsTable(
                clients: results,
                stats: statsMap,
                onTapClient: _openDetail,
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: AppleListSection(
                children: [
                  for (final c in results)
                    _ClientRow(client: c, onTap: () => _openDetail(c)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // --- Grand écran : maître / détail ---

  Widget _buildTwoPane(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final clients = ref.watch(clientsProvider);
    // Le mode maître/détail affiche toujours une liste (jamais le tableau).
    final (results, _) = _resolve(clients, wantTableStats: false);
    Client? shown;
    for (final c in clients) {
      if (c.id == _selectedId) {
        shown = c;
        break;
      }
    }

    final list = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(l.clientsTitle,
                    style:
                        AppleTypography.title1.copyWith(color: colors.label)),
              ),
              _ViewStyleToggle(
                style: ref.watch(settingsControllerProvider
                    .select((s) => s.clientsListStyle)),
                onChanged: (v) => ref
                    .read(settingsControllerProvider.notifier)
                    .setClientsListStyle(v),
              ),
              IconButton(
                onPressed: _addClient,
                icon: Icon(Icons.person_add_alt, color: context.accentColor),
                tooltip: l.clientsNew,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
          child: AppleSearchField(
            hintText: l.clientsSearch,
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        const SizedBox(height: 8),
        _segmentBar(),
        _tagBar(clients),
        const SizedBox(height: 8),
        Expanded(
          child: results.isEmpty
              ? _emptyState(collectionEmpty: clients.isEmpty)
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    AppleListSection(
                      children: [
                        for (final c in results)
                          _ClientRow(
                            client: c,
                            selected: c.id == shown?.id,
                            onTap: () => setState(() => _selectedId = c.id),
                          ),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );

    return ColoredBox(
      color: colors.groupedBackground,
      child: SafeArea(
        child: shown == null
            ? list
            : Row(
                children: [
                  SizedBox(width: 380, child: list),
                  VerticalDivider(
                      width: 0.5, thickness: 0.5, color: colors.separator),
                  Expanded(
                    child: ClientDetailView(
                      key: ValueKey(shown.id),
                      clientId: shown.id,
                      onClose: () => setState(() => _selectedId = null),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ClientRow extends StatelessWidget {
  const _ClientRow({
    required this.client,
    required this.onTap,
    this.selected = false,
  });

  final Client client;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected
            ? context.accentColor.withValues(alpha: 0.10)
            : Colors.transparent,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          splashColor: colors.fill,
          highlightColor: colors.fill,
          child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 16, vertical: 10),
          child: Row(
            children: [
              AppleAvatar(name: client.name),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(client.displayName,
                        style: AppleTypography.body
                            .copyWith(color: colors.label)),
                    Text(client.phone,
                        style: AppleTypography.footnote
                            .copyWith(color: colors.secondaryLabel)),
                  ],
                ),
              ),
              Icon(context.chevronForward,
                  size: 20, color: colors.tertiaryLabel),
            ],
          ),
          ),
        ),
      ),
    );
  }
}

/// Bascule liste ↔ grille dans la barre d'outils (affiche l'icône du mode
/// *suivant*, tap = basculer).
class _ViewStyleToggle extends StatelessWidget {
  const _ViewStyleToggle({required this.style, required this.onChanged});

  final ClientsListStyle style;
  final ValueChanged<ClientsListStyle> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    const values = ClientsListStyle.values;
    final next = values[(style.index + 1) % values.length];
    return IconButton(
      onPressed: () => onChanged(next),
      icon: Icon(next.icon, color: context.accentColor),
      tooltip: next.label(l),
    );
  }
}

/// Carte client (mode grille) : avatar, nom, badge de type, et téléphone ou ville.
class _ClientCard extends StatelessWidget {
  const _ClientCard({required this.client, required this.onTap});

  final Client client;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final subtitle =
        client.phone.isNotEmpty ? client.phone : (client.city ?? '');
    return AppleCard(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              AppleAvatar(name: client.name, size: 40),
              const SizedBox(width: 10),
              // Se réduit plutôt que de déborder sur les colonnes étroites.
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: AppleBadge(
                        label: client.type.label(l),
                        color: context.accentColor),
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(client.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppleTypography.subheadline.copyWith(
                      color: colors.label, fontWeight: FontWeight.w600)),
              if (subtitle.isNotEmpty)
                Text(subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppleTypography.footnote
                        .copyWith(color: colors.secondaryLabel)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Colonnes triables du tableau des clients.
enum _SortCol { name, type, phone, email, city, outstanding, activity }

/// Tableau des clients (nom · type · téléphone · e-mail · ville · impayé ·
/// dernière activité), construit avec les tokens du design system. Fonctions :
/// **tri sur toutes les colonnes** (3 états : ascendant → descendant → aucun),
/// **lignes alternées** (zébrures), **en-tête** distinct et **pied de total**
/// (nombre de clients + somme des impayés). Défilable horizontalement sur les
/// écrans étroits ; chaque ligne ouvre le détail. Statistiques fournies par
/// l'écran.
class _ClientsTable extends StatefulWidget {
  const _ClientsTable(
      {required this.clients, required this.stats, required this.onTapClient});

  final List<Client> clients;
  final Map<String, ClientStats> stats;
  final void Function(Client) onTapClient;

  @override
  State<_ClientsTable> createState() => _ClientsTableState();
}

class _ClientsTableState extends State<_ClientsTable> {
  _SortCol? _col;
  bool _asc = true;
  int _page = 0;
  static const _pageSize = 25;

  @override
  void didUpdateWidget(covariant _ClientsTable old) {
    super.didUpdateWidget(old);
    // Le jeu de résultats a changé (recherche/segment) → revenir page 1.
    if (old.clients.length != widget.clients.length) _page = 0;
  }

  // Largeurs de colonnes (px). Total = largeur minimale du tableau.
  static const _wName = 220.0;
  static const _wType = 120.0;
  static const _wPhone = 150.0;
  static const _wEmail = 220.0;
  static const _wCity = 150.0;
  static const _wOutstanding = 120.0;
  static const _wActivity = 140.0;
  static const _total = _wName +
      _wType +
      _wPhone +
      _wEmail +
      _wCity +
      _wOutstanding +
      _wActivity;

  /// Cycle 3 états : ascendant → descendant → tri désactivé.
  void _tapHeader(_SortCol c) => setState(() {
        _page = 0;
        if (_col != c) {
          _col = c;
          _asc = true;
        } else if (_asc) {
          _asc = false;
        } else {
          _col = null;
        }
      });

  double _due(Client c) => widget.stats[c.id]?.outstanding ?? 0;
  DateTime? _last(Client c) => widget.stats[c.id]?.lastActivity;

  List<Client> _sortedWith(String Function(Client) typeStr) {
    final col = _col;
    if (col == null) return widget.clients;
    final list = [...widget.clients];
    int cmp(Client a, Client b) {
      switch (col) {
        case _SortCol.name:
          return a.displayName
              .toLowerCase()
              .compareTo(b.displayName.toLowerCase());
        case _SortCol.type:
          return typeStr(a).toLowerCase().compareTo(typeStr(b).toLowerCase());
        case _SortCol.phone:
          return a.phone.toLowerCase().compareTo(b.phone.toLowerCase());
        case _SortCol.email:
          return (a.email ?? '')
              .toLowerCase()
              .compareTo((b.email ?? '').toLowerCase());
        case _SortCol.city:
          return (a.city ?? '')
              .toLowerCase()
              .compareTo((b.city ?? '').toLowerCase());
        case _SortCol.outstanding:
          return _due(a).compareTo(_due(b));
        case _SortCol.activity:
          final da = _last(a);
          final db = _last(b);
          if (da == null && db == null) return 0;
          if (da == null) return 1; // sans activité en dernier (tri asc)
          if (db == null) return -1;
          return da.compareTo(db);
      }
    }

    list.sort(cmp);
    return _asc ? list : list.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appleColors;
    final df = AppFormats.dateFormat;
    final sorted = _sortedWith((c) => c.type.label(l));
    final totalDue = widget.stats.values
        .fold<double>(0, (s, st) => s + st.outstanding);

    // Pagination : découpe le jeu trié en pages de [_pageSize].
    final paginated = sorted.length > _pageSize;
    final pageCount = paginated ? (sorted.length / _pageSize).ceil() : 1;
    final page = _page.clamp(0, pageCount - 1);
    final start = page * _pageSize;
    final end = (start + _pageSize) < sorted.length
        ? start + _pageSize
        : sorted.length;
    final visible = paginated ? sorted.sublist(start, end) : sorted;

    Widget cell(String text, double width, {Color? color}) => SizedBox(
          width: width,
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppleTypography.subheadline
                .copyWith(color: color ?? colors.label),
          ),
        );

    // En-tête cliquable (flèche + surbrillance sur la colonne de tri active).
    Widget head(String text, double width, _SortCol sort) {
      final active = _col == sort;
      return SizedBox(
        width: width,
        child: InkWell(
          onTap: () => _tapHeader(sort),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Flexible(
              child: Text(text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppleTypography.caption1.copyWith(
                      color:
                          active ? context.accentColor : colors.secondaryLabel,
                      fontWeight: FontWeight.w600)),
            ),
            if (active)
              Icon(_asc ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 12, color: context.accentColor),
          ]),
        ),
      );
    }

    // Séparateur « hairline » du design system (indenté entre les lignes,
    // pleine largeur pour isoler l'en-tête et le pied).
    Widget hair([double indent = 16]) => Divider(
        height: 0.5, thickness: 0.5, indent: indent, color: colors.separator);

    Widget navBtn(IconData icon, bool enabled, VoidCallback onTap) => InkWell(
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(icon,
                size: 18,
                color: enabled ? context.accentColor : colors.tertiaryLabel),
          ),
        );

    final countText = paginated
        ? '${start + 1}–$end / ${sorted.length}'
        : '${sorted.length} ${l.clientsTitle}';
    final prevIcon = context.isRtl ? Icons.chevron_right : Icons.chevron_left;

    return LayoutBuilder(builder: (context, constraints) {
      // Les colonnes s'étirent pour remplir la largeur disponible ; le tableau
      // ne défile horizontalement que s'il est trop étroit pour tout afficher.
      const minRow = _total + 32; // 32 = marge horizontale des lignes
      final avail = constraints.maxWidth;
      final k = avail > minRow ? (avail - 32) / _total : 1.0;
      double w(double base) => base * k;
      final rowWidth = _total * k + 32;

      final headerRow = Padding(
        padding:
            const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          head(l.fieldName, w(_wName), _SortCol.name),
          head(l.fieldType, w(_wType), _SortCol.type),
          head(l.fieldPhone, w(_wPhone), _SortCol.phone),
          head(l.fieldEmail, w(_wEmail), _SortCol.email),
          head(l.clientCity, w(_wCity), _SortCol.city),
          head(l.clientStatOutstanding, w(_wOutstanding), _SortCol.outstanding),
          head(l.clientLastActivity, w(_wActivity), _SortCol.activity),
        ]),
      );

      final rows = <Widget>[headerRow, hair(0)];
      for (var i = 0; i < visible.length; i++) {
        final c = visible[i];
        final due = _due(c);
        final last = _last(c);
        if (i > 0) rows.add(hair());
        rows.add(Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => widget.onTapClient(c),
            splashColor: colors.fill,
            highlightColor: colors.fill,
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 16, vertical: 12),
              child: Row(children: [
                SizedBox(
                  width: w(_wName),
                  child: Row(children: [
                    AppleAvatar(name: c.name, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(c.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppleTypography.subheadline
                              .copyWith(color: colors.label)),
                    ),
                  ]),
                ),
                cell(c.type.label(l), w(_wType), color: colors.secondaryLabel),
                cell(c.phone.isEmpty ? '—' : c.phone, w(_wPhone)),
                cell(c.email ?? '—', w(_wEmail), color: colors.secondaryLabel),
                cell(c.city ?? '—', w(_wCity), color: colors.secondaryLabel),
                cell(due > 0.005 ? AppFormats.money(due, decimals: 0) : '—',
                    w(_wOutstanding),
                    color:
                        due > 0.005 ? colors.orange : colors.secondaryLabel),
                cell(last == null ? '—' : df.format(last), w(_wActivity),
                    color: colors.secondaryLabel),
              ]),
            ),
          ),
        ));
      }

      // Pied : plage/nombre de clients · somme des impayés · pagination.
      final footer = Padding(
        padding:
            const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
        child: Row(children: [
          SizedBox(
            width: w(_wName),
            child: Text(countText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppleTypography.caption1.copyWith(
                    color: colors.secondaryLabel,
                    fontWeight: FontWeight.w600)),
          ),
          SizedBox(width: w(_wType + _wPhone + _wEmail + _wCity)),
          SizedBox(
            width: w(_wOutstanding),
            child: Text(AppFormats.money(totalDue, decimals: 0),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppleTypography.subheadline.copyWith(
                    color: totalDue > 0.005 ? colors.orange : colors.label,
                    fontWeight: FontWeight.w600)),
          ),
          SizedBox(
            width: w(_wActivity),
            child: paginated
                ? Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    navBtn(prevIcon, page > 0,
                        () => setState(() => _page = page - 1)),
                    Text('${page + 1}/$pageCount',
                        style: AppleTypography.caption1
                            .copyWith(color: colors.secondaryLabel)),
                    navBtn(context.chevronForward, page < pageCount - 1,
                        () => setState(() => _page = page + 1)),
                  ])
                : const SizedBox.shrink(),
          ),
        ]),
      );
      rows.add(hair(0));
      rows.add(footer);

      return AppleCard(
        padding: EdgeInsets.zero,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: rowWidth,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: rows),
          ),
        ),
      );
    });
  }
}

