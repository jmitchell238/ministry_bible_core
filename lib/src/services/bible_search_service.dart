import '../models/bible_book.dart';
import '../models/bible_verse.dart';
import '../models/search_result.dart';
import 'bible_content_service.dart';

/// Full-text Bible search and reference lookup.
///
/// Search history is NOT managed here — that is an app-level concern.
/// This service operates on the already-loaded [BibleContentService].
class BibleSearchService {
  final BibleContentService _content;

  BibleSearchService(this._content);

  /// Search verse text for [query] (case- and punctuation-insensitive).
  ///
  /// Returns an empty list if [query] is blank or no matches are found.
  List<SearchResult> searchVerses(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final normalizedQuery = _normalizeText(trimmed);
    final results = <SearchResult>[];

    for (final book in _content.getAllBooks()) {
      for (final chapter in book.chapters) {
        for (final verse in chapter.verses) {
          final normalizedText = _normalizeText(verse.text);
          if (normalizedText.contains(normalizedQuery)) {
            final matchIndex = normalizedText.indexOf(normalizedQuery);
            results.add(SearchResult(
              verse: verse,
              highlightedText: _createHighlightedText(verse.text, matchIndex, trimmed.length),
              matchPosition: matchIndex,
            ));
          }
        }
      }
    }

    return results;
  }

  /// Search book names for [query] (case-insensitive partial match).
  List<BibleBook> searchBooks(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];
    final lower = trimmed.toLowerCase();
    return _content.getAllBooks()
        .where((b) => b.name.toLowerCase().contains(lower))
        .toList();
  }

  /// Look up a verse by reference string, e.g. "John 3:16" or "1 Cor 13:4".
  ///
  /// Matches the full book name case-insensitively.
  /// Returns null if the reference cannot be parsed or the verse is not found.
  BibleVerse? searchByReference(String reference) {
    final trimmed = reference.trim();
    if (trimmed.isEmpty) return null;

    final regex = RegExp(
      r'^(\d?\s?[A-Za-z]+(?:\s[A-Za-z]+)*)\s+(\d+):(\d+)$',
      caseSensitive: false,
    );

    final match = regex.firstMatch(trimmed);
    if (match == null) return null;

    final bookName = match.group(1)?.trim();
    final chapterNum = int.tryParse(match.group(2) ?? '');
    final verseNum = int.tryParse(match.group(3) ?? '');

    if (bookName == null || chapterNum == null || verseNum == null) return null;

    final book = _content.getBookByName(bookName);
    if (book == null) return null;

    try {
      final chapter = book.chapters.firstWhere((c) => c.number == chapterNum);
      return chapter.verses.firstWhere((v) => v.number == verseNum);
    } catch (_) {
      return null;
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  String _normalizeText(String text) =>
      text
          .toLowerCase()
          .replaceAll(RegExp(r'''[,;:.!?\-—'"()\[\]{}]'''), '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

  String _createHighlightedText(String text, int matchPosition, int matchLength) =>
      text; // UI layer handles actual highlighting
}
