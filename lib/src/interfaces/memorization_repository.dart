import '../models/memorization_entry.dart';

/// Abstract contract for persisting verse memorization entries.
abstract class MemorizationRepository {
  Future<List<MemorizationEntry>> getAll();

  /// Returns the entry for [verseId], or null if not being memorized.
  Future<MemorizationEntry?> getForVerse(String verseId);

  /// Returns all entries with the given [status].
  Future<List<MemorizationEntry>> getByStatus(MemorizationStatus status);

  /// Returns entries whose [MemorizationEntry.nextReviewDate] is on or before [asOf].
  Future<List<MemorizationEntry>> getDueForReview(DateTime asOf);

  Future<void> add(MemorizationEntry entry);
  Future<void> update(MemorizationEntry entry);
  Future<void> delete(String id);
}
