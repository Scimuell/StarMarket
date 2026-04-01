import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../db/app_db.dart';

Future<void> seedCatalogIfEmpty(AppDatabase db) async {
  final n = await db.catalogItemCount();
  if (n > 0) return;
  final raw = await rootBundle.loadString('assets/catalog_seed.json');
  final map = jsonDecode(raw) as Map<String, dynamic>;
  await db.importCatalogJson(map);
}
