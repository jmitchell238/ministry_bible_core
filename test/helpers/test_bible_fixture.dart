import 'package:ministry_bible_core/ministry_bible_core.dart';

/// Minimal in-memory [BibleAssetLoader] for use in tests.
class InMemoryBibleAssetLoader implements BibleAssetLoader {
  final List<BibleBook> books;
  const InMemoryBibleAssetLoader(this.books);

  @override
  Future<List<BibleBook>> loadBooks() async => books;
}

BibleVerse makeVerse(int bookId, String bookName, int chapter, int number,
    {String? text, int wordCount = 5}) {
  return BibleVerse(
    id: '${bookName.replaceAll(' ', '')}-$chapter-$number',
    bookId: bookId,
    chapter: chapter,
    number: number,
    text: text ?? 'Verse text $number.',
    wordCount: wordCount,
  );
}

/// Two-book (Genesis OT, John NT) minimal fixture with 2 chapters each.
List<BibleBook> buildTestBible() {
  final genesis = BibleBook(
    id: 1,
    name: 'Genesis',
    testament: 'OT',
    chapters: [
      BibleChapter(bookId: 1, number: 1, verses: [
        makeVerse(1, 'Genesis', 1, 1, text: 'In the beginning God', wordCount: 4),
        makeVerse(1, 'Genesis', 1, 2, text: 'And the earth was void', wordCount: 5),
        makeVerse(1, 'Genesis', 1, 3, text: 'And God said let there be light', wordCount: 7),
      ]),
      BibleChapter(bookId: 1, number: 2, verses: [
        makeVerse(1, 'Genesis', 2, 1, text: 'The heavens and the earth were finished', wordCount: 7),
        makeVerse(1, 'Genesis', 2, 2, text: 'On the seventh day God rested', wordCount: 6),
      ]),
    ],
  );

  final john = BibleBook(
    id: 43,
    name: 'John',
    testament: 'NT',
    chapters: [
      BibleChapter(bookId: 43, number: 1, verses: [
        makeVerse(43, 'John', 1, 1, text: 'In the beginning was the Word', wordCount: 6),
        makeVerse(43, 'John', 1, 2, text: 'The same was in the beginning', wordCount: 6),
      ]),
      BibleChapter(bookId: 43, number: 3, verses: [
        makeVerse(43, 'John', 3, 16, text: 'For God so loved the world', wordCount: 6),
        makeVerse(43, 'John', 3, 17, text: 'God sent not his Son to condemn', wordCount: 7),
      ]),
    ],
  );

  return [genesis, john];
}

/// Build and pre-load a [BibleContentService] with the test fixture.
Future<BibleContentService> buildLoadedService() async {
  final service = BibleContentService(InMemoryBibleAssetLoader(buildTestBible()));
  await service.load();
  return service;
}
