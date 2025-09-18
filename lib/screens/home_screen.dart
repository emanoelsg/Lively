// screens/home_screen.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lively/core/constants.dart';
import 'package:lively/core/theme.dart';
import 'package:lively/core/utils/formatters.dart';
import 'package:lively/providers/budget_provider.dart';
import 'package:lively/providers/event_provider.dart';

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
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventState = ref.watch(eventNotifierProvider);
    final budgetState = ref.watch(budgetNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lively'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/history'),
            tooltip: 'History',
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
            tooltip: 'Profile',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/config'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: eventState.isLoading || budgetState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : budgetState.budget == null
              ? _NoBudgetView()
              : _BudgetView(
                  budget: budgetState.budget!,
                  remainingBudget: budgetState.remainingBudget!,
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/event/add'),
        child: const Icon(Icons.add),
      ),
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
          const Text(
            'No monthly budget set',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.push('/config'),
            child: const Text('Set Budget'),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 300,
            width: 300,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    startDegreeOffset: 270,
                    sectionsSpace: 0,
                    centerSpaceRadius: 100,
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
                        style: const TextStyle(
                          fontSize: 40,
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
          Text(
            'Spent: ${formatNumber(spent)}',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            'Budget: ${formatNumber(budget)}',
            style: const TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}