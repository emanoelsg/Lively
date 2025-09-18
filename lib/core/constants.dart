// core/constants.dart
/// Core constants used throughout the Lively app
class AppConstants {
  // Database
  static const String dbName = 'lively.db';
  static const String eventsTable = 'events';
  static const String settingsTable = 'settings';
  
  // File paths
  static const String backupFileName = 'lively_backup.json';
  
  // Theme
  static const double donutStrokeWidth = 25.0;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largeSpacing = 24.0;
  
  // Input validation
  static const int maxNameLength = 50;
  static const int maxDecimalPlaces = 2;
  static const double maxBudgetValue = 999999.99;
  
  // Animation durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 4);
  
  // JSON Backup
  static const String appName = 'Lively';
  static const int backupVersion = 1;
  
  // Storage keys
  static const String nicknameKey = 'nickname';
  static const String profilePhotoPathKey = 'profile_photo_path';
  static const String monthlyBudgetKey = 'monthly_budget';
  
  // Error messages are moved to .arb files for localization
}