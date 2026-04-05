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
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return FutureBuilder<_DashStats>(
      future: _load(db),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final s = snap.data!;
        return ListView(
          padding: EdgeInsets.zero,
          children: [
            // ── Hero banner ───────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
              decoration: BoxDecoration(
                color: surface,
                border: Border(bottom: BorderSide(color: outline)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomPaint(size: const Size(22, 22), painter: _DiamondPainter(color: cyan)),
                      const SizedBox(width: 10),
                      Text('STARMARKET',
                          style: TextStyle(
                              color: cyan,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 4,
                              fontFamily: 'monospace')),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Star Citizen Trade Companion',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 11,
                          letterSpacing: 2)),
                ],
              ),
            ),

            // ── Stat grid ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _StatCard(label: 'CATALOG ITEMS', value: s.catalogCount.toString(), icon: Icons.dataset_outlined, color: cyan)),
                      const SizedBox(width: 10),
                      Expanded(child: _StatCard(label: 'TRADE LOGS', value: s.logCount.toString(), icon: Icons.receipt_long_outlined, color: const Color(0xFF00FF9C))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _StatCard(label: 'ACTIVE ALERTS', value: s.alertCount.toString(), icon: Icons.radar_outlined, color: s.alertCount > 0 ? const Color(0xFFFF4C6A) : Theme.of(context).colorScheme.onSurface)),
                      const SizedBox(width: 10),
                      Expanded(child: _StatCard(label: 'OPEN TRADES', value: s.tradeCount.toString(), icon: Icons.bar_chart_outlined, color: const Color(0xFFFFD700))),
                    ],
                  ),
                ],
              ),
            ),

            // ── Firing alerts ─────────────────────────────────────────
            if (s.triggered.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A0810),
                    border: Border.all(color: const Color(0xFFFF4C6A).withValues(alpha: 0.6)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                        child: Row(children: [
                          const Icon(Icons.radar, color: Color(0xFFFF4C6A), size: 14),
                          const SizedBox(width: 6),
                          Text('ALERTS FIRING', style: TextStyle(color: const Color(0xFFFF4C6A), fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w700)),
                        ]),
                      ),
                      Divider(height: 1, color: const Color(0xFFFF4C6A).withValues(alpha: 0.3)),
                      ...s.triggered.map((e) => Padding(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('> ', style: TextStyle(color: Color(0xFFFF4C6A), fontFamily: 'monospace', fontSize: 12)),
                              Expanded(child: Text(e, style: const TextStyle(fontSize: 12))),
                            ]),
                          )),
                    ],
                  ),
                ),
              ),

            // ── Recent price logs ─────────────────────────────────────
            if (s.recent.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(label: 'RECENT PRICE LOGS', cyan: cyan),
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
                          return Column(children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Row(children: [
                                Expanded(child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(r.itemName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                    Text(_fmt(r.loggedAt), style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface)),
                                  ],
                                )),
                                Text('${NumberFormat.decimalPattern().format(r.price)} aUEC',
                                    style: TextStyle(color: cyan, fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.w700)),
                              ]),
                            ),
                            if (!isLast) Divider(height: 1, color: outline),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

            if (s.recent.isEmpty && s.triggered.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: surface,
                    border: Border.all(color: outline),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(children: [
                    Icon(Icons.info_outline, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), size: 28),
                    const SizedBox(height: 8),
                    Text('Sync market data in Settings to get started.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12)),
                  ]),
                ),
              ),

            const SizedBox(height: 8),
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

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 9, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
            Text(value, style: TextStyle(color: color, fontFamily: 'monospace', fontWeight: FontWeight.w800, fontSize: 20)),
          ],
        )),
      ]),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.cyan});
  final String label;
  final Color cyan;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 2, height: 12, color: cyan),
      const SizedBox(width: 8),
      Text(label, style: TextStyle(color: cyan, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w700)),
      const SizedBox(width: 8),
      Expanded(child: Divider(color: cyan.withValues(alpha: 0.3))),
    ]);
  }
}

class _DashStats {
  _DashStats({required this.catalogCount, required this.logCount, required this.alertCount, required this.tradeCount, required this.triggered, required this.recent});
  final int catalogCount;
  final int logCount;
  final int alertCount;
  final int tradeCount;
  final List<String> triggered;
  final List<PriceLogRow> recent;
}

class _DiamondPainter extends CustomPainter {
  const _DiamondPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1.5;
    final fill = Paint()..color = color.withValues(alpha: 0.15)..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(0, size.height / 2)
      ..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, paint);
    final lp = Paint()..color = color.withValues(alpha: 0.5)..strokeWidth = 0.8;
    canvas.drawLine(Offset(size.width / 2, 2), Offset(size.width / 2, size.height - 2), lp);
    canvas.drawLine(Offset(2, size.height / 2), Offset(size.width - 2, size.height / 2), lp);
  }

  @override
  bool shouldRepaint(_DiamondPainter old) => old.color != color;
}
