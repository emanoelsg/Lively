// screens/home_screen.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lively/core/constants.dart';
import 'package:lively/core/theme.dart';
import 'package:lively/core/utils/formatters.dart';
import 'package:lively/models/event.dart';
import 'package:lively/providers/budget_provider.dart';
import 'package:lively/providers/event_provider.dart';
import 'package:lively/providers/profile_provider.dart';
import 'dart:io';

/// The main home screen of the app showing the budget donut chart
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(eventNotifierProvider.notifier).loadEvents();
      ref.read(budgetNotifierProvider.notifier).loadBudget();
      ref.read(profileNotifierProvider.notifier).loadProfile();
    });
  }

void _showSetBudgetDialog() {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return _SetBudgetDialog();
    },
  );
}

  @override
  Widget build(BuildContext context) {
    // Acessamos o 'ref' diretamente, sem precisar passá-lo como parâmetro
    final eventState = ref.watch(eventNotifierProvider);
    final budgetState = ref.watch(budgetNotifierProvider);
    final profileState = ref.watch(profileNotifierProvider);

    if (!budgetState.isLoading && budgetState.budget == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSetBudgetDialog();
      });
    }

    return Scaffold(
      appBar: AppBar(
        // Conditionally show a personalized greeting
        title: profileState.nickname.isEmpty
            ? const Text('Lively')
            : Text('Welcome, ${profileState.nickname}!'),
        actions: [
          // Show the profile photo in the app bar
          if (profileState.photoPath != null &&
              File(profileState.photoPath!).existsSync())
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: CircleAvatar(
                backgroundImage: FileImage(File(profileState.photoPath!)),
                radius: 18,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/history'),
            tooltip: 'Event History',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/config'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: eventState.isLoading || budgetState.isLoading || profileState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : budgetState.budget == null
              ? _NoBudgetView()
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _BudgetView(
                        budget: budgetState.budget!,
                        remainingBudget: budgetState.remainingBudget!,
                      ),
                      const SizedBox(height: 24),
                      if (eventState.events.isNotEmpty)
                        _RecentEventsList(events: eventState.events.take(5).toList()),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/event/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Event'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

/// Widget shown when no budget is set
class _NoBudgetView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No monthly budget set',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Set your budget to start tracking expenses.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/config'),
            icon: const Icon(Icons.settings),
            label: const Text('Set Budget'),
          ),
        ],
      ),
    );
  }
}

/// Widget showing the budget donut chart
class _BudgetView extends StatelessWidget {
  final double budget;
  final double remainingBudget;

  const _BudgetView({
    required this.budget,
    required this.remainingBudget,
  });

  @override
  Widget build(BuildContext context) {
    final spent = budget - remainingBudget;
    final percentage = (remainingBudget / budget).clamp(0.0, 1.0);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          children: [
            SizedBox(
              height: 220,
              width: 220,
              child: Stack(
                children: [
                  PieChart(
                    PieChartData(
                      startDegreeOffset: 270,
                      sectionsSpace: 0,
                      centerSpaceRadius: 80,
                      sections: [
                        PieChartSectionData(
                          value: percentage * 100,
                          color: AppTheme.primaryColor,
                          title: '',
                          radius: AppConstants.donutStrokeWidth,
                        ),
                        if (percentage < 1)
                          PieChartSectionData(
                            value: (1 - percentage) * 100,
                            color: Colors.grey.shade300,
                            title: '',
                            radius: AppConstants.donutStrokeWidth,
                          ),
                      ],
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          formatNumber(remainingBudget),
                          style:
                              Theme.of(context).textTheme.headlineMedium!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const Text(
                          'Remaining',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _BudgetInfo(
                    title: 'Spent',
                    value: formatNumber(spent),
                    color: Colors.red,
                  ),
                  _BudgetInfo(
                    title: 'Total Budget',
                    value: formatNumber(budget),
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetInfo extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _BudgetInfo({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style:
              TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}

class _RecentEventsList extends ConsumerWidget {
  final List<Event> events;

  const _RecentEventsList({required this.events});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Events',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () => context.push('/history'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return ListTile(
                  dense: true,
                  title: Text(event.name),
                  trailing: Text(
                    formatNumber(event.value),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () => context.push('/event/edit/${event.id}'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SetBudgetDialog extends ConsumerStatefulWidget {
  @override
  _SetBudgetDialogState createState() => _SetBudgetDialogState();
}

class _SetBudgetDialogState extends ConsumerState<_SetBudgetDialog> {
  final _budgetController = TextEditingController();

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Your Monthly Budget'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            const Text(
                'Welcome! To start tracking your expenses, please set your monthly budget.'),
            const SizedBox(height: 16),
            TextField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monthly Budget',
                border: OutlineInputBorder(),
                prefixText: 'R\$ ',
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Save'),
          onPressed: () {
            final double? budget = double.tryParse(_budgetController.text);
            if (budget != null && budget > 0) {
              // Salva o orçamento e fecha o diálogo
              ref.read(budgetNotifierProvider.notifier).setBudget(budget);
              Navigator.of(context).pop();
            } else {
              // Mostra um erro se o valor for inválido
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid budget.')),
              );
            }
          },
        ),
      ],
    );
  }
}