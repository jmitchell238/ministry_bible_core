import '../models/reading_streak.dart';

/// Abstract contract for persisting streak state.
abstract class StreakRepository {
  /// Load the current streak record.
  Future<ReadingStreak> load();

  /// Persist [streak] as the current state.
  Future<void> save(ReadingStreak streak);
}
