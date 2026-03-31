import 'package:test/test.dart';
import 'package:ministry_bible_core/ministry_bible_core.dart';

void main() {
  group('ReadingStreak.empty', () {
    test('all streak counts are 0', () {
      final s = ReadingStreak.empty();
      expect(s.currentActionStreak, equals(0));
      expect(s.highestActionStreak, equals(0));
      expect(s.currentGoalStreak, equals(0));
      expect(s.highestGoalStreak, equals(0));
    });

    test('dates are null', () {
      final s = ReadingStreak.empty();
      expect(s.lastActionDate, isNull);
      expect(s.lastGoalDate, isNull);
    });

    test('createdAt and modifiedAt are set', () {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final s = ReadingStreak.empty();
      expect(s.createdAt.isAfter(before), isTrue);
      expect(s.modifiedAt.isAfter(before), isTrue);
    });
  });

  group('ReadingStreak fromJson/toJson', () {
    test('round-trip with null dates', () {
      final s = ReadingStreak(
        currentActionStreak: 5,
        highestActionStreak: 10,
        currentGoalStreak: 3,
        highestGoalStreak: 7,
        createdAt: DateTime(2026, 1, 1),
        modifiedAt: DateTime(2026, 1, 15),
      );
      final json = s.toJson();
      final restored = ReadingStreak.fromJson(json);
      expect(restored, equals(s));
    });

    test('round-trip with dates set', () {
      final actionDate = DateTime(2026, 3, 27);
      final goalDate = DateTime(2026, 3, 26);
      final s = ReadingStreak(
        currentActionStreak: 3,
        highestActionStreak: 3,
        currentGoalStreak: 1,
        highestGoalStreak: 2,
        lastActionDate: actionDate,
        lastGoalDate: goalDate,
        createdAt: DateTime(2026, 1, 1),
        modifiedAt: DateTime(2026, 3, 27),
      );
      final json = s.toJson();
      final restored = ReadingStreak.fromJson(json);
      expect(restored.lastActionDate, equals(actionDate));
      expect(restored.lastGoalDate, equals(goalDate));
    });
  });

  group('ReadingStreak.copyWith', () {
    test('changes only specified fields', () {
      final s = ReadingStreak.empty();
      final updated = s.copyWith(currentActionStreak: 5, highestActionStreak: 5);
      expect(updated.currentActionStreak, equals(5));
      expect(updated.highestActionStreak, equals(5));
      expect(updated.currentGoalStreak, equals(0));
    });

    test('clearLastActionDate sets to null', () {
      final s = ReadingStreak(
        currentActionStreak: 1,
        highestActionStreak: 1,
        currentGoalStreak: 0,
        highestGoalStreak: 0,
        lastActionDate: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
        modifiedAt: DateTime(2026, 1, 1),
      );
      final cleared = s.copyWith(clearLastActionDate: true);
      expect(cleared.lastActionDate, isNull);
    });
  });

  group('ReadingStreak equality', () {
    test('same values are equal', () {
      final s1 = ReadingStreak(
        currentActionStreak: 3,
        highestActionStreak: 5,
        currentGoalStreak: 1,
        highestGoalStreak: 2,
        createdAt: DateTime(2026, 1, 1),
        modifiedAt: DateTime(2026, 1, 1),
      );
      final s2 = ReadingStreak(
        currentActionStreak: 3,
        highestActionStreak: 5,
        currentGoalStreak: 1,
        highestGoalStreak: 2,
        createdAt: DateTime(2026, 1, 1),
        modifiedAt: DateTime(2026, 1, 1),
      );
      expect(s1, equals(s2));
      expect(s1.hashCode, equals(s2.hashCode));
    });

    test('different streak count is not equal', () {
      final s1 = ReadingStreak(
        currentActionStreak: 1,
        highestActionStreak: 1,
        currentGoalStreak: 0,
        highestGoalStreak: 0,
        createdAt: DateTime(2026, 1, 1),
        modifiedAt: DateTime(2026, 1, 1),
      );
      final s2 = s1.copyWith(currentActionStreak: 2);
      expect(s1, isNot(equals(s2)));
    });
  });

  group('ReadingProgressEntry', () {
    test('fromJson/toJson round-trip', () {
      final entry = ReadingProgressEntry(
        verseId: 'Genesis-1-1',
        readAt: DateTime(2026, 3, 27, 10, 30),
      );
      final json = entry.toJson();
      final restored = ReadingProgressEntry.fromJson(json);
      expect(restored.verseId, equals(entry.verseId));
      expect(restored.readAt, equals(entry.readAt));
    });

    test('copyWith', () {
      final entry = ReadingProgressEntry(
        verseId: 'Genesis-1-1',
        readAt: DateTime(2026, 1, 1),
      );
      final copy = entry.copyWith(verseId: 'John-3-16');
      expect(copy.verseId, equals('John-3-16'));
      expect(copy.readAt, equals(entry.readAt));
    });

    test('equality', () {
      final e1 = ReadingProgressEntry(
        verseId: 'Genesis-1-1',
        readAt: DateTime(2026, 1, 1),
      );
      final e2 = ReadingProgressEntry(
        verseId: 'Genesis-1-1',
        readAt: DateTime(2026, 1, 1),
      );
      expect(e1, equals(e2));
    });

    test('toString contains verseId', () {
      final entry = ReadingProgressEntry(
        verseId: 'John-3-16',
        readAt: DateTime(2026, 3, 27),
      );
      expect(entry.toString(), contains('John-3-16'));
    });

    test('hashCode is consistent', () {
      final e1 = ReadingProgressEntry(
        verseId: 'Genesis-1-1',
        readAt: DateTime(2026, 1, 1),
      );
      final e2 = ReadingProgressEntry(
        verseId: 'Genesis-1-1',
        readAt: DateTime(2026, 1, 1),
      );
      expect(e1.hashCode, equals(e2.hashCode));
    });

    test('copyWith with no args returns equal copy', () {
      final entry = ReadingProgressEntry(
        verseId: 'Genesis-1-1',
        readAt: DateTime(2026, 1, 1),
      );
      final copy = entry.copyWith();
      expect(copy.verseId, equals(entry.verseId));
      expect(copy.readAt, equals(entry.readAt));
    });
  });

  group('ReadingStreak toString', () {
    test('toString contains streak info', () {
      final s = ReadingStreak(
        currentActionStreak: 5,
        highestActionStreak: 10,
        currentGoalStreak: 2,
        highestGoalStreak: 4,
        createdAt: DateTime(2026, 1, 1),
        modifiedAt: DateTime(2026, 1, 1),
      );
      expect(s.toString(), contains('5/10'));
      expect(s.toString(), contains('2/4'));
    });
  });
}
