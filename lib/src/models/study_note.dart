import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

/// A reusable research note for sermon/ministry prep, distinct from [ReadingNote].
///
/// Study notes are intended to be cited across multiple sermons rather than
/// tied to a single reading session.
class StudyNote {
  final String id;
  final String? verseId;
  final String? passageRef;
  final String content;
  final String? source;
  final List<String> tags;
  final bool usedInSermon;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudyNote({
    required this.id,
    this.verseId,
    this.passageRef,
    required this.content,
    this.source,
    List<String>? tags,
    this.usedInSermon = false,
    required this.createdAt,
    required this.updatedAt,
  }) : tags = tags ?? [];

  /// Creates a new [StudyNote] with a generated UUID and current timestamp.
  factory StudyNote.create({
    required String content,
    String? verseId,
    String? passageRef,
    String? source,
    List<String>? tags,
    bool usedInSermon = false,
  }) {
    final now = DateTime.now();
    return StudyNote(
      id: const Uuid().v4(),
      verseId: verseId,
      passageRef: passageRef,
      content: content,
      source: source,
      tags: tags,
      usedInSermon: usedInSermon,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory StudyNote.fromJson(Map<String, dynamic> json) => StudyNote(
        id: json['id'] as String,
        verseId: json['verseId'] as String?,
        passageRef: json['passageRef'] as String?,
        content: json['content'] as String,
        source: json['source'] as String?,
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        usedInSermon: json['usedInSermon'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'verseId': verseId,
        'passageRef': passageRef,
        'content': content,
        'source': source,
        'tags': tags,
        'usedInSermon': usedInSermon,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  StudyNote copyWith({
    String? id,
    String? verseId,
    String? passageRef,
    String? content,
    String? source,
    List<String>? tags,
    bool? usedInSermon,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearVerseId = false,
    bool clearPassageRef = false,
    bool clearSource = false,
  }) =>
      StudyNote(
        id: id ?? this.id,
        verseId: clearVerseId ? null : (verseId ?? this.verseId),
        passageRef: clearPassageRef ? null : (passageRef ?? this.passageRef),
        content: content ?? this.content,
        source: clearSource ? null : (source ?? this.source),
        tags: tags ?? List<String>.from(this.tags),
        usedInSermon: usedInSermon ?? this.usedInSermon,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudyNote &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          verseId == other.verseId &&
          passageRef == other.passageRef &&
          content == other.content &&
          source == other.source &&
          const ListEquality<String>().equals(tags, other.tags) &&
          usedInSermon == other.usedInSermon &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(
        id,
        verseId,
        passageRef,
        content,
        source,
        const ListEquality<String>().hash(tags),
        usedInSermon,
        createdAt,
        updatedAt,
      );

  @override
  String toString() =>
      'StudyNote(id: $id, verseId: $verseId, passageRef: $passageRef, '
      'content: $content, source: $source, tags: $tags, '
      'usedInSermon: $usedInSermon, createdAt: $createdAt)';
}
