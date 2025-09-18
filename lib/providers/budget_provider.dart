// providers/budget_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:lively/services/budget_repository.dart';

/// State class for budget with loading and error states
class BudgetState {
  final double? budget;
  final double? remainingBudget;
  final bool isLoading;
  final String? error;

  const BudgetState({
    this.budget,
    this.remainingBudget,
    required this.isLoading,
    this.error,
  });

  BudgetState copyWith({
    double? budget,
    double? remainingBudget,
    bool? isLoading,
    String? error,
  }) {
    return BudgetState(
      budget: budget ?? this.budget,
      remainingBudget: remainingBudget ?? this.remainingBudget,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier class that manages the budget state
class BudgetNotifier extends StateNotifier<BudgetState> {
  final BudgetRepository _repository;

  BudgetNotifier(this._repository)
      : super(const BudgetState(isLoading: true));

  /// Loads the budget and remaining amount
  Future<void> loadBudget() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final budget = await _repository.getBudget();
      final remainingBudget = await _repository.getRemainingBudget();
      state = state.copyWith(
        budget: budget,
        remainingBudget: remainingBudget,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Sets a new budget amount
  Future<void> setBudget(double budget) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _repository.setBudget(budget);
      await loadBudget();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
}

/// Provider that creates and maintains the budget repository
final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository();
});

/// Provider that creates and maintains the budget notifier
final budgetNotifierProvider =
    StateNotifierProvider<BudgetNotifier, BudgetState>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  return BudgetNotifier(repository);
});