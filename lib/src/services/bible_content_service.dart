import '../interfaces/bible_asset_loader.dart';
import '../models/bible_book.dart';
import '../models/bible_chapter.dart';
import '../models/bible_verse.dart';

/// Provides access to Bible content using an injected [BibleAssetLoader].
///
/// Call [load] once before accessing any other methods. This decouples
/// the service from any platform-specific asset system (Flutter rootBundle,
/// filesystem, HTTP, or in-memory test doubles).
class BibleContentService {
  final BibleAssetLoader _loader;

  List<BibleBook>? _books;
  bool _isLoaded = false;

  final Map<String, List<BibleBook>> _translations = {};

  BibleContentService(this._loader);

  /// Whether [load] has been called successfully.
  bool get isLoaded => _isLoaded;

  /// Load Bible data from the injected [BibleAssetLoader].
  ///
  /// Subsequent calls are no-ops.
  Future<void> load() async {
    if (_isLoaded) return;
    _books = await _loader.loadBooks();
    _isLoaded = true;
  }

  /// All books in canonical order (unmodifiable).
  List<BibleBook> getAllBooks() {
    _ensureLoaded();
    return List.unmodifiable(_books!);
  }

  /// Find a book by its numeric ID.
  ///
  /// Throws if not found.
  BibleBook getBook(int id) {
    _ensureLoaded();
    try {
      return _books!.firstWhere((b) => b.id == id);
    } catch (_) {
      throw Exception('Book with ID $id not found');
    }
  }

  /// Find a book by name (case-insensitive).
  ///
  /// Returns null if not found.
  BibleBook? getBookByName(String name) {
    _ensureLoaded();
    final lower = name.toLowerCase();
    for (final book in _books!) {
      if (book.name.toLowerCase() == lower) return book;
    }
    return null;
  }

  /// Retrieve a specific chapter from a book.
  ///
  /// Throws if the book ID or chapter number is not found.
  BibleChapter getChapter(int bookId, int chapterNum) {
    final book = getBook(bookId);
    try {
      return book.chapters.firstWhere((c) => c.number == chapterNum);
    } catch (_) {
      throw Exception('Chapter $chapterNum not found in book ID $bookId');
    }
  }

  /// All verses in a specific chapter.
  List<BibleVerse> getVerses(int bookId, int chapterNum) =>
      getChapter(bookId, chapterNum).verses;

  /// Total number of verses across all loaded books.
  int getTotalVerseCount() {
    _ensureLoaded();
    var count = 0;
    for (final book in _books!) {
      for (final chapter in book.chapters) {
        count += chapter.verses.length;
      }
    }
    return count;
  }

  /// Total word count across all loaded books.
  int getTotalWordCount() {
    _ensureLoaded();
    var count = 0;
    for (final book in _books!) {
      for (final chapter in book.chapters) {
        for (final verse in chapter.verses) {
          count += verse.wordCount;
        }
      }
    }
    return count;
  }

  // ── Name-based lookup helpers (used by MinistryBase-style callers) ──────────

  /// Text of a specific verse identified by book name, chapter, and verse number.
  ///
  /// Returns null if the book, chapter, or verse cannot be found.
  String? verseText(String bookName, int chapter, int verseNumber) {
    final book = getBookByName(bookName);
    if (book == null) return null;
    try {
      final ch = book.chapters.firstWhere((c) => c.number == chapter);
      return ch.verses.firstWhere((v) => v.number == verseNumber).text;
    } catch (_) {
      return null;
    }
  }

  /// Verse numbers available in a specific chapter.
  ///
  /// Returns an empty list if the book or chapter is not found.
  List<int> versesInChapter(String bookName, int chapter) {
    final book = getBookByName(bookName);
    if (book == null) return [];
    try {
      final ch = book.chapters.firstWhere((c) => c.number == chapter);
      return ch.verses.map((v) => v.number).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Multi-translation ──────────────────────────────────────────────────────

  /// Translation codes that have been loaded via [loadTranslation].
  List<String> get loadedTranslationCodes => List.unmodifiable(_translations.keys);

  /// Load an additional translation by [code] using the provided [loader].
  ///
  /// If [code] is already loaded, the call is a no-op (first load wins).
  Future<void> loadTranslation(String code, BibleAssetLoader loader) async {
    if (_translations.containsKey(code)) return;
    _translations[code] = await loader.loadBooks();
  }

  /// Find a verse by its [verseId] in the specified [translationCode].
  ///
  /// Returns null if the translation is not loaded or the verse is not found.
  BibleVerse? getVerseInTranslation(String verseId, String translationCode) {
    final books = _translations[translationCode];
    if (books == null) return null;
    for (final book in books) {
      for (final chapter in book.chapters) {
        for (final verse in chapter.verses) {
          if (verse.id == verseId) return verse;
        }
      }
    }
    return null;
  }

  // ── Private ────────────────────────────────────────────────────────────────

  void _ensureLoaded() {
    if (!_isLoaded || _books == null) {
      throw StateError('Bible data not loaded. Call load() first.');
    }
  }
}
