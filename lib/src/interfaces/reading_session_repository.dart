import '../models/reading_session.dart';

/// Abstract contract for persisting reading sessions.
abstract class ReadingSessionRepository {
  Future<List<ReadingSession>> getAll();

  /// Returns sessions that started on [date] (by calendar day).
  Future<List<ReadingSession>> getForDate(DateTime date);

  /// Returns the [count] most recent sessions, ordered newest first.
  Future<List<ReadingSession>> getRecent(int count);

  Future<void> add(ReadingSession session);
  Future<void> update(ReadingSession session);
  Future<void> delete(String id);
}
