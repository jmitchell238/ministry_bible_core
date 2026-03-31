import '../models/reading_streak.dart';
import 'grace_period_helper.dart';

/// Pure, stateless streak calculator.
///
/// All methods are static and return new [ReadingStreak] instances —
/// nothing is mutated and there are no async operations or storage concerns.
abstract final class StreakCalculator {

  /// Apply a reading event to the current streak state and return a new [ReadingStreak].
  ///
  /// [eventDate] is normalized via [GracePeriodHelper.getEffectiveDate] before
  /// comparison, so readings between 12:00am–1:00am count for the previous day.
  ///
  /// Throws [ArgumentError] if [eventDate] (after normalization) is in the future.
  static ReadingStreak recordActivity(
    ReadingStreak current,
    DateTime eventDate, {
    required bool hasAction,
    required bool goalAchieved,
  }) {
    final normalized = GracePeriodHelper.getEffectiveDate(eventDate);
    final today = GracePeriodHelper.getCurrentTrackingDay();

    if (normalized.isAfter(today)) {
      throw ArgumentError('Cannot record progress for future dates');
    }

    int currentActionStreak = current.currentActionStreak;
    int highestActionStreak = current.highestActionStreak;
    DateTime? lastActionDate = current.lastActionDate;

    int currentGoalStreak = current.currentGoalStreak;
    int highestGoalStreak = current.highestGoalStreak;
    DateTime? lastGoalDate = current.lastGoalDate;

    // Update action streak
    if (hasAction) {
      if (_isConsecutiveDay(lastActionDate, normalized)) {
        currentActionStreak++;
      } else if (!_isSameDay(lastActionDate, normalized)) {
        currentActionStreak = 1;
      }
      if (currentActionStreak > highestActionStreak) {
        highestActionStreak = currentActionStreak;
      }
      lastActionDate = normalized;
    }

    // Update goal streak
    if (goalAchieved) {
      if (_isConsecutiveDay(lastGoalDate, normalized)) {
        currentGoalStreak++;
      } else if (!_isSameDay(lastGoalDate, normalized)) {
        currentGoalStreak = 1;
      }
      if (currentGoalStreak > highestGoalStreak) {
        highestGoalStreak = currentGoalStreak;
      }
      lastGoalDate = normalized;
    } else {
      // Goal not achieved — reset current goal streak
      currentGoalStreak = 0;
    }

    return current.copyWith(
      currentActionStreak: currentActionStreak,
      highestActionStreak: highestActionStreak,
      currentGoalStreak: currentGoalStreak,
      highestGoalStreak: highestGoalStreak,
      lastActionDate: lastActionDate,
      lastGoalDate: lastGoalDate,
      modifiedAt: DateTime.now(),
    );
  }

  /// Rebuild a [ReadingStreak] from scratch given a sorted list of history records.
  ///
  /// [records] must be sorted in ascending date order (earliest first).
  /// Each record contains the date, number of verses read, and whether the goal
  /// was achieved for that day.
  static ReadingStreak recalculateFromHistory(
    List<({DateTime date, int versesRead, bool goalAchieved})> records,
  ) {
    if (records.isEmpty) return ReadingStreak.empty();

    // Sort defensively
    final sorted = List.of(records)
      ..sort((a, b) => a.date.compareTo(b.date));

    int actionStreak = 0;
    int highestActionStreak = 0;
    DateTime? lastActionDate;

    int goalStreak = 0;
    int highestGoalStreak = 0;
    DateTime? lastGoalDate;

    for (final record in sorted) {
      final date = GracePeriodHelper.getEffectiveDate(record.date);

      if (record.versesRead > 0) {
        if (_isConsecutiveDay(lastActionDate, date)) {
          actionStreak++;
        } else {
          actionStreak = 1;
        }
        if (actionStreak > highestActionStreak) highestActionStreak = actionStreak;
        lastActionDate = date;
      }

      if (record.goalAchieved) {
        if (_isConsecutiveDay(lastGoalDate, date)) {
          goalStreak++;
        } else {
          goalStreak = 1;
        }
        if (goalStreak > highestGoalStreak) highestGoalStreak = goalStreak;
        lastGoalDate = date;
      } else {
        goalStreak = 0;
      }
    }

    // If the last activity was more than one day ago (not today or yesterday),
    // the current streak has been broken.
    final today = GracePeriodHelper.getCurrentTrackingDay();
    final yesterday = today.subtract(const Duration(days: 1));

    if (lastActionDate != null &&
        lastActionDate != today &&
        lastActionDate != yesterday) {
      actionStreak = 0;
    }

    if (lastGoalDate != null &&
        lastGoalDate != today &&
        lastGoalDate != yesterday) {
      goalStreak = 0;
    }

    final now = DateTime.now();
    return ReadingStreak(
      currentActionStreak: actionStreak,
      highestActionStreak: highestActionStreak,
      currentGoalStreak: goalStreak,
      highestGoalStreak: highestGoalStreak,
      lastActionDate: lastActionDate,
      lastGoalDate: lastGoalDate,
      createdAt: now,
      modifiedAt: now,
    );
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  /// Returns true if [nextDate] is exactly one day after [lastDate].
  static bool _isConsecutiveDay(DateTime? lastDate, DateTime nextDate) {
    if (lastDate == null) return false;
    return lastDate.add(const Duration(days: 1)) == nextDate;
  }

  /// Returns true if [date1] and [date2] represent the same calendar day.
  static bool _isSameDay(DateTime? date1, DateTime date2) {
    if (date1 == null) return false;
    return date1 == date2;
  }
}
