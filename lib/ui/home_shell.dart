import 'package:flutter/material.dart';

import '../db/app_db.dart';
import 'ai_chat_page.dart';
import 'alerts_page.dart';
import 'catalog_page.dart';
import 'dashboard_page.dart';
import 'logs_page.dart';
import 'profit_page.dart';
import 'rare_armor_page.dart';
import 'settings_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.db});

  final AppDatabase db;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAlerts(reason: 'open'));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAlerts(reason: 'resume');
    }
  }

  Future<void> _checkAlerts({required String reason}) async {
    final lines = await widget.db.evaluateTriggeredAlerts();
    if (!mounted || lines.isEmpty) return;
    final cyan = Theme.of(context).colorScheme.primary;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          reason == 'open' ? 'PRICE ALERTS' : 'PRICE ALERTS',
          style: TextStyle(color: cyan, letterSpacing: 3),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: lines
                .map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('> ', style: TextStyle(color: cyan, fontFamily: 'monospace')),
                          Expanded(child: Text(e)),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('DISMISS')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DashboardPage(
        db: widget.db,
        onOpenAlerts: () => setState(() => _index = 4),
        onOpenProfit: () => setState(() => _index = 5),
      ),
      CatalogPage(db: widget.db),
      LogsPage(db: widget.db),
      AiChatPage(db: widget.db),
      AlertsPage(db: widget.db),
      ProfitPage(db: widget.db),
      const RareArmorPage(),
    ];

    const titles = ['OVERVIEW', 'MARKET DATA', 'TRADE LOG', 'AI ADVISOR', 'ALERTS', 'PROFIT', 'RARE ARMOUR'];

    return Scaffold(
      appBar: AppBar(
        title: _AppBarTitle(title: titles[_index.clamp(0, 6)]),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Settings',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => SettingsPage(db: widget.db)),
              );
              if (mounted) setState(() {});
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _index.clamp(0, 6),
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view), label: 'OVERVIEW'),
            NavigationDestination(icon: Icon(Icons.dataset_outlined), selectedIcon: Icon(Icons.dataset), label: 'MARKET'),
            NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'LOG'),
            NavigationDestination(icon: Icon(Icons.terminal_outlined), selectedIcon: Icon(Icons.terminal), label: 'AI'),
            NavigationDestination(icon: Icon(Icons.radar_outlined), selectedIcon: Icon(Icons.radar), label: 'ALERTS'),
            NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'PROFIT'),
            NavigationDestination(icon: Icon(Icons.shield_outlined), selectedIcon: Icon(Icons.shield), label: 'ARMOUR'),
          ],
        ),
      ),
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final cyan = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 3, height: 16, color: cyan),
        const SizedBox(width: 8),
        Text(title),
      ],
    );
  }
}
