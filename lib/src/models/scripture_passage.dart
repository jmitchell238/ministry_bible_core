import 'package:collection/collection.dart';

/// The result of a scripture lookup — a consecutive range of verses.
///
/// Uses [translationCode] (e.g. "KJV") instead of an app-specific enum,
/// keeping this model decoupled from any app's translation enum.
class ScripturePassage {
  final String book;
  final int chapter;
  final int verseStart;
  final int verseEnd;

  /// Translation identifier, e.g. "KJV", "ASV", "AKJV".
  final String translationCode;

  /// Actual verse texts in order from [verseStart] to [verseEnd].
  final List<String> verses;

  const ScripturePassage({
    required this.book,
    required this.chapter,
    required this.verseStart,
    required this.verseEnd,
    required this.translationCode,
    required this.verses,
  });

  /// Human-readable reference, e.g. "John 3:16 (KJV)" or "John 3:16-18 (KJV)".
  String get reference {
    final ref = verseStart == verseEnd
        ? '$book $chapter:$verseStart'
        : '$book $chapter:$verseStart-$verseEnd';
    return '$ref ($translationCode)';
  }

  /// All verses joined into a single string, separated by spaces.
  String get fullText => verses.join(' ');

  factory ScripturePassage.fromJson(Map<String, dynamic> json) => ScripturePassage(
        book: json['book'] as String,
        chapter: json['chapter'] as int,
        verseStart: json['verseStart'] as int,
        verseEnd: json['verseEnd'] as int,
        translationCode: json['translationCode'] as String,
        verses: (json['verses'] as List<dynamic>).cast<String>(),
      );

  Map<String, dynamic> toJson() => {
        'book': book,
        'chapter': chapter,
        'verseStart': verseStart,
        'verseEnd': verseEnd,
        'translationCode': translationCode,
        'verses': verses,
      };

  ScripturePassage copyWith({
    String? book,
    int? chapter,
    int? verseStart,
    int? verseEnd,
    String? translationCode,
    List<String>? verses,
  }) =>
      ScripturePassage(
        book: book ?? this.book,
        chapter: chapter ?? this.chapter,
        verseStart: verseStart ?? this.verseStart,
        verseEnd: verseEnd ?? this.verseEnd,
        translationCode: translationCode ?? this.translationCode,
        verses: verses ?? this.verses,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScripturePassage &&
          runtimeType == other.runtimeType &&
          book == other.book &&
          chapter == other.chapter &&
          verseStart == other.verseStart &&
          verseEnd == other.verseEnd &&
          translationCode == other.translationCode &&
          const ListEquality<String>().equals(verses, other.verses);

  @override
  int get hashCode => Object.hash(
        book,
        chapter,
        verseStart,
        verseEnd,
        translationCode,
        const ListEquality<String>().hash(verses),
      );

  @override
  String toString() =>
      'ScripturePassage(reference: $reference, verses: ${verses.length})';
}
