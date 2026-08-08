import 'package:atelier_reparation/features/clients/domain/client.dart';
import 'package:atelier_reparation/features/invoices/domain/invoice.dart';
import 'package:atelier_reparation/features/quotes/domain/quote.dart';
import 'package:atelier_reparation/features/repairs/domain/repair.dart';
import 'package:atelier_reparation/features/search/application/search.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final clients = [
    const Client(
        id: 'c1',
        type: ClientType.company,
        name: 'Emma Dubois',
        companyName: 'Dubois Informatique',
        phone: '0102030405'),
  ];
  final repairs = [
    Repair(
      reference: '#R-2048',
      device: 'iPhone 13',
      kind: DeviceKind.phone,
      client: 'Emma Dubois',
      status: RepairStatus.inProgress,
      priority: RepairPriority.normal,
      progress: 0,
      updatedLabel: '',
      hoursAgo: 1,
    ),
  ];
  final invoices = [
    Invoice(
        id: 'i1',
        number: 'FACT-2026-0001',
        clientId: 'c1',
        clientName: 'Dubois Informatique',
        status: InvoiceStatus.issued,
        date: DateTime(2026, 1, 1)),
  ];
  final quotes = [
    Quote(
        id: 'q1',
        number: 'DEVIS-2026-0001',
        clientId: 'c1',
        clientName: 'Dubois Informatique',
        date: DateTime(2026, 1, 1)),
  ];

  List<SearchHit> run(String q) => searchAll(q,
      clients: clients, repairs: repairs, invoices: invoices, quotes: quotes);

  test('empty query returns nothing', () {
    expect(run('   '), isEmpty);
  });

  test('matches a company across clients, invoices and quotes', () {
    // "informatique" appears in the company name (client/invoice/quote) but
    // not on the repair (whose client label is the civil name "Emma Dubois").
    final hits = run('informatique');
    expect(hits.map((h) => h.kind).toSet(), {
      SearchKind.client,
      SearchKind.invoice,
      SearchKind.quote,
    });
  });

  test('matches a repair by reference and device', () {
    expect(run('R-2048').single.kind, SearchKind.repair);
    expect(run('iphone').single.kind, SearchKind.repair);
  });

  test('matches an invoice by number', () {
    expect(run('FACT-2026').single.kind, SearchKind.invoice);
  });

  test('is case-insensitive and matches civil name too', () {
    // "Emma" is the civil name → matches the client (and the repair labelled
    // with it); assert the client hit is present regardless of case.
    expect(run('EMMA').any((h) => h.kind == SearchKind.client), isTrue);
  });
}
