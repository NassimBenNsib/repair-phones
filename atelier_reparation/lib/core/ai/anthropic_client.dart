import 'dart:convert';

import 'package:http/http.dart' as http;

/// Client minimal de l'API Messages d'Anthropic (Claude).
///
/// La clé API est fournie par l'utilisateur (stockée localement, jamais
/// journalisée). L'en-tête `anthropic-dangerous-direct-browser-access` permet
/// l'appel direct depuis le web ; en pratique, le natif reste la cible fiable.
class AnthropicClient {
  AnthropicClient({required this.apiKey, required this.model});

  final String apiKey;
  final String model;

  static final Uri _endpoint =
      Uri.parse('https://api.anthropic.com/v1/messages');

  /// Envoie [messages] (liste `{role, content}`) avec une consigne [system].
  /// Renvoie le texte concaténé de la réponse.
  Future<String> ask({
    required String system,
    required List<Map<String, String>> messages,
    int maxTokens = 1024,
  }) async {
    final res = await http.post(
      _endpoint,
      headers: {
        'content-type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'anthropic-dangerous-direct-browser-access': 'true',
      },
      body: jsonEncode({
        'model': model,
        'max_tokens': maxTokens,
        'system': system,
        'messages': messages,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Anthropic API ${res.statusCode}');
    }
    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, Object?>;
    final content = (data['content'] as List? ?? const []);
    return content
        .map((b) => (b as Map)['text']?.toString() ?? '')
        .join()
        .trim();
  }
}
