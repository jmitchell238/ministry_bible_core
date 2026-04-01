import 'package:test/test.dart';
import 'package:ministry_bible_core/ministry_bible_core.dart';

void main() {
  final start = DateTime(2026, 1, 1);

  group('ReadingPlanEventType', () {
    test('has all three values', () {
      expect(ReadingPlanEventType.values, hasLength(3));
      expect(ReadingPlanEventType.values, contains(ReadingPlanEventType.paused));
      expect(ReadingPlanEventType.values, contains(ReadingPlanEventType.resumed));
      expect(ReadingPlanEventType.values, contains(ReadingPlanEventType.skipped));
    });
  });

  group('ReadingPlanEvent', () {
    test('constructor stores type and date', () {
      final e = ReadingPlanEvent(
        type: ReadingPlanEventType.paused,
        date: start,
      );
      expect(e.type, equals(ReadingPlanEventType.paused));
      expect(e.date, equals(start));
    });

    test('fromJson / toJson round-trip', () {
      for (final t in ReadingPlanEventType.values) {
        final e = ReadingPlanEvent(type: t, date: start);
        expect(ReadingPlanEvent.fromJson(e.toJson()), equals(e));
      }
    });

    test('equality', () {
      final a = ReadingPlanEvent(type: ReadingPlanEventType.paused, date: start);
      final b = ReadingPlanEvent(type: ReadingPlanEventType.paused, date: start);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('different type is not equal', () {
      final a = ReadingPlanEvent(type: ReadingPlanEventType.paused, date: start);
      final b = ReadingPlanEvent(type: ReadingPlanEventType.resumed, date: start);
      expect(a, isNot(equals(b)));
    });

    test('toString contains type name', () {
      final e = ReadingPlanEvent(type: ReadingPlanEventType.skipped, date: start);
      expect(e.toString(), contains('skipped'));
    });
  });

  group('ReadingPlanState', () {
    group('ReadingPlanState.create', () {
      test('creates state with startDate and empty events', () {
        final state = ReadingPlanState.create(startDate: start);
        expect(state.startDate, equals(start));
        expect(state.events, isEmpty);
      });
    });

    group('fromJson / toJson', () {
      test('round-trip with events', () {
        final state = ReadingPlanState(
          startDate: start,
          events: [
            ReadingPlanEvent(type: ReadingPlanEventType.paused, date: DateTime(2026, 1, 5)),
            ReadingPlanEvent(type: ReadingPlanEventType.resumed, date: DateTime(2026, 1, 8)),
          ],
        );
        expect(ReadingPlanState.fromJson(state.toJson()), equals(state));
      });

      test('round-trip with no events', () {
        final state = ReadingPlanState(startDate: start, events: []);
        expect(ReadingPlanState.fromJson(state.toJson()), equals(state));
      });
    });

    group('effectiveDayNumber', () {
      test('no events: counts calendar days from startDate + 1', () {
        final state = ReadingPlanState(startDate: start, events: []);
        // 10 days after start → day 11
        expect(state.effectiveDayNumber(DateTime(2026, 1, 11)), equals(11));
      });

      test('same day as startDate is day 1', () {
        final state = ReadingPlanState(startDate: start, events: []);
        expect(state.effectiveDayNumber(start), equals(1));
      });

      test('paused without resume: paused days do not count', () {
        // Start Jan 1, pause Jan 4 (after day 4), check Jan 10
        // Active days: Jan 1,2,3,4 = 4 days. Jan 5-10 are paused (6 days).
        final state = ReadingPlanState(
          startDate: start,
          events: [
            ReadingPlanEvent(
              type: ReadingPlanEventType.paused,
              date: DateTime(2026, 1, 4),
            ),
          ],
        );
        expect(state.effectiveDayNumber(DateTime(2026, 1, 10)), equals(4));
      });

      test('paused then resumed: subtracts paused interval', () {
        // Start Jan 1, pause Jan 5, resume Jan 8
        // Paused for 3 calendar days (Jan 5,6,7)
        // Check on Jan 11 → 10 elapsed days − 3 paused = 7 active + 1 = day 8
        final state = ReadingPlanState(
          startDate: start,
          events: [
            ReadingPlanEvent(
              type: ReadingPlanEventType.paused,
              date: DateTime(2026, 1, 5),
            ),
            ReadingPlanEvent(
              type: ReadingPlanEventType.resumed,
              date: DateTime(2026, 1, 8),
            ),
          ],
        );
        expect(state.effectiveDayNumber(DateTime(2026, 1, 11)), equals(8));
      });

      test('multiple pause/resume cycles', () {
        // Start Jan 1
        // Pause Jan 3 → resume Jan 5  (2 paused days)
        // Pause Jan 8 → resume Jan 10 (2 paused days)
        // Check Jan 12 → 11 elapsed − 4 paused = 7 active + 1 = day 8
        final state = ReadingPlanState(
          startDate: start,
          events: [
            ReadingPlanEvent(type: ReadingPlanEventType.paused, date: DateTime(2026, 1, 3)),
            ReadingPlanEvent(type: ReadingPlanEventType.resumed, date: DateTime(2026, 1, 5)),
            ReadingPlanEvent(type: ReadingPlanEventType.paused, date: DateTime(2026, 1, 8)),
            ReadingPlanEvent(type: ReadingPlanEventType.resumed, date: DateTime(2026, 1, 10)),
          ],
        );
        expect(state.effectiveDayNumber(DateTime(2026, 1, 12)), equals(8));
      });
    });

    group('isPaused', () {
      test('returns false with no events', () {
        final state = ReadingPlanState(startDate: start, events: []);
        expect(state.isPaused(DateTime(2026, 1, 5)), isFalse);
      });

      test('returns true after a paused event', () {
        final state = ReadingPlanState(
          startDate: start,
          events: [
            ReadingPlanEvent(type: ReadingPlanEventType.paused, date: DateTime(2026, 1, 3)),
          ],
        );
        expect(state.isPaused(DateTime(2026, 1, 5)), isTrue);
      });

      test('returns false after paused then resumed', () {
        final state = ReadingPlanState(
          startDate: start,
          events: [
            ReadingPlanEvent(type: ReadingPlanEventType.paused, date: DateTime(2026, 1, 3)),
            ReadingPlanEvent(type: ReadingPlanEventType.resumed, date: DateTime(2026, 1, 5)),
          ],
        );
        expect(state.isPaused(DateTime(2026, 1, 6)), isFalse);
      });
    });

    group('skippedDays', () {
      test('returns empty when no skip events', () {
        final state = ReadingPlanState(startDate: start, events: []);
        expect(state.skippedDays, isEmpty);
      });

      test('returns dates of skip events', () {
        final d1 = DateTime(2026, 1, 5);
        final d2 = DateTime(2026, 1, 9);
        final state = ReadingPlanState(
          startDate: start,
          events: [
            ReadingPlanEvent(type: ReadingPlanEventType.skipped, date: d1),
            ReadingPlanEvent(type: ReadingPlanEventType.paused, date: DateTime(2026, 1, 7)),
            ReadingPlanEvent(type: ReadingPlanEventType.skipped, date: d2),
          ],
        );
        expect(state.skippedDays, containsAll([d1, d2]));
        expect(state.skippedDays, hasLength(2));
      });
    });

    group('copyWith', () {
      test('changes specified fields', () {
        final state = ReadingPlanState(startDate: start, events: []);
        final newEvent = ReadingPlanEvent(
          type: ReadingPlanEventType.skipped,
          date: DateTime(2026, 1, 2),
        );
        final copy = state.copyWith(events: [newEvent]);
        expect(copy.events, hasLength(1));
        expect(copy.startDate, equals(start));
      });

      test('with no args returns equal copy', () {
        final state = ReadingPlanState(
          startDate: start,
          events: [
            ReadingPlanEvent(type: ReadingPlanEventType.paused, date: DateTime(2026, 1, 3)),
          ],
        );
        expect(state.copyWith(), equals(state));
      });
    });

    group('equality', () {
      test('same values are equal', () {
        final a = ReadingPlanState(startDate: start, events: []);
        final b = ReadingPlanState(startDate: start, events: []);
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('different startDate is not equal', () {
        final a = ReadingPlanState(startDate: start, events: []);
        final b = ReadingPlanState(startDate: DateTime(2026, 2, 1), events: []);
        expect(a, isNot(equals(b)));
      });

      test('different events is not equal', () {
        final a = ReadingPlanState(startDate: start, events: []);
        final b = ReadingPlanState(
          startDate: start,
          events: [ReadingPlanEvent(type: ReadingPlanEventType.paused, date: start)],
        );
        expect(a, isNot(equals(b)));
      });
    });

    test('toString contains startDate', () {
      final state = ReadingPlanState(startDate: start, events: []);
      expect(state.toString(), contains('2026'));
    });
  });

  group('ReadingPlanService with ReadingPlanState', () {
    // Integration: getCurrentDayNumber respects paused state
  });
}
