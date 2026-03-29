import '../models/bible_book.dart';

/// Abstract interface for loading Bible content from a platform-specific source.
///
/// Each app provides its own implementation:
/// - Flutter app: loads from `rootBundle` (Flutter assets)
/// - Server app: loads from the filesystem
/// - Test: returns in-memory data
abstract class BibleAssetLoader {
  /// Load all [BibleBook] objects from the underlying data source.
  Future<List<BibleBook>> loadBooks();
}
