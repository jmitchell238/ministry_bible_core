import '../constants/bible_books.dart';

/// Encodes and decodes the canonical verse ID format used throughout the package.
///
/// Format: `"BookName-Chapter-Verse"` where spaces are stripped from the book name.
///
/// Examples:
/// - Genesis 1:1    → `"Genesis-1-1"`
/// - Song of Solomon 3:2 → `"SongofSolomon-3-2"`
/// - 1 Corinthians 13:4 → `"1Corinthians-13-4"`
abstract final class VerseId {

  /// Encode a book name, chapter, and verse number into a verse ID string.
  static String encode(String bookName, int chapter, int verse) {
    final stripped = bookName.replaceAll(' ', '');
    return '$stripped-$chapter-$verse';
  }

  /// Encode a book name and chapter into a chapter-level ID string.
  static String chapterId(String bookName, int chapter) {
    final stripped = bookName.replaceAll(' ', '');
    return '$stripped-$chapter';
  }

  /// Decode a verse ID string back into its components.
  ///
  /// Performs a reverse lookup of the book name from [BibleBooks.all] by
  /// matching against the space-stripped form. Returns a named record
  /// `({String book, int chapter, int verse})`.
  ///
  /// Throws [ArgumentError] if the format is invalid or the book is not found.
  static ({String book, int chapter, int verse}) decode(String verseId) {
    final parts = verseId.split('-');
    if (parts.length < 3) {
      throw ArgumentError('Invalid verse ID format: "$verseId"');
    }

    // Parts: [strippedBook, chapter, verse]
    // The book part may be split by '-' if a numbered book like "1Corinthians"
    // but actually numbered books like "1 Corinthians" strip spaces → "1Corinthians"
    // so only 3 parts total for those.
    // However, a book name itself won't contain '-', so the first part is always the book.
    final strippedBook = parts[0];
    final chapter = int.tryParse(parts[1]);
    final verse = int.tryParse(parts[2]);

    if (chapter == null || verse == null) {
      throw ArgumentError('Invalid verse ID format: "$verseId"');
    }

    // Reverse-lookup canonical book name from BibleBooks.all
    final book = BibleBooks.all.where(
      (b) => b.replaceAll(' ', '') == strippedBook,
    ).firstOrNull;

    if (book == null) {
      throw ArgumentError('Unknown book in verse ID: "$verseId" (stripped: "$strippedBook")');
    }

    return (book: book, chapter: chapter, verse: verse);
  }
}
