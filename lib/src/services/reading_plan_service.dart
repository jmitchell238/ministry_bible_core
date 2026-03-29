import 'bible_content_service.dart';

/// Plan type constants for [ReadingPlanService].
const kPlanSequential = 'sequential';
const kPlanAlternating = 'alternating';
const kPlanChronological = 'chronological';
const kPlanCategoryMix = 'category_mix';
const kPlanVerseCount = 'verse_count';
const kPlanWordCount = 'word_count';

/// Generates and manages Bible reading plan assignments.
///
/// Plans are generated once and cached in memory. The service operates on the
/// already-loaded [BibleContentService] — no I/O is performed here.
class ReadingPlanService {
  final BibleContentService _content;
  final Map<String, List<String>> _planCache = {};

  ReadingPlanService(this._content);

  /// Verse IDs assigned to [dayNumber] (1-based) for [planType].
  ///
  /// Returns an empty list if the plan is complete.
  List<String> getTodaysAssignment(
    String planType,
    DateTime startDate,
    int dayNumber,
  ) {
    final plan = _getFullPlan(planType);
    final versesPerDay = _getVersesPerDayForPlan(planType);
    final startIndex = (dayNumber - 1) * versesPerDay;

    if (startIndex >= plan.length) return [];

    final endIndex = startIndex + versesPerDay;
    return plan.sublist(startIndex, endIndex > plan.length ? plan.length : endIndex);
  }

  /// Current day number (1 = start date) based on [startDate].
  int getCurrentDayNumber(DateTime startDate) {
    final difference = DateTime.now().difference(startDate).inDays;
    return difference + 1;
  }

  /// Fractional progress (0.0–1.0) through the plan up to today.
  double getPlanProgress(
    String planType,
    DateTime startDate,
    List<String> readVerses,
  ) {
    final dayNumber = getCurrentDayNumber(startDate);
    final plan = _getFullPlan(planType);
    final versesPerDay = _getVersesPerDayForPlan(planType);
    final targetIndex = (dayNumber - 1) * versesPerDay;

    if (targetIndex >= plan.length) return 1.0;

    int completed = 0;
    for (int i = 0; i < targetIndex && i < plan.length; i++) {
      if (readVerses.contains(plan[i])) completed++;
    }

    return targetIndex > 0 ? completed / targetIndex : 0.0;
  }

  /// Whether today's assignment has been fully read.
  bool isTodaysAssignmentComplete(
    String planType,
    DateTime startDate,
    List<String> readVerses,
  ) {
    final day = getCurrentDayNumber(startDate);
    final assignment = getTodaysAssignment(planType, startDate, day);
    return assignment.every(readVerses.contains);
  }

  /// Clear the plan cache (useful when switching plan types).
  void clearCache() => _planCache.clear();

  // ── Plan generation ────────────────────────────────────────────────────────

  List<String> _getFullPlan(String planType) {
    if (_planCache.containsKey(planType)) return _planCache[planType]!;

    final plan = switch (planType) {
      kPlanAlternating => _generateAlternatingPlan(),
      kPlanChronological => _generateChronologicalPlan(),
      kPlanCategoryMix => _generateCategoryMixPlan(),
      kPlanVerseCount || kPlanWordCount => _generateSequentialPlan(),
      _ => _generateSequentialPlan(),
    };

    _planCache[planType] = plan;
    return plan;
  }

  int _getVersesPerDayForPlan(String planType) {
    if (planType == kPlanVerseCount || planType == kPlanWordCount) {
      return 85; // ≈ 31,102 ÷ 365
    }
    return (_content.getTotalVerseCount() / 365).ceil();
  }

  List<String> _generateSequentialPlan() {
    final plan = <String>[];
    for (final book in _content.getAllBooks()) {
      for (final chapter in book.chapters) {
        for (final verse in chapter.verses) {
          plan.add(verse.id);
        }
      }
    }
    return plan;
  }

  List<String> _generateAlternatingPlan() {
    final books = _content.getAllBooks();
    final otBooks = books.where((b) => b.testament == 'OT').toList();
    final ntBooks = books.where((b) => b.testament == 'NT').toList();

    final plan = <String>[];
    int ntIndex = 0;

    for (int otIndex = 0; otIndex < otBooks.length || ntIndex < ntBooks.length;) {
      if (otIndex < otBooks.length) {
        final otBook = otBooks[otIndex];
        for (int ci = 0; ci < otBook.chapters.length; ci++) {
          for (final verse in otBook.chapters[ci].verses) {
            plan.add(verse.id);
          }
          if (ntIndex < ntBooks.length && ci % 2 == 0) {
            final ntBook = ntBooks[ntIndex];
            if (ntBook.chapters.isNotEmpty) {
              for (final verse in ntBook.chapters[0].verses) {
                plan.add(verse.id);
              }
              if (ntBook.chapters.length == 1) ntIndex++;
            }
          }
        }
        otIndex++;
      }
      if (otIndex >= otBooks.length && ntIndex < ntBooks.length) {
        final ntBook = ntBooks[ntIndex];
        for (final chapter in ntBook.chapters) {
          for (final verse in chapter.verses) {
            plan.add(verse.id);
          }
        }
        ntIndex++;
      }
    }
    return plan;
  }

  List<String> _generateChronologicalPlan() {
    const chronologicalOrder = [
      1, 18, 2, 3, 4, 5, 6, 7, 8, 9, 10, 13, 14, 15, 16, 17, 16, 17,
      19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34,
      35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50,
      51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66,
    ];

    final books = _content.getAllBooks();
    final plan = <String>[];

    for (final bookId in chronologicalOrder) {
      try {
        final book = books.firstWhere((b) => b.id == bookId);
        for (final chapter in book.chapters) {
          for (final verse in chapter.verses) {
            plan.add(verse.id);
          }
        }
      } catch (_) {
        // Skip missing books gracefully
      }
    }
    return plan;
  }

  List<String> _generateCategoryMixPlan() {
    final books = _content.getAllBooks();
    final categories = [
      books.where((b) => b.id >= 1 && b.id <= 5).toList(),
      books.where((b) => b.id >= 6 && b.id <= 17).toList(),
      books.where((b) => b.id >= 18 && b.id <= 22).toList(),
      books.where((b) => b.id >= 23 && b.id <= 27).toList(),
      books.where((b) => b.id >= 28 && b.id <= 39).toList(),
      books.where((b) => b.id >= 40 && b.id <= 43).toList(),
      books.where((b) => b.id == 44).toList(),
      books.where((b) => b.id >= 45 && b.id <= 65).toList(),
      books.where((b) => b.id == 66).toList(),
    ];

    final plan = <String>[];
    final maxChapters = categories
        .map((cat) => cat.fold(0, (sum, book) => sum + book.chapters.length))
        .reduce((a, b) => a > b ? a : b);

    for (int round = 0; round < maxChapters; round++) {
      for (final category in categories) {
        for (final book in category) {
          if (round < book.chapters.length) {
            for (final verse in book.chapters[round].verses) {
              plan.add(verse.id);
            }
          }
        }
      }
    }
    return plan;
  }
}
