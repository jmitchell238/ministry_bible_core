import 'package:test/test.dart';
import 'package:ministry_bible_core/ministry_bible_core.dart';

void main() {
  group('ScriptureAutoDetector.detect', () {
    test('single verse — John 3:16', () {
      final results = ScriptureAutoDetector.detect('For God so loved the world — John 3:16.');
      expect(results, hasLength(1));
      expect(results[0].book, equals('John'));
      expect(results[0].chapter, equals(3));
      expect(results[0].verseStart, equals(16));
      expect(results[0].verseEnd, isNull);
    });

    test('verse range — John 3:16-18', () {
      final results = ScriptureAutoDetector.detect('See John 3:16-18 for context.');
      expect(results, hasLength(1));
      expect(results[0].book, equals('John'));
      expect(results[0].chapter, equals(3));
      expect(results[0].verseStart, equals(16));
      expect(results[0].verseEnd, equals(18));
    });

    test('abbreviated book — Gen 1:1', () {
      final results = ScriptureAutoDetector.detect('In the beginning — Gen 1:1');
      expect(results, hasLength(1));
      expect(results[0].book, equals('Genesis'));
      expect(results[0].chapter, equals(1));
      expect(results[0].verseStart, equals(1));
    });

    test('numbered book — 1 Cor 13:4', () {
      final results = ScriptureAutoDetector.detect('Love is patient — 1 Cor 13:4');
      expect(results, hasLength(1));
      expect(results[0].book, equals('1 Corinthians'));
      expect(results[0].chapter, equals(13));
      expect(results[0].verseStart, equals(4));
    });

    test('psalm abbreviation — Ps 23:1', () {
      final results = ScriptureAutoDetector.detect('The LORD is my shepherd — Ps 23:1');
      expect(results, hasLength(1));
      expect(results[0].book, equals('Psalms'));
      expect(results[0].chapter, equals(23));
      expect(results[0].verseStart, equals(1));
    });

    test('multi-word book — Song of Solomon 3:1', () {
      final results = ScriptureAutoDetector.detect('Song of Solomon 3:1 is poetic.');
      expect(results, hasLength(1));
      expect(results[0].book, equals('Song of Solomon'));
      expect(results[0].chapter, equals(3));
      expect(results[0].verseStart, equals(1));
    });

    test('no match returns empty list', () {
      final results = ScriptureAutoDetector.detect('No scripture references here.');
      expect(results, isEmpty);
    });

    test('multiple references detected in order', () {
      final results = ScriptureAutoDetector.detect(
        'Compare John 3:16 with Rom 8:28 and Ps 119:105.',
      );
      expect(results, hasLength(3));
      expect(results[0].book, equals('John'));
      expect(results[1].book, equals('Romans'));
      expect(results[2].book, equals('Psalms'));
    });

    test('rawText captures exact matched string', () {
      final results = ScriptureAutoDetector.detect('See John 3:16 today.');
      expect(results[0].rawText, equals('John 3:16'));
    });

    test('startOffset and endOffset are correct', () {
      const text = 'See John 3:16 today.';
      final results = ScriptureAutoDetector.detect(text);
      expect(results[0].startOffset, equals(4));
      expect(results[0].endOffset, equals(13));
      expect(text.substring(results[0].startOffset, results[0].endOffset), equals('John 3:16'));
    });

    test('case insensitive — john 3:16', () {
      final results = ScriptureAutoDetector.detect('john 3:16');
      expect(results, hasLength(1));
      expect(results[0].book, equals('John'));
    });

    test('numbered book 1 John 1:9', () {
      final results = ScriptureAutoDetector.detect('1 John 1:9 is key.');
      expect(results, hasLength(1));
      expect(results[0].book, equals('1 John'));
      expect(results[0].chapter, equals(1));
      expect(results[0].verseStart, equals(9));
    });

    test('2 Peter 1:3', () {
      final results = ScriptureAutoDetector.detect('2 Pet 1:3 is encouraging.');
      expect(results, hasLength(1));
      expect(results[0].book, equals('2 Peter'));
      expect(results[0].chapter, equals(1));
      expect(results[0].verseStart, equals(3));
    });
  });
}
