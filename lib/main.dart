import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'presentation/app.dart';
import 'data/datasources/local/database/app_database.dart';
import 'data/datasources/local/database/database_provider.dart';
import 'data/datasources/local/database/migration_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final db = AppDatabase();
  final migrator = MigrationService(prefs, db);
  await migrator.migrateFromSharedPreferences();

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
      ],
      child: const VaultNoteApp(),
    ),
  );
}
