import 'package:test/test.dart';
import 'package:ministry_bible_core/ministry_bible_core.dart';

void main() {
  final fixed = DateTime(2026, 1, 1);

  VerseCard makeCard({
    String verseId = 'John-3-16',
    String reference = 'John 3:16',
    String verseText = 'For God so loved the world.',
    String translationCode = 'KJV',
    String? theme,
    String? color,
  }) =>
      VerseCard(
        verseId: verseId,
        reference: reference,
        verseText: verseText,
        translationCode: translationCode,
        theme: theme,
        color: color,
        createdAt: fixed,
      );

  group('VerseCard', () {
    test('constructor stores all fields', () {
      final card = makeCard(theme: 'sunrise', color: '#FF6B35');
      expect(card.verseId, equals('John-3-16'));
      expect(card.reference, equals('John 3:16'));
      expect(card.verseText, equals('For God so loved the world.'));
      expect(card.translationCode, equals('KJV'));
      expect(card.theme, equals('sunrise'));
      expect(card.color, equals('#FF6B35'));
      expect(card.createdAt, equals(fixed));
    });

    test('theme defaults to null', () {
      expect(makeCard().theme, isNull);
    });

    test('color defaults to null', () {
      expect(makeCard().color, isNull);
    });

    group('shareText', () {
      test('returns verse text and reference', () {
        final card = makeCard();
        expect(card.shareText, contains('For God so loved the world.'));
        expect(card.shareText, contains('John 3:16'));
        expect(card.shareText, contains('KJV'));
      });

      test('format is "text\\n— Reference (Translation)"', () {
        final card = makeCard(
          verseText: 'Trust in the Lord.',
          reference: 'Proverbs 3:5',
          translationCode: 'KJV',
        );
        expect(
          card.shareText,
          equals('Trust in the Lord.\n— Proverbs 3:5 (KJV)'),
        );
      });
    });

    group('fromJson / toJson', () {
      test('round-trip with all fields', () {
        final card = makeCard(theme: 'default', color: '#123456');
        expect(VerseCard.fromJson(card.toJson()), equals(card));
      });

      test('round-trip with null optionals', () {
        final card = makeCard();
        final restored = VerseCard.fromJson(card.toJson());
        expect(restored.theme, isNull);
        expect(restored.color, isNull);
      });

      test('toJson includes all keys', () {
        final json = makeCard().toJson();
        for (final key in [
          'verseId', 'reference', 'verseText', 'translationCode',
          'theme', 'color', 'createdAt',
        ]) {
          expect(json.containsKey(key), isTrue, reason: 'missing: $key');
        }
      });
    });

    group('copyWith', () {
      test('changes specified fields', () {
        final card = makeCard();
        final copy = card.copyWith(theme: 'night', color: '#000000');
        expect(copy.theme, equals('night'));
        expect(copy.color, equals('#000000'));
        expect(copy.verseId, equals(card.verseId));
      });

      test('with no args returns equal copy', () {
        final card = makeCard(theme: 'dawn', color: '#AABBCC');
        expect(card.copyWith(), equals(card));
      });

      test('clearTheme sets to null', () {
        final card = makeCard(theme: 'sunrise');
        expect(card.copyWith(clearTheme: true).theme, isNull);
      });

      test('clearColor sets to null', () {
        final card = makeCard(color: '#FF0000');
        expect(card.copyWith(clearColor: true).color, isNull);
      });
    });

    group('equality', () {
      test('same values are equal', () {
        expect(makeCard(), equals(makeCard()));
        expect(makeCard().hashCode, equals(makeCard().hashCode));
      });

      test('different verseText is not equal', () {
        expect(
          makeCard(verseText: 'a'),
          isNot(equals(makeCard(verseText: 'b'))),
        );
      });

      test('different theme is not equal', () {
        expect(
          makeCard(theme: 'light'),
          isNot(equals(makeCard(theme: 'dark'))),
        );
      });
    });

    test('toString contains reference and translation', () {
      final card = makeCard();
      expect(card.toString(), contains('John 3:16'));
      expect(card.toString(), contains('KJV'));
    });
  });
}
