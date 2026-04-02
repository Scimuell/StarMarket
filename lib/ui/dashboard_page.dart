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
    final cyan = Theme.of(context).colorScheme.primary;
    final surface = Theme.of(context).colorScheme.surface;
    final outline = Theme.of(context).colorScheme.outline;

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
            _SectionHeader(label: 'SYSTEM STATUS', cyan: cyan),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: surface,
                border: Border.all(color: outline),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  _StatRow(label: 'CATALOG ITEMS', value: s.catalogCount.toString(), cyan: cyan),
                  Divider(height: 1, color: outline),
                  _StatRow(label: 'TRADE LOGS', value: s.logCount.toString(), cyan: cyan),
                  Divider(height: 1, color: outline),
                  _StatRow(label: 'ACTIVE ALERTS', value: s.alertCount.toString(), cyan: cyan),
                  Divider(height: 1, color: outline),
                  _StatRow(label: 'TRACKED TRADES', value: s.tradeCount.toString(), cyan: cyan),
                ],
              ),
            ),
            if (s.triggered.isNotEmpty) ...[
              const SizedBox(height: 20),
              _SectionHeader(label: 'ALERTS ACTIVE', cyan: const Color(0xFFFF4C6A)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A0810),
                  border: Border.all(color: const Color(0xFFFF4C6A).withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: s.triggered
                      .map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('> ', style: TextStyle(color: Color(0xFFFF4C6A), fontFamily: 'monospace')),
                                Expanded(child: Text(e, style: const TextStyle(fontSize: 12))),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
            if (s.recent.isNotEmpty) ...[
              const SizedBox(height: 20),
              _SectionHeader(label: 'RECENT LOGS', cyan: cyan),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: surface,
                  border: Border.all(color: outline),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: s.recent.asMap().entries.map((entry) {
                    final r = entry.value;
                    final isLast = entry.key == s.recent.length - 1;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(r.itemName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 2),
                                    Text(_fmt(r.loggedAt), style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface)),
                                  ],
                                ),
                              ),
                              Text(
                                '${NumberFormat.decimalPattern().format(r.price)} aUEC',
                                style: TextStyle(color: cyan, fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        if (!isLast) Divider(height: 1, color: outline),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onOpenAlerts,
                    icon: const Icon(Icons.radar_outlined, size: 16),
                    label: const Text('ALERTS'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onOpenProfit,
                    icon: const Icon(Icons.bar_chart, size: 16),
                    label: const Text('PROFIT'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  static String _fmt(DateTime d) => DateFormat('dd MMM, HH:mm').format(d);

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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.cyan});
  final String label;
  final Color cyan;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 2, height: 12, color: cyan),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: cyan, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w700, fontFamily: 'monospace')),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: cyan.withValues(alpha: 0.3))),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value, required this.cyan});
  final String label;
  final String value;
  final Color cyan;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, letterSpacing: 1)),
          Text(value, style: TextStyle(color: cyan, fontFamily: 'monospace', fontWeight: FontWeight.w700, fontSize: 14)),
        ],
      ),
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
