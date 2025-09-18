// test/helpers/test_setup.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MockPathProvider with MockPlatformInterfaceMixin implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async => '/test/docs';
  
  @override
  Future<String?> getTemporaryPath() async => '/test/temp';
  
  @override
  Future<String?> getApplicationSupportPath() async => '/test/support';
  
  @override
  Future<String?> getLibraryPath() async => '/test/lib';
  
  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async => ['/test/external'];
  
  @override
  Future<List<String>?> getExternalCachePaths() async => ['/test/cache'];
  
  @override
  Future<String?> getDownloadsPath() async => '/test/downloads';
  
  @override
  Future<String?> getApplicationCachePath() async => '/test/cache';
  
  @override
  Future<String?> getExternalStoragePath() async => '/test/external';
}

/// Initialize test environment, particularly for SQLite testing
Future<void> setupTestEnvironment() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Always use FFI for testing
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Set up temporary directory for tests
  final tempDir = await Directory.systemTemp.createTemp('lively_test_');

  // Mock path_provider
  PathProviderPlatform.instance = MockPathProvider();

  // Create test database
  final dbPath = join(tempDir.path, 'test.db');
  final db = await databaseFactory.openDatabase(
    dbPath,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        // Create tables
        await db.execute('''
          CREATE TABLE events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            value REAL NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE settings (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
    ),
  );

  // Close the database to avoid memory leaks
  await db.close();
}

/// Clean up test environment
Future<void> cleanupTestEnvironment() async {
  // Close and delete all test databases
  await databaseFactory.deleteDatabase(
    join((await Directory.systemTemp.createTemp('lively_test_')).path, 'test.db'),
  );

  // Initialize a new path provider instance for the next test
  PathProviderPlatform.instance = MockPathProvider();

  // Reset database factory to default
  databaseFactory = databaseFactoryFfi;
}