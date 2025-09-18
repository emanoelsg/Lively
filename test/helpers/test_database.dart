// test/helpers/test_database.dart
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:lively/core/constants.dart';

/// Helper class to manage test database operations
class TestDatabase {
  static late Database _db;
  static late String _dbPath;

  /// Initialize a test database with schema
  static Future<Database> initTestDb() async {
    final tempDir = await Directory.systemTemp.createTemp('lively_test_');
    _dbPath = join(tempDir.path, 'test.db');
    
    _db = await databaseFactory.openDatabase(
      _dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE ${AppConstants.eventsTable} (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              value REAL NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE ${AppConstants.settingsTable} (
              key TEXT PRIMARY KEY,
              value TEXT NOT NULL
            )
          ''');
        },
      ),
    );

    return _db;
  }

  /// Clean up test database
  static Future<void> cleanUp() async {
    await _db.close();
    await databaseFactory.deleteDatabase(_dbPath);
  }

  /// Get the test database instance
  static Database get db => _db;
}