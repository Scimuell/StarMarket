import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/app_db.dart';

class CatalogDetailPage extends StatelessWidget {
  const CatalogDetailPage({super.key, required this.db, required this.itemId});

  final AppDatabase db;
  final int itemId;

  @override
  Widget build(BuildContext context) {
    final cyan = Theme.of(context).colorScheme.primary;
    final outline = Theme.of(context).colorScheme.outline;
    final surface = Theme.of(context).colorScheme.surface;

    return FutureBuilder<_Bundle>(
      future: _load(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('LOADING...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final b = snap.data!;
        return Scaffold(
          appBar: AppBar(
            title: Text(b.item.name.toUpperCase(), style: const TextStyle(fontSize: 13)),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Container(width: 2, height: 12, color: cyan),
                  const SizedBox(width: 8),
                  Text('PATCH ${b.item.patch}', style: TextStyle(color: cyan, fontSize: 11, letterSpacing: 2)),
                  const SizedBox(width: 8),
                  Expanded(child: Divider(color: cyan.withValues(alpha: 0.3))),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(width: 2, height: 12, color: outline),
                  const SizedBox(width: 8),
                  Text('TRADE LOCATIONS', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 11, letterSpacing: 2)),
                  const SizedBox(width: 8),
                  Expanded(child: Divider(color: outline)),
                ],
              ),
              const SizedBox(height: 8),
              if (b.offers.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surface,
                    border: Border.all(color: outline),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('No location data available.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12)),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: surface,
                    border: Border.all(color: outline),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: b.offers.asMap().entries.map((entry) {
                      final o = entry.value;
                      final isLast = entry.key == b.offers.length - 1;
                      final hasBuy = o.buyAuec != null;
                      final hasSell = o.sellAuec != null;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  o.location,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    if (hasBuy) ...[
                                      _PriceChip(label: 'BUY', value: _fmt(o.buyAuec), color: const Color(0xFF00D4FF)),
                                      const SizedBox(width: 8),
                                    ],
                                    if (hasSell)
                                      _PriceChip(label: 'SELL', value: _fmt(o.sellAuec), color: const Color(0xFF00FF9C)),
                                    if (!hasBuy && !hasSell)
                                      Text('—', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                                  ],
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
              const SizedBox(height: 16),
              Text(
                'Data sourced from UEX community reports. Prices may vary in-game.',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 10, letterSpacing: 0.5),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<_Bundle> _load() async {
    final item = await db.catalogById(itemId);
    if (item == null) throw StateError('missing item');
    final offers = await db.offersForItem(itemId);
    return _Bundle(item: item, offers: offers);
  }

  static String _fmt(int? v) => v == null ? '—' : '${NumberFormat.decimalPattern().format(v)} aUEC';
}

class _PriceChip extends StatelessWidget {
  const _PriceChip({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 9, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
          const SizedBox(width: 6),
          Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}

class _Bundle {
  _Bundle({required this.item, required this.offers});

  final CatalogItemRow item;
  final List<CatalogOfferRow> offers;
}
