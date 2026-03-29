import 'package:test/test.dart';
import 'package:ministry_bible_core/ministry_bible_core.dart';

// ── In-memory test double ────────────────────────────────────────────────────

class InMemoryBibleAssetLoader implements BibleAssetLoader {
  final List<BibleBook> books;
  const InMemoryBibleAssetLoader(this.books);

  @override
  Future<List<BibleBook>> loadBooks() async => books;
}

// ── Minimal test fixture ─────────────────────────────────────────────────────

// Genesis ch1: 3 verses, ch2: 2 verses
// John ch1: 2 verses, ch2: 2 verses

BibleVerse _v(int bookId, String bookName, int chapter, int number, String text, int wc) =>
    BibleVerse(
      id: '${bookName.replaceAll(' ', '')}-$chapter-$number',
      bookId: bookId,
      chapter: chapter,
      number: number,
      text: text,
      wordCount: wc,
    );

List<BibleBook> buildFixture() {
  final genesis = BibleBook(
    id: 1,
    name: 'Genesis',
    testament: 'OT',
    chapters: [
      BibleChapter(bookId: 1, number: 1, verses: [
        _v(1, 'Genesis', 1, 1, 'In the beginning', 4),
        _v(1, 'Genesis', 1, 2, 'And the earth was without form', 6),
        _v(1, 'Genesis', 1, 3, 'And God said let there be light', 7),
      ]),
      BibleChapter(bookId: 1, number: 2, verses: [
        _v(1, 'Genesis', 2, 1, 'Thus the heavens and the earth were finished', 8),
        _v(1, 'Genesis', 2, 2, 'And on the seventh day God ended his work', 9),
      ]),
    ],
  );

  final john = BibleBook(
    id: 43,
    name: 'John',
    testament: 'NT',
    chapters: [
      BibleChapter(bookId: 43, number: 1, verses: [
        _v(43, 'John', 1, 1, 'In the beginning was the Word', 6),
        _v(43, 'John', 1, 2, 'The same was in the beginning with God', 7),
      ]),
      BibleChapter(bookId: 43, number: 3, verses: [
        _v(43, 'John', 3, 16, 'For God so loved the world', 7),
        _v(43, 'John', 3, 17, 'For God sent not his Son', 6),
      ]),
    ],
  );

  return [genesis, john];
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  late BibleContentService service;

  setUp(() {
    service = BibleContentService(InMemoryBibleAssetLoader(buildFixture()));
  });

  group('Before load()', () {
    test('isLoaded is false', () {
      expect(service.isLoaded, isFalse);
    });

    test('getAllBooks throws before loading', () {
      expect(() => service.getAllBooks(), throwsStateError);
    });

    test('getBook throws before loading', () {
      expect(() => service.getBook(1), throwsStateError);
    });

    test('getTotalVerseCount throws before loading', () {
      expect(() => service.getTotalVerseCount(), throwsStateError);
    });
  });

  group('After load()', () {
    setUp(() async => await service.load());

    test('isLoaded is true', () {
      expect(service.isLoaded, isTrue);
    });

    test('calling load() twice is a no-op', () async {
      await service.load(); // second call
      expect(service.isLoaded, isTrue);
      expect(service.getAllBooks(), hasLength(2));
    });

    test('getAllBooks returns all books', () {
      expect(service.getAllBooks(), hasLength(2));
    });

    test('getAllBooks is unmodifiable', () {
      final books = service.getAllBooks();
      final fakeBook = BibleBook(id: 99, name: 'Fake', testament: 'OT', chapters: []);
      expect(() => books.add(fakeBook), throwsUnsupportedError);
    });

    test('getBook by id — Genesis (1)', () {
      final book = service.getBook(1);
      expect(book.name, equals('Genesis'));
    });

    test('getBook by id — John (43)', () {
      final book = service.getBook(43);
      expect(book.name, equals('John'));
    });

    test('getBook throws for unknown id', () {
      expect(() => service.getBook(99), throwsException);
    });

    test('getBookByName — exact match', () {
      final book = service.getBookByName('Genesis');
      expect(book, isNotNull);
      expect(book!.id, equals(1));
    });

    test('getBookByName — case-insensitive', () {
      final book = service.getBookByName('genesis');
      expect(book, isNotNull);
    });

    test('getBookByName — unknown returns null', () {
      expect(service.getBookByName('Hezekiah'), isNull);
    });

    test('getChapter returns correct chapter', () {
      final ch = service.getChapter(1, 1);
      expect(ch.number, equals(1));
      expect(ch.verses, hasLength(3));
    });

    test('getChapter throws for unknown chapter', () {
      expect(() => service.getChapter(1, 99), throwsException);
    });

    test('getVerses returns verses for a chapter', () {
      final verses = service.getVerses(1, 1);
      expect(verses, hasLength(3));
      expect(verses[0].text, equals('In the beginning'));
    });

    test('getTotalVerseCount sums all verses', () {
      // Genesis: 3+2=5, John: 2+2=4 → total 9
      expect(service.getTotalVerseCount(), equals(9));
    });

    test('getTotalWordCount sums all word counts', () {
      // Gen ch1: 4+6+7=17, ch2: 8+9=17 → 34
      // John ch1: 6+7=13, ch3: 7+6=13 → 26
      // Total: 60
      expect(service.getTotalWordCount(), equals(60));
    });

    test('verseText returns correct text', () {
      expect(service.verseText('Genesis', 1, 1), equals('In the beginning'));
      expect(service.verseText('John', 3, 16), equals('For God so loved the world'));
    });

    test('verseText returns null for unknown book', () {
      expect(service.verseText('Hezekiah', 1, 1), isNull);
    });

    test('verseText returns null for unknown verse', () {
      expect(service.verseText('Genesis', 1, 99), isNull);
    });

    test('versesInChapter returns verse numbers', () {
      expect(service.versesInChapter('Genesis', 1), equals([1, 2, 3]));
      expect(service.versesInChapter('John', 3), equals([16, 17]));
    });

    test('versesInChapter returns empty list for unknown book', () {
      expect(service.versesInChapter('Hezekiah', 1), isEmpty);
    });

    test('versesInChapter returns empty list for unknown chapter', () {
      expect(service.versesInChapter('Genesis', 99), isEmpty);
    });
  });
}
