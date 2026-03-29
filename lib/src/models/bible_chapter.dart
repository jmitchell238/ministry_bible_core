import 'package:collection/collection.dart';
import 'bible_verse.dart';

/// A chapter of the Bible containing a list of verses.
class BibleChapter {
  final int bookId;
  final int number;
  final List<BibleVerse> verses;

  const BibleChapter({
    required this.bookId,
    required this.number,
    required this.verses,
  });

  factory BibleChapter.fromJson(
    Map<String, dynamic> json, {
    required int bookId,
    required String bookName,
  }) {
    final number = json['number'] as int;
    final versesJson = json['verses'] as List<dynamic>;

    final verses = versesJson
        .map((verseJson) => BibleVerse.fromJson(
              verseJson as Map<String, dynamic>,
              bookId: bookId,
              bookName: bookName,
              chapter: number,
            ))
        .toList();

    return BibleChapter(
      bookId: bookId,
      number: number,
      verses: verses,
    );
  }

  Map<String, dynamic> toJson() => {
        'number': number,
        'verses': verses.map((v) => v.toJson()).toList(),
      };

  BibleChapter copyWith({
    int? bookId,
    int? number,
    List<BibleVerse>? verses,
  }) =>
      BibleChapter(
        bookId: bookId ?? this.bookId,
        number: number ?? this.number,
        verses: verses ?? this.verses,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BibleChapter &&
          runtimeType == other.runtimeType &&
          bookId == other.bookId &&
          number == other.number &&
          const ListEquality<BibleVerse>().equals(verses, other.verses);

  @override
  int get hashCode =>
      Object.hash(bookId, number, const ListEquality<BibleVerse>().hash(verses));

  @override
  String toString() =>
      'BibleChapter(bookId: $bookId, number: $number, verses: ${verses.length})';
}
