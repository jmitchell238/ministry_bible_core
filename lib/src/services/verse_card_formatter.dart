import '../models/bible_verse.dart';
import '../models/verse_card.dart';

/// Produces a [VerseCard] from a [BibleVerse] and display options.
abstract final class VerseCardFormatter {
  /// Format [verse] into a shareable [VerseCard].
  ///
  /// [bookName] is the canonical book name (e.g. "Song of Solomon") used to
  /// build the human-readable [VerseCard.reference].
  static VerseCard format({
    required BibleVerse verse,
    required String bookName,
    required String translationCode,
    String? theme,
    String? color,
  }) {
    final reference = '$bookName ${verse.chapter}:${verse.number}';
    return VerseCard(
      verseId: verse.id,
      reference: reference,
      verseText: verse.text,
      translationCode: translationCode,
      theme: theme,
      color: color,
      createdAt: DateTime.now(),
    );
  }
}
