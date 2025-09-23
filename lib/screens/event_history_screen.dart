// screens/event_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lively/providers/event_provider.dart';
import 'package:lively/core/utils/formatters.dart';

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
                    return ListTile(
                      title: Text(event.name),
                      subtitle: Text(formatNumber(event.value)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => context.push('/event/edit/${event.id}'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              ref
                                  .read(eventNotifierProvider.notifier)
                                  .deleteEvent(event.id!,ref);
                            },
                          ),
                        ],
                      ),
                      onTap: () => context.push('/event/edit/${event.id}'),
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
            Icons.list_alt,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No events yet',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start by adding your first event.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.push('/event/add'),
            icon: const Icon(Icons.add),
            label: const Text('Add First Event'),
          ),
        ],
      ),
    );
  }
}
