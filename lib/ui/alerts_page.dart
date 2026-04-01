import 'package:flutter/material.dart';

import '../db/app_db.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key, required this.db});

  final AppDatabase db;

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  Future<void> _reload() async => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<AlertRow>>(
        future: widget.db.allAlerts(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final rows = snap.data!;
          if (rows.isEmpty) {
            return const Center(child: Text('No alerts. Add a target and we will check it when you open the app.'));
          }
          return ListView.separated(
            itemCount: rows.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final r = rows[i];
              final when = r.fireWhen == 'below_or_equal' ? '≤' : '≥';
              return ListTile(
                title: Text(r.itemName),
                subtitle: Text('Notify when latest log is $when ${r.targetAuec} aUEC'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await widget.db.deleteAlert(r.id);
                    await _reload();
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final ok = await _showAdd(context, widget.db);
          if (ok == true) await _reload();
        },
        child: const Icon(Icons.add_alert_outlined),
      ),
    );
  }
}

Future<bool?> _showAdd(BuildContext context, AppDatabase db) {
  final item = TextEditingController();
  final target = TextEditingController();
  var mode = 'below_or_equal';

  return showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setLocal) {
        return AlertDialog(
          title: const Text('New alert'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: item,
                decoration: const InputDecoration(
                  labelText: 'Item name (matches your logs, case-insensitive)',
                ),
              ),
              TextField(
                controller: target,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Target aUEC'),
              ),
              DropdownButtonFormField<String>(
                value: mode,
                items: const [
                  DropdownMenuItem(
                    value: 'below_or_equal',
                    child: Text('Fire when latest log is ≤ target (buy low)'),
                  ),
                  DropdownMenuItem(
                    value: 'above_or_equal',
                    child: Text('Fire when latest log is ≥ target (sell high)'),
                  ),
                ],
                onChanged: (v) => setLocal(() => mode = v ?? 'below_or_equal'),
                decoration: const InputDecoration(labelText: 'Condition'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final t = int.tryParse(target.text.trim().replaceAll(RegExp(r'[^0-9\-]'), ''));
                if (item.text.trim().isEmpty || t == null) {
                  Navigator.pop(ctx, false);
                  return;
                }
                await db.insertAlert(itemName: item.text.trim(), targetAuec: t, fireWhen: mode);
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
