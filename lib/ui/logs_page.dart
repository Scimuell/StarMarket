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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<PriceLogRow>>(
        future: widget.db.recentLogs(limit: 200),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final rows = snap.data!;
          if (rows.isEmpty) {
            return const Center(child: Text('No logs yet. Tap + to add a price observation.'));
          }
          return ListView.separated(
            itemCount: rows.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final r = rows[i];
              return ListTile(
                title: Text(r.itemName),
                subtitle: Text(
                  '${NumberFormat.decimalPattern().format(r.price)} aUEC • ${r.location ?? "—"} • ${_fmt(r.loggedAt)}',
                ),
                trailing: Text(r.logType, style: Theme.of(context).textTheme.labelSmall),
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ItemHistoryPage(db: widget.db, itemName: r.itemName),
                    ),
                  );
                  await _reload();
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final ok = await _showAddLogDialog(context, widget.db);
          if (ok == true) await _reload();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  static String _fmt(DateTime d) => DateFormat.yMMMd().add_jm().format(d);
}

Future<bool?> _showAddLogDialog(BuildContext context, AppDatabase db) {
  final item = TextEditingController();
  final price = TextEditingController();
  final loc = TextEditingController();
  final note = TextEditingController();
  String logType = 'spot';
  DateTime when = DateTime.now();

  return showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setLocal) {
        return AlertDialog(
          title: const Text('Log price'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: item, decoration: const InputDecoration(labelText: 'Item name')),
                TextField(
                  controller: price,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'aUEC price'),
                ),
                TextField(controller: loc, decoration: const InputDecoration(labelText: 'Location / vendor (optional)')),
                TextField(controller: note, decoration: const InputDecoration(labelText: 'Note (optional)')),
                DropdownButtonFormField<String>(
                  value: logType,
                  items: const [
                    DropdownMenuItem(value: 'spot', child: Text('Observation (spot)')),
                    DropdownMenuItem(value: 'buy', child: Text('Buy')),
                    DropdownMenuItem(value: 'sell', child: Text('Sell')),
                  ],
                  onChanged: (v) => setLocal(() => logType = v ?? 'spot'),
                  decoration: const InputDecoration(labelText: 'Log type'),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Logged time'),
                  subtitle: Text(DateFormat.yMMMd().add_jm().format(when)),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_calendar_outlined),
                    onPressed: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: when,
                        firstDate: DateTime(2018),
                        lastDate: DateTime(2100),
                      );
                      if (d == null) return;
                      final t = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(when),
                      );
                      if (t == null) return;
                      setLocal(() {
                        when = DateTime(d.year, d.month, d.day, t.hour, t.minute);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final p = int.tryParse(price.text.trim().replaceAll(RegExp(r'[^0-9\-]'), ''));
                if (item.text.trim().isEmpty || p == null) {
                  Navigator.pop(ctx, false);
                  return;
                }
                await db.insertLog(
                  itemName: item.text.trim(),
                  price: p,
                  location: loc.text.trim().isEmpty ? null : loc.text.trim(),
                  loggedAt: when,
                  logType: logType,
                  note: note.text.trim().isEmpty ? null : note.text.trim(),
                );
                if (ctx.mounted) Navigator.pop(ctx, true);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    ),
  );
}
