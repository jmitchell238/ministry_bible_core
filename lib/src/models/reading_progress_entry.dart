/// A record that a specific verse was read at a given time.
class ReadingProgressEntry {
  final String verseId;
  final DateTime readAt;

  const ReadingProgressEntry({
    required this.verseId,
    required this.readAt,
  });

  factory ReadingProgressEntry.fromJson(Map<String, dynamic> json) =>
      ReadingProgressEntry(
        verseId: json['verseId'] as String,
        readAt: DateTime.parse(json['readAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'verseId': verseId,
        'readAt': readAt.toIso8601String(),
      };

  ReadingProgressEntry copyWith({String? verseId, DateTime? readAt}) =>
      ReadingProgressEntry(
        verseId: verseId ?? this.verseId,
        readAt: readAt ?? this.readAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingProgressEntry &&
          runtimeType == other.runtimeType &&
          verseId == other.verseId &&
          readAt == other.readAt;

  @override
  int get hashCode => Object.hash(verseId, readAt);

  @override
  String toString() => 'ReadingProgressEntry(verseId: $verseId, readAt: $readAt)';
}
