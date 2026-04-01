import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/app_db.dart';

class CatalogDetailPage extends StatelessWidget {
  const CatalogDetailPage({super.key, required this.db, required this.itemId});

  final AppDatabase db;
  final int itemId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_Bundle>(
      future: _load(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Item')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final b = snap.data!;
        return Scaffold(
          appBar: AppBar(title: Text(b.item.name)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Imported for patch ${b.item.patch}', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              Text('Locations & reference aUEC', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...b.offers.map((o) {
                return Card(
                  child: ListTile(
                    title: Text(o.location),
                    subtitle: Text(
                      'Buy: ${_fmt(o.buyAuec)} • Sell: ${_fmt(o.sellAuec)}',
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              Text(
                'These values come from your imported catalog file, not live servers.',
                style: Theme.of(context).textTheme.bodySmall,
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

class _Bundle {
  _Bundle({required this.item, required this.offers});

  final CatalogItemRow item;
  final List<CatalogOfferRow> offers;
}
