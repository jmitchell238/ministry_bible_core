import 'package:test/test.dart';
import 'package:ministry_bible_core/ministry_bible_core.dart';

void main() {
  group('BibleMeta', () {
    test('isOldTestament returns true for OT books', () {
      expect(BibleMeta.isOldTestament('Genesis'), isTrue);
      expect(BibleMeta.isOldTestament('Malachi'), isTrue);
      expect(BibleMeta.isOldTestament('Psalms'), isTrue);
    });

    test('isOldTestament returns false for NT books', () {
      expect(BibleMeta.isOldTestament('Matthew'), isFalse);
      expect(BibleMeta.isOldTestament('Revelation'), isFalse);
    });

    test('isNewTestament returns true for NT books', () {
      expect(BibleMeta.isNewTestament('Matthew'), isTrue);
      expect(BibleMeta.isNewTestament('John'), isTrue);
      expect(BibleMeta.isNewTestament('Revelation'), isTrue);
    });

    test('isNewTestament returns false for OT books', () {
      expect(BibleMeta.isNewTestament('Genesis'), isFalse);
      expect(BibleMeta.isNewTestament('Malachi'), isFalse);
    });

    test('chaptersIn returns correct count for known books', () {
      expect(BibleMeta.chaptersIn('Genesis'), equals(50));
      expect(BibleMeta.chaptersIn('Psalms'), equals(150));
      expect(BibleMeta.chaptersIn('Obadiah'), equals(1));
      expect(BibleMeta.chaptersIn('Revelation'), equals(22));
    });

    test('chaptersIn returns 0 for unknown book', () {
      expect(BibleMeta.chaptersIn('Hezekiah'), equals(0));
    });

    test('oldTestament contains 39 books', () {
      expect(BibleMeta.oldTestament, hasLength(39));
    });

    test('newTestament contains 27 books', () {
      expect(BibleMeta.newTestament, hasLength(27));
    });
  });
}
