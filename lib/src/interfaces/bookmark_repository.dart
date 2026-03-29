import '../models/bookmark.dart';
import '../models/bookmark_collection.dart';

/// Abstract contract for persisting bookmarks and bookmark collections.
abstract class BookmarkRepository {
  // ── Bookmarks ──────────────────────────────────────────────────────────────

  Future<List<Bookmark>> getAll();
  Future<List<Bookmark>> getForVerse(String verseId);
  Future<List<Bookmark>> getForCollection(String? collectionId);

  Future<void> add(Bookmark bookmark);
  Future<void> update(Bookmark bookmark);
  Future<void> delete(String id);

  Future<bool> isVerseBookmarked(String verseId);

  // ── Collections ────────────────────────────────────────────────────────────

  Future<List<BookmarkCollection>> getCollections();
  Future<void> addCollection(BookmarkCollection collection);
  Future<void> updateCollection(BookmarkCollection collection);
  Future<void> deleteCollection(String id);
}
