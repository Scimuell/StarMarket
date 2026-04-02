import 'package:flutter/material.dart';

import '../db/app_db.dart';
import 'catalog_detail_page.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key, required this.db});

  final AppDatabase db;

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final _q = TextEditingController();

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cyan = Theme.of(context).colorScheme.primary;
    final outline = Theme.of(context).colorScheme.outline;

    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: TextField(
            controller: _q,
            decoration: InputDecoration(
              hintText: 'SEARCH COMMODITIES...',
              hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 12, letterSpacing: 1),
              prefixIcon: Icon(Icons.search, color: cyan, size: 18),
              suffixIcon: _q.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onSurface, size: 16),
                      onPressed: () => setState(() => _q.clear()),
                    )
                  : null,
            ),
            style: const TextStyle(fontSize: 13, letterSpacing: 1),
            onChanged: (_) => setState(() {}),
          ),
        ),
        Divider(height: 1, color: outline),
        Expanded(
          child: FutureBuilder<List<CatalogItemRow>>(
            key: ValueKey(_q.text),
            future: widget.db.searchCatalog(_q.text.trim()),
            builder: (context, snap) {
              if (!snap.hasData) {
                return Center(child: CircularProgressIndicator(color: cyan));
              }
              final rows = snap.data!;
              if (rows.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.dataset_outlined, color: Theme.of(context).colorScheme.onSurface, size: 40),
                      const SizedBox(height: 12),
                      Text(
                        _q.text.isEmpty ? 'NO CATALOG DATA' : 'NO RESULTS',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, letterSpacing: 2, fontSize: 12),
                      ),
                      if (_q.text.isEmpty) ...[
                        const SizedBox(height: 4),
                        Text('Sync from Settings to load market data',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 11)),
                      ],
                    ],
                  ),
                );
              }
              return ListView.builder(
                itemCount: rows.length,
                itemBuilder: (context, i) {
                  final r = rows[i];
                  return Column(
                    children: [
                      InkWell(
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => CatalogDetailPage(db: widget.db, itemId: r.id),
                            ),
                          );
                          if (mounted) setState(() {});
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Container(width: 2, height: 32, color: cyan.withValues(alpha: 0.4)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(r.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                                    const SizedBox(height: 2),
                                    Text('PATCH ${r.patch}', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface, letterSpacing: 1.5)),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right, color: cyan.withValues(alpha: 0.6), size: 18),
                            ],
                          ),
                        ),
                      ),
                      Divider(height: 1, color: outline),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
