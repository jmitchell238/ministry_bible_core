import 'package:test/test.dart';
import 'package:ministry_bible_core/ministry_bible_core.dart';

void main() {
  final fixed = DateTime(2026, 1, 1);
  final review = DateTime(2026, 2, 1);

  MemorizationEntry makeEntry({
    String id = 'mem-1',
    String verseId = 'John-3-16',
    MemorizationStatus status = MemorizationStatus.learning,
    DateTime? nextReviewDate,
    DateTime? lastReviewedAt,
    int reviewCount = 0,
  }) =>
      MemorizationEntry(
        id: id,
        verseId: verseId,
        status: status,
        nextReviewDate: nextReviewDate,
        lastReviewedAt: lastReviewedAt,
        reviewCount: reviewCount,
        createdAt: fixed,
        updatedAt: fixed,
      );

  group('MemorizationStatus', () {
    test('has all three values', () {
      expect(MemorizationStatus.values, contains(MemorizationStatus.learning));
      expect(MemorizationStatus.values, contains(MemorizationStatus.reviewing));
      expect(MemorizationStatus.values, contains(MemorizationStatus.mastered));
      expect(MemorizationStatus.values, hasLength(3));
    });
  });

  group('MemorizationEntry', () {
    test('constructor stores all fields', () {
      final e = makeEntry(
        status: MemorizationStatus.reviewing,
        nextReviewDate: review,
        lastReviewedAt: fixed,
        reviewCount: 3,
      );
      expect(e.verseId, equals('John-3-16'));
      expect(e.status, equals(MemorizationStatus.reviewing));
      expect(e.nextReviewDate, equals(review));
      expect(e.lastReviewedAt, equals(fixed));
      expect(e.reviewCount, equals(3));
    });

    test('nullable fields default to null', () {
      final e = makeEntry();
      expect(e.nextReviewDate, isNull);
      expect(e.lastReviewedAt, isNull);
    });

    group('MemorizationEntry.create', () {
      test('generates id and timestamps, reviewCount = 0', () {
        final before = DateTime.now().subtract(const Duration(seconds: 1));
        final e = MemorizationEntry.create(verseId: 'Gen-1-1');
        expect(e.id, isNotEmpty);
        expect(e.createdAt.isAfter(before), isTrue);
        expect(e.reviewCount, equals(0));
        expect(e.lastReviewedAt, isNull);
      });

      test('uses provided status and nextReviewDate', () {
        final e = MemorizationEntry.create(
          verseId: 'Gen-1-1',
          status: MemorizationStatus.reviewing,
          nextReviewDate: review,
        );
        expect(e.status, equals(MemorizationStatus.reviewing));
        expect(e.nextReviewDate, equals(review));
      });
    });

    group('fromJson / toJson', () {
      test('round-trip with all fields', () {
        final e = makeEntry(
          status: MemorizationStatus.mastered,
          nextReviewDate: review,
          lastReviewedAt: fixed,
          reviewCount: 5,
        );
        expect(MemorizationEntry.fromJson(e.toJson()), equals(e));
      });

      test('round-trip with null optional fields', () {
        final e = makeEntry();
        final restored = MemorizationEntry.fromJson(e.toJson());
        expect(restored.nextReviewDate, isNull);
        expect(restored.lastReviewedAt, isNull);
      });

      test('round-trip for all three status values', () {
        for (final s in MemorizationStatus.values) {
          final e = makeEntry(status: s);
          expect(MemorizationEntry.fromJson(e.toJson()).status, equals(s));
        }
      });
    });

    group('copyWith', () {
      test('changes specified fields', () {
        final e = makeEntry(reviewCount: 0);
        final copy = e.copyWith(
          reviewCount: 1,
          status: MemorizationStatus.reviewing,
          lastReviewedAt: fixed,
        );
        expect(copy.reviewCount, equals(1));
        expect(copy.status, equals(MemorizationStatus.reviewing));
        expect(copy.lastReviewedAt, equals(fixed));
        expect(copy.id, equals(e.id));
      });

      test('with no args returns equal copy', () {
        final e = makeEntry(
          status: MemorizationStatus.reviewing,
          nextReviewDate: review,
          lastReviewedAt: fixed,
          reviewCount: 2,
        );
        expect(e.copyWith(), equals(e));
      });

      test('clearNextReviewDate sets to null', () {
        final e = makeEntry(nextReviewDate: review);
        expect(e.copyWith(clearNextReviewDate: true).nextReviewDate, isNull);
      });

      test('clearLastReviewedAt sets to null', () {
        final e = makeEntry(lastReviewedAt: fixed);
        expect(e.copyWith(clearLastReviewedAt: true).lastReviewedAt, isNull);
      });
    });

    group('equality', () {
      test('same values are equal', () {
        expect(makeEntry(), equals(makeEntry()));
        expect(makeEntry().hashCode, equals(makeEntry().hashCode));
      });

      test('different status is not equal', () {
        expect(
          makeEntry(status: MemorizationStatus.learning),
          isNot(equals(makeEntry(status: MemorizationStatus.mastered))),
        );
      });

      test('different reviewCount is not equal', () {
        expect(makeEntry(reviewCount: 0), isNot(equals(makeEntry(reviewCount: 1))));
      });
    });

    test('toString contains verseId and status', () {
      final e = makeEntry(verseId: 'John-3-16', status: MemorizationStatus.mastered);
      expect(e.toString(), contains('John-3-16'));
      expect(e.toString(), contains('mastered'));
    });
  });
}
