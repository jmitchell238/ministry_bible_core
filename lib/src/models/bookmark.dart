import 'package:uuid/uuid.dart';

/// A bookmarked Bible verse, optionally linked to a [BookmarkCollection].
class Bookmark {
  final String id;

  /// Canonical verse ID, e.g. "Genesis-1-1".
  final String verseId;

  final int bookId;
  final int chapter;
  final int verseNumber;

  /// User note; empty string if no note was provided.
  final String note;

  /// Collection ID, or null for the default (uncategorized) collection.
  final String? collectionId;

  final DateTime createdAt;

  /// Optional color tag as an ARGB integer.
  final int? color;

  const Bookmark({
    required this.id,
    required this.verseId,
    required this.bookId,
    required this.chapter,
    required this.verseNumber,
    required this.note,
    this.collectionId,
    required this.createdAt,
    this.color,
  });

  /// Creates a new [Bookmark] with a generated UUID and current timestamp.
  factory Bookmark.create({
    required String verseId,
    required int bookId,
    required int chapter,
    required int verseNumber,
    String note = '',
    String? collectionId,
    int? color,
  }) =>
      Bookmark(
        id: const Uuid().v4(),
        verseId: verseId,
        bookId: bookId,
        chapter: chapter,
        verseNumber: verseNumber,
        note: note,
        collectionId: collectionId,
        createdAt: DateTime.now(),
        color: color,
      );

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
        id: json['id'] as String,
        verseId: json['verseId'] as String,
        bookId: json['bookId'] as int,
        chapter: json['chapter'] as int,
        verseNumber: json['verseNumber'] as int,
        note: json['note'] as String? ?? '',
        collectionId: json['collectionId'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        color: json['color'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'verseId': verseId,
        'bookId': bookId,
        'chapter': chapter,
        'verseNumber': verseNumber,
        'note': note,
        'collectionId': collectionId,
        'createdAt': createdAt.toIso8601String(),
        'color': color,
      };

  Bookmark copyWith({
    String? id,
    String? verseId,
    int? bookId,
    int? chapter,
    int? verseNumber,
    String? note,
    String? collectionId,
    DateTime? createdAt,
    int? color,
    bool clearCollectionId = false,
    bool clearColor = false,
  }) =>
      Bookmark(
        id: id ?? this.id,
        verseId: verseId ?? this.verseId,
        bookId: bookId ?? this.bookId,
        chapter: chapter ?? this.chapter,
        verseNumber: verseNumber ?? this.verseNumber,
        note: note ?? this.note,
        collectionId: clearCollectionId ? null : (collectionId ?? this.collectionId),
        createdAt: createdAt ?? this.createdAt,
        color: clearColor ? null : (color ?? this.color),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bookmark &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          verseId == other.verseId &&
          bookId == other.bookId &&
          chapter == other.chapter &&
          verseNumber == other.verseNumber &&
          note == other.note &&
          collectionId == other.collectionId &&
          createdAt == other.createdAt &&
          color == other.color;

  @override
  int get hashCode => Object.hash(
        id, verseId, bookId, chapter, verseNumber, note, collectionId, createdAt, color,
      );

  @override
  String toString() =>
      'Bookmark(id: $id, verseId: $verseId, bookId: $bookId, '
      'chapter: $chapter, verseNumber: $verseNumber, note: $note, '
      'collectionId: $collectionId, createdAt: $createdAt, color: $color)';
}
