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

  Future<void> _confirmDelete(BuildContext context, AlertRow r) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('DELETE ALERT?'),
        content: Text('Remove alert for "${r.itemName}"?'),
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
      await widget.db.deleteAlert(r.id);
      await _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cyan = Theme.of(context).colorScheme.primary;
    final outline = Theme.of(context).colorScheme.outline;

    return Scaffold(
      body: FutureBuilder<List<AlertRow>>(
        future: widget.db.allAlerts(),
        builder: (context, snap) {
          if (!snap.hasData) return Center(child: CircularProgressIndicator(color: cyan));
          final rows = snap.data!;
          if (rows.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.radar_outlined, color: Theme.of(context).colorScheme.onSurface, size: 40),
                  const SizedBox(height: 12),
                  Text('NO ACTIVE ALERTS', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, letterSpacing: 2, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('Tap + to set a price target', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 11)),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: rows.length,
            itemBuilder: (context, i) {
              final r = rows[i];
              final isBuy = r.fireWhen == 'below_or_equal';
              final condColor = isBuy ? cyan : const Color(0xFF00FF9C);
              final condLabel = isBuy ? 'BUY TARGET' : 'SELL TARGET';
              final condSymbol = isBuy ? '≤' : '≥';
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
                      onLongPress: () async {
                        final ok = await _showAlertDialog(context, widget.db, r);
                        if (ok == true) await _reload();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Container(width: 2, height: 40, color: condColor.withValues(alpha: 0.6)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r.itemName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: condColor.withValues(alpha: 0.1),
                                          border: Border.all(color: condColor.withValues(alpha: 0.4)),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                        child: Text(condLabel, style: TextStyle(color: condColor, fontSize: 9, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
                                      ),
                                      const SizedBox(width: 8),
                                      Text('$condSymbol ${r.targetAuec} aUEC', style: TextStyle(color: condColor, fontSize: 12, fontFamily: 'monospace')),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit_outlined, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), size: 18),
                              onPressed: () async {
                                final ok = await _showAlertDialog(context, widget.db, r);
                                if (ok == true) await _reload();
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.onSurface, size: 20),
                              onPressed: () => _confirmDelete(context, r),
                            ),
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
          final ok = await _showAlertDialog(context, widget.db, null);
          if (ok == true) await _reload();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

Future<bool?> _showAlertDialog(BuildContext context, AppDatabase db, AlertRow? existing) {
  final isEdit = existing != null;
  final item = TextEditingController(text: existing?.itemName ?? '');
  final target = TextEditingController(text: existing != null ? '${existing.targetAuec}' : '');
  var mode = existing?.fireWhen ?? 'below_or_equal';

  return showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setLocal) {
        return AlertDialog(
          title: Text(isEdit ? 'EDIT ALERT' : 'NEW ALERT'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: item, decoration: const InputDecoration(labelText: 'ITEM NAME')),
              const SizedBox(height: 8),
              TextField(
                controller: target,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'TARGET aUEC'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: mode,
                items: const [
                  DropdownMenuItem(value: 'below_or_equal', child: Text('ALERT WHEN PRICE ≤ TARGET')),
                  DropdownMenuItem(value: 'above_or_equal', child: Text('ALERT WHEN PRICE ≥ TARGET')),
                ],
                onChanged: (v) => setLocal(() => mode = v ?? 'below_or_equal'),
                decoration: const InputDecoration(labelText: 'CONDITION'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
            FilledButton(
              onPressed: () async {
                final t = int.tryParse(target.text.trim().replaceAll(RegExp(r'[^0-9\-]'), ''));
                if (item.text.trim().isEmpty || t == null) { Navigator.pop(ctx, false); return; }
                if (isEdit) {
                  await db.updateAlert(id: existing!.id, itemName: item.text.trim(), targetAuec: t, fireWhen: mode);
                } else {
                  await db.insertAlert(itemName: item.text.trim(), targetAuec: t, fireWhen: mode);
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
