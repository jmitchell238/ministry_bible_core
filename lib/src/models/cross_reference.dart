/// The semantic relationship between two Bible verses.
enum CrossReferenceType { parallel, fulfillment, quotation, thematic }

/// A directional link between two Bible verses.
///
/// Cross-references may come from a built-in dataset or be user-created.
/// The pair ([fromVerseId], [toVerseId], [type]) serves as the natural key.
class CrossReference {
  /// Source verse, e.g. "Matthew-5-17".
  final String fromVerseId;

  /// Target verse, e.g. "Isaiah-53-5".
  final String toVerseId;

  final CrossReferenceType type;

  /// Optional human-readable note explaining the connection.
  final String? note;

  const CrossReference({
    required this.fromVerseId,
    required this.toVerseId,
    required this.type,
    this.note,
  });

  factory CrossReference.fromJson(Map<String, dynamic> json) => CrossReference(
        fromVerseId: json['fromVerseId'] as String,
        toVerseId: json['toVerseId'] as String,
        type: CrossReferenceType.values.byName(json['type'] as String),
        note: json['note'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'fromVerseId': fromVerseId,
        'toVerseId': toVerseId,
        'type': type.name,
        'note': note,
      };

  CrossReference copyWith({
    String? fromVerseId,
    String? toVerseId,
    CrossReferenceType? type,
    String? note,
    bool clearNote = false,
  }) =>
      CrossReference(
        fromVerseId: fromVerseId ?? this.fromVerseId,
        toVerseId: toVerseId ?? this.toVerseId,
        type: type ?? this.type,
        note: clearNote ? null : (note ?? this.note),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CrossReference &&
          runtimeType == other.runtimeType &&
          fromVerseId == other.fromVerseId &&
          toVerseId == other.toVerseId &&
          type == other.type &&
          note == other.note;

  @override
  int get hashCode => Object.hash(fromVerseId, toVerseId, type, note);

  @override
  String toString() =>
      'CrossReference($fromVerseId → $toVerseId, type: $type)';
}
