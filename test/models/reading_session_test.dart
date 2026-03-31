import 'package:test/test.dart';
import 'package:ministry_bible_core/ministry_bible_core.dart';

void main() {
  final start = DateTime(2026, 3, 30, 9, 0);
  final end = DateTime(2026, 3, 30, 9, 30);
  final fixed = DateTime(2026, 3, 30);

  ReadingSession makeSession({
    String id = 'sess-1',
    DateTime? startedAt,
    DateTime? endedAt,
    List<String>? verseIds,
  }) =>
      ReadingSession(
        id: id,
        startedAt: startedAt ?? start,
        endedAt: endedAt,
        verseIds: verseIds ?? ['Genesis-1-1', 'Genesis-1-2'],
        createdAt: fixed,
      );

  group('ReadingSession', () {
    test('constructor stores all fields', () {
      final s = makeSession(endedAt: end);
      expect(s.id, equals('sess-1'));
      expect(s.startedAt, equals(start));
      expect(s.endedAt, equals(end));
      expect(s.verseIds, hasLength(2));
      expect(s.createdAt, equals(fixed));
    });

    test('endedAt defaults to null', () {
      expect(makeSession().endedAt, isNull);
    });

    group('computed getters', () {
      test('durationMinutes returns 0 when session not ended', () {
        expect(makeSession().durationMinutes, equals(0));
      });

      test('durationMinutes returns elapsed minutes when ended', () {
        final s = makeSession(startedAt: start, endedAt: end);
        expect(s.durationMinutes, equals(30));
      });

      test('versesRead returns verse count', () {
        expect(makeSession(verseIds: ['A', 'B', 'C']).versesRead, equals(3));
      });

      test('versesRead returns 0 for empty session', () {
        expect(makeSession(verseIds: []).versesRead, equals(0));
      });
    });

    group('ReadingSession.create', () {
      test('generates id and createdAt', () {
        final before = DateTime.now().subtract(const Duration(seconds: 1));
        final s = ReadingSession.create(startedAt: start);
        expect(s.id, isNotEmpty);
        expect(s.createdAt.isAfter(before), isTrue);
      });

      test('uses provided optional fields', () {
        final s = ReadingSession.create(
          startedAt: start,
          endedAt: end,
          verseIds: ['John-3-16'],
        );
        expect(s.endedAt, equals(end));
        expect(s.verseIds, equals(['John-3-16']));
      });

      test('verseIds list is a copy, not alias', () {
        final list = ['John-3-16'];
        final s = ReadingSession.create(startedAt: start, verseIds: list);
        list.add('Gen-1-1');
        expect(s.verseIds, hasLength(1));
      });
    });

    group('fromJson / toJson', () {
      test('round-trip with endedAt', () {
        final s = makeSession(endedAt: end);
        final restored = ReadingSession.fromJson(s.toJson());
        expect(restored, equals(s));
      });

      test('round-trip without endedAt', () {
        final s = makeSession();
        final restored = ReadingSession.fromJson(s.toJson());
        expect(restored.endedAt, isNull);
      });

      test('toJson includes all keys', () {
        final json = makeSession(endedAt: end).toJson();
        for (final key in ['id', 'startedAt', 'endedAt', 'verseIds', 'createdAt']) {
          expect(json.containsKey(key), isTrue, reason: 'missing: $key');
        }
      });
    });

    group('copyWith', () {
      test('changes specified fields', () {
        final s = makeSession();
        final copy = s.copyWith(endedAt: end);
        expect(copy.endedAt, equals(end));
        expect(copy.id, equals(s.id));
      });

      test('with no args returns equal copy', () {
        final s = makeSession(endedAt: end, verseIds: ['John-3-16']);
        expect(s.copyWith(), equals(s));
      });

      test('clearEndedAt sets to null', () {
        final s = makeSession(endedAt: end);
        expect(s.copyWith(clearEndedAt: true).endedAt, isNull);
      });

      test('verseIds list defaults do not alias original', () {
        final s = makeSession(verseIds: ['John-3-16']);
        expect(s.copyWith().verseIds, equals(s.verseIds));
      });
    });

    group('equality', () {
      test('same values are equal', () {
        final s1 = makeSession();
        final s2 = makeSession();
        expect(s1, equals(s2));
        expect(s1.hashCode, equals(s2.hashCode));
      });

      test('different verseIds is not equal', () {
        expect(
          makeSession(verseIds: ['A']),
          isNot(equals(makeSession(verseIds: ['B']))),
        );
      });

      test('different endedAt is not equal', () {
        expect(makeSession(endedAt: end), isNot(equals(makeSession())));
      });
    });

    test('toString contains key info', () {
      final s = makeSession(endedAt: end);
      expect(s.toString(), contains('sess-1'));
      expect(s.toString(), contains('durationMinutes: 30'));
    });
  });
}
