import '../models/saved_search.dart';

/// Persists [SavedSearch] entries across sessions.
abstract interface class SearchHistoryRepository {
  Future<List<SavedSearch>> getAll();
  Future<void> add(SavedSearch search);
  Future<void> update(SavedSearch search);
  Future<void> delete(String id);
}
