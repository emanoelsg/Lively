// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Lively';

  @override
  String get remaining => 'Remaining';

  @override
  String get spent => 'Spent';

  @override
  String get budget => 'Budget';

  @override
  String get noBudget => 'No monthly budget set';

  @override
  String get setBudget => 'Set Budget';

  @override
  String get history => 'Event History';

  @override
  String get noEvents => 'No events yet';

  @override
  String get addEvent => 'Add Event';

  @override
  String get editEvent => 'Edit Event';

  @override
  String get name => 'Name';

  @override
  String get namePlaceholder => 'Enter event name';

  @override
  String get value => 'Value';

  @override
  String get valuePlaceholder => 'Enter value';

  @override
  String get deleteConfirm => 'Are you sure you want to delete this event?';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save Changes';

  @override
  String get add => 'Add Event';

  @override
  String get nameRequired => 'Please enter a name';

  @override
  String get valueRequired => 'Please enter a value';

  @override
  String get invalidNumber => 'Please enter a valid number';

  @override
  String get valuePositive => 'Value must be greater than zero';

  @override
  String get valueTooLarge => 'Value is too large';

  @override
  String get profileTitle => 'Profile';

  @override
  String get changePhoto => 'Change Photo';

  @override
  String get nickname => 'Nickname';

  @override
  String get nicknamePlaceholder => 'Enter your nickname';

  @override
  String get saveProfile => 'Save Profile';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String errorPickingImage(Object error) {
    return 'Error picking image: $error';
  }

  @override
  String errorSavingProfile(Object error) {
    return 'Error saving profile: $error';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get monthlyBudget => 'Monthly Budget';

  @override
  String get budgetAmount => 'Budget Amount';

  @override
  String get budgetPlaceholder => 'Enter monthly budget';

  @override
  String get saveBudget => 'Save Budget';

  @override
  String get budgetSaved => 'Budget saved';

  @override
  String get backup => 'Backup';

  @override
  String get export => 'Export to Downloads';

  @override
  String get import => 'Import from Downloads';

  @override
  String get importTitle => 'Import Backup';

  @override
  String get importConfirm => 'Do you want to replace all existing data with the backup?';

  @override
  String get merge => 'Merge';

  @override
  String get replace => 'Replace';

  @override
  String backupSaved(Object path) {
    return 'Backup saved to $path';
  }

  @override
  String get backupImported => 'Backup imported successfully';

  @override
  String fileNotFound(Object path) {
    return 'Backup file not found at $path';
  }

  @override
  String get invalidFormat => 'Invalid backup file format';

  @override
  String exportError(Object error) {
    return 'Error exporting backup: $error';
  }

  @override
  String importError(Object error) {
    return 'Error importing backup: $error';
  }

  @override
  String error(Object message) {
    return 'Error: $message';
  }

  @override
  String get ok => 'OK';
}
