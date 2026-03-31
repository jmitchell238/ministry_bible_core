import 'package:test/test.dart';
import 'package:ministry_bible_core/ministry_bible_core.dart';
import '../helpers/test_bible_fixture.dart';
import '../helpers/in_memory_repositories.dart';

void main() {
  late BibleContentService content;
  late InMemoryReadingProgressRepository progress;
  late ReadingStatsService stats;

  setUp(() async {
    content = await buildLoadedService();
    progress = InMemoryReadingProgressRepository();
    stats = ReadingStatsService(content, progress);
  });

  // Test bible has: Genesis (OT, 5 verses), John (NT, 4 verses) = 9 total

  group('percentBibleRead', () {
    test('returns 0.0 when nothing read', () async {
      expect(await stats.percentBibleRead(), equals(0.0));
    });

    test('returns 1.0 when all verses read', () async {
      for (final book in content.getAllBooks()) {
        for (final chapter in book.chapters) {
          for (final verse in chapter.verses) {
            await progress.markVerseRead(verse.id,
                readAt: DateTime(2026, 1, 1));
          }
        }
      }
      expect(await stats.percentBibleRead(), equals(1.0));
    });

    test('returns partial fraction', () async {
      // Read Genesis 1:1 only (1 of 9 verses in fixture)
      await progress.markVerseRead('Genesis-1-1', readAt: DateTime(2026, 1, 1));
      final pct = await stats.percentBibleRead();
      expect(pct, greaterThan(0.0));
      expect(pct, lessThan(1.0));
    });
  });

  group('percentOTRead', () {
    test('returns 0.0 when nothing read', () async {
      expect(await stats.percentOTRead(), equals(0.0));
    });

    test('returns 1.0 when all OT verses read', () async {
      final genesis = content.getBook(1);
      for (final chapter in genesis.chapters) {
        for (final verse in chapter.verses) {
          await progress.markVerseRead(verse.id, readAt: DateTime(2026, 1, 1));
        }
      }
      expect(await stats.percentOTRead(), equals(1.0));
    });

    test('NT reads do not count toward OT percent', () async {
      await progress.markVerseRead('John-3-16', readAt: DateTime(2026, 1, 1));
      expect(await stats.percentOTRead(), equals(0.0));
    });
  });

  group('percentNTRead', () {
    test('returns 0.0 when nothing read', () async {
      expect(await stats.percentNTRead(), equals(0.0));
    });

    test('returns 1.0 when all NT verses read', () async {
      final john = content.getBook(43);
      for (final chapter in john.chapters) {
        for (final verse in chapter.verses) {
          await progress.markVerseRead(verse.id, readAt: DateTime(2026, 1, 1));
        }
      }
      expect(await stats.percentNTRead(), equals(1.0));
    });
  });

  group('booksFullyRead', () {
    test('returns empty when nothing read', () async {
      expect(await stats.booksFullyRead(), isEmpty);
    });

    test('returns book name when all verses in that book are read', () async {
      final genesis = content.getBook(1);
      for (final chapter in genesis.chapters) {
        for (final verse in chapter.verses) {
          await progress.markVerseRead(verse.id, readAt: DateTime(2026, 1, 1));
        }
      }
      expect(await stats.booksFullyRead(), contains('Genesis'));
    });

    test('does not include partially-read books', () async {
      await progress.markVerseRead('Genesis-1-1', readAt: DateTime(2026, 1, 1));
      expect(await stats.booksFullyRead(), isEmpty);
    });
  });

  group('chaptersCompleted', () {
    test('returns empty when nothing read', () async {
      expect(await stats.chaptersCompleted(), isEmpty);
    });

    test('returns chapter id when all verses in that chapter are read', () async {
      // Genesis chapter 2 has 2 verses in fixture
      await progress.markVerseRead('Genesis-2-1', readAt: DateTime(2026, 1, 1));
      await progress.markVerseRead('Genesis-2-2', readAt: DateTime(2026, 1, 1));
      expect(await stats.chaptersCompleted(), contains('Genesis-2'));
    });

    test('does not include partially-read chapters', () async {
      await progress.markVerseRead('Genesis-1-1', readAt: DateTime(2026, 1, 1));
      expect(await stats.chaptersCompleted(), isNot(contains('Genesis-1')));
    });
  });

  group('averageVersesPerDay', () {
    test('returns 0.0 when no progress', () async {
      expect(await stats.averageVersesPerDay(), equals(0.0));
    });

    test('returns verse count when all read on same day', () async {
      await progress.markVerseRead('Genesis-1-1', readAt: DateTime(2026, 1, 1, 10));
      await progress.markVerseRead('Genesis-1-2', readAt: DateTime(2026, 1, 1, 11));
      await progress.markVerseRead('Genesis-1-3', readAt: DateTime(2026, 1, 1, 12));
      expect(await stats.averageVersesPerDay(), equals(3.0));
    });

    test('averages across multiple days', () async {
      await progress.markVerseRead('Genesis-1-1', readAt: DateTime(2026, 1, 1, 10));
      await progress.markVerseRead('Genesis-1-2', readAt: DateTime(2026, 1, 2, 10));
      expect(await stats.averageVersesPerDay(), equals(1.0));
    });
  });

  group('longestGap', () {
    test('returns null when fewer than two reading days', () async {
      expect(await stats.longestGap(), isNull);
    });

    test('returns null when only one day has reads', () async {
      await progress.markVerseRead('Genesis-1-1', readAt: DateTime(2026, 1, 1));
      await progress.markVerseRead('Genesis-1-2', readAt: DateTime(2026, 1, 1));
      expect(await stats.longestGap(), isNull);
    });

    test('returns duration between two reading days', () async {
      await progress.markVerseRead('Genesis-1-1', readAt: DateTime(2026, 1, 1));
      await progress.markVerseRead('Genesis-1-2', readAt: DateTime(2026, 1, 5));
      final gap = await stats.longestGap();
      expect(gap, equals(const Duration(days: 4)));
    });

    test('returns largest gap among multiple days', () async {
      await progress.markVerseRead('Genesis-1-1', readAt: DateTime(2026, 1, 1));
      await progress.markVerseRead('Genesis-1-2', readAt: DateTime(2026, 1, 3));
      await progress.markVerseRead('Genesis-1-3', readAt: DateTime(2026, 1, 10));
      final gap = await stats.longestGap();
      expect(gap, equals(const Duration(days: 7)));
    });
  });
}
