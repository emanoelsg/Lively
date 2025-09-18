// core/db/app_database.dart
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:lively/core/constants.dart';

/// Database helper class that manages SQLite operations
class AppDatabase {
  /// Singleton instance of the database helper
  static final AppDatabase instance = AppDatabase._();
  static Database? _database;

  AppDatabase._();

  /// Gets the database instance, creating it if necessary
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initializes the database
  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, AppConstants.dbName);

    return openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  /// Creates the initial database schema
  Future<void> _createDatabase(Database db, int version) async {
    // Create events table
    await db.execute('''
      CREATE TABLE ${AppConstants.eventsTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        value REAL NOT NULL CHECK (value >= 0)
      )
    ''');

    // Create settings table
    await db.execute('''
      CREATE TABLE ${AppConstants.settingsTable} (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  /// Closes the database
  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}