import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

/// A discrete Bible reading session with a start time, optional end time,
/// and a list of verse IDs read during the session.
class ReadingSession {
  final String id;
  final DateTime startedAt;

  /// End time; null while the session is still active.
  final DateTime? endedAt;

  /// Canonical verse IDs read during this session.
  final List<String> verseIds;

  final DateTime createdAt;

  const ReadingSession({
    required this.id,
    required this.startedAt,
    this.endedAt,
    required this.verseIds,
    required this.createdAt,
  });

  /// Creates a new [ReadingSession] with a generated UUID and current timestamp.
  factory ReadingSession.create({
    required DateTime startedAt,
    DateTime? endedAt,
    List<String> verseIds = const [],
  }) =>
      ReadingSession(
        id: const Uuid().v4(),
        startedAt: startedAt,
        endedAt: endedAt,
        verseIds: List<String>.from(verseIds),
        createdAt: DateTime.now(),
      );

  factory ReadingSession.fromJson(Map<String, dynamic> json) => ReadingSession(
        id: json['id'] as String,
        startedAt: DateTime.parse(json['startedAt'] as String),
        endedAt: json['endedAt'] != null
            ? DateTime.parse(json['endedAt'] as String)
            : null,
        verseIds: List<String>.from(
          (json['verseIds'] as List<dynamic>).cast<String>(),
        ),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt?.toIso8601String(),
        'verseIds': verseIds.toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  ReadingSession copyWith({
    String? id,
    DateTime? startedAt,
    DateTime? endedAt,
    List<String>? verseIds,
    DateTime? createdAt,
    bool clearEndedAt = false,
  }) =>
      ReadingSession(
        id: id ?? this.id,
        startedAt: startedAt ?? this.startedAt,
        endedAt: clearEndedAt ? null : (endedAt ?? this.endedAt),
        verseIds: verseIds ?? List<String>.from(this.verseIds),
        createdAt: createdAt ?? this.createdAt,
      );

  /// Minutes elapsed between [startedAt] and [endedAt]. Returns 0 if session
  /// has not ended.
  int get durationMinutes =>
      endedAt == null ? 0 : endedAt!.difference(startedAt).inMinutes;

  /// Number of verses read during this session.
  int get versesRead => verseIds.length;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingSession &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          startedAt == other.startedAt &&
          endedAt == other.endedAt &&
          const ListEquality<String>().equals(verseIds, other.verseIds) &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(
        id,
        startedAt,
        endedAt,
        const ListEquality<String>().hash(verseIds),
        createdAt,
      );

  @override
  String toString() =>
      'ReadingSession(id: $id, startedAt: $startedAt, endedAt: $endedAt, '
      'verses: $versesRead, durationMinutes: $durationMinutes)';
}
