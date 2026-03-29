import 'package:test/test.dart';
import 'package:ministry_bible_core/ministry_bible_core.dart';
import '../helpers/test_bible_fixture.dart';

void main() {
  late ReadingPlanService planService;
  late BibleContentService content;

  setUp(() async {
    content = await buildLoadedService();
    planService = ReadingPlanService(content);
  });

  group('ReadingPlanService.getTodaysAssignment', () {
    test('day 1 returns first N verses of sequential plan', () {
      final assignment = planService.getTodaysAssignment(
        kPlanSequential,
        DateTime.now(),
        1,
      );
      expect(assignment, isNotEmpty);
      // First verse should be from Genesis chapter 1 verse 1
      expect(assignment.first, equals('Genesis-1-1'));
    });

    test('returns empty list when plan is complete', () {
      final assignment = planService.getTodaysAssignment(
        kPlanSequential,
        DateTime.now(),
        99999, // far beyond plan length
      );
      expect(assignment, isEmpty);
    });
  });

  group('ReadingPlanService.getCurrentDayNumber', () {
    test('start date today is day 1', () {
      final dayNum = planService.getCurrentDayNumber(DateTime.now());
      expect(dayNum, equals(1));
    });

    test('start date yesterday is day 2', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final dayNum = planService.getCurrentDayNumber(yesterday);
      expect(dayNum, equals(2));
    });
  });

  group('ReadingPlanService.getPlanProgress', () {
    test('no verses read returns 0.0', () {
      final progress = planService.getPlanProgress(
        kPlanSequential,
        DateTime.now().subtract(const Duration(days: 1)), // started yesterday
        [],
      );
      expect(progress, equals(0.0));
    });

    test('far in future start date returns 0.0 (day 0)', () {
      final progress = planService.getPlanProgress(
        kPlanSequential,
        DateTime.now(),
        [],
      );
      expect(progress, equals(0.0));
    });
  });

  group('ReadingPlanService.isTodaysAssignmentComplete', () {
    test('empty read list returns false', () {
      final complete = planService.isTodaysAssignmentComplete(
        kPlanSequential,
        DateTime.now(),
        [],
      );
      expect(complete, isFalse);
    });

    test('all assigned verses read returns true', () {
      // Get day 1 assignment
      final assignment = planService.getTodaysAssignment(
        kPlanSequential,
        DateTime.now(),
        1,
      );
      final complete = planService.isTodaysAssignmentComplete(
        kPlanSequential,
        DateTime.now(),
        assignment, // pass all assigned verses as "read"
      );
      expect(complete, isTrue);
    });
  });

  group('Plan types generate plans', () {
    test('sequential plan starts with Genesis-1-1', () {
      final day1 = planService.getTodaysAssignment(kPlanSequential, DateTime.now(), 1);
      expect(day1.first, equals('Genesis-1-1'));
    });

    test('alternating plan is non-empty', () {
      final day1 = planService.getTodaysAssignment(kPlanAlternating, DateTime.now(), 1);
      expect(day1, isNotEmpty);
    });

    test('category_mix plan is non-empty', () {
      final day1 = planService.getTodaysAssignment(kPlanCategoryMix, DateTime.now(), 1);
      expect(day1, isNotEmpty);
    });

    test('verse_count plan is non-empty', () {
      final day1 = planService.getTodaysAssignment(kPlanVerseCount, DateTime.now(), 1);
      expect(day1, isNotEmpty);
    });

    test('word_count plan is non-empty', () {
      final day1 = planService.getTodaysAssignment(kPlanWordCount, DateTime.now(), 1);
      expect(day1, isNotEmpty);
    });

    test('unknown plan type falls back to sequential', () {
      final day1 = planService.getTodaysAssignment('unknown_plan', DateTime.now(), 1);
      expect(day1.first, equals('Genesis-1-1'));
    });
  });

  group('Plan caching', () {
    test('clearCache resets cached plans', () {
      // Warm up the cache
      planService.getTodaysAssignment(kPlanSequential, DateTime.now(), 1);
      planService.clearCache();
      // Should regenerate without error
      final day1 = planService.getTodaysAssignment(kPlanSequential, DateTime.now(), 1);
      expect(day1, isNotEmpty);
    });
  });
}
