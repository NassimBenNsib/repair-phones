import '../../clients/domain/client.dart';
import '../../invoices/domain/invoice.dart';
import '../../quotes/domain/quote.dart';
import '../../repairs/domain/repair.dart';

/// Type d'entité d'un résultat de recherche.
enum SearchKind { client, repair, invoice, quote }

/// Résultat de recherche globale : type + identifiant + libellés d'affichage.
class SearchHit {
  const SearchHit({
    required this.kind,
    required this.id,
    required this.title,
    required this.subtitle,
  });

  final SearchKind kind;
  final String id; // client.id / repair.reference / invoice.id / quote.id
  final String title;
  final String subtitle;
}

/// Recherche transverse (clients, réparations, factures, devis). Fonction pure
/// (testable) ; renvoie une liste vide pour une requête vide.
List<SearchHit> searchAll(
  String query, {
  required List<Client> clients,
  required List<Repair> repairs,
  required List<Invoice> invoices,
  required List<Quote> quotes,
}) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];
  bool has(String? s) => s != null && s.toLowerCase().contains(q);

  final hits = <SearchHit>[];

  for (final c in clients) {
    if (has(c.displayName) ||
        has(c.name) ||
        has(c.phone) ||
        has(c.email) ||
        has(c.city) ||
        c.channels.any((ch) => has(ch.value))) {
      hits.add(SearchHit(
          kind: SearchKind.client,
          id: c.id,
          title: c.displayName,
          subtitle: c.phone));
    }
  }
  for (final r in repairs) {
    if (has(r.reference) || has(r.device) || has(r.client)) {
      hits.add(SearchHit(
          kind: SearchKind.repair,
          id: r.reference,
          title: r.device,
          subtitle: '${r.reference} · ${r.client}'));
    }
  }
  for (final i in invoices) {
    if (has(i.number) || has(i.clientName)) {
      hits.add(SearchHit(
          kind: SearchKind.invoice,
          id: i.id,
          title: i.number.isEmpty ? i.clientName : i.number,
          subtitle: i.clientName));
    }
  }
  for (final qt in quotes) {
    if (has(qt.number) || has(qt.clientName)) {
      hits.add(SearchHit(
          kind: SearchKind.quote,
          id: qt.id,
          title: qt.number,
          subtitle: qt.clientName));
    }
  }
  return hits;
}
