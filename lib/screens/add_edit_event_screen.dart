// screens/add_edit_event_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lively/core/constants.dart';
import 'package:lively/core/utils/formatters.dart';
import 'package:lively/models/event.dart';
import 'package:lively/providers/event_provider.dart';

/// Screen for adding or editing an event
class AddEditEventScreen extends ConsumerStatefulWidget {
  final int? eventId;

  const AddEditEventScreen({super.key, this.eventId});

  @override
  ConsumerState<AddEditEventScreen> createState() => _AddEditEventScreenState();
}

class _AddEditEventScreenState extends ConsumerState<AddEditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _valueController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.eventId != null) {
      _loadEvent();
    }
  }

  Future<void> _loadEvent() async {
    setState(() => _isLoading = true);
    final event = await ref
        .read(eventNotifierProvider.notifier)
        .getEventById(widget.eventId!);
    if (event != null) {
      _nameController.text = event.name;
      _valueController.text = formatNumber(event.value);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final value = double.parse(_valueController.text);

    final event = Event(
      id: widget.eventId,
      name: name,
      value: value,
    );

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(eventNotifierProvider.notifier);
      if (widget.eventId == null) {
        await notifier.addEvent(event);
      } else {
        await notifier.updateEvent(event);
      }
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventId == null ? 'Add Event' : 'Edit Event'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            hintText: 'Enter event name',
                            border: OutlineInputBorder(),
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          maxLength: AppConstants.maxNameLength,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _valueController,
                          decoration: const InputDecoration(
                            labelText: 'Value',
                            hintText: 'Enter value',
                            border: OutlineInputBorder(),
                            prefixText: '\$', // Add currency symbol
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            DecimalTextInputFormatter(),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a value';
                            }
                            final number = double.tryParse(value);
                            if (number == null || number <= 0 || number > AppConstants.maxBudgetValue) {
                              return 'Please enter a valid amount';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        onPressed: _saveEvent,
                        icon: Icon(widget.eventId == null ? Icons.add_circle_outline : Icons.save_outlined),
                        label: Text(
                          widget.eventId == null ? 'Add Event' : 'Save Changes',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
