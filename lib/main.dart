import 'package:flutter/material.dart';

import 'db/app_db.dart';
import 'services/bootstrap.dart';
import 'ui/home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await AppDatabase.open();
  await seedCatalogIfEmpty(db);
  runApp(StarcitizenTraderApp(db: db));
}

class StarcitizenTraderApp extends StatelessWidget {
  const StarcitizenTraderApp({super.key, required this.db});

  final AppDatabase db;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Starcitizen Trader (local)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A90D9)),
        useMaterial3: true,
      ),
      home: HomeShell(db: db),
    );
  }
}
