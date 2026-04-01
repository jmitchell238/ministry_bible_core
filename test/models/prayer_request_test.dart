import 'package:test/test.dart';
import 'package:ministry_bible_core/ministry_bible_core.dart';

void main() {
  final fixed = DateTime(2026, 1, 1);
  final answered = DateTime(2026, 3, 1);

  PrayerRequest makeReq({
    String id = 'pr-1',
    String content = 'Lord, guide my steps.',
    String? verseId,
    PrayerStatus status = PrayerStatus.active,
    DateTime? answeredAt,
  }) =>
      PrayerRequest(
        id: id,
        content: content,
        verseId: verseId,
        status: status,
        createdAt: fixed,
        answeredAt: answeredAt,
      );

  group('PrayerStatus', () {
    test('has all three values', () {
      expect(PrayerStatus.values, hasLength(3));
      expect(PrayerStatus.values, contains(PrayerStatus.active));
      expect(PrayerStatus.values, contains(PrayerStatus.answered));
      expect(PrayerStatus.values, contains(PrayerStatus.archived));
    });
  });

  group('PrayerRequest', () {
    test('constructor stores all fields', () {
      final r = makeReq(
        verseId: 'Psalms-23-1',
        status: PrayerStatus.answered,
        answeredAt: answered,
      );
      expect(r.id, equals('pr-1'));
      expect(r.content, equals('Lord, guide my steps.'));
      expect(r.verseId, equals('Psalms-23-1'));
      expect(r.status, equals(PrayerStatus.answered));
      expect(r.createdAt, equals(fixed));
      expect(r.answeredAt, equals(answered));
    });

    test('verseId defaults to null', () {
      expect(makeReq().verseId, isNull);
    });

    test('answeredAt defaults to null', () {
      expect(makeReq().answeredAt, isNull);
    });

    group('PrayerRequest.create', () {
      test('generates id and sets createdAt', () {
        final before = DateTime.now().subtract(const Duration(seconds: 1));
        final r = PrayerRequest.create(content: 'Heal the sick');
        expect(r.id, isNotEmpty);
        expect(r.createdAt.isAfter(before), isTrue);
      });

      test('status defaults to active', () {
        expect(PrayerRequest.create(content: 'x').status, equals(PrayerStatus.active));
      });

      test('uses provided verseId', () {
        final r = PrayerRequest.create(content: 'x', verseId: 'John-3-16');
        expect(r.verseId, equals('John-3-16'));
      });
    });

    group('fromJson / toJson', () {
      test('round-trip with all fields', () {
        final r = makeReq(
          verseId: 'Psalms-46-1',
          status: PrayerStatus.answered,
          answeredAt: answered,
        );
        expect(PrayerRequest.fromJson(r.toJson()), equals(r));
      });

      test('round-trip with null optionals', () {
        final r = makeReq();
        final restored = PrayerRequest.fromJson(r.toJson());
        expect(restored.verseId, isNull);
        expect(restored.answeredAt, isNull);
      });

      test('round-trip for all status values', () {
        for (final s in PrayerStatus.values) {
          final r = makeReq(status: s);
          expect(PrayerRequest.fromJson(r.toJson()).status, equals(s));
        }
      });
    });

    group('copyWith', () {
      test('changes specified fields', () {
        final r = makeReq();
        final copy = r.copyWith(
          status: PrayerStatus.answered,
          answeredAt: answered,
        );
        expect(copy.status, equals(PrayerStatus.answered));
        expect(copy.answeredAt, equals(answered));
        expect(copy.id, equals(r.id));
      });

      test('with no args returns equal copy', () {
        final r = makeReq(verseId: 'John-3-16', status: PrayerStatus.archived);
        expect(r.copyWith(), equals(r));
      });

      test('clearVerseId sets to null', () {
        final r = makeReq(verseId: 'John-3-16');
        expect(r.copyWith(clearVerseId: true).verseId, isNull);
      });

      test('clearAnsweredAt sets to null', () {
        final r = makeReq(answeredAt: answered);
        expect(r.copyWith(clearAnsweredAt: true).answeredAt, isNull);
      });
    });

    group('equality', () {
      test('same values are equal', () {
        expect(makeReq(), equals(makeReq()));
        expect(makeReq().hashCode, equals(makeReq().hashCode));
      });

      test('different status is not equal', () {
        expect(
          makeReq(status: PrayerStatus.active),
          isNot(equals(makeReq(status: PrayerStatus.archived))),
        );
      });

      test('different content is not equal', () {
        expect(makeReq(content: 'a'), isNot(equals(makeReq(content: 'b'))));
      });

      test('different verseId is not equal', () {
        expect(
          makeReq(verseId: 'John-3-16'),
          isNot(equals(makeReq(verseId: 'Gen-1-1'))),
        );
      });
    });

    test('toString contains content and status', () {
      final r = makeReq(status: PrayerStatus.answered);
      expect(r.toString(), contains('Lord, guide my steps.'));
      expect(r.toString(), contains('answered'));
    });
  });
}
