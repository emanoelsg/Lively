// services/budget_repository.dart
import 'package:sqflite/sqflite.dart';
import 'package:lively/core/constants.dart';
import 'package:lively/core/db/app_database.dart';

/// Repository for managing budget settings
class BudgetRepository {
  final AppDatabase _db;

  /// Creates a new budget repository instance
  BudgetRepository([AppDatabase? db]) : _db = db ?? AppDatabase.instance;

  /// Sets the monthly budget
  Future<void> setBudget(double budget) async {
    if (budget < 0) {
      throw ArgumentError('Budget cannot be negative');
    }

    if (budget > AppConstants.maxBudgetValue) {
      throw ArgumentError('Budget exceeds maximum allowed value');
    }

    final db = await _db.database;
    await db.insert(
      AppConstants.settingsTable,
      {
        'key': AppConstants.monthlyBudgetKey,
        'value': budget.toString(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Gets the current monthly budget. Returns null if not set.
  Future<double?> getBudget() async {
    final db = await _db.database;
    final result = await db.query(
      AppConstants.settingsTable,
      where: 'key = ?',
      whereArgs: [AppConstants.monthlyBudgetKey],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return double.tryParse(result.first['value'] as String);
  }

  /// Gets the remaining budget (budget - total spent)
  Future<double?> getRemainingBudget() async {
    final budget = await getBudget();
    if (budget == null) {
      return null;
    }

    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(value), 0.0) as total FROM ${AppConstants.eventsTable}',
    );

    final spent = (result.first['total'] as num).toDouble();
    return budget - spent;
  }
}