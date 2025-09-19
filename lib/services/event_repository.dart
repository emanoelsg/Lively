// services/event_repository.dart
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:lively/core/constants.dart';
import 'package:lively/core/db/app_database.dart';
import 'package:lively/models/event.dart';
import 'package:sqflite/sqflite.dart';

/// Repository for managing events in the database
class EventRepository {
  final AppDatabase _db;

  /// Creates a new event repository instance
  EventRepository([AppDatabase? db]) : _db = db ?? AppDatabase.instance;

  /// Inserts a new event into the database
  Future<int> insertEvent(Event event) async {
    final db = await _db.database;
    return db.insert(AppConstants.eventsTable, event.toMap());
  }

  /// Updates an existing event in the database
  Future<int> updateEvent(Event event) async {
    if (event.id == null) {
      throw ArgumentError('Cannot update event without an ID');
    }

    final db = await _db.database;
    return db.update(
      AppConstants.eventsTable,
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  /// Deletes an event from the database
  Future<int> deleteEvent(int id) async {
    final db = await _db.database;
    return db.delete(
      AppConstants.eventsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Gets all events from the database ordered by ID ascending
  Future<List<Event>> getAllEvents() async {
    final db = await _db.database;
    final maps = await db.query(
      AppConstants.eventsTable,
      orderBy: 'id ASC',
    );

    return maps.map((map) => Event.fromMap(map)).toList();
  }

  /// Gets the total spent amount (sum of all event values)
  Future<double> getTotalSpent() async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(value), 0.0) as total FROM ${AppConstants.eventsTable}',
    );

    return (result.first['total'] as num).toDouble();
  }

  /// Gets a single event by its ID
  Future<Event?> getEventById(int id) async {
    final db = await _db.database;
    final maps = await db.query(
      AppConstants.eventsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Event.fromMap(maps.first);
  }

  /// Exports all events to a JSON file in the downloads directory
  Future<String> exportToJson(double budget) async {
    final events = await getAllEvents();
    final Map<String, dynamic> data = {
      'meta': {
        'exported_at': DateTime.now().toIso8601String(),
        'app': AppConstants.appName,
        'version': AppConstants.backupVersion,
      },
      'budget': budget,
      'events': events.map((e) => e.toMap()).toList(),
    };

    final downloadsDir = await _getDownloadsDirectory();
    final file = File('${downloadsDir.path}/${AppConstants.backupFileName}');
    await file.writeAsString(jsonEncode(data));

    return file.path;
  }

  /// Imports events from a JSON file
  Future<void> importFromJson(String filePath, {bool replace = true}) async {
    final file = File(filePath);
    final jsonString = await file.readAsString();
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    // Validate structure
    if (!data.containsKey('events') || !data.containsKey('budget')) {
      throw const FormatException('Invalid backup file format');
    }

    final db = await _db.database;
    await db.transaction((txn) async {
      if (replace) {
        // Clear existing events if replacing
        await txn.delete(AppConstants.eventsTable);
      }

      // Insert events from backup
      for (final eventMap in data['events'] as List) {
        final event = Event.fromMap(eventMap as Map<String, dynamic>);
        await txn.insert(AppConstants.eventsTable, event.toMap());
      }

      // Update budget
      await txn.insert(
        AppConstants.settingsTable,
        {
          'key': AppConstants.monthlyBudgetKey,
          'value': data['budget'].toString(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }
   Future<void> deleteAllEvents() async {
    final db = await AppDatabase.instance.database;
    await db.delete(AppConstants.eventsTable);
  }
  /// Gets the platform-specific downloads directory
  Future<Directory> _getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw const FileSystemException('Could not access external storage');
      }
      return directory;
    }

    final directory = await getApplicationDocumentsDirectory();
    return directory;
  }
}