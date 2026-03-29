/// A single Bible verse with its text and metadata.
class BibleVerse {
  final String id;
  final int bookId;
  final int chapter;
  final int number;
  final String text;
  final int wordCount;

  const BibleVerse({
    required this.id,
    required this.bookId,
    required this.chapter,
    required this.number,
    required this.text,
    required this.wordCount,
  });

  factory BibleVerse.fromJson(
    Map<String, dynamic> json, {
    required int bookId,
    required String bookName,
    required int chapter,
  }) {
    final number = json['number'] as int;
    final text = json['text'] as String;
    final wordCount = json['wordCount'] as int;

    final cleanBookName = bookName.replaceAll(' ', '');
    final id = '$cleanBookName-$chapter-$number';

    return BibleVerse(
      id: id,
      bookId: bookId,
      chapter: chapter,
      number: number,
      text: text,
      wordCount: wordCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'number': number,
        'text': text,
        'wordCount': wordCount,
      };

  BibleVerse copyWith({
    String? id,
    int? bookId,
    int? chapter,
    int? number,
    String? text,
    int? wordCount,
  }) =>
      BibleVerse(
        id: id ?? this.id,
        bookId: bookId ?? this.bookId,
        chapter: chapter ?? this.chapter,
        number: number ?? this.number,
        text: text ?? this.text,
        wordCount: wordCount ?? this.wordCount,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BibleVerse &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          bookId == other.bookId &&
          chapter == other.chapter &&
          number == other.number &&
          text == other.text &&
          wordCount == other.wordCount;

  @override
  int get hashCode => Object.hash(id, bookId, chapter, number, text, wordCount);

  @override
  String toString() =>
      'BibleVerse(id: $id, bookId: $bookId, chapter: $chapter, number: $number, '
      'text: ${text.length > 30 ? "${text.substring(0, 30)}…" : text}, wordCount: $wordCount)';
}
