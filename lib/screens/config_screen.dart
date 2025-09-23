// screens/config_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lively/core/constants.dart';
import 'package:lively/core/utils/formatters.dart';
import 'package:lively/providers/budget_provider.dart';
import 'package:lively/providers/event_provider.dart';

/// Screen for app configuration and backup management
class ConfigScreen extends ConsumerStatefulWidget {
  const ConfigScreen({super.key});

  @override
  ConsumerState<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends ConsumerState<ConfigScreen> {
  final _budgetController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final budget = ref.read(budgetNotifierProvider).budget;
    if (budget != null) {
      _budgetController.text = formatNumber(budget);
    }
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _saveBudget() async {
    final value = tryParseDouble(_budgetController.text);
    if (value == null) {
      _showError('Please enter a valid number');
      return;
    }

    if (value <= 0) {
      _showError('Budget must be greater than zero');
      return;
    }

    if (value > AppConstants.maxBudgetValue) {
      _showError('Budget is too large');
      return;
    }

    try {
      setState(() => _isLoading = true);
      await ref.read(budgetNotifierProvider.notifier).setBudget(value);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Budget saved successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportBackup() async {
    try {
      setState(() => _isLoading = true);
      final budget = ref.read(budgetNotifierProvider).budget ?? 0.0;
      await ref.read(eventNotifierProvider.notifier).exportToJson(budget);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup saved successfully!'),
            duration: AppConstants.snackBarDuration,
          ),
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _importBackup() async {
    try {
      setState(() => _isLoading = true);
      final shouldReplace = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Import Backup'),
          content: const Text(
            'Do you want to replace all existing data with the backup or merge them?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Merge'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Replace'),
            ),
          ],
        ),
      );

      if (shouldReplace == null) return;

      final downloadsDir = await _getDownloadsDirectory();
      final filePath = '${downloadsDir.path}/${AppConstants.backupFileName}';

      if (!File(filePath).existsSync()) {
        throw 'Backup file not found at $filePath';
      }

      await ref.read(eventNotifierProvider.notifier).importFromJson(
            filePath,ref,
            replace: shouldReplace,
          );

      await ref.read(budgetNotifierProvider.notifier).loadBudget();

      if (mounted) {
        final budget = ref.read(budgetNotifierProvider).budget;
        if (budget != null) {
          _budgetController.text = formatNumber(budget);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup imported successfully!')),
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $message')),
    );
  }

  Future<Directory> _getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      final directory = Directory('/storage/emulated/0/Download');
      if (!directory.existsSync()) {
        throw const FileSystemException(
          'Downloads directory not found',
        );
      }
      return directory;
    }

    return Directory('${Directory.systemTemp.path}/Downloads')
      ..createSync(recursive: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Monthly Budget',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _budgetController,
                            decoration: const InputDecoration(
                              labelText: 'Budget Amount',
                              hintText: 'Enter monthly budget',
                              border: OutlineInputBorder(),
                              prefixText: '\$', // Add currency symbol
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              DecimalTextInputFormatter(),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _saveBudget,
                            child: const Text('Save Budget'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Backup',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _exportBackup,
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Export Data'),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _importBackup,
                            icon: const Icon(Icons.download_for_offline),
                            label: const Text('Import Data'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
