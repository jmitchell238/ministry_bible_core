import 'package:test/test.dart';
import 'package:ministry_bible_core/ministry_bible_core.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

BibleVerse makeVerse({int number = 1, String text = 'In the beginning', int wordCount = 4}) =>
    BibleVerse(
      id: 'Genesis-1-$number',
      bookId: 1,
      chapter: 1,
      number: number,
      text: text,
      wordCount: wordCount,
    );

BibleChapter makeChapter({int number = 1, List<BibleVerse>? verses}) => BibleChapter(
      bookId: 1,
      number: number,
      verses: verses ?? [makeVerse()],
    );

BibleBook makeBook({int id = 1, String name = 'Genesis', String testament = 'OT'}) => BibleBook(
      id: id,
      name: name,
      testament: testament,
      chapters: [makeChapter()],
    );

// ── BibleVerse ────────────────────────────────────────────────────────────────

void main() {
  group('BibleVerse', () {
    test('fromJson generates id from bookName + chapter + number', () {
      final verse = BibleVerse.fromJson(
        {'number': 1, 'text': 'In the beginning', 'wordCount': 4},
        bookId: 1,
        bookName: 'Genesis',
        chapter: 1,
      );
      expect(verse.id, equals('Genesis-1-1'));
      expect(verse.bookId, equals(1));
      expect(verse.chapter, equals(1));
      expect(verse.number, equals(1));
      expect(verse.text, equals('In the beginning'));
      expect(verse.wordCount, equals(4));
    });

    test('fromJson strips spaces from multi-word book name in id', () {
      final verse = BibleVerse.fromJson(
        {'number': 1, 'text': 'text', 'wordCount': 1},
        bookId: 22,
        bookName: 'Song of Solomon',
        chapter: 3,
      );
      expect(verse.id, equals('SongofSolomon-3-1'));
    });

    test('toJson omits id (only number/text/wordCount)', () {
      final verse = makeVerse();
      final json = verse.toJson();
      expect(json, containsPair('number', 1));
      expect(json, containsPair('text', 'In the beginning'));
      expect(json, containsPair('wordCount', 4));
      expect(json.containsKey('id'), isFalse);
    });

    test('fromJson/toJson round-trip', () {
      final verse = makeVerse(number: 5, text: 'test text', wordCount: 2);
      final json = verse.toJson();
      final restored = BibleVerse.fromJson(
        json,
        bookId: verse.bookId,
        bookName: 'Genesis',
        chapter: verse.chapter,
      );
      expect(restored.text, equals(verse.text));
      expect(restored.wordCount, equals(verse.wordCount));
      expect(restored.number, equals(verse.number));
    });

    test('copyWith changes only specified fields', () {
      final verse = makeVerse();
      final copy = verse.copyWith(text: 'new text', wordCount: 2);
      expect(copy.text, equals('new text'));
      expect(copy.wordCount, equals(2));
      expect(copy.id, equals(verse.id));
      expect(copy.number, equals(verse.number));
    });

    test('equality — same values are equal', () {
      final v1 = makeVerse();
      final v2 = makeVerse();
      expect(v1, equals(v2));
      expect(v1.hashCode, equals(v2.hashCode));
    });

    test('equality — different text is not equal', () {
      final v1 = makeVerse(text: 'abc');
      final v2 = makeVerse(text: 'xyz');
      expect(v1, isNot(equals(v2)));
    });

    test('toString contains key fields', () {
      final verse = makeVerse();
      final s = verse.toString();
      expect(s, contains('Genesis-1-1'));
      expect(s, contains('bookId: 1'));
    });
  });

  // ── BibleChapter ────────────────────────────────────────────────────────────

  group('BibleChapter', () {
    test('fromJson builds chapter with verses', () {
      final json = {
        'number': 1,
        'verses': [
          {'number': 1, 'text': 'In the beginning', 'wordCount': 4},
          {'number': 2, 'text': 'And the earth', 'wordCount': 4},
        ],
      };
      final chapter = BibleChapter.fromJson(json, bookId: 1, bookName: 'Genesis');
      expect(chapter.number, equals(1));
      expect(chapter.bookId, equals(1));
      expect(chapter.verses, hasLength(2));
      expect(chapter.verses[0].id, equals('Genesis-1-1'));
      expect(chapter.verses[1].id, equals('Genesis-1-2'));
    });

    test('toJson/fromJson round-trip', () {
      final chapter = makeChapter(number: 3, verses: [makeVerse(number: 2)]);
      final json = chapter.toJson();
      final restored = BibleChapter.fromJson(json, bookId: 1, bookName: 'Genesis');
      expect(restored.number, equals(3));
      expect(restored.verses, hasLength(1));
    });

    test('copyWith', () {
      final chapter = makeChapter();
      final copy = chapter.copyWith(number: 5);
      expect(copy.number, equals(5));
      expect(copy.bookId, equals(chapter.bookId));
    });

    test('equality', () {
      final c1 = makeChapter();
      final c2 = makeChapter();
      expect(c1, equals(c2));
    });

    test('equality — different verse list is not equal', () {
      final c1 = makeChapter(verses: [makeVerse(number: 1)]);
      final c2 = makeChapter(verses: [makeVerse(number: 2)]);
      expect(c1, isNot(equals(c2)));
    });

    test('toString shows verse count', () {
      final chapter = makeChapter();
      expect(chapter.toString(), contains('verses: 1'));
    });
  });

  // ── BibleBook ───────────────────────────────────────────────────────────────

  group('BibleBook', () {
    test('fromJson builds book with chapters and verses', () {
      final json = {
        'id': 1,
        'name': 'Genesis',
        'testament': 'OT',
        'chapters': [
          {
            'number': 1,
            'verses': [
              {'number': 1, 'text': 'In the beginning', 'wordCount': 4},
            ],
          },
        ],
      };
      final book = BibleBook.fromJson(json);
      expect(book.id, equals(1));
      expect(book.name, equals('Genesis'));
      expect(book.testament, equals('OT'));
      expect(book.chapters, hasLength(1));
      expect(book.chapters[0].verses[0].id, equals('Genesis-1-1'));
    });

    test('toJson/fromJson round-trip', () {
      final book = makeBook();
      final json = book.toJson();
      final restored = BibleBook.fromJson(json);
      expect(restored.id, equals(book.id));
      expect(restored.name, equals(book.name));
      expect(restored.testament, equals(book.testament));
      expect(restored.chapters, hasLength(1));
    });

    test('copyWith', () {
      final book = makeBook();
      final copy = book.copyWith(name: 'Exodus', id: 2);
      expect(copy.name, equals('Exodus'));
      expect(copy.id, equals(2));
      expect(copy.testament, equals(book.testament));
    });

    test('equality', () {
      final b1 = makeBook();
      final b2 = makeBook();
      expect(b1, equals(b2));
      expect(b1.hashCode, equals(b2.hashCode));
    });

    test('equality — different testament is not equal', () {
      final b1 = makeBook(testament: 'OT');
      final b2 = makeBook(testament: 'NT');
      expect(b1, isNot(equals(b2)));
    });

    test('toString shows chapter count', () {
      final book = makeBook();
      expect(book.toString(), contains('chapters: 1'));
      expect(book.toString(), contains('Genesis'));
    });
  });

  group('copyWith defaults (all ?? this.x paths)', () {
    test('BibleVerse.copyWith with no args returns equal copy', () {
      final verse = makeVerse();
      final copy = verse.copyWith();
      expect(copy, equals(verse));
      expect(copy.id, equals(verse.id));
      expect(copy.text, equals(verse.text));
      expect(copy.wordCount, equals(verse.wordCount));
    });

    test('BibleChapter.copyWith with no args returns equal copy', () {
      final chapter = makeChapter();
      final copy = chapter.copyWith();
      expect(copy, equals(chapter));
      expect(copy.number, equals(chapter.number));
      expect(copy.verses, equals(chapter.verses));
    });

    test('BibleBook.copyWith with no args returns equal copy', () {
      final book = makeBook();
      final copy = book.copyWith();
      expect(copy, equals(book));
      expect(copy.id, equals(book.id));
      expect(copy.name, equals(book.name));
      expect(copy.testament, equals(book.testament));
    });
  });
}
