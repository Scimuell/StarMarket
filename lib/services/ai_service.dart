import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AiMessage {
  AiMessage({required this.role, required this.content});

  final String role;
  final String content;

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

class AiService {
  static const _kBaseUrl = 'ai_base_url';
  static const _kModel = 'ai_model';
  static const _kApiKey = 'ai_api_key';

  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  Future<String> getBaseUrl() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kBaseUrl) ?? 'https://api.openai.com';
  }

  Future<void> setBaseUrl(String v) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kBaseUrl, v.replaceAll(RegExp(r'/$'), ''));
  }

  Future<String> getModel() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kModel) ?? 'gpt-4o-mini';
  }

  Future<void> setModel(String v) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kModel, v.trim());
  }

  Future<String?> getApiKey() => _secure.read(key: _kApiKey);

  Future<void> setApiKey(String? v) async {
    if (v == null || v.trim().isEmpty) {
      await _secure.delete(key: _kApiKey);
    } else {
      await _secure.write(key: _kApiKey, value: v.trim());
    }
  }

  /// OpenAI-compatible chat completions. Works with OpenAI, many proxies, LM Studio (/v1), etc.
  /// [temperature] optional; omit to use default 0.2.
  Future<String> completeChat({
    required List<AiMessage> messages,
    String? system,
    double? temperature,
  }) async {
    final key = await getApiKey();
    final base = await getBaseUrl();
    final model = await getModel();
    final uri = Uri.parse('$base/v1/chat/completions');

    final payload = <String, dynamic>{
      'model': model,
      'messages': [
        if (system != null && system.isNotEmpty)
          {'role': 'system', 'content': system},
        ...messages.map((m) => m.toJson()),
      ],
      'temperature': temperature ?? 0.2,
    };

    final headers = <String, String>{'Content-Type': 'application/json'};
    if (key != null && key.isNotEmpty) {
      headers['Authorization'] = 'Bearer $key';
    }

    final res = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(payload),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw StateError('API error ${res.statusCode}: ${res.body}');
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    final choices = decoded['choices'] as List<dynamic>?;
    final first = choices?.isNotEmpty == true ? choices!.first as Map<String, dynamic> : null;
    final msg = first?['message'] as Map<String, dynamic>?;
    final content = msg?['content'] as String?;
    if (content == null || content.isEmpty) {
      throw StateError('Empty model response.');
    }
    return content.trim();
  }
}
