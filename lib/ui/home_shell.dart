import 'package:flutter/material.dart';

import '../db/app_db.dart';
import 'ai_chat_page.dart';
import 'alerts_page.dart';
import 'catalog_page.dart';
import 'dashboard_page.dart';
import 'logs_page.dart';
import 'profit_page.dart';
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
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(reason == 'open' ? 'Price alerts' : 'Price alerts (on return)'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: lines.map((e) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(e))).toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
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
    ];

    const titles = ['Home', 'Catalog', 'Logs', 'Ask AI', 'Alerts', 'Profit'];
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index.clamp(0, 5)]),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => SettingsPage(db: widget.db)),
              );
              if (mounted) setState(() {});
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index.clamp(0, 5),
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Catalog'),
          NavigationDestination(icon: Icon(Icons.edit_note_outlined), selectedIcon: Icon(Icons.edit_note), label: 'Logs'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Ask AI'),
          NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications), label: 'Alerts'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Profit'),
        ],
      ),
    );
  }
}
