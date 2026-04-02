import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/app_db.dart';
import 'item_history_page.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key, required this.db});

  final AppDatabase db;

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  Future<void> _reload() async => setState(() {});

  Future<void> _confirmDelete(BuildContext context, PriceLogRow r) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('DELETE LOG?'),
        content: Text('Remove "${r.itemName}" at ${r.price} aUEC?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await widget.db.deleteLog(r.id);
      await _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cyan = Theme.of(context).colorScheme.primary;
    final outline = Theme.of(context).colorScheme.outline;

    return Scaffold(
      body: FutureBuilder<List<PriceLogRow>>(
        future: widget.db.recentLogs(limit: 200),
        builder: (context, snap) {
          if (!snap.hasData) return Center(child: CircularProgressIndicator(color: cyan));
          final rows = snap.data!;
          if (rows.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined, color: Theme.of(context).colorScheme.onSurface, size: 40),
                  const SizedBox(height: 12),
                  Text('NO TRADE LOGS', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, letterSpacing: 2, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('Tap + to record a price observation', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 11)),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: rows.length,
            itemBuilder: (context, i) {
              final r = rows[i];
              final typeColor = r.logType == 'buy'
                  ? cyan
                  : r.logType == 'sell'
                      ? const Color(0xFF00FF9C)
                      : Theme.of(context).colorScheme.onSurface;
              return Dismissible(
                key: ValueKey(r.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Theme.of(context).colorScheme.error,
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                confirmDismiss: (_) async {
                  await _confirmDelete(context, r);
                  return false;
                },
                child: Column(
                  children: [
                    InkWell(
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ItemHistoryPage(db: widget.db, itemName: r.itemName),
                          ),
                        );
                        await _reload();
                      },
                      onLongPress: () async {
                        final ok = await _showLogDialog(context, widget.db, r);
                        if (ok == true) await _reload();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            Container(width: 2, height: 36, color: typeColor.withValues(alpha: 0.6)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r.itemName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${r.location ?? '—'} • ${_fmt(r.loggedAt)}',
                                    style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${NumberFormat.decimalPattern().format(r.price)} aUEC',
                                  style: TextStyle(color: cyan, fontFamily: 'monospace', fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: typeColor.withValues(alpha: 0.1),
                                    border: Border.all(color: typeColor.withValues(alpha: 0.3)),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Text(
                                    r.logType.toUpperCase(),
                                    style: TextStyle(color: typeColor, fontSize: 9, letterSpacing: 1.5, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.more_vert, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                          ],
                        ),
                      ),
                    ),
                    Divider(height: 1, color: outline),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final ok = await _showLogDialog(context, widget.db, null);
          if (ok == true) await _reload();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  static String _fmt(DateTime d) => DateFormat('dd MMM, HH:mm').format(d);
}

Future<bool?> _showLogDialog(BuildContext context, AppDatabase db, PriceLogRow? existing) {
  final isEdit = existing != null;
  final item = TextEditingController(text: existing?.itemName ?? '');
  final price = TextEditingController(text: existing != null ? '${existing.price}' : '');
  final loc = TextEditingController(text: existing?.location ?? '');
  final note = TextEditingController(text: existing?.note ?? '');
  String logType = existing?.logType ?? 'spot';
  DateTime when = existing?.loggedAt ?? DateTime.now();

  return showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setLocal) {
        return AlertDialog(
          title: Text(isEdit ? 'EDIT LOG' : 'LOG PRICE'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: item, decoration: const InputDecoration(labelText: 'ITEM NAME')),
                const SizedBox(height: 8),
                TextField(
                  controller: price,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'aUEC PRICE'),
                ),
                const SizedBox(height: 8),
                TextField(controller: loc, decoration: const InputDecoration(labelText: 'LOCATION (optional)')),
                const SizedBox(height: 8),
                TextField(controller: note, decoration: const InputDecoration(labelText: 'NOTE (optional)')),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: logType,
                  items: const [
                    DropdownMenuItem(value: 'spot', child: Text('OBSERVATION')),
                    DropdownMenuItem(value: 'buy', child: Text('BUY')),
                    DropdownMenuItem(value: 'sell', child: Text('SELL')),
                  ],
                  onChanged: (v) => setLocal(() => logType = v ?? 'spot'),
                  decoration: const InputDecoration(labelText: 'LOG TYPE'),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('TIMESTAMP', style: TextStyle(fontSize: 11, letterSpacing: 1, color: Theme.of(context).colorScheme.onSurface)),
                  subtitle: Text(DateFormat('dd MMM yyyy, HH:mm').format(when), style: const TextStyle(fontSize: 13)),
                  trailing: IconButton(
                    icon: Icon(Icons.edit_calendar_outlined, color: Theme.of(context).colorScheme.primary),
                    onPressed: () async {
                      final d = await showDatePicker(context: context, initialDate: when, firstDate: DateTime(2018), lastDate: DateTime(2100));
                      if (d == null) return;
                      final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(when));
                      if (t == null) return;
                      setLocal(() { when = DateTime(d.year, d.month, d.day, t.hour, t.minute); });
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
            FilledButton(
              onPressed: () async {
                final p = int.tryParse(price.text.trim().replaceAll(RegExp(r'[^0-9\-]'), ''));
                if (item.text.trim().isEmpty || p == null) { Navigator.pop(ctx, false); return; }
                if (isEdit) {
                  await db.updateLog(
                    id: existing!.id,
                    itemName: item.text.trim(),
                    price: p,
                    location: loc.text.trim().isEmpty ? null : loc.text.trim(),
                    loggedAt: when,
                    logType: logType,
                    note: note.text.trim().isEmpty ? null : note.text.trim(),
                  );
                } else {
                  await db.insertLog(
                    itemName: item.text.trim(),
                    price: p,
                    location: loc.text.trim().isEmpty ? null : loc.text.trim(),
                    loggedAt: when,
                    logType: logType,
                    note: note.text.trim().isEmpty ? null : note.text.trim(),
                  );
                }
                if (ctx.mounted) Navigator.pop(ctx, true);
              },
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    ),
  );
}
