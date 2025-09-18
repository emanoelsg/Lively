// screens/event_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lively/providers/event_provider.dart';
import 'package:lively/widgets/event_card.dart';

/// Screen that shows the history of all events
class EventHistoryScreen extends ConsumerWidget {
  const EventHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventState = ref.watch(eventNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event History'),
      ),
      body: eventState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : eventState.events.isEmpty
              ? _EmptyHistoryView()
              : ListView.builder(
                  itemCount: eventState.events.length,
                  itemBuilder: (context, index) {
                    final event = eventState.events[index];
                    return EventCard(
                      event: event,
                      onEdit: () => context.push('/event/edit/${event.id}'),
                      onDelete: () {
                        ref
                            .read(eventNotifierProvider.notifier)
                            .deleteEvent(event.id!);
                      },
                    );
                  },
                ),
    );
  }
}

/// Widget shown when there are no events
class _EmptyHistoryView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.history,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No events yet',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.push('/event/add'),
            child: const Text('Add Event'),
          ),
        ],
      ),
    );
  }
}