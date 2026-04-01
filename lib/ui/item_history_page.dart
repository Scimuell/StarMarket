import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/app_db.dart';

class ItemHistoryPage extends StatelessWidget {
  const ItemHistoryPage({super.key, required this.db, required this.itemName});

  final AppDatabase db;
  final String itemName;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PriceLogRow>>(
      future: db.logsForItem(itemName),
      builder: (context, snap) {
        if (!snap.hasData) {
          return Scaffold(
            appBar: AppBar(title: Text(itemName)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final rows = snap.data!;
        return Scaffold(
          appBar: AppBar(title: Text(itemName)),
          body: rows.isEmpty
      ? const Center(child: Text('No history for this item.'))
      : Column(
                children: [
                  SizedBox(
                    height: 240,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _Chart(rows: rows),
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.separated(
                      itemCount: rows.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final r = rows[rows.length - 1 - i];
                        return ListTile(
                          title: Text(NumberFormat.decimalPattern().format(r.price) + ' aUEC'),
                          subtitle: Text('${r.location ?? "—"} • ${_fmt(r.loggedAt)} • ${r.logType}'),
                        );
                      },
                    ),
                  ),
                ],
              ),
        );
      },
    );
  }

  static String _fmt(DateTime d) => DateFormat.yMMMd().add_jm().format(d);
}

class _Chart extends StatelessWidget {
  const _Chart({required this.rows});

  final List<PriceLogRow> rows;

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (var i = 0; i < rows.length; i++) {
      spots.add(FlSpot(i.toDouble(), rows[i].price.toDouble()));
    }
    final minY = rows.map((e) => e.price).reduce((a, b) => a < b ? a : b).toDouble();
    final maxY = rows.map((e) => e.price).reduce((a, b) => a > b ? a : b).toDouble();
    final pad = (maxY - minY).abs() < 1 ? 10.0 : (maxY - minY) * 0.08;

    return LineChart(
      LineChartData(
        minY: minY - pad,
        maxY: maxY + pad,
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((t) {
                final idx = t.x.toInt();
                if (idx < 0 || idx >= rows.length) {
                  return LineTooltipItem('', const TextStyle());
                }
                final r = rows[idx];
                return LineTooltipItem(
                  '${r.price} aUEC\n${_fmt(r.loggedAt)}',
                  const TextStyle(color: Colors.white, fontSize: 12),
                );
              }).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (v, m) => Text(
                NumberFormat.compact().format(v),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }

  static String _fmt(DateTime d) => DateFormat.MMMd().add_jm().format(d);
}
