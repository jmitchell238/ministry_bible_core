import 'package:test/test.dart';
import 'package:ministry_bible_core/ministry_bible_core.dart';

void main() {
  group('GracePeriodHelper.getEffectiveDate', () {
    test('midnight (00:00) maps to previous day', () {
      final dt = DateTime(2026, 1, 2, 0, 0);
      final result = GracePeriodHelper.getEffectiveDate(dt);
      expect(result, equals(DateTime(2026, 1, 1)));
    });

    test('00:30 maps to previous day (in grace period)', () {
      final dt = DateTime(2026, 1, 2, 0, 30);
      final result = GracePeriodHelper.getEffectiveDate(dt);
      expect(result, equals(DateTime(2026, 1, 1)));
    });

    test('00:59 maps to previous day (still in grace period)', () {
      final dt = DateTime(2026, 1, 2, 0, 59, 59);
      final result = GracePeriodHelper.getEffectiveDate(dt);
      expect(result, equals(DateTime(2026, 1, 1)));
    });

    test('01:00 maps to same day (after grace period)', () {
      final dt = DateTime(2026, 1, 2, 1, 0);
      final result = GracePeriodHelper.getEffectiveDate(dt);
      expect(result, equals(DateTime(2026, 1, 2)));
    });

    test('noon maps to same day', () {
      final dt = DateTime(2026, 1, 2, 12, 0);
      final result = GracePeriodHelper.getEffectiveDate(dt);
      expect(result, equals(DateTime(2026, 1, 2)));
    });

    test('23:50 maps to same day', () {
      final dt = DateTime(2026, 1, 2, 23, 50);
      final result = GracePeriodHelper.getEffectiveDate(dt);
      expect(result, equals(DateTime(2026, 1, 2)));
    });

    test('result is always midnight-normalized (no time component)', () {
      final dt = DateTime(2026, 6, 15, 14, 35, 22);
      final result = GracePeriodHelper.getEffectiveDate(dt);
      expect(result.hour, equals(0));
      expect(result.minute, equals(0));
      expect(result.second, equals(0));
      expect(result.millisecond, equals(0));
    });

    test('grace period crossing month boundary maps to last day of previous month', () {
      final dt = DateTime(2026, 2, 1, 0, 30); // Feb 1 at 00:30
      final result = GracePeriodHelper.getEffectiveDate(dt);
      expect(result, equals(DateTime(2026, 1, 31)));
    });

    test('grace period crossing year boundary maps to last day of previous year', () {
      final dt = DateTime(2026, 1, 1, 0, 30); // Jan 1 at 00:30
      final result = GracePeriodHelper.getEffectiveDate(dt);
      expect(result, equals(DateTime(2025, 12, 31)));
    });
  });

  group('GracePeriodHelper constants', () {
    test('gracePeriodHour is 1', () {
      expect(GracePeriodHelper.gracePeriodHour, equals(1));
    });
  });
}
