import 'package:test/test.dart';
import 'package:ministry_bible_core/ministry_bible_core.dart';

void main() {
  final fixed = DateTime(2026, 1, 1);

  ReadingGoal makeGoal({
    String id = 'goal-1',
    GoalType type = GoalType.versesPerDay,
    int target = 85,
  }) =>
      ReadingGoal(
        id: id,
        type: type,
        target: target,
        createdAt: fixed,
        updatedAt: fixed,
      );

  group('GoalType', () {
    test('has all three values', () {
      expect(GoalType.values, contains(GoalType.versesPerDay));
      expect(GoalType.values, contains(GoalType.chaptersPerDay));
      expect(GoalType.values, contains(GoalType.minutesPerDay));
      expect(GoalType.values, hasLength(3));
    });
  });

  group('ReadingGoal', () {
    test('constructor stores all fields', () {
      final g = makeGoal(type: GoalType.chaptersPerDay, target: 3);
      expect(g.type, equals(GoalType.chaptersPerDay));
      expect(g.target, equals(3));
      expect(g.createdAt, equals(fixed));
    });

    group('ReadingGoal.create', () {
      test('generates id and timestamps', () {
        final before = DateTime.now().subtract(const Duration(seconds: 1));
        final g = ReadingGoal.create(type: GoalType.versesPerDay, target: 85);
        expect(g.id, isNotEmpty);
        expect(g.createdAt.isAfter(before), isTrue);
      });
    });

    group('fromJson / toJson', () {
      test('round-trip versesPerDay', () {
        final g = makeGoal(type: GoalType.versesPerDay, target: 85);
        expect(ReadingGoal.fromJson(g.toJson()), equals(g));
      });

      test('round-trip chaptersPerDay', () {
        final g = makeGoal(type: GoalType.chaptersPerDay, target: 3);
        expect(ReadingGoal.fromJson(g.toJson()), equals(g));
      });

      test('round-trip minutesPerDay', () {
        final g = makeGoal(type: GoalType.minutesPerDay, target: 30);
        expect(ReadingGoal.fromJson(g.toJson()), equals(g));
      });
    });

    group('copyWith', () {
      test('changes specified fields', () {
        final g = makeGoal(target: 85);
        final copy = g.copyWith(target: 100);
        expect(copy.target, equals(100));
        expect(copy.id, equals(g.id));
      });

      test('with no args returns equal copy', () {
        expect(makeGoal().copyWith(), equals(makeGoal()));
      });
    });

    group('isAchieved — versesPerDay', () {
      test('returns true when versesRead meets target', () {
        final g = makeGoal(type: GoalType.versesPerDay, target: 5);
        expect(g.isAchieved(versesRead: 5), isTrue);
        expect(g.isAchieved(versesRead: 10), isTrue);
      });

      test('returns false when versesRead below target', () {
        final g = makeGoal(type: GoalType.versesPerDay, target: 5);
        expect(g.isAchieved(versesRead: 4), isFalse);
        expect(g.isAchieved(versesRead: 0), isFalse);
      });
    });

    group('isAchieved — chaptersPerDay', () {
      test('returns true when chaptersRead meets target', () {
        final g = makeGoal(type: GoalType.chaptersPerDay, target: 3);
        expect(g.isAchieved(versesRead: 0, chaptersRead: 3), isTrue);
        expect(g.isAchieved(versesRead: 0, chaptersRead: 5), isTrue);
      });

      test('returns false when chaptersRead below target', () {
        final g = makeGoal(type: GoalType.chaptersPerDay, target: 3);
        expect(g.isAchieved(versesRead: 0, chaptersRead: 2), isFalse);
      });
    });

    group('isAchieved — minutesPerDay', () {
      test('returns true when minutesRead meets target', () {
        final g = makeGoal(type: GoalType.minutesPerDay, target: 30);
        expect(g.isAchieved(versesRead: 0, minutesRead: 30), isTrue);
        expect(g.isAchieved(versesRead: 0, minutesRead: 60), isTrue);
      });

      test('returns false when minutesRead below target', () {
        final g = makeGoal(type: GoalType.minutesPerDay, target: 30);
        expect(g.isAchieved(versesRead: 0, minutesRead: 29), isFalse);
      });
    });

    group('equality', () {
      test('same values are equal', () {
        expect(makeGoal(), equals(makeGoal()));
        expect(makeGoal().hashCode, equals(makeGoal().hashCode));
      });

      test('different target is not equal', () {
        expect(makeGoal(target: 85), isNot(equals(makeGoal(target: 100))));
      });

      test('different type is not equal', () {
        expect(
          makeGoal(type: GoalType.versesPerDay),
          isNot(equals(makeGoal(type: GoalType.chaptersPerDay))),
        );
      });
    });

    test('toString contains type and target', () {
      final g = makeGoal(type: GoalType.versesPerDay, target: 85);
      expect(g.toString(), contains('versesPerDay'));
      expect(g.toString(), contains('85'));
    });
  });
}
