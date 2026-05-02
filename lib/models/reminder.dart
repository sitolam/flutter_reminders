import 'dart:convert';

enum IntervalUnit { minutes, hours, days }

class Reminder {
  final int id;
  final String title;
  final String? note;
  final int intervalValue;
  final IntervalUnit intervalUnit;
  final bool enabled;
  final DateTime createdAt;

  Reminder({
    required this.id,
    required this.title,
    this.note,
    required this.intervalValue,
    required this.intervalUnit,
    this.enabled = true,
    required this.createdAt,
  });

  Duration get duration {
    switch (intervalUnit) {
      case IntervalUnit.minutes:
        return Duration(minutes: intervalValue);
      case IntervalUnit.hours:
        return Duration(hours: intervalValue);
      case IntervalUnit.days:
        return Duration(days: intervalValue);
    }
  }

  String get intervalLabel {
    final unit = switch (intervalUnit) {
      IntervalUnit.minutes => intervalValue == 1 ? 'minute' : 'minutes',
      IntervalUnit.hours => intervalValue == 1 ? 'hour' : 'hours',
      IntervalUnit.days => intervalValue == 1 ? 'day' : 'days',
    };
    return 'Every $intervalValue $unit';
  }

  Reminder copyWith({
    int? id,
    String? title,
    String? note,
    int? intervalValue,
    IntervalUnit? intervalUnit,
    bool? enabled,
    DateTime? createdAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      intervalValue: intervalValue ?? this.intervalValue,
      intervalUnit: intervalUnit ?? this.intervalUnit,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'note': note,
        'intervalValue': intervalValue,
        'intervalUnit': intervalUnit.name,
        'enabled': enabled,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Reminder.fromMap(Map<String, dynamic> m) => Reminder(
        id: m['id'] as int,
        title: m['title'] as String,
        note: m['note'] as String?,
        intervalValue: m['intervalValue'] as int,
        intervalUnit: IntervalUnit.values
            .firstWhere((e) => e.name == m['intervalUnit']),
        enabled: m['enabled'] as bool? ?? true,
        createdAt: DateTime.parse(m['createdAt'] as String),
      );

  String toJson() => jsonEncode(toMap());
  factory Reminder.fromJson(String s) =>
      Reminder.fromMap(jsonDecode(s) as Map<String, dynamic>);
}
