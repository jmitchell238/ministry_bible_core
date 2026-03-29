import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

/// The scope of a [ReadingNote].
enum NoteType {
  daily,
  chapter,
  verse,
}

/// A user-written note attached to a daily reading session, a chapter, or a verse.
class ReadingNote {
  final String id;
  final NoteType type;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// For [NoteType.daily] notes — the date being journaled.
  final DateTime? date;

  /// For [NoteType.chapter] notes — the book identifier.
  final int? bookId;

  /// For [NoteType.chapter] notes — the chapter number.
  final int? chapter;

  /// For [NoteType.verse] notes — the canonical verse ID (e.g. "Genesis-1-1").
  final String? verseId;

  final List<String> tags;
  final bool isPinned;

  ReadingNote({
    required this.id,
    required this.type,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.date,
    this.bookId,
    this.chapter,
    this.verseId,
    List<String>? tags,
    this.isPinned = false,
  }) : tags = tags ?? [];

  /// Creates a new [ReadingNote] with a generated UUID and current timestamp.
  factory ReadingNote.create({
    required NoteType type,
    required String content,
    DateTime? date,
    int? bookId,
    int? chapter,
    String? verseId,
    List<String>? tags,
    bool isPinned = false,
  }) {
    final now = DateTime.now();
    return ReadingNote(
      id: const Uuid().v4(),
      type: type,
      content: content,
      createdAt: now,
      updatedAt: now,
      date: date,
      bookId: bookId,
      chapter: chapter,
      verseId: verseId,
      tags: tags,
      isPinned: isPinned,
    );
  }

  factory ReadingNote.fromJson(Map<String, dynamic> json) => ReadingNote(
        id: json['id'] as String,
        type: NoteType.values.byName(json['type'] as String),
        content: json['content'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        date: json['date'] != null
            ? DateTime.parse(json['date'] as String)
            : null,
        bookId: json['bookId'] as int?,
        chapter: json['chapter'] as int?,
        verseId: json['verseId'] as String?,
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        isPinned: json['isPinned'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'date': date?.toIso8601String(),
        'bookId': bookId,
        'chapter': chapter,
        'verseId': verseId,
        'tags': tags,
        'isPinned': isPinned,
      };

  ReadingNote copyWith({
    String? id,
    NoteType? type,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? date,
    int? bookId,
    int? chapter,
    String? verseId,
    List<String>? tags,
    bool? isPinned,
  }) =>
      ReadingNote(
        id: id ?? this.id,
        type: type ?? this.type,
        content: content ?? this.content,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        date: date ?? this.date,
        bookId: bookId ?? this.bookId,
        chapter: chapter ?? this.chapter,
        verseId: verseId ?? this.verseId,
        tags: tags ?? List<String>.from(this.tags),
        isPinned: isPinned ?? this.isPinned,
      );

  // ── Static key generators ──────────────────────────────────────────────────

  /// Key for looking up daily notes: "YYYY-MM-DD".
  static String generateDailyKey(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final year = normalized.year.toString();
    final month = normalized.month.toString().padLeft(2, '0');
    final day = normalized.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Key for looking up chapter notes: "bookId-chapter".
  static String generateChapterKey(int bookId, int chapter) => '$bookId-$chapter';

  /// Key for looking up verse notes (same as the verseId itself).
  static String generateVerseKey(String verseId) => verseId;

  // ── Display helpers ────────────────────────────────────────────────────────

  /// Human-readable reference string based on [type].
  String getDisplayReference() {
    switch (type) {
      case NoteType.daily:
        return date != null ? formatDate(date!) : 'Daily Note';
      case NoteType.chapter:
        if (bookId != null && chapter != null) {
          return 'Book $bookId, Chapter $chapter';
        }
        return 'Chapter Note';
      case NoteType.verse:
        if (verseId != null) {
          final parts = verseId!.split('-');
          if (parts.length >= 3) return '${parts[0]} ${parts[1]}:${parts[2]}';
          return verseId!;
        }
        return 'Verse Note';
    }
  }

  /// Format a date as "MMM d, YYYY" (e.g. "Jan 15, 2026").
  static String formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // ── Value semantics ────────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingNote &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          content == other.content &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          date == other.date &&
          bookId == other.bookId &&
          chapter == other.chapter &&
          verseId == other.verseId &&
          const ListEquality<String>().equals(tags, other.tags) &&
          isPinned == other.isPinned;

  @override
  int get hashCode => Object.hash(
        id,
        type,
        content,
        createdAt,
        updatedAt,
        date,
        bookId,
        chapter,
        verseId,
        const ListEquality<String>().hash(tags),
        isPinned,
      );

  @override
  String toString() =>
      'ReadingNote(id: $id, type: $type, content: $content, '
      'createdAt: $createdAt, updatedAt: $updatedAt, '
      'date: $date, bookId: $bookId, chapter: $chapter, verseId: $verseId, '
      'tags: $tags, isPinned: $isPinned)';
}
