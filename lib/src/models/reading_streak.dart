/// Immutable reading streak state.
///
/// All fields are final — [StreakCalculator] returns a new [ReadingStreak]
/// instance rather than mutating the existing one.
class ReadingStreak {
  final int currentActionStreak;
  final int highestActionStreak;
  final int currentGoalStreak;
  final int highestGoalStreak;

  /// The last date any reading activity was recorded (midnight-normalized).
  final DateTime? lastActionDate;

  /// The last date the daily goal was achieved (midnight-normalized).
  final DateTime? lastGoalDate;

  final DateTime createdAt;
  final DateTime modifiedAt;

  const ReadingStreak({
    required this.currentActionStreak,
    required this.highestActionStreak,
    required this.currentGoalStreak,
    required this.highestGoalStreak,
    this.lastActionDate,
    this.lastGoalDate,
    required this.createdAt,
    required this.modifiedAt,
  });

  /// Creates an empty streak with all counts set to 0.
  factory ReadingStreak.empty() {
    final now = DateTime.now();
    return ReadingStreak(
      currentActionStreak: 0,
      highestActionStreak: 0,
      currentGoalStreak: 0,
      highestGoalStreak: 0,
      lastActionDate: null,
      lastGoalDate: null,
      createdAt: now,
      modifiedAt: now,
    );
  }

  factory ReadingStreak.fromJson(Map<String, dynamic> json) => ReadingStreak(
        currentActionStreak: json['currentActionStreak'] as int,
        highestActionStreak: json['highestActionStreak'] as int,
        currentGoalStreak: json['currentGoalStreak'] as int,
        highestGoalStreak: json['highestGoalStreak'] as int,
        lastActionDate: json['lastActionDate'] != null
            ? DateTime.parse(json['lastActionDate'] as String)
            : null,
        lastGoalDate: json['lastGoalDate'] != null
            ? DateTime.parse(json['lastGoalDate'] as String)
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
        modifiedAt: DateTime.parse(json['modifiedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'currentActionStreak': currentActionStreak,
        'highestActionStreak': highestActionStreak,
        'currentGoalStreak': currentGoalStreak,
        'highestGoalStreak': highestGoalStreak,
        'lastActionDate': lastActionDate?.toIso8601String(),
        'lastGoalDate': lastGoalDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'modifiedAt': modifiedAt.toIso8601String(),
      };

  ReadingStreak copyWith({
    int? currentActionStreak,
    int? highestActionStreak,
    int? currentGoalStreak,
    int? highestGoalStreak,
    DateTime? lastActionDate,
    DateTime? lastGoalDate,
    DateTime? createdAt,
    DateTime? modifiedAt,
    bool clearLastActionDate = false,
    bool clearLastGoalDate = false,
  }) =>
      ReadingStreak(
        currentActionStreak: currentActionStreak ?? this.currentActionStreak,
        highestActionStreak: highestActionStreak ?? this.highestActionStreak,
        currentGoalStreak: currentGoalStreak ?? this.currentGoalStreak,
        highestGoalStreak: highestGoalStreak ?? this.highestGoalStreak,
        lastActionDate:
            clearLastActionDate ? null : (lastActionDate ?? this.lastActionDate),
        lastGoalDate:
            clearLastGoalDate ? null : (lastGoalDate ?? this.lastGoalDate),
        createdAt: createdAt ?? this.createdAt,
        modifiedAt: modifiedAt ?? this.modifiedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingStreak &&
          runtimeType == other.runtimeType &&
          currentActionStreak == other.currentActionStreak &&
          highestActionStreak == other.highestActionStreak &&
          currentGoalStreak == other.currentGoalStreak &&
          highestGoalStreak == other.highestGoalStreak &&
          lastActionDate == other.lastActionDate &&
          lastGoalDate == other.lastGoalDate &&
          createdAt == other.createdAt &&
          modifiedAt == other.modifiedAt;

  @override
  int get hashCode => Object.hash(
        currentActionStreak,
        highestActionStreak,
        currentGoalStreak,
        highestGoalStreak,
        lastActionDate,
        lastGoalDate,
        createdAt,
        modifiedAt,
      );

  @override
  String toString() =>
      'ReadingStreak(action: $currentActionStreak/$highestActionStreak, '
      'goal: $currentGoalStreak/$highestGoalStreak, '
      'lastAction: $lastActionDate, lastGoal: $lastGoalDate)';
}
