import 'package:collection/collection.dart';

/// The type of a [ReadingPlanEvent].
enum ReadingPlanEventType { paused, resumed, skipped }

/// A single state-change event in a [ReadingPlanState].
class ReadingPlanEvent {
  final ReadingPlanEventType type;
  final DateTime date;

  const ReadingPlanEvent({required this.type, required this.date});

  factory ReadingPlanEvent.fromJson(Map<String, dynamic> json) => ReadingPlanEvent(
        type: ReadingPlanEventType.values.byName(json['type'] as String),
        date: DateTime.parse(json['date'] as String),
      );

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'date': date.toIso8601String(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingPlanEvent &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          date == other.date;

  @override
  int get hashCode => Object.hash(type, date);

  @override
  String toString() => 'ReadingPlanEvent(type: ${type.name}, date: $date)';
}

/// Tracks pause/resume/skip events for a reading plan, allowing the effective
/// day number to exclude days when the plan was paused.
class ReadingPlanState {
  final DateTime startDate;
  final List<ReadingPlanEvent> events;

  ReadingPlanState({
    required this.startDate,
    required List<ReadingPlanEvent> events,
  }) : events = List.unmodifiable(events);

  /// Creates a fresh [ReadingPlanState] with no events.
  factory ReadingPlanState.create({required DateTime startDate}) =>
      ReadingPlanState(startDate: startDate, events: []);

  factory ReadingPlanState.fromJson(Map<String, dynamic> json) => ReadingPlanState(
        startDate: DateTime.parse(json['startDate'] as String),
        events: (json['events'] as List<dynamic>)
            .map((e) => ReadingPlanEvent.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'startDate': startDate.toIso8601String(),
        'events': events.map((e) => e.toJson()).toList(),
      };

  /// The effective plan day number as of [asOf], accounting for paused intervals.
  ///
  /// Days when the plan is paused (between a [ReadingPlanEventType.paused] and
  /// the next [ReadingPlanEventType.resumed] event) are not counted.
  /// If paused with no resume, counting stops at the pause date.
  int effectiveDayNumber(DateTime asOf) {
    final totalElapsed = asOf.difference(startDate).inDays;

    int pausedDays = 0;
    DateTime? pausedAt;

    for (final event in events) {
      if (event.date.isAfter(asOf)) break;

      if (event.type == ReadingPlanEventType.paused) {
        pausedAt = event.date;
      } else if (event.type == ReadingPlanEventType.resumed && pausedAt != null) {
        pausedDays += event.date.difference(pausedAt).inDays;
        pausedAt = null;
      }
    }

    // Still paused — count paused days up to asOf
    if (pausedAt != null) {
      pausedDays += asOf.difference(pausedAt).inDays;
    }

    return (totalElapsed - pausedDays) + 1;
  }

  /// Whether the plan is currently paused as of [asOf].
  bool isPaused(DateTime asOf) {
    ReadingPlanEventType? lastRelevant;
    for (final event in events) {
      if (event.date.isAfter(asOf)) break;
      if (event.type == ReadingPlanEventType.paused ||
          event.type == ReadingPlanEventType.resumed) {
        lastRelevant = event.type;
      }
    }
    return lastRelevant == ReadingPlanEventType.paused;
  }

  /// All dates on which the plan was intentionally skipped.
  List<DateTime> get skippedDays => events
      .where((e) => e.type == ReadingPlanEventType.skipped)
      .map((e) => e.date)
      .toList();

  ReadingPlanState copyWith({
    DateTime? startDate,
    List<ReadingPlanEvent>? events,
  }) =>
      ReadingPlanState(
        startDate: startDate ?? this.startDate,
        events: events ?? List<ReadingPlanEvent>.from(this.events),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingPlanState &&
          runtimeType == other.runtimeType &&
          startDate == other.startDate &&
          const ListEquality<ReadingPlanEvent>().equals(events, other.events);

  @override
  int get hashCode => Object.hash(
        startDate,
        const ListEquality<ReadingPlanEvent>().hash(events),
      );

  @override
  String toString() =>
      'ReadingPlanState(startDate: $startDate, events: ${events.length})';
}
