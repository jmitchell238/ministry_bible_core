# Integrating into an app

## Step 1 — Add the dependency

```yaml
# pubspec.yaml
dependencies:
  ministry_bible_core:
    path: ../ministry_bible_core
```

## Step 2 — Implement BibleAssetLoader

Each app provides one implementation that knows where its Bible JSON lives (see the [BibleAssetLoader](API.md#bibleassetloader) examples).

## Step 3 — Implement the repository interfaces

Each app provides concrete storage implementations. A Flutter + Hive app would create:

- `HiveReadingProgressRepository implements ReadingProgressRepository`
- `HiveBookmarkRepository implements BookmarkRepository`
- `HiveReadingNoteRepository implements ReadingNoteRepository`
- `HiveStreakRepository implements StreakRepository`
- `HiveSermonRepository implements SermonRepository`
- `HiveMemorizationRepository implements MemorizationRepository`
- `HivePrayerRepository implements PrayerRepository`
- `HiveStudyNoteRepository implements StudyNoteRepository`

A JSON-file-based app (e.g. MinistryBase) would create `Json*Repository` classes using the same interfaces.

## Step 4 — Wire it up

```dart
// App startup
final loader  = FlutterBibleAssetLoader();
final content = BibleContentService(loader);
await content.load();

final search  = BibleSearchService(content);
final plans   = ReadingPlanService(content);
final stats   = ReadingStatsService(content, progressRepo);

// Repository implementations (app-specific)
final progress = HiveReadingProgressRepository();
final streaks  = HiveStreakRepository();
final sermons  = HiveSermonRepository();

// Record a reading session
final session = ReadingSession.create(verseIds: ['John-3-16']);
await progress.markVerseRead('John-3-16', readAt: DateTime.now());

// Update streak
ReadingStreak streak = await streaks.load();
streak = StreakCalculator.recordActivity(
  streak,
  DateTime.now(),
  hasAction: true,
  goalAchieved: true,
);
await streaks.save(streak);

// Check Bible coverage
double pct = await stats.percentBibleRead();
print('${(pct * 100).toStringAsFixed(1)}% of the Bible read');

// Verse of the day
final votd  = VerseOfTheDayService(content);
final verse = await votd.getVerse(DateTime.now());
final card  = VerseCardFormatter.format(
  verse: verse!,
  bookName: 'John',
  translationCode: 'KJV',
);
print(card.shareText);
```
