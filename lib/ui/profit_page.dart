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

  Future<void> _confirmDelete(BuildContext context, TradeRow t) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('DELETE TRADE?'),
        content: Text('Remove trade for "${t.itemName}"? This cannot be undone.'),
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
      await widget.db.deleteTrade(t.id);
      await _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cyan = Theme.of(context).colorScheme.primary;
    final green = const Color(0xFF00FF9C);
    final red = Theme.of(context).colorScheme.error;
    final outline = Theme.of(context).colorScheme.outline;
    final surface = Theme.of(context).colorScheme.surface;

    return Scaffold(
      body: FutureBuilder<List<TradeRow>>(
        future: widget.db.allTrades(),
        builder: (context, snap) {
          if (!snap.hasData) return Center(child: CircularProgressIndicator(color: cyan));
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
          final isProfit = realized >= 0;

          return Column(
            children: [
              Container(
                color: surface,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'REALIZED P/L',
                        value: '${isProfit ? '+' : ''}${NumberFormat.decimalPattern().format(realized)}',
                        unit: 'aUEC',
                        color: isProfit ? green : red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'OPEN',
                        value: open.toString(),
                        unit: 'positions',
                        color: cyan,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: outline),
              Expanded(
                child: rows.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bar_chart, color: Theme.of(context).colorScheme.onSurface, size: 40),
                            const SizedBox(height: 12),
                            Text('NO TRADES YET', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, letterSpacing: 2, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text('Tap + to log a trade', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 11)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: rows.length,
                        itemBuilder: (context, i) {
                          final t = rows[i];
                          final pl = t.profitAuec();
                          final plColor = pl == null ? Theme.of(context).colorScheme.onSurface : (pl >= 0 ? green : red);
                          return Dismissible(
                            key: ValueKey(t.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: Theme.of(context).colorScheme.error,
                              child: const Icon(Icons.delete_outline, color: Colors.white),
                            ),
                            confirmDismiss: (_) async {
                              await _confirmDelete(context, t);
                              return false;
                            },
                            child: Column(
                              children: [
                                InkWell(
                                  onLongPress: () async {
                                    final ok = await _editTradeDialog(context, widget.db, t);
                                    if (ok == true) await _reload();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(width: 2, height: 48, color: t.isOpen ? cyan.withValues(alpha: 0.5) : plColor.withValues(alpha: 0.5)),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(t.itemName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                              const SizedBox(height: 4),
                                              Text(
                                                'BUY  ${t.buyQty} × ${NumberFormat.decimalPattern().format(t.buyAuec)} aUEC  •  ${_fmt(t.boughtAt)}',
                                                style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface),
                                              ),
                                              if (!t.isOpen)
                                                Text(
                                                  'SELL ${t.sellQty} × ${NumberFormat.decimalPattern().format(t.sellAuec)} aUEC  •  ${_fmt(t.soldAt!)}',
                                                  style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface),
                                                ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            if (t.isOpen)
                                              FilledButton(
                                                onPressed: () async {
                                                  final ok = await _closeDialog(context, widget.db, t);
                                                  if (ok == true) await _reload();
                                                },
                                                style: FilledButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                  textStyle: const TextStyle(fontSize: 11, letterSpacing: 1),
                                                ),
                                                child: const Text('CLOSE'),
                                              )
                                            else ...[
                                              Text(
                                                pl == null ? '—' : '${pl >= 0 ? '+' : ''}${NumberFormat.decimalPattern().format(pl)}',
                                                style: TextStyle(color: plColor, fontFamily: 'monospace', fontWeight: FontWeight.w700, fontSize: 14),
                                              ),
                                              Text('aUEC', style: TextStyle(color: plColor.withValues(alpha: 0.7), fontSize: 10, letterSpacing: 1)),
                                            ],
                                            const SizedBox(height: 4),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                GestureDetector(
                                                  onTap: () async {
                                                    final ok = await _editTradeDialog(context, widget.db, t);
                                                    if (ok == true) await _reload();
                                                  },
                                                  child: Icon(Icons.edit_outlined, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                                                ),
                                                const SizedBox(width: 8),
                                                GestureDetector(
                                                  onTap: () => _confirmDelete(context, t),
                                                  child: Icon(Icons.delete_outline, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                                                ),
                                              ],
                                            ),
                                          ],
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

  static String _fmt(DateTime d) => DateFormat('dd MMM yyyy').format(d);
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.unit, required this.color});
  final String label;
  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: color, fontFamily: 'monospace', fontWeight: FontWeight.w700, fontSize: 18)),
          Text(unit, style: TextStyle(color: color.withValues(alpha: 0.6), fontSize: 10, letterSpacing: 1)),
        ],
      ),
    );
  }
}

/// Edit buy details (and optionally sell details for closed trades)
Future<bool?> _editTradeDialog(BuildContext context, AppDatabase db, TradeRow t) {
  final item = TextEditingController(text: t.itemName);
  final buyQtyCtrl = TextEditingController(text: '${t.buyQty}');
  final buyPxCtrl = TextEditingController(text: '${t.buyAuec}');
  final notesCtrl = TextEditingController(text: t.notes ?? '');
  final sellPxCtrl = TextEditingController(text: t.sellAuec != null ? '${t.sellAuec}' : '');
  final sellQtyCtrl = TextEditingController(text: t.sellQty != null ? '${t.sellQty}' : '');
  DateTime boughtAt = t.boughtAt;
  DateTime? soldAt = t.soldAt;

  return showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setLocal) {
        return AlertDialog(
          title: const Text('EDIT TRADE'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: item, decoration: const InputDecoration(labelText: 'COMMODITY')),
                const SizedBox(height: 8),
                TextField(controller: buyQtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'BUY QUANTITY')),
                const SizedBox(height: 8),
                TextField(controller: buyPxCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'BUY PRICE (aUEC each)')),
                const SizedBox(height: 8),
                TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'NOTES (optional)')),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('BUY DATE', style: TextStyle(fontSize: 11, letterSpacing: 1, color: Theme.of(context).colorScheme.onSurface)),
                  subtitle: Text(DateFormat('dd MMM yyyy, HH:mm').format(boughtAt), style: const TextStyle(fontSize: 13)),
                  trailing: IconButton(
                    icon: Icon(Icons.edit_calendar_outlined, color: Theme.of(context).colorScheme.primary),
                    onPressed: () async {
                      final d = await showDatePicker(context: context, initialDate: boughtAt, firstDate: DateTime(2018), lastDate: DateTime(2100));
                      if (d == null) return;
                      final tm = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(boughtAt));
                      if (tm == null) return;
                      setLocal(() { boughtAt = DateTime(d.year, d.month, d.day, tm.hour, tm.minute); });
                    },
                  ),
                ),
                if (!t.isOpen) ...[
                  const Divider(),
                  TextField(controller: sellQtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'SELL QUANTITY')),
                  const SizedBox(height: 8),
                  TextField(controller: sellPxCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'SELL PRICE (aUEC each)')),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('SELL DATE', style: TextStyle(fontSize: 11, letterSpacing: 1, color: Theme.of(context).colorScheme.onSurface)),
                    subtitle: Text(DateFormat('dd MMM yyyy, HH:mm').format(soldAt ?? DateTime.now()), style: const TextStyle(fontSize: 13)),
                    trailing: IconButton(
                      icon: Icon(Icons.edit_calendar_outlined, color: Theme.of(context).colorScheme.primary),
                      onPressed: () async {
                        final base = soldAt ?? DateTime.now();
                        final d = await showDatePicker(context: context, initialDate: base, firstDate: DateTime(2018), lastDate: DateTime(2100));
                        if (d == null) return;
                        final tm = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(base));
                        if (tm == null) return;
                        setLocal(() { soldAt = DateTime(d.year, d.month, d.day, tm.hour, tm.minute); });
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
            FilledButton(
              onPressed: () async {
                final bQty = int.tryParse(buyQtyCtrl.text.trim());
                final bPx = int.tryParse(buyPxCtrl.text.trim().replaceAll(RegExp(r'[^0-9\-]'), ''));
                if (item.text.trim().isEmpty || bQty == null || bPx == null) { Navigator.pop(ctx, false); return; }
                await db.updateTradeBuy(
                  id: t.id,
                  itemName: item.text.trim(),
                  buyAuec: bPx,
                  buyQty: bQty,
                  boughtAt: boughtAt,
                  notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                );
                if (!t.isOpen) {
                  final sQty = int.tryParse(sellQtyCtrl.text.trim());
                  final sPx = int.tryParse(sellPxCtrl.text.trim().replaceAll(RegExp(r'[^0-9\-]'), ''));
                  if (sQty != null && sPx != null && soldAt != null) {
                    await db.updateTradeSale(id: t.id, sellAuec: sPx, sellQty: sQty, soldAt: soldAt!);
                  }
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
          title: const Text('LOG BUY'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: item, decoration: const InputDecoration(labelText: 'COMMODITY')),
                const SizedBox(height: 8),
                TextField(controller: buy, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'QUANTITY')),
                const SizedBox(height: 8),
                TextField(controller: px, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'BUY PRICE (aUEC each)')),
                const SizedBox(height: 8),
                TextField(controller: notes, decoration: const InputDecoration(labelText: 'NOTES (optional)')),
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
                final qty = int.tryParse(buy.text.trim());
                final price = int.tryParse(px.text.trim().replaceAll(RegExp(r'[^0-9\-]'), ''));
                if (item.text.trim().isEmpty || qty == null || price == null) { Navigator.pop(ctx, false); return; }
                await db.insertTrade(itemName: item.text.trim(), buyAuec: price, buyQty: qty, boughtAt: when, notes: notes.text.trim().isEmpty ? null : notes.text.trim());
                if (ctx.mounted) Navigator.pop(ctx, true);
              },
              child: const Text('CONFIRM'),
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
          title: Text('CLOSE — ${t.itemName.toUpperCase()}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: sellQty, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'SELL QUANTITY')),
              const SizedBox(height: 8),
              TextField(controller: sellPx, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'SELL PRICE (aUEC each)')),
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
                    final tm = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(when));
                    if (tm == null) return;
                    setLocal(() { when = DateTime(d.year, d.month, d.day, tm.hour, tm.minute); });
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
            FilledButton(
              onPressed: () async {
                final q = int.tryParse(sellQty.text.trim());
                final p = int.tryParse(sellPx.text.trim().replaceAll(RegExp(r'[^0-9\-]'), ''));
                if (q == null || p == null) { Navigator.pop(ctx, false); return; }
                await db.updateTradeSale(id: t.id, sellAuec: p, sellQty: q, soldAt: when);
                if (ctx.mounted) Navigator.pop(ctx, true);
              },
              child: const Text('CONFIRM'),
            ),
          ],
        );
      },
    ),
  );
}
