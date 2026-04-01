import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/app_db.dart';

class ProfitPage extends StatefulWidget {
  const ProfitPage({super.key, required this.db});

  final AppDatabase db;

  @override
  State<ProfitPage> createState() => _ProfitPageState();
}

class _ProfitPageState extends State<ProfitPage> {
  Future<void> _reload() async => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<TradeRow>>(
        future: widget.db.allTrades(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final rows = snap.data!;
          var realized = 0;
          var open = 0;
          for (final t in rows) {
            if (t.isOpen) {
              open++;
            } else {
              realized += t.profitAuec() ?? 0;
            }
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Realized P/L', style: Theme.of(context).textTheme.labelMedium),
                              Text(
                                '${NumberFormat.decimalPattern().format(realized)} aUEC',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Open positions', style: Theme.of(context).textTheme.labelMedium),
                              Text('$open', style: Theme.of(context).textTheme.titleLarge),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: rows.isEmpty
                    ? const Center(child: Text('No trades yet.'))
                    : ListView.separated(
                        itemCount: rows.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final t = rows[i];
                          final pl = t.profitAuec();
                          return ListTile(
                            title: Text(t.itemName),
                            subtitle: Text(
                              'Buy ${t.buyQty}×${t.buyAuec} • ${_fmt(t.boughtAt)}\n'
                              '${t.isOpen ? "Open" : "Sell ${t.sellQty}×${t.sellAuec} • ${_fmt(t.soldAt!)}"}',
                            ),
                            isThreeLine: true,
                            trailing: t.isOpen
                                ? FilledButton(
                                    onPressed: () async {
                                      final ok = await _closeDialog(context, widget.db, t);
                                      if (ok == true) await _reload();
                                    },
                                    child: const Text('Close'),
                                  )
                                : Text(
                                    pl == null ? '—' : '${NumberFormat.decimalPattern().format(pl)} aUEC',
                                  ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final ok = await _buyDialog(context, widget.db);
          if (ok == true) await _reload();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  static String _fmt(DateTime d) => DateFormat.yMMMd().format(d);
}

Future<bool?> _buyDialog(BuildContext context, AppDatabase db) {
  final item = TextEditingController();
  final buy = TextEditingController(text: '1');
  final px = TextEditingController();
  final notes = TextEditingController();
  var when = DateTime.now();

  return showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setLocal) {
        return AlertDialog(
          title: const Text('Log buy'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: item, decoration: const InputDecoration(labelText: 'Item')),
                TextField(
                  controller: buy,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                ),
                TextField(
                  controller: px,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Buy price (aUEC each)'),
                ),
                TextField(controller: notes, decoration: const InputDecoration(labelText: 'Notes (optional)')),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Bought at'),
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
                      final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(when));
                      if (t == null) return;
                      setLocal(() => when = DateTime(d.year, d.month, d.day, t.hour, t.minute));
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
                final qty = int.tryParse(buy.text.trim());
                final price = int.tryParse(px.text.trim().replaceAll(RegExp(r'[^0-9\-]'), ''));
                if (item.text.trim().isEmpty || qty == null || price == null) {
                  Navigator.pop(ctx, false);
                  return;
                }
                await db.insertTrade(
                  itemName: item.text.trim(),
                  buyAuec: price,
                  buyQty: qty,
                  boughtAt: when,
                  notes: notes.text.trim().isEmpty ? null : notes.text.trim(),
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

Future<bool?> _closeDialog(BuildContext context, AppDatabase db, TradeRow t) {
  final sellPx = TextEditingController();
  final sellQty = TextEditingController(text: '${t.buyQty}');
  var when = DateTime.now();

  return showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setLocal) {
        return AlertDialog(
          title: Text('Close ${t.itemName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: sellQty,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Sell quantity'),
              ),
              TextField(
                controller: sellPx,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Sell price (aUEC each)'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Sold at'),
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
                    final tm = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(when));
                    if (tm == null) return;
                    setLocal(() => when = DateTime(d.year, d.month, d.day, tm.hour, tm.minute));
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final q = int.tryParse(sellQty.text.trim());
                final p = int.tryParse(sellPx.text.trim().replaceAll(RegExp(r'[^0-9\-]'), ''));
                if (q == null || p == null) {
                  Navigator.pop(ctx, false);
                  return;
                }
                await db.updateTradeSale(id: t.id, sellAuec: p, sellQty: q, soldAt: when);
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
