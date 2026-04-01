import 'package:test/test.dart';
import 'package:ministry_bible_core/ministry_bible_core.dart';

void main() {
  group('BibleBooks', () {
    test('all contains 66 books', () {
      expect(BibleBooks.all, hasLength(66));
    });

    test('count returns 66', () {
      expect(BibleBooks.count, equals(66));
    });

    test('all starts with Genesis and ends with Revelation', () {
      expect(BibleBooks.all.first, equals('Genesis'));
      expect(BibleBooks.all.last, equals('Revelation'));
    });

    test('contains returns true for valid book', () {
      expect(BibleBooks.contains('Genesis'), isTrue);
      expect(BibleBooks.contains('Revelation'), isTrue);
      expect(BibleBooks.contains('John'), isTrue);
    });

    test('contains returns false for invalid book', () {
      expect(BibleBooks.contains('Hezekiah'), isFalse);
      expect(BibleBooks.contains(''), isFalse);
    });

    test('findBook returns canonical name for exact match', () {
      expect(BibleBooks.findBook('Genesis'), equals('Genesis'));
      expect(BibleBooks.findBook('John'), equals('John'));
    });

    test('findBook returns match for prefix', () {
      expect(BibleBooks.findBook('Gen'), equals('Genesis'));
      expect(BibleBooks.findBook('Rev'), equals('Revelation'));
    });

    test('findBook is case-insensitive', () {
      expect(BibleBooks.findBook('gen'), equals('Genesis'));
      expect(BibleBooks.findBook('GEN'), equals('Genesis'));
    });

    test('findBook returns null for empty string', () {
      expect(BibleBooks.findBook(''), isNull);
    });

    test('findBook returns null for no match', () {
      expect(BibleBooks.findBook('Hezekiah'), isNull);
      expect(BibleBooks.findBook('zzz'), isNull);
    });

    group('findBook aliases', () {
      test('Psalm → Psalms', () {
        expect(BibleBooks.findBook('Psalm'), equals('Psalms'));
      });

      test('Revelations → Revelation', () {
        expect(BibleBooks.findBook('Revelations'), equals('Revelation'));
      });

      test('Song of Songs → Song of Solomon', () {
        expect(BibleBooks.findBook('Song of Songs'), equals('Song of Solomon'));
      });

      test('SoS → Song of Solomon', () {
        expect(BibleBooks.findBook('SoS'), equals('Song of Solomon'));
      });

      test('1st John → 1 John', () {
        expect(BibleBooks.findBook('1st John'), equals('1 John'));
      });

      test('2nd Kings → 2 Kings', () {
        expect(BibleBooks.findBook('2nd Kings'), equals('2 Kings'));
      });

      test('3rd John → 3 John', () {
        expect(BibleBooks.findBook('3rd John'), equals('3 John'));
      });

      test('alias lookup is case-insensitive', () {
        expect(BibleBooks.findBook('psalm'), equals('Psalms'));
        expect(BibleBooks.findBook('REVELATIONS'), equals('Revelation'));
        expect(BibleBooks.findBook('song of songs'), equals('Song of Solomon'));
      });

      test('prefix matching still works after alias check', () {
        expect(BibleBooks.findBook('Gen'), equals('Genesis'));
        expect(BibleBooks.findBook('Rev'), equals('Revelation'));
      });
    });
  });
}
