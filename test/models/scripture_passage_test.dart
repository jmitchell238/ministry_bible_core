import 'package:test/test.dart';
import 'package:ministry_bible_core/ministry_bible_core.dart';

ScripturePassage makePassage({
  String book = 'John',
  int chapter = 3,
  int verseStart = 16,
  int verseEnd = 16,
  String translationCode = 'KJV',
  List<String>? verses,
}) =>
    ScripturePassage(
      book: book,
      chapter: chapter,
      verseStart: verseStart,
      verseEnd: verseEnd,
      translationCode: translationCode,
      verses: verses ?? ['For God so loved the world'],
    );

void main() {
  group('ScripturePassage', () {
    test('reference — single verse', () {
      final p = makePassage();
      expect(p.reference, equals('John 3:16 (KJV)'));
    });

    test('reference — verse range', () {
      final p = makePassage(verseStart: 16, verseEnd: 18, verses: ['v16', 'v17', 'v18']);
      expect(p.reference, equals('John 3:16-18 (KJV)'));
    });

    test('fullText joins verses with spaces', () {
      final p = makePassage(verses: ['Hello', 'world', 'today']);
      expect(p.fullText, equals('Hello world today'));
    });

    test('fromJson/toJson round-trip', () {
      final p = makePassage(verses: ['In the beginning']);
      final json = p.toJson();
      final restored = ScripturePassage.fromJson(json);
      expect(restored, equals(p));
    });

    test('copyWith changes only specified fields', () {
      final p = makePassage();
      final copy = p.copyWith(translationCode: 'ASV');
      expect(copy.translationCode, equals('ASV'));
      expect(copy.book, equals(p.book));
      expect(copy.chapter, equals(p.chapter));
    });

    test('equality — same values equal', () {
      final p1 = makePassage();
      final p2 = makePassage();
      expect(p1, equals(p2));
      expect(p1.hashCode, equals(p2.hashCode));
    });

    test('equality — different translation code is not equal', () {
      final p1 = makePassage(translationCode: 'KJV');
      final p2 = makePassage(translationCode: 'ASV');
      expect(p1, isNot(equals(p2)));
    });

    test('equality — different verses list is not equal', () {
      final p1 = makePassage(verses: ['text one']);
      final p2 = makePassage(verses: ['text two']);
      expect(p1, isNot(equals(p2)));
    });

    test('toString contains reference', () {
      final p = makePassage();
      expect(p.toString(), contains('John 3:16'));
    });
  });

  group('SearchResult', () {
    late BibleVerse verse;

    setUp(() {
      verse = BibleVerse.fromJson(
        {'number': 16, 'text': 'For God so loved the world', 'wordCount': 7},
        bookId: 43,
        bookName: 'John',
        chapter: 3,
      );
    });

    test('fromJson/toJson round-trip', () {
      final result = SearchResult(
        verse: verse,
        highlightedText: 'For **God** so loved',
        matchPosition: 4,
      );
      final json = result.toJson();
      // We can't fully round-trip fromJson without bookId/bookName/chapter context
      // so just verify toJson has the right keys
      expect(json['highlightedText'], equals('For **God** so loved'));
      expect(json['matchPosition'], equals(4));
      expect(json['verse'], isA<Map>());
    });

    test('copyWith', () {
      final result = SearchResult(
        verse: verse,
        highlightedText: 'original',
        matchPosition: 0,
      );
      final copy = result.copyWith(highlightedText: 'updated', matchPosition: 5);
      expect(copy.highlightedText, equals('updated'));
      expect(copy.matchPosition, equals(5));
      expect(copy.verse.id, equals(verse.id));
    });

    test('equality', () {
      final r1 = SearchResult(verse: verse, highlightedText: 'text', matchPosition: 1);
      final r2 = SearchResult(verse: verse, highlightedText: 'text', matchPosition: 1);
      expect(r1, equals(r2));
    });

    test('equality — different matchPosition is not equal', () {
      final r1 = SearchResult(verse: verse, highlightedText: 'text', matchPosition: 1);
      final r2 = SearchResult(verse: verse, highlightedText: 'text', matchPosition: 2);
      expect(r1, isNot(equals(r2)));
    });

    test('toString contains verse id and match info', () {
      final result = SearchResult(verse: verse, highlightedText: 'x', matchPosition: 3);
      expect(result.toString(), contains('John-3-16'));
      expect(result.toString(), contains('matchPosition: 3'));
    });

    test('fromJson full round-trip', () {
      final original = SearchResult(
        verse: verse,
        highlightedText: 'For God so loved',
        matchPosition: 4,
      );
      final json = original.toJson();
      final restored = SearchResult.fromJson(
        json,
        bookId: 43,
        bookName: 'John',
        chapter: 3,
      );
      expect(restored.highlightedText, equals(original.highlightedText));
      expect(restored.matchPosition, equals(original.matchPosition));
      expect(restored.verse.id, equals(original.verse.id));
    });

    test('copyWith with no args returns equal copy', () {
      final result = SearchResult(
        verse: verse,
        highlightedText: 'text',
        matchPosition: 2,
      );
      final copy = result.copyWith();
      expect(copy.verse.id, equals(result.verse.id));
      expect(copy.highlightedText, equals(result.highlightedText));
      expect(copy.matchPosition, equals(result.matchPosition));
    });

    test('hashCode is consistent', () {
      final r1 = SearchResult(verse: verse, highlightedText: 'text', matchPosition: 1);
      final r2 = SearchResult(verse: verse, highlightedText: 'text', matchPosition: 1);
      expect(r1.hashCode, equals(r2.hashCode));
    });
  });

  group('ScripturePassage copyWith defaults', () {
    test('copyWith with no args returns equal copy', () {
      final p = makePassage();
      final copy = p.copyWith();
      expect(copy, equals(p));
      expect(copy.book, equals(p.book));
      expect(copy.translationCode, equals(p.translationCode));
    });
  });
}
