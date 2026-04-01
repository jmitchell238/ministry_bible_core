import 'package:test/test.dart';
import 'package:ministry_bible_core/ministry_bible_core.dart';

void main() {
  // Build a verse directly — formatter doesn't need BibleContentService
  BibleVerse makeVerse({
    String id = 'John-3-16',
    String bookName = 'John',
    int bookId = 43,
    int chapter = 3,
    int number = 16,
    String text = 'For God so loved the world.',
  }) =>
      BibleVerse(
        id: id,
        bookId: bookId,
        chapter: chapter,
        number: number,
        text: text,
        wordCount: text.split(' ').length,
      );

  group('VerseCardFormatter.format', () {
    test('returns a VerseCard with correct reference and text', () {
      final verse = makeVerse();
      final card = VerseCardFormatter.format(
        verse: verse,
        bookName: 'John',
        translationCode: 'KJV',
      );
      expect(card.verseId, equals('John-3-16'));
      expect(card.reference, equals('John 3:16'));
      expect(card.verseText, equals('For God so loved the world.'));
      expect(card.translationCode, equals('KJV'));
    });

    test('reference format is "BookName Chapter:Verse"', () {
      final verse = makeVerse(
        id: 'Psalms-23-1',
        bookName: 'Psalms',
        bookId: 19,
        chapter: 23,
        number: 1,
        text: 'The Lord is my shepherd.',
      );
      final card = VerseCardFormatter.format(
        verse: verse,
        bookName: 'Psalms',
        translationCode: 'KJV',
      );
      expect(card.reference, equals('Psalms 23:1'));
    });

    test('sets createdAt to approximately now', () {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final card = VerseCardFormatter.format(
        verse: makeVerse(),
        bookName: 'John',
        translationCode: 'KJV',
      );
      expect(card.createdAt.isAfter(before), isTrue);
    });

    test('passes optional theme', () {
      final card = VerseCardFormatter.format(
        verse: makeVerse(),
        bookName: 'John',
        translationCode: 'KJV',
        theme: 'sunrise',
      );
      expect(card.theme, equals('sunrise'));
    });

    test('passes optional color', () {
      final card = VerseCardFormatter.format(
        verse: makeVerse(),
        bookName: 'John',
        translationCode: 'KJV',
        color: '#336699',
      );
      expect(card.color, equals('#336699'));
    });

    test('theme is null when not provided', () {
      final card = VerseCardFormatter.format(
        verse: makeVerse(),
        bookName: 'John',
        translationCode: 'KJV',
      );
      expect(card.theme, isNull);
    });

    test('shareText is properly formatted', () {
      final card = VerseCardFormatter.format(
        verse: makeVerse(),
        bookName: 'John',
        translationCode: 'KJV',
      );
      expect(
        card.shareText,
        equals('For God so loved the world.\n— John 3:16 (KJV)'),
      );
    });

    test('multi-word book name formats correctly', () {
      final verse = makeVerse(
        id: 'SongofSolomon-1-2',
        bookId: 22,
        chapter: 1,
        number: 2,
        text: 'Let him kiss me with the kisses of his mouth.',
      );
      final card = VerseCardFormatter.format(
        verse: verse,
        bookName: 'Song of Solomon',
        translationCode: 'KJV',
      );
      expect(card.reference, equals('Song of Solomon 1:2'));
    });
  });
}
