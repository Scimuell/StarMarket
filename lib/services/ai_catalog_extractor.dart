import 'dart:convert';

import 'ai_service.dart';

/// Calls your configured AI once to turn free-form notes into [importCatalogJson]-compatible data.
class AiCatalogExtractor {
  AiCatalogExtractor({AiService? ai}) : _ai = ai ?? AiService();

  final AiService _ai;

  static const _maxChars = 120000;

  /// Returns a map ready for [AppDatabase.importCatalogJson].
  Future<Map<String, dynamic>> extractFromPlainText({
    required String rawText,
    required String patch,
  }) async {
    final trimmed = rawText.trim();
    if (trimmed.isEmpty) {
      throw StateError('File or pasted text is empty.');
    }
    if (trimmed.length > _maxChars) {
      throw StateError(
        'Text is ${trimmed.length} characters; limit is $_maxChars. Split into smaller files.',
      );
    }

    final system = '''
You extract a Star Citizen item catalog (aUEC prices per location) from the USER TEXT.
The user saved or pasted this text locally; you must not browse the web.

Output rules:
- Return exactly ONE JSON object. No markdown fences, no code blocks, no explanation before or after.
- Schema:
  {"patch":string,"items":[{"name":string,"offers":[{"location":string,"buy_auec":number|null,"sell_auec":number|null}]}]}
- "patch" must be "$patch" if applicable, else use best explicit version from text or "$patch".
- prices are whole aUEC integers only (round if needed). Use null when unknown.
- Only include rows you can map to a specific item name and location (station/shop/city as written).
- If there is no usable price data, return {"patch":"$patch","items":[]}.

''';

    final reply = await _ai.completeChat(
      system: system,
      messages: [
        AiMessage(role: 'user', content: 'USER TEXT:\n\n$trimmed'),
      ],
      temperature: 0.1,
    );

    final map = _parseCatalogObject(reply);
    if (map['items'] is! List<dynamic>) {
      throw StateError('Model JSON missing "items" list.');
    }
    return map;
  }

  Map<String, dynamic> _parseCatalogObject(String reply) {
    var s = reply.trim();
    final fence = RegExp(r'```(?:json)?\s*([\s\S]*?)```', multiLine: true);
    final m = fence.firstMatch(s);
    if (m != null) {
      s = m.group(1)!.trim();
    }
    final start = s.indexOf('{');
    final end = s.lastIndexOf('}');
    if (start < 0 || end <= start) {
      throw StateError('Could not find JSON object in model output.');
    }
    s = s.substring(start, end + 1);
    final decoded = jsonDecode(s);
    if (decoded is! Map<String, dynamic>) {
      throw StateError('Root JSON must be an object.');
    }
    return decoded;
  }
}
