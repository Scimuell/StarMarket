import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/app_db.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.db,
    required this.onOpenAlerts,
    required this.onOpenProfit,
  });

  final AppDatabase db;
  final VoidCallback onOpenAlerts;
  final VoidCallback onOpenProfit;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DashStats>(
      future: _load(db),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final s = snap.data!;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Overview', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('Catalog items: ${s.catalogCount}'),
                    Text('Price logs: ${s.logCount}'),
                    Text('Open alerts: ${s.alertCount}'),
                    Text('Tracked trades: ${s.tradeCount}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (s.triggered.isNotEmpty)
              Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Alerts firing now', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      ...s.triggered.map((e) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(e))),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            if (s.recent.isNotEmpty) ...[
              Text('Recent logs', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...s.recent.map(
                (r) => ListTile(
                  dense: true,
                  title: Text(r.itemName),
                  subtitle: Text(
                    '${NumberFormat.decimalPattern().format(r.price)} aUEC • ${_fmt(r.loggedAt)}',
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onOpenAlerts,
                    icon: const Icon(Icons.notifications_outlined),
                    label: const Text('Alerts'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onOpenProfit,
                    icon: const Icon(Icons.account_balance_wallet_outlined),
                    label: const Text('Profit'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static String _fmt(DateTime d) => DateFormat.yMMMd().add_jm().format(d);

  static Future<_DashStats> _load(AppDatabase db) async {
    final catalogCount = await db.catalogItemCount();
    final logCount = await db.priceLogCount();
    final logs = await db.recentLogs(limit: 25);
    final alerts = await db.allAlerts();
    final triggered = await db.evaluateTriggeredAlerts();
    final tradeCount = await db.tradeCount();
    return _DashStats(
      catalogCount: catalogCount,
      logCount: logCount,
      alertCount: alerts.length,
      tradeCount: tradeCount,
      triggered: triggered,
      recent: logs.take(6).toList(),
    );
  }
}

class _DashStats {
  _DashStats({
    required this.catalogCount,
    required this.logCount,
    required this.alertCount,
    required this.tradeCount,
    required this.triggered,
    required this.recent,
  });

  final int catalogCount;
  final int logCount;
  final int alertCount;
  final int tradeCount;
  final List<String> triggered;
  final List<PriceLogRow> recent;
}
