import 'package:test/test.dart';
import 'package:ministry_bible_core/ministry_bible_core.dart';
import '../helpers/test_bible_fixture.dart';

void main() {
  // Build a second translation loader with identical structure but different verse text
  InMemoryBibleAssetLoader buildAltLoader() {
    final books = [
      BibleBook(
        id: 1,
        name: 'Genesis',
        testament: 'OT',
        chapters: [
          BibleChapter(bookId: 1, number: 1, verses: [
            BibleVerse(
              id: 'Genesis-1-1',
              bookId: 1,
              chapter: 1,
              number: 1,
              text: 'In the beginning God created (ALT)',
              wordCount: 7,
            ),
          ]),
        ],
      ),
    ];
    return InMemoryBibleAssetLoader(books);
  }

  group('BibleContentService multi-translation', () {
    late BibleContentService service;

    setUp(() async {
      service = await buildLoadedService();
    });

    test('loadedTranslationCodes is empty before any extra translations loaded', () {
      expect(service.loadedTranslationCodes, isEmpty);
    });

    test('loadTranslation adds the translation code', () async {
      await service.loadTranslation('ALT', buildAltLoader());
      expect(service.loadedTranslationCodes, contains('ALT'));
    });

    test('loadTranslation with multiple codes', () async {
      await service.loadTranslation('ALT', buildAltLoader());
      await service.loadTranslation('ALT2', buildAltLoader());
      expect(service.loadedTranslationCodes, containsAll(['ALT', 'ALT2']));
      expect(service.loadedTranslationCodes, hasLength(2));
    });

    test('getVerseInTranslation returns verse from loaded translation', () async {
      await service.loadTranslation('ALT', buildAltLoader());
      final verse = service.getVerseInTranslation('Genesis-1-1', 'ALT');
      expect(verse, isNotNull);
      expect(verse!.text, contains('ALT'));
    });

    test('getVerseInTranslation returns null for unknown verse id', () async {
      await service.loadTranslation('ALT', buildAltLoader());
      expect(service.getVerseInTranslation('Revelation-22-21', 'ALT'), isNull);
    });

    test('getVerseInTranslation returns null for unloaded translation', () {
      expect(service.getVerseInTranslation('Genesis-1-1', 'UNKNOWN'), isNull);
    });

    test('loading a translation again is a no-op (first load wins)', () async {
      await service.loadTranslation('ALT', buildAltLoader());
      // Load again with different books — should still have original ALT data
      final emptyLoader = InMemoryBibleAssetLoader([]);
      await service.loadTranslation('ALT', emptyLoader);
      final verse = service.getVerseInTranslation('Genesis-1-1', 'ALT');
      expect(verse, isNotNull);
    });

    test('primary service still works after extra translations loaded', () async {
      await service.loadTranslation('ALT', buildAltLoader());
      final books = service.getAllBooks();
      expect(books, hasLength(2));
    });
  });
}
