import '../models/reading_progress_entry.dart';

/// Abstract contract for persisting Bible reading progress.
///
/// Each app provides its own implementation (Hive, JSON file, SQL, HTTP).
abstract class ReadingProgressRepository {
  /// Record that [verseId] was read at [readAt].
  Future<void> markVerseRead(String verseId, {required DateTime readAt});

  /// Remove the read record for [verseId].
  Future<void> markVerseUnread(String verseId);

  /// Whether [verseId] has been read at least once.
  Future<bool> isVerseRead(String verseId);

  /// All progress entries across every book.
  Future<List<ReadingProgressEntry>> allProgress();

  /// Progress entries for a single book, identified by its canonical name.
  Future<List<ReadingProgressEntry>> progressForBook(String bookName);

  /// Remove all progress records.
  Future<void> clear();
}
