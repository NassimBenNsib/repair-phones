// IN1 — validation locale des intégrations : champs requis, format URL/e-mail,
// longueur des secrets, et liaison OAuth.

import 'package:atelier_reparation/features/integrations/domain/integration.dart';
import 'package:flutter_test/flutter_test.dart';

Integration _i(IntegrationKind k, Map<String, String> config) =>
    Integration(kind: k, config: config);

void main() {
  test('champ requis manquant → missingField sur la bonne clé', () {
    final v = validateIntegration(_i(IntegrationKind.flouci, {'appId': 'a'}));
    expect(v.issue, IntegrationIssue.missingField);
    expect(v.fieldKey, 'privateToken');
  });

  test('secret trop court → tooShort', () {
    final v = validateIntegration(_i(IntegrationKind.stripe, {'secretKey': 'abc'}));
    expect(v.issue, IntegrationIssue.tooShort);
    expect(v.fieldKey, 'secretKey');
  });

  test('config complète et valide → ok', () {
    final v = validateIntegration(
        _i(IntegrationKind.flouci, {'appId': 'app_1', 'privateToken': 'tok_123456'}));
    expect(v.ok, isTrue);
    expect(v.issue, IntegrationIssue.none);
  });

  test('URL de webhook invalide → invalidUrl', () {
    final bad = validateIntegration(
        _i(IntegrationKind.slack, {'webhookUrl': 'not-a-url'}));
    expect(bad.issue, IntegrationIssue.invalidUrl);

    final good = validateIntegration(_i(
        IntegrationKind.slack, {'webhookUrl': 'https://hooks.slack.com/abc'}));
    expect(good.ok, isTrue);
  });

  test('e-mail invalide → invalidEmail', () {
    final bad = validateIntegration(
        _i(IntegrationKind.gmail, {'email': 'nope', 'appPassword': 'app-pass-1'}));
    expect(bad.issue, IntegrationIssue.invalidEmail);

    final good = validateIntegration(_i(IntegrationKind.gmail,
        {'email': 'shop@example.com', 'appPassword': 'app-pass-1'}));
    expect(good.ok, isTrue);
  });

  test('OAuth : non lié → notConnected, lié → ok', () {
    expect(validateIntegration(_i(IntegrationKind.googleDrive, {})).issue,
        IntegrationIssue.notConnected);
    expect(
        validateIntegration(
                _i(IntegrationKind.googleDrive, {'connected': 'true'}))
            .ok,
        isTrue);
  });
}
