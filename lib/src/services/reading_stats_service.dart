import '../interfaces/reading_progress_repository.dart';
import '../services/bible_content_service.dart';
import '../services/grace_period_helper.dart';
import '../utils/verse_id.dart';

/// Derives reading statistics from a [BibleContentService] and a
/// [ReadingProgressRepository].
///
/// All methods are pure reads — nothing is mutated.
class ReadingStatsService {
  ReadingStatsService(this._content, this._progress);

  final BibleContentService _content;
  final ReadingProgressRepository _progress;

  /// Fraction of the entire Bible that has been read (0.0–1.0).
  Future<double> percentBibleRead() async {
    final total = _content.getTotalVerseCount();
    if (total == 0) return 0.0;
    final read = await _readVerseIds();
    return read.length / total;
  }

  /// Fraction of the Old Testament that has been read (0.0–1.0).
  Future<double> percentOTRead() async =>
      _percentTestamentRead('OT');

  /// Fraction of the New Testament that has been read (0.0–1.0).
  Future<double> percentNTRead() async =>
      _percentTestamentRead('NT');

  /// Book names (canonical) for every book where all verses have been read.
  Future<List<String>> booksFullyRead() async {
    final read = await _readVerseIds();
    final result = <String>[];
    for (final book in _content.getAllBooks()) {
      final allVersesInBook = book.chapters
          .expand((c) => c.verses)
          .map((v) => v.id)
          .toSet();
      if (allVersesInBook.isNotEmpty && read.containsAll(allVersesInBook)) {
        result.add(book.name);
      }
    }
    return result;
  }

  /// Chapter IDs (e.g. "Genesis-1") for every chapter where all verses have
  /// been read.
  Future<List<String>> chaptersCompleted() async {
    final read = await _readVerseIds();
    final result = <String>[];
    for (final book in _content.getAllBooks()) {
      for (final chapter in book.chapters) {
        final verseIds = chapter.verses.map((v) => v.id).toSet();
        if (verseIds.isNotEmpty && read.containsAll(verseIds)) {
          result.add(VerseId.chapterId(book.name, chapter.number));
        }
      }
    }
    return result;
  }

  /// Average verses read per active reading day.
  ///
  /// Returns 0.0 if no progress has been recorded.
  Future<double> averageVersesPerDay() async {
    final entries = await _progress.allProgress();
    if (entries.isEmpty) return 0.0;
    final days = entries
        .map((e) => GracePeriodHelper.getEffectiveDate(e.readAt))
        .toSet();
    return entries.length / days.length;
  }

  /// The longest gap between consecutive reading days, or null if fewer than
  /// two distinct reading days exist.
  Future<Duration?> longestGap() async {
    final entries = await _progress.allProgress();
    final days = entries
        .map((e) => GracePeriodHelper.getEffectiveDate(e.readAt))
        .toSet()
        .toList()
      ..sort();
    if (days.length < 2) return null;
    Duration max = Duration.zero;
    for (var i = 1; i < days.length; i++) {
      final gap = days[i].difference(days[i - 1]);
      if (gap > max) max = gap;
    }
    return max;
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<Set<String>> _readVerseIds() async {
    final entries = await _progress.allProgress();
    return entries.map((e) => e.verseId).toSet();
  }

  Future<double> _percentTestamentRead(String testament) async {
    final total = _content
        .getAllBooks()
        .where((b) => b.testament == testament)
        .expand((b) => b.chapters)
        .expand((c) => c.verses)
        .length;
    if (total == 0) return 0.0;
    final read = await _readVerseIds();
    final testamentBooks = _content
        .getAllBooks()
        .where((b) => b.testament == testament)
        .toList();
    final verseIds = testamentBooks
        .expand((b) => b.chapters)
        .expand((c) => c.verses)
        .map((v) => v.id)
        .toSet();
    final readCount = read.intersection(verseIds).length;
    return readCount / total;
  }
}
