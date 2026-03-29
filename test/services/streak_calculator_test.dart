import 'package:test/test.dart';
import 'package:ministry_bible_core/ministry_bible_core.dart';

// Fixed historical dates at noon — won't trigger the grace period (hour=0)
// and are safely in the past for the future-date validation test.
final _d0 = DateTime(2025, 6, 1, 12, 0); // day 0
final _d1 = DateTime(2025, 6, 2, 12, 0); // day 1 (consecutive after d0)
final _d2 = DateTime(2025, 6, 3, 12, 0); // day 2
final _d3 = DateTime(2025, 6, 4, 12, 0); // day 3
final _d5 = DateTime(2025, 6, 6, 12, 0); // day 5 (2-day gap after d3)

// Normalized versions (what getEffectiveDate returns)
final _n0 = DateTime(2025, 6, 1);
final _n1 = DateTime(2025, 6, 2);

void main() {
  group('StreakCalculator.recordActivity', () {
    test('first ever read — action streak goes 0→1', () {
      final initial = ReadingStreak.empty();
      final result = StreakCalculator.recordActivity(
        initial,
        _d0,
        hasAction: true,
        goalAchieved: false,
      );
      expect(result.currentActionStreak, equals(1));
      expect(result.highestActionStreak, equals(1));
      expect(result.lastActionDate, equals(_n0));
    });

    test('consecutive day — action streak increments', () {
      final streak = ReadingStreak(
        currentActionStreak: 3,
        highestActionStreak: 3,
        currentGoalStreak: 0,
        highestGoalStreak: 0,
        lastActionDate: _n0,
        createdAt: _n0,
        modifiedAt: _n0,
      );
      final result = StreakCalculator.recordActivity(
        streak,
        _d1,
        hasAction: true,
        goalAchieved: false,
      );
      expect(result.currentActionStreak, equals(4));
      expect(result.highestActionStreak, equals(4));
    });

    test('same day twice — streak does not increment', () {
      final streak = ReadingStreak(
        currentActionStreak: 2,
        highestActionStreak: 2,
        currentGoalStreak: 0,
        highestGoalStreak: 0,
        lastActionDate: _n0,
        createdAt: _n0,
        modifiedAt: _n0,
      );
      // Second read on the same day
      final result = StreakCalculator.recordActivity(
        streak,
        _d0,
        hasAction: true,
        goalAchieved: false,
      );
      expect(result.currentActionStreak, equals(2)); // unchanged
    });

    test('gap of 2+ days — action streak resets to 1', () {
      final streak = ReadingStreak(
        currentActionStreak: 5,
        highestActionStreak: 10,
        currentGoalStreak: 0,
        highestGoalStreak: 0,
        lastActionDate: _n0,
        createdAt: _n0,
        modifiedAt: _n0,
      );
      final result = StreakCalculator.recordActivity(
        streak,
        _d5, // skip d1..d4
        hasAction: true,
        goalAchieved: false,
      );
      expect(result.currentActionStreak, equals(1));
      expect(result.highestActionStreak, equals(10)); // preserved
    });

    test('grace period — 00:30 today counts as yesterday', () {
      // lastActionDate is day0; we record at day1 00:30 (grace period).
      // getEffectiveDate(day1 00:30) = day0 → same day as lastActionDate → no increment.
      final streak = ReadingStreak(
        currentActionStreak: 2,
        highestActionStreak: 2,
        currentGoalStreak: 0,
        highestGoalStreak: 0,
        lastActionDate: _n1,
        createdAt: _n0,
        modifiedAt: _n1,
      );
      final day2At0030 = DateTime(_d2.year, _d2.month, _d2.day, 0, 30);
      // getEffectiveDate(day2 00:30) = day1 = _n1 = lastActionDate → same day
      final result = StreakCalculator.recordActivity(
        streak,
        day2At0030,
        hasAction: true,
        goalAchieved: false,
      );
      expect(result.currentActionStreak, equals(2)); // same day, no increment
      expect(result.lastActionDate, equals(_n1));
    });

    test('goal achieved increments goal streak', () {
      final initial = ReadingStreak.empty();
      final result = StreakCalculator.recordActivity(
        initial,
        _d0,
        hasAction: true,
        goalAchieved: true,
      );
      expect(result.currentGoalStreak, equals(1));
      expect(result.highestGoalStreak, equals(1));
    });

    test('goal NOT achieved resets goal streak to 0', () {
      final streak = ReadingStreak(
        currentActionStreak: 3,
        highestActionStreak: 3,
        currentGoalStreak: 5,
        highestGoalStreak: 7,
        lastActionDate: _n0,
        lastGoalDate: _n0,
        createdAt: _n0,
        modifiedAt: _n0,
      );
      final result = StreakCalculator.recordActivity(
        streak,
        _d1,
        hasAction: true,
        goalAchieved: false,
      );
      expect(result.currentGoalStreak, equals(0));
      expect(result.highestGoalStreak, equals(7)); // preserved
    });

    test('highest streak is preserved when current drops', () {
      final streak = ReadingStreak(
        currentActionStreak: 1,
        highestActionStreak: 15,
        currentGoalStreak: 0,
        highestGoalStreak: 8,
        lastActionDate: _n0,
        createdAt: _n0,
        modifiedAt: _n0,
      );
      // Gap from d0 to d5 — resets to 1
      final result = StreakCalculator.recordActivity(
        streak,
        _d5,
        hasAction: true,
        goalAchieved: false,
      );
      expect(result.currentActionStreak, equals(1));
      expect(result.highestActionStreak, equals(15));
    });

    test('future date throws ArgumentError', () {
      final initial = ReadingStreak.empty();
      final future = DateTime.now().add(const Duration(days: 2));
      expect(
        () => StreakCalculator.recordActivity(
          initial,
          future,
          hasAction: true,
          goalAchieved: false,
        ),
        throwsArgumentError,
      );
    });

    test('hasAction=false does not update action streak or lastActionDate', () {
      final initial = ReadingStreak.empty();
      final result = StreakCalculator.recordActivity(
        initial,
        _d0,
        hasAction: false,
        goalAchieved: false,
      );
      expect(result.currentActionStreak, equals(0));
      expect(result.lastActionDate, isNull);
    });

    test('three consecutive days — streak reaches 3', () {
      ReadingStreak s = ReadingStreak.empty();
      s = StreakCalculator.recordActivity(s, _d0, hasAction: true, goalAchieved: false);
      s = StreakCalculator.recordActivity(s, _d1, hasAction: true, goalAchieved: false);
      s = StreakCalculator.recordActivity(s, _d2, hasAction: true, goalAchieved: false);
      expect(s.currentActionStreak, equals(3));
      expect(s.highestActionStreak, equals(3));
    });
  });

  group('StreakCalculator.recalculateFromHistory', () {
    test('empty history returns empty streak', () {
      final result = StreakCalculator.recalculateFromHistory([]);
      expect(result.currentActionStreak, equals(0));
      expect(result.currentGoalStreak, equals(0));
    });

    test('single day with reading — highest is 1, current is 0 (old data)', () {
      // The day is far in the past so current streak is 0 (broken)
      final result = StreakCalculator.recalculateFromHistory([
        (date: _d0, versesRead: 5, goalAchieved: true),
      ]);
      expect(result.highestActionStreak, equals(1));
      expect(result.highestGoalStreak, equals(1));
      // Current streak is 0 because d0 is not today or yesterday
      expect(result.currentActionStreak, equals(0));
    });

    test('two consecutive days — highest is 2, current 0 (old data)', () {
      final result = StreakCalculator.recalculateFromHistory([
        (date: _d0, versesRead: 5, goalAchieved: true),
        (date: _d1, versesRead: 3, goalAchieved: true),
      ]);
      expect(result.highestActionStreak, equals(2));
      expect(result.currentActionStreak, equals(0)); // broken (old data)
    });

    test('gap resets current streak but preserves highest', () {
      final result = StreakCalculator.recalculateFromHistory([
        (date: _d0, versesRead: 3, goalAchieved: false),
        (date: _d1, versesRead: 3, goalAchieved: false),
        (date: _d3, versesRead: 0, goalAchieved: false), // gap + no reading
        (date: _d5, versesRead: 3, goalAchieved: false),
      ]);
      expect(result.highestActionStreak, equals(2));
    });

    test('sorts records by date even if given out of order', () {
      final result = StreakCalculator.recalculateFromHistory([
        (date: _d1, versesRead: 3, goalAchieved: false),
        (date: _d0, versesRead: 3, goalAchieved: false),
      ]);
      expect(result.highestActionStreak, equals(2));
    });

    test('goal not achieved resets goal streak in history', () {
      final result = StreakCalculator.recalculateFromHistory([
        (date: _d0, versesRead: 3, goalAchieved: true),
        (date: _d1, versesRead: 3, goalAchieved: true),
        (date: _d2, versesRead: 3, goalAchieved: false), // goal broken
        (date: _d3, versesRead: 3, goalAchieved: true),
      ]);
      expect(result.highestGoalStreak, equals(2)); // d0+d1
    });
  });
}
