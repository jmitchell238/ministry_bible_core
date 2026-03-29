import 'package:test/test.dart';
import 'package:ministry_bible_core/ministry_bible_core.dart';

void main() {
  group('VerseId.encode', () {
    test('single-word book', () {
      expect(VerseId.encode('Genesis', 1, 1), equals('Genesis-1-1'));
    });

    test('multi-word book strips spaces', () {
      expect(VerseId.encode('Song of Solomon', 3, 2), equals('SongofSolomon-3-2'));
    });

    test('numbered book strips space', () {
      expect(VerseId.encode('1 Corinthians', 13, 4), equals('1Corinthians-13-4'));
    });

    test('large chapter and verse numbers', () {
      expect(VerseId.encode('Psalms', 119, 176), equals('Psalms-119-176'));
    });
  });

  group('VerseId.chapterId', () {
    test('single-word book', () {
      expect(VerseId.chapterId('Genesis', 1), equals('Genesis-1'));
    });

    test('multi-word book strips spaces', () {
      expect(VerseId.chapterId('Song of Solomon', 3), equals('SongofSolomon-3'));
    });

    test('numbered book', () {
      expect(VerseId.chapterId('1 Kings', 22), equals('1Kings-22'));
    });
  });

  group('VerseId.decode', () {
    test('round-trip single-word book', () {
      final id = VerseId.encode('Genesis', 1, 1);
      final result = VerseId.decode(id);
      expect(result.book, equals('Genesis'));
      expect(result.chapter, equals(1));
      expect(result.verse, equals(1));
    });

    test('round-trip multi-word book', () {
      final id = VerseId.encode('Song of Solomon', 3, 2);
      final result = VerseId.decode(id);
      expect(result.book, equals('Song of Solomon'));
      expect(result.chapter, equals(3));
      expect(result.verse, equals(2));
    });

    test('round-trip numbered book', () {
      final id = VerseId.encode('1 Corinthians', 13, 4);
      final result = VerseId.decode(id);
      expect(result.book, equals('1 Corinthians'));
      expect(result.chapter, equals(13));
      expect(result.verse, equals(4));
    });

    test('round-trip 2 Chronicles', () {
      final id = VerseId.encode('2 Chronicles', 7, 14);
      final result = VerseId.decode(id);
      expect(result.book, equals('2 Chronicles'));
      expect(result.chapter, equals(7));
      expect(result.verse, equals(14));
    });

    test('round-trip 3 John', () {
      final id = VerseId.encode('3 John', 1, 4);
      final result = VerseId.decode(id);
      expect(result.book, equals('3 John'));
      expect(result.chapter, equals(1));
      expect(result.verse, equals(4));
    });

    test('throws on invalid format (too few parts)', () {
      expect(() => VerseId.decode('Genesis-1'), throwsArgumentError);
    });

    test('throws on unknown book', () {
      expect(() => VerseId.decode('FakeBook-1-1'), throwsArgumentError);
    });

    test('throws on non-numeric chapter', () {
      expect(() => VerseId.decode('Genesis-abc-1'), throwsArgumentError);
    });
  });
}
