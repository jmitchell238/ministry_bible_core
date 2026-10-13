# ministry_bible_core

A pure Dart package with the Bible reading logic meant to be shared between Ministrative and Bible Reading Tracker: Bible text and search, reading plans, streaks, notes, bookmarks, scripture detection and more. It has no Flutter or Hive dependency, so it runs anywhere Dart does. Each app supplies its own storage by implementing the package's repository interfaces.

Neither app depends on it yet.

Copyright (c) 2026 James Mitchell / 238 Apps. All rights reserved. This is proprietary software: it may not be used, copied, modified, distributed or forked without written permission. See [LICENSE](LICENSE).

## Installation

Add as a local path dependency in your app's `pubspec.yaml`:

```yaml
dependencies:
  ministry_bible_core:
    path: ../ministry_bible_core
```

Then import the package:

```dart
import 'package:ministry_bible_core/ministry_bible_core.dart';
```

## What's in the package

| Category | Classes |
|---|---|
| Constants | `BibleBooks`, `BibleMeta` |
| Models | `BibleVerse`, `BibleChapter`, `BibleBook`, `ScripturePassage`, `SearchResult`, `Bookmark`, `BookmarkCollection`, `ReadingNote` (`NoteType`), `ReadingStreak`, `ReadingProgressEntry`, `SermonOutline` (`SermonPoint`, `SermonStatus`), `PassageCollection`, `ReadingGoal` (`GoalType`), `ReadingSession`, `MemorizationEntry` (`MemorizationStatus`), `CrossReference` (`CrossReferenceType`), `SavedSearch`, `PrayerRequest` (`PrayerStatus`), `StudyNote`, `ReadingPlanState` (`ReadingPlanEvent`, `ReadingPlanEventType`), `VerseCard` |
| Services | `BibleContentService`, `BibleSearchService`, `ReadingPlanService`, `ReadingStatsService`, `TagService`, `StreakCalculator`, `GracePeriodHelper`, `ScriptureAutoDetector`, `VerseOfTheDayService`, `VerseCardFormatter` |
| Repository interfaces | `BibleAssetLoader`, `ReadingProgressRepository`, `BookmarkRepository`, `ReadingNoteRepository`, `StreakRepository`, `SermonRepository`, `PassageCollectionRepository`, `ReadingSessionRepository`, `MemorizationRepository`, `CrossReferenceRepository`, `SearchHistoryRepository`, `PrayerRepository`, `StudyNoteRepository` |
| Utils | `VerseId` |

All models are immutable plain Dart classes with `fromJson` / `toJson`, `copyWith`, `==`, `hashCode`, and `toString`. No `@freezed`, no Hive annotations — storage is handled entirely by each app's repository implementations.

## Quick Start

```dart
// 1. Provide a platform-specific asset loader (see BibleAssetLoader below)
final service = BibleContentService(MyAssetLoader());
await service.load();

// 2. Look up a verse
final text = service.verseText('John', 3, 16);
print(text); // "For God so loved the world..."

// 3. Search
final search = BibleSearchService(service);
final results = search.searchVerses('God so loved');
for (final r in results) {
  print('${r.verse.id}: ${r.verse.text}');
}

// 4. Detect scripture references in any string
final refs = ScriptureAutoDetector.detect('See John 3:16 and Gen 1:1');
for (final ref in refs) {
  print('${ref.book} ${ref.chapter}:${ref.verseStart}');
}

// 5. Encode / decode verse IDs
final id = VerseId.encode('Song of Solomon', 3, 2); // "SongofSolomon-3-2"
final decoded = VerseId.decode(id);                 // (book: "Song of Solomon", chapter: 3, verse: 2)
```

## Docs

- [docs/API.md](docs/API.md): every constant, model, service and repository interface, with examples
- [docs/INTEGRATING.md](docs/INTEGRATING.md): wiring the package into an app
- [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md): tests and coverage
- [CHANGELOG.md](CHANGELOG.md)
