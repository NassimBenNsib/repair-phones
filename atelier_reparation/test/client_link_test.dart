import 'package:atelier_reparation/features/clients/domain/client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Client.matchesLabel (Repair→Client fallback)', () {
    const company = Client(
      id: 'seed-emma',
      type: ClientType.company,
      name: 'Emma Dubois',
      companyName: 'Dubois Informatique',
      phone: '+33 7 11 22 33 44',
    );
    const individual = Client(
      id: 'seed-sofia',
      name: 'Sofia Haddad',
      phone: '+33 6 12 34 56 78',
    );

    test('company client matches BOTH civil name and company name', () {
      // Regression: repairs store the civil name ("Emma Dubois"), but the old
      // matcher only compared displayName ("Dubois Informatique") → clientId
      // was silently dropped on invoice generation.
      expect(company.matchesLabel('Emma Dubois'), isTrue);
      expect(company.matchesLabel('Dubois Informatique'), isTrue);
      expect(company.displayName, 'Dubois Informatique');
    });

    test('individual client matches its name', () {
      expect(individual.matchesLabel('Sofia Haddad'), isTrue);
      expect(individual.displayName, 'Sofia Haddad');
    });

    test('no false positives across clients', () {
      expect(company.matchesLabel('Sofia Haddad'), isFalse);
      expect(individual.matchesLabel('Dubois Informatique'), isFalse);
    });
  });
}
