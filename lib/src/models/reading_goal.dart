import 'package:uuid/uuid.dart';

/// The unit of measurement for a daily reading goal.
enum GoalType { versesPerDay, chaptersPerDay, minutesPerDay }

/// A configurable daily reading goal.
///
/// Use [isAchieved] to let the library determine whether a day's activity
/// meets the goal, rather than computing it in each consuming app.
class ReadingGoal {
  final String id;
  final GoalType type;

  /// The numeric target (e.g. 3 chapters, 85 verses, 30 minutes).
  final int target;

  final DateTime createdAt;
  final DateTime updatedAt;

  const ReadingGoal({
    required this.id,
    required this.type,
    required this.target,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a new [ReadingGoal] with a generated UUID and current timestamps.
  factory ReadingGoal.create({
    required GoalType type,
    required int target,
  }) {
    final now = DateTime.now();
    return ReadingGoal(
      id: const Uuid().v4(),
      type: type,
      target: target,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory ReadingGoal.fromJson(Map<String, dynamic> json) => ReadingGoal(
        id: json['id'] as String,
        type: GoalType.values.byName(json['type'] as String),
        target: json['target'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'target': target,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  ReadingGoal copyWith({
    String? id,
    GoalType? type,
    int? target,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      ReadingGoal(
        id: id ?? this.id,
        type: type ?? this.type,
        target: target ?? this.target,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  /// Returns true if the activity described by the parameters meets this goal.
  ///
  /// Pass whichever metrics apply — unused parameters default to 0.
  bool isAchieved({
    required int versesRead,
    int chaptersRead = 0,
    int minutesRead = 0,
  }) {
    switch (type) {
      case GoalType.versesPerDay:
        return versesRead >= target;
      case GoalType.chaptersPerDay:
        return chaptersRead >= target;
      case GoalType.minutesPerDay:
        return minutesRead >= target;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingGoal &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          target == other.target &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(id, type, target, createdAt, updatedAt);

  @override
  String toString() =>
      'ReadingGoal(id: $id, type: $type, target: $target)';
}
