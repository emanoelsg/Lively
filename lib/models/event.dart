// models/event.dart
/// Represents an expense event in the Lively app
class Event {
  /// Unique identifier for the event. Null for new events.
  final int? id;
  
  /// Name/description of the expense
  final String name;
  
  /// Value of the expense (always positive)
  final double value;

  const Event({
    this.id,
    required this.name,
    required this.value,
  });

  /// Creates a copy of this event with the given fields replaced with new values
  Event copyWith({
    int? id,
    String? name,
    double? value,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      value: value ?? this.value,
    );
  }

  /// Creates an Event from a map (e.g., from database or JSON)
  factory Event.fromMap(Map<String, dynamic> map) {
    final rawValue = map['value'];
    double value;
    
    if (rawValue is num) {
      value = rawValue.toDouble();
    } else if (rawValue is String) {
      value = double.parse(rawValue);
    } else {
      throw FormatException('Invalid value type: ${rawValue.runtimeType}');
    }

    return Event(
      id: map['id'] != null ? int.parse(map['id'].toString()) : null,
      name: map['name'] as String,
      value: value,
    );
  }

  /// Converts this event to a map for database storage or JSON serialization
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'value': value,
    };
  }

  @override
  String toString() => 'Event(id: $id, name: $name, value: $value)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Event &&
        other.id == id &&
        other.name == name &&
        other.value == value;
  }

  @override
  int get hashCode => Object.hash(id, name, value);
}