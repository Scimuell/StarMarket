import 'package:flutter/material.dart';

import '../db/app_db.dart';
import '../services/ai_service.dart';
import 'rare_armor_page.dart' show rareArmorContextBlob;

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key, required this.db});

  final AppDatabase db;

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final _ai = AiService();
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _msgs = <_Bubble>[];
  var _busy = false;

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _busy) return;
    setState(() {
      _busy = true;
      _msgs.add(_Bubble(role: 'user', text: text));
      _ctrl.clear();
    });
    _scrollToEnd();

    try {
      // Extract keywords from the user's message so the DB can prioritise
      // relevant items within the token budget.
      final keywords = text
          .toLowerCase()
          .replaceAll(RegExp(r'[^\w\s]'), ' ')
          .split(RegExp(r'\s+'))
          .where((w) => w.length > 2)
          .toList();

      // Groq free tier: ~6k TPM limit — keep catalog to ~4000 chars (~1000 tokens)
      // to leave headroom for the conversation + system prompt.
      // Other providers (OpenAI, local, etc.): use full 10k budget.
      final groq = await _ai.isGroq();
      final charBudget = groq ? 4000 : 10000;

      final catalog = await widget.db.catalogContextBlob(
        charBudget: charBudget,
        keywords: keywords,
      );
      final logs = await widget.db.recentLogs(limit: 10);
      final logText = logs
          .map((e) => '${e.itemName}: ${e.price} aUEC @ ${e.loggedAt.toIso8601String()} (${e.logType})')
          .join('\n');

      final system = '''
You help with Star Citizen trading questions using ONLY the local context below.
Currency is aUEC. If the context does not contain the answer, say you do not have that data locally and suggest logging prices or importing catalog data.
Do not claim live or online prices.

LOCAL CATALOG (partial, imported snapshot):
$catalog

RECENT USER LOGS:
$logText

${rareArmorContextBlob()}
''';

      final reply = await _ai.completeChat(
        system: system,
        messages: [
          ..._msgs.where((m) => m.role != 'err').map((m) => AiMessage(role: m.role == 'user' ? 'user' : 'assistant', content: m.text)),
        ],
      );

      if (!mounted) return;
      setState(() => _msgs.add(_Bubble(role: 'assistant', text: reply)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _msgs.add(_Bubble(role: 'err', text: e.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
      _scrollToEnd();
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            'Uses your catalog + recent logs as context. In Settings choose OpenAI-compatible or Google Gemini and add an API key.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(16),
            itemCount: _msgs.length,
            itemBuilder: (context, i) {
              final m = _msgs[i];
              final isUser = m.role == 'user';
              final isErr = m.role == 'err';
              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.86),
                  decoration: BoxDecoration(
                    color: isErr
                        ? Theme.of(context).colorScheme.errorContainer
                        : isUser
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SelectableText(m.text, style: TextStyle(color: isErr ? Theme.of(context).colorScheme.onErrorContainer : null)),
                ),
              );
            },
          ),
        ),
        if (_busy) const LinearProgressIndicator(minHeight: 2),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'e.g. “Where is MedPen cheapest in my catalog?”',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _busy ? null : _send,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Bubble {
  _Bubble({required this.role, required this.text});

  final String role;
  final String text;
}
