// test/unit/event_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:lively/models/event.dart';
import 'package:lively/services/event_repository.dart';
import 'package:lively/providers/budget_provider.dart';

/// State class for event list with loading and error states
class EventState {
  final List<Event> events;
  final bool isLoading;
  final String? error;
  final double totalSpent;

  const EventState({
    required this.events,
    required this.isLoading,
    this.error,
    required this.totalSpent,
  });

  EventState copyWith({
    List<Event>? events,
    bool? isLoading,
    String? error,
    double? totalSpent,
  }) {
    return EventState(
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totalSpent: totalSpent ?? this.totalSpent,
    );
  }
}

/// Notifier class that manages the event state
class EventNotifier extends StateNotifier<EventState> {
  final EventRepository _repository;
  final Ref ref;

  EventNotifier(this._repository, this.ref)
      : super(const EventState(events: [], isLoading: true, totalSpent: 0));

  /// Loads all events from the repository
  Future<void> loadEvents() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final events = await _repository.getAllEvents();
      final totalSpent = await _repository.getTotalSpent();
      state = state.copyWith(
        events: events,
        totalSpent: totalSpent,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> clearAllEvents() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _repository.deleteAllEvents();
      await loadEvents();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Adds a new event
  Future<void> addEvent(Event event) async {
    try {
      await _repository.insertEvent(event);

      final updatedEvents = [...state.events, event];
      final updatedTotalSpent = state.totalSpent + event.value;

      state = state.copyWith(
        events: updatedEvents,
        totalSpent: updatedTotalSpent,
      );

      await loadEvents();

      // 🔥 Atualiza orçamento
      await ref.read(budgetNotifierProvider.notifier).loadBudget();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> updateEvent(Event event) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _repository.updateEvent(event);
      await loadEvents();

      // 🔥 Atualiza orçamento
      await ref.read(budgetNotifierProvider.notifier).loadBudget();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> deleteEvent(int id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _repository.deleteEvent(id);
      await loadEvents();

      // 🔥 Atualiza orçamento
      await ref.read(budgetNotifierProvider.notifier).loadBudget();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Gets an event by ID
  Future<Event?> getEventById(int id) async {
    try {
      return await _repository.getEventById(id);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Exports events to JSON
  Future<String?> exportToJson(double budget) async {
    try {
      return await _repository.exportToJson(budget);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Imports events from JSON
  Future<void> importFromJson(String filePath, {bool replace = true}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _repository.importFromJson(filePath, replace: replace);
      await loadEvents();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
}

/// Provider that creates and maintains the event repository
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository();
});

/// Provider that creates and maintains the event notifier
final eventNotifierProvider =
    StateNotifierProvider<EventNotifier, EventState>((ref) {
  final repository = ref.watch(eventRepositoryProvider);
  return EventNotifier(repository, ref);
});
