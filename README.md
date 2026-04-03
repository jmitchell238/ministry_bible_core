# ministry_bible_core

> **Copyright (c) 2026 James Mitchell / 238 Apps. All Rights Reserved.**
> This software is proprietary. No use, copying, modification, distribution, or forking is permitted without the explicit written permission of the author. See [LICENSE](LICENSE) for full terms.

A pure Dart package containing all shared Bible reading business logic for MinistryBase and the bible-reading-tracker mobile app. No Flutter SDK dependency, no Hive — just plain Dart that runs anywhere.

```
┌─────────────────────────────────────────────────────────────────┐
│                      ministry_bible_core                         │
│  models · services · constants · abstract repository interfaces  │
└─────────────────────────────────────────────────────────────────┘
         ▲                     ▲                    ▲
         │                     │                    │
  ┌──────────────┐  ┌──────────────────┐  ┌─────────────────────┐
  │ bible-reading│  │ sermon_tracker   │  │  Future: REST/gRPC  │
  │ -tracker     │  │ _flutter         │  │  Server / Web App   │
  │ (mobile)     │  │ (MinistryBase    │  │                     │
  │ Hive storage │  │  desktop)        │  │  DB / API storage   │
  └──────────────┘  └──────────────────┘  └─────────────────────┘
```

**514 tests, 100% line coverage (1456/1456 lines)**

---

## Table of Contents

- [Installation](#installation)
- [What's in the package](#whats-in-the-package)
- [Quick Start](#quick-start)
- [Constants](#constants)
  - [BibleBooks](#biblebooks)
  - [BibleMeta](#biblemeta)
- [Models](#models)
  - [BibleVerse / BibleChapter / BibleBook](#bibleverse--biblechapter--biblebook)
  - [ScripturePassage](#scripturepassage)
  - [SearchResult](#searchresult)
  - [Bookmark / BookmarkCollection](#bookmark--bookmarkcollection)
  - [ReadingNote](#readingnote)
  - [ReadingStreak](#readingstreak)
  - [ReadingProgressEntry](#readingprogressentry)
  - [SermonOutline](#sermonoutline)
  - [PassageCollection](#passagecollection)
  - [ReadingGoal](#readinggoal)
  - [ReadingSession](#readingsession)
  - [MemorizationEntry](#memorizationentry)
  - [CrossReference](#crossreference)
  - [SavedSearch](#savedsearch)
  - [PrayerRequest](#prayerrequest)
  - [StudyNote](#studynote)
  - [ReadingPlanState](#readingplanstate)
  - [VerseCard](#versecard)
- [Services](#services)
  - [BibleContentService](#biblecontentservice)
  - [BibleSearchService](#biblesearchservice)
  - [ReadingPlanService](#readingplanservice)
  - [ReadingStatsService](#readingstatsservice)
  - [TagService](#tagservice)
  - [StreakCalculator](#streakcalculator)
  - [GracePeriodHelper](#graceperiodhelper)
  - [ScriptureAutoDetector](#scriptureautodetector)
  - [VerseOfTheDayService](#verseofthedayservice)
  - [VerseCardFormatter](#verseCardFormatter)
- [Utils](#utils)
  - [VerseId](#verseid)
- [Abstract Repository Interfaces](#abstract-repository-interfaces)
  - [BibleAssetLoader](#bibleassetloader)
  - [ReadingProgressRepository](#readingprogressrepository)
  - [BookmarkRepository](#bookmarkrepository)
  - [ReadingNoteRepository](#readingnoterepository)
  - [StreakRepository](#streakrepository)
  - [SermonRepository](#sermonrepository)
  - [PassageCollectionRepository](#passagecollectionrepository)
  - [ReadingSessionRepository](#readingsessionrepository)
  - [MemorizationRepository](#memorizationrepository)
  - [CrossReferenceRepository](#crossreferencerepository)
  - [SearchHistoryRepository](#searchhistoryrepository)
  - [PrayerRepository](#prayerrepository)
  - [StudyNoteRepository](#studynoterepository)
- [Integrating into an App](#integrating-into-an-app)
- [Running the Tests](#running-the-tests)

---

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

---

## What's in the package

| Category | Classes |
|---|---|
| **Constants** | `BibleBooks`, `BibleMeta` |
| **Models** | `BibleVerse`, `BibleChapter`, `BibleBook`, `ScripturePassage`, `SearchResult`, `Bookmark`, `BookmarkCollection`, `ReadingNote` (`NoteType`), `ReadingStreak`, `ReadingProgressEntry`, `SermonOutline` (`SermonPoint`, `SermonStatus`), `PassageCollection`, `ReadingGoal` (`GoalType`), `ReadingSession`, `MemorizationEntry` (`MemorizationStatus`), `CrossReference` (`CrossReferenceType`), `SavedSearch`, `PrayerRequest` (`PrayerStatus`), `StudyNote`, `ReadingPlanState` (`ReadingPlanEvent`, `ReadingPlanEventType`), `VerseCard` |
| **Services** | `BibleContentService`, `BibleSearchService`, `ReadingPlanService`, `ReadingStatsService`, `TagService`, `StreakCalculator`, `GracePeriodHelper`, `ScriptureAutoDetector`, `VerseOfTheDayService`, `VerseCardFormatter` |
| **Repository interfaces** | `BibleAssetLoader`, `ReadingProgressRepository`, `BookmarkRepository`, `ReadingNoteRepository`, `StreakRepository`, `SermonRepository`, `PassageCollectionRepository`, `ReadingSessionRepository`, `MemorizationRepository`, `CrossReferenceRepository`, `SearchHistoryRepository`, `PrayerRepository`, `StudyNoteRepository` |
| **Utils** | `VerseId` |

All models are immutable plain Dart classes with `fromJson` / `toJson`, `copyWith`, `==`, `hashCode`, and `toString`. No `@freezed`, no Hive annotations — storage is handled entirely by each app's repository implementations.

---

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

---

## Constants

### BibleBooks

All 66 canonical book names in canonical order, with helpers. The `findBook` helper also recognizes common aliases and alternate spellings, so user input like `Psalm`, `Revelations`, `Song of Songs`, `1st John`, or `II Kings` will resolve to the correct canonical name.

```dart
// All 66 names in order
List<String> all = BibleBooks.all;

// Total count
int count = BibleBooks.count; // 66

// Exact-match lookup
bool valid   = BibleBooks.contains('Genesis'); // true
bool invalid = BibleBooks.contains('genesis'); // false (case-sensitive)

// Case-insensitive prefix and alias search — returns first match or null
String? book  = BibleBooks.findBook('gen');           // "Genesis"
String? book2 = BibleBooks.findBook('1 co');          // "1 Corinthians"
String? alias1 = BibleBooks.findBook('psalm');         // "Psalms"
String? alias2 = BibleBooks.findBook('Revelations');   // "Revelation"
String? alias3 = BibleBooks.findBook('Song of Songs'); // "Song of Solomon"
String? alias4 = BibleBooks.findBook('1st John');      // "1 John"
String? alias5 = BibleBooks.findBook('II Kings');      // "2 Kings"
String? notFound = BibleBooks.findBook('xyz');         // null
```

### BibleMeta

Testament groupings and chapter counts.

```dart
// Testament lists
List<String> ot = BibleMeta.oldTestament;  // 39 books
List<String> nt = BibleMeta.newTestament;  // 27 books

// Chapter count
int chapters = BibleMeta.chaptersIn('Psalms');  // 150
int unknown  = BibleMeta.chaptersIn('Fake');    // 0

// Testament checks
bool isOT = BibleMeta.isOldTestament('Genesis'); // true
bool isNT = BibleMeta.isNewTestament('John');     // true
```

---

## Models

All models follow the same pattern:

```dart
// Construction
final obj = MyModel(field: value, ...);

// Factory constructors
final obj = MyModel.fromJson(map);

// Serialization
Map<String, dynamic> json = obj.toJson();

// Non-destructive update
final updated = obj.copyWith(field: newValue);

// Value equality
obj1 == obj2; // true if all fields match
```

### BibleVerse / BibleChapter / BibleBook

The core content tree. A `BibleBook` contains a list of `BibleChapter`s; each chapter contains a list of `BibleVerse`s.

```dart
// BibleVerse fields
String id;          // "Genesis-1-1"
int bookId;
int chapter;
int number;
String text;
int wordCount;

// BibleChapter fields
int bookId;
int number;
List<BibleVerse> verses;

// BibleBook fields
int id;
String name;
String testament;   // "OT" or "NT"
List<BibleChapter> chapters;

// fromJson — BibleBook is the root-level deserializer
final book = BibleBook.fromJson(jsonMap);

// fromJson — BibleChapter and BibleVerse require context params
final chapter = BibleChapter.fromJson(map, bookId: 1, bookName: 'Genesis');
final verse   = BibleVerse.fromJson(map, bookId: 1, bookName: 'Genesis', chapter: 1);
// Note: fromJson for verse/chapter generates the id automatically from bookName+chapter+number
```

### ScripturePassage

A consecutive range of verses from a single chapter.

```dart
// Fields
String book;
int chapter;
int verseStart;
int verseEnd;
String translationCode;   // e.g. "KJV", "ASV"
List<String> verses;      // actual verse texts in order

// Computed getters
String reference; // "John 3:16 (KJV)" or "John 3:16-18 (KJV)"
String fullText;  // all verses joined with spaces

// Construction
final passage = ScripturePassage(
  book: 'John',
  chapter: 3,
  verseStart: 16,
  verseEnd: 18,
  translationCode: 'KJV',
  verses: ['For God so loved...', 'For God sent not...', 'He that believeth...'],
);

print(passage.reference); // "John 3:16-18 (KJV)"
print(passage.fullText);  // "For God so loved... For God sent not... He that believeth..."

// Serialization
final json     = passage.toJson();
final restored = ScripturePassage.fromJson(json);
```

### SearchResult

A verse match returned by `BibleSearchService.searchVerses`.

```dart
// Fields
BibleVerse verse;
String highlightedText;   // currently the full verse text (UI handles highlight rendering)
int matchPosition;        // character offset of match in normalized text

// Example
final result = SearchResult(
  verse: verse,
  highlightedText: verse.text,
  matchPosition: 4,
);
```

### Bookmark / BookmarkCollection

```dart
// Bookmark fields
String id;             // UUID
String verseId;        // "Genesis-1-1"
int bookId;
int chapter;
int verseNumber;
String note;           // empty string if no note
String? collectionId;  // null = uncategorized
DateTime createdAt;
int? color;            // ARGB integer

// Create with auto-generated UUID + timestamp
final bookmark = Bookmark.create(
  verseId: 'John-3-16',
  bookId: 43,
  chapter: 3,
  verseNumber: 16,
  note: 'Key verse',
  collectionId: 'col-favorites',
  color: 0xFF4CAF50,
);

// copyWith — clear nullable fields using flags
final updated = bookmark.copyWith(note: 'Updated note');
final cleared = bookmark.copyWith(clearCollectionId: true);

// BookmarkCollection fields
String id;
String name;
String? description;
DateTime createdAt;
int? color;

final collection = BookmarkCollection.create(name: 'Favorites', color: 0xFF2196F3);
```

### ReadingNote

A user note attached to a daily reading, a chapter, or a specific verse.

```dart
// NoteType enum
enum NoteType { daily, chapter, verse }

// ReadingNote fields
String id;
NoteType type;
String content;
DateTime createdAt;
DateTime updatedAt;
DateTime? date;      // for NoteType.daily
int? bookId;         // for NoteType.chapter
int? chapter;        // for NoteType.chapter
String? verseId;     // for NoteType.verse
List<String> tags;
bool isPinned;

// Create with auto-generated UUID
final dailyNote = ReadingNote.create(
  type: NoteType.daily,
  content: 'Great passage today.',
  date: DateTime.now(),
  tags: ['prayer'],
);

final verseNote = ReadingNote.create(
  type: NoteType.verse,
  content: 'Key cross-reference.',
  verseId: 'John-3-16',
  isPinned: true,
);

final chapterNote = ReadingNote.create(
  type: NoteType.chapter,
  content: 'Structure of Genesis 1.',
  bookId: 1,
  chapter: 1,
);

// Static key generators (for indexed lookups)
String dayKey     = ReadingNote.generateDailyKey(DateTime.now());  // "2026-03-28"
String chapterKey = ReadingNote.generateChapterKey(1, 3);           // "1-3"
String verseKey   = ReadingNote.generateVerseKey('Genesis-1-1');    // "Genesis-1-1"

// Display helpers
String ref = note.getDisplayReference();  // "Jan 15, 2026" / "Book 1, Chapter 3" / "John 3:16"
String fmt = ReadingNote.formatDate(DateTime(2026, 3, 28)); // "Mar 28, 2026"
```

### ReadingStreak

Immutable streak state. All fields are `final` — `StreakCalculator` returns a new instance rather than mutating.

```dart
// Fields
int currentActionStreak;   // consecutive days any reading happened
int highestActionStreak;
int currentGoalStreak;     // consecutive days the daily goal was met
int highestGoalStreak;
DateTime? lastActionDate;  // midnight-normalized
DateTime? lastGoalDate;    // midnight-normalized
DateTime createdAt;
DateTime modifiedAt;

// Start fresh
final streak = ReadingStreak.empty();

// Serialization
final json     = streak.toJson();
final restored = ReadingStreak.fromJson(json);

// copyWith — clear nullable date fields using flags
final updated = streak.copyWith(currentActionStreak: 5);
final cleared = streak.copyWith(clearLastActionDate: true);
```

### ReadingProgressEntry

A lightweight record that a specific verse was read at a given time.

```dart
// Fields
String verseId;
DateTime readAt;

final entry = ReadingProgressEntry(
  verseId: 'Genesis-1-1',
  readAt: DateTime.now(),
);

final json     = entry.toJson();
final restored = ReadingProgressEntry.fromJson(json);
```

### SermonOutline

A sermon or lesson draft. Supports `SermonStatus` (draft / delivered) and a structured list of `SermonPoint`s. Useful for tracking sermon preparation and organizing scripture references before preaching.

```dart
// SermonStatus enum
enum SermonStatus { draft, delivered }

// SermonPoint fields
String id;        // UUID
String heading;
String? content;
List<String> scriptureRefs;  // e.g. ["John 3:16", "Romans 5:8"]

// SermonOutline fields
String id;
String title;
DateTime? date;              // scheduled or preached date
List<String> scriptureRefs; // top-level passage references
List<SermonPoint> points;
SermonStatus status;
String? notes;               // free-form prep notes
String? seriesName;

// Factory create() — generates UUID and sets status to draft
final outline = SermonOutline.create(
  title: 'The Precious Blood of Christ',
  date: DateTime(2026, 4, 5),
  scriptureRefs: ['1 Peter 1:18-19', 'Hebrews 9:14'],
  points: [
    SermonPoint(
      id: 'pt-1',
      heading: 'The Price of Redemption',
      content: 'We were not redeemed with corruptible things...',
      scriptureRefs: ['1 Peter 1:18'],
    ),
    SermonPoint(
      id: 'pt-2',
      heading: 'The Purity of the Sacrifice',
      scriptureRefs: ['Hebrews 9:14'],
    ),
  ],
  seriesName: 'C&C Lesson 52',
  notes: 'Emphasize the contrast with animal sacrifice.',
);

print(outline.status); // SermonStatus.draft

// Mark as delivered
final delivered = outline.copyWith(status: SermonStatus.delivered);

// Clear optional fields using named flags
final noDate   = outline.copyWith(clearDate: true);
final noSeries = outline.copyWith(clearSeriesName: true);
final noNotes  = outline.copyWith(clearNotes: true);

// Serialization
final json     = outline.toJson();
final restored = SermonOutline.fromJson(json);
```

### PassageCollection

A named collection of `ScripturePassage`s — for example, a thematic cross-reference set, a lesson's supporting passages, or an article research group.

```dart
// Fields
String id;
String name;
String? description;
List<ScripturePassage> passages;
int? color;          // ARGB integer
DateTime createdAt;
DateTime updatedAt;

// Factory create() — generates UUID and sets both timestamps to now
final collection = PassageCollection.create(
  name: 'Blood of Christ — Cross-references',
  description: 'Supporting passages for C&C Lesson 52',
  passages: [
    ScripturePassage(
      book: '1 Peter', chapter: 1, verseStart: 18, verseEnd: 19,
      translationCode: 'KJV', verses: ['Forasmuch as ye know...', 'But with the precious blood...'],
    ),
  ],
  color: 0xFFB71C1C,
);

// Add a passage (copyWith returns a new instance)
final updated = collection.copyWith(
  passages: [...collection.passages, anotherPassage],
  updatedAt: DateTime.now(),
);

// Serialization
final json     = collection.toJson();
final restored = PassageCollection.fromJson(json);
```

### ReadingGoal

A daily reading goal with a configurable type and target quantity.

```dart
// GoalType enum
enum GoalType { versesPerDay, chaptersPerDay, minutesPerDay }

// ReadingGoal fields
String id;
GoalType type;
int target;

// Construction
final goal = ReadingGoal(
  id: 'goal-1',
  type: GoalType.versesPerDay,
  target: 25,
);

// Key method — check whether the goal has been achieved for a session
bool achieved = goal.isAchieved(versesRead: 25);               // true  (versesPerDay)
bool partial  = goal.isAchieved(versesRead: 10);               // false

final chapterGoal = ReadingGoal(id: 'g2', type: GoalType.chaptersPerDay, target: 3);
bool done = chapterGoal.isAchieved(versesRead: 0, chaptersRead: 3); // true

final timeGoal = ReadingGoal(id: 'g3', type: GoalType.minutesPerDay, target: 20);
bool timed = timeGoal.isAchieved(versesRead: 0, minutesRead: 22);   // true

// Serialization
final json     = goal.toJson();
final restored = ReadingGoal.fromJson(json);
```

### ReadingSession

A timed reading event with a start time, optional end time, and the verse IDs covered. Computed properties derive duration and verse count from those fields.

```dart
// Fields
String id;
DateTime startedAt;
DateTime? endedAt;
List<String> verseIds;

// Computed getters
int durationMinutes; // 0 if endedAt is null
int versesRead;      // verseIds.length

// Factory create() — generates UUID and sets startedAt to now
final session = ReadingSession.create(
  verseIds: ['John-3-16', 'John-3-17', 'John-3-18'],
);

// Close the session when reading is done
final closed = session.copyWith(endedAt: DateTime.now());

print(closed.durationMinutes); // e.g. 4
print(closed.versesRead);      // 3

// Clear endedAt if needed
final reopened = closed.copyWith(clearEndedAt: true);

// Serialization
final json     = session.toJson();
final restored = ReadingSession.fromJson(json);
```

### MemorizationEntry

A spaced-repetition (SRS) style record for tracking verse memorization progress. Status advances from `learning` to `reviewing` to `mastered` as the user reviews a verse over time.

```dart
// MemorizationStatus enum
enum MemorizationStatus { learning, reviewing, mastered }

// MemorizationEntry fields
String id;
String verseId;
MemorizationStatus status;
DateTime? nextReviewDate;
DateTime? lastReviewedAt;
int reviewCount;

// Factory create() — generates UUID, sets status to learning, reviewCount to 0
final entry = MemorizationEntry.create(verseId: 'Psalms-119-11');

// Record a review
final afterReview = entry.copyWith(
  status: MemorizationStatus.reviewing,
  lastReviewedAt: DateTime.now(),
  nextReviewDate: DateTime.now().add(const Duration(days: 3)),
  reviewCount: entry.reviewCount + 1,
);

// Mark as mastered
final mastered = afterReview.copyWith(
  status: MemorizationStatus.mastered,
  nextReviewDate: DateTime.now().add(const Duration(days: 30)),
  reviewCount: afterReview.reviewCount + 1,
);

// Serialization
final json     = entry.toJson();
final restored = MemorizationEntry.fromJson(json);
```

### CrossReference

Links two verse IDs with a typed relationship. Uses a natural composite key (fromVerseId + toVerseId + type) rather than an auto-generated ID.

```dart
// CrossReferenceType enum
enum CrossReferenceType { parallel, fulfillment, quotation, thematic }

// CrossReference fields
String fromVerseId;
String toVerseId;
CrossReferenceType type;
String? note;

// Construction (no factory create() — natural key only)
final ref = CrossReference(
  fromVerseId: 'Isaiah-53-5',
  toVerseId: '1Peter-2-24',
  type: CrossReferenceType.fulfillment,
  note: 'The suffering servant prophecy fulfilled in Christ.',
);

final parallel = CrossReference(
  fromVerseId: 'Matthew-5-3',
  toVerseId: 'Luke-6-20',
  type: CrossReferenceType.parallel,
);

// Serialization
final json     = ref.toJson();
final restored = CrossReference.fromJson(json);
```

### SavedSearch

A search query saved for quick re-use, with an optional display label and last-used timestamp.

```dart
// Fields
String id;
String query;
String? label;
DateTime createdAt;
DateTime? lastUsedAt;

// Factory create() — generates UUID and sets createdAt to now
final saved = SavedSearch.create(
  query: 'grace mercy peace',
  label: 'Pastoral epistles opener',
);

// Record usage
final used = saved.copyWith(lastUsedAt: DateTime.now());

// Serialization
final json     = saved.toJson();
final restored = SavedSearch.fromJson(json);
```

### PrayerRequest

A prayer item with status lifecycle (active → answered or archived) and an optional verse association.

```dart
// PrayerStatus enum
enum PrayerStatus { active, answered, archived }

// PrayerRequest fields
String id;
String content;
PrayerStatus status;
String? verseId;       // optional supporting verse
DateTime? answeredAt;  // set when status becomes answered
DateTime createdAt;
DateTime updatedAt;

// Factory create() — generates UUID, sets status to active
final request = PrayerRequest.create(
  content: 'Wisdom for the Wednesday Bible study series on Last Things.',
  verseId: 'James-1-5',
);

// Mark as answered
final answered = request.copyWith(
  status: PrayerStatus.answered,
  answeredAt: DateTime.now(),
);

// Archive it later
final archived = answered.copyWith(status: PrayerStatus.archived);

// Serialization
final json     = request.toJson();
final restored = PrayerRequest.fromJson(json);
```

### StudyNote

A reusable ministry research note — distinct from `ReadingNote`, which is tied to a reading session. `StudyNote` is for longer-form reference material: commentary excerpts, word studies, historical background, source attributions. Notes can be tagged and flagged when incorporated into a sermon.

```dart
// Fields
String id;
String? verseId;        // optional — pin to a specific verse
String? passageRef;     // optional — human-readable ref, e.g. "Romans 6:1-4"
String content;
String? source;         // attribution, e.g. "Matthew Henry's Commentary"
List<String> tags;
bool usedInSermon;
DateTime createdAt;
DateTime updatedAt;

// Factory create() — generates UUID, sets usedInSermon to false
final note = StudyNote.create(
  verseId: 'Romans-6-4',
  passageRef: 'Romans 6:4',
  content: 'Buried with him in baptism... Paul uses the aorist passive to emphasize '
      'that this is something done to us, not by us.',
  source: 'Robertson\'s Word Pictures in the New Testament',
  tags: ['baptism', 'resurrection', 'Romans'],
);

// Mark used in a sermon
final used = note.copyWith(usedInSermon: true, updatedAt: DateTime.now());

// Serialization
final json     = note.toJson();
final restored = StudyNote.fromJson(json);
```

### ReadingPlanState

Tracks pause, resume, and skip events for a reading plan so that `effectiveDayNumber` correctly excludes paused days. A `ReadingPlanEvent` records the type and date of each plan lifecycle change.

```dart
// ReadingPlanEventType enum
enum ReadingPlanEventType { paused, resumed, skipped }

// ReadingPlanEvent fields
ReadingPlanEventType type;
DateTime date;

// ReadingPlanState fields
List<ReadingPlanEvent> events;

// Factory create() — starts with an empty event list
final state = ReadingPlanState.create(startDate: DateTime(2026, 1, 1));

// Record a pause and later a resume
final paused = state.copyWith(events: [
  ...state.events,
  ReadingPlanEvent(type: ReadingPlanEventType.paused,  date: DateTime(2026, 2, 1)),
  ReadingPlanEvent(type: ReadingPlanEventType.resumed, date: DateTime(2026, 2, 8)),
]);

// effectiveDayNumber excludes the 7 paused days
int day = paused.effectiveDayNumber(DateTime(2026, 3, 1)); // actual day minus 7

// Check whether the plan is currently paused
bool active = paused.isPaused(DateTime(2026, 2, 4)); // true
bool running = paused.isPaused(DateTime(2026, 3, 1)); // false

// How many days were explicitly skipped
int skipped = paused.skippedDays; // 0

// Use with ReadingPlanService
final plans = ReadingPlanService(service);
final dayNum = plans.getCurrentDayNumber(DateTime(2026, 1, 1), state: paused);

// Serialization
final json     = state.toJson();
final restored = ReadingPlanState.fromJson(json);
```

### VerseCard

A verse formatted for sharing — for example, posting on social media or copying to a notes app. The `shareText` getter produces a publication-ready string.

```dart
// Fields
String id;
String verseId;
String reference;      // human-readable, e.g. "John 3:16"
String verseText;
String translationCode;
String? theme;         // optional label, e.g. "salvation"
int? color;            // ARGB integer
DateTime createdAt;

// Computed getter
String shareText; // "verseText\n— Reference (Translation)"

// Construction (typically via VerseCardFormatter — see Services below)
final card = VerseCard(
  id: 'vc-1',
  verseId: 'John-3-16',
  reference: 'John 3:16',
  verseText: 'For God so loved the world...',
  translationCode: 'KJV',
  theme: 'salvation',
  color: 0xFF1565C0,
  createdAt: DateTime.now(),
);

print(card.shareText);
// For God so loved the world...
// — John 3:16 (KJV)

// Serialization
final json     = card.toJson();
final restored = VerseCard.fromJson(json);
```

---

## Services

### BibleContentService

The central Bible data service. Requires a `BibleAssetLoader` implementation (see [BibleAssetLoader](#bibleassetloader) below). Must call `load()` before any other method.

```dart
final service = BibleContentService(MyAssetLoader());
await service.load();

// Check load state
bool loaded = service.isLoaded; // true after load()

// All books (unmodifiable list)
List<BibleBook> books = service.getAllBooks();

// Book by numeric id
BibleBook genesis = service.getBook(1);

// Book by name (case-insensitive, returns null if not found)
BibleBook? john = service.getBookByName('john');

// Chapter (throws if not found)
BibleChapter ch = service.getChapter(bookId: 1, chapterNum: 1);

// Verses in a chapter
List<BibleVerse> verses = service.getVerses(bookId: 1, chapterNum: 1);

// Aggregates
int totalVerses = service.getTotalVerseCount(); // 31,102 for full KJV
int totalWords  = service.getTotalWordCount();

// Name-based lookup helpers
String? text = service.verseText('John', 3, 16);     // null if not found
List<int> nums = service.versesInChapter('John', 3); // [1, 2, ..., 36]
```

**Multi-translation support:** Load additional translations alongside the default. Each translation is identified by a short code (e.g. `'ASV'`, `'ESV'`).

```dart
// Load a second translation using its own BibleAssetLoader
await service.loadTranslation('ASV', asvLoader);

// List all loaded translation codes
List<String> codes = service.loadedTranslationCodes; // ['ASV']

// Retrieve a verse in a specific translation (null if not loaded or not found)
BibleVerse? verse = service.getVerseInTranslation('John-3-16', 'ASV');
print(verse?.text); // "For God so loved the world..."
```

### BibleSearchService

Full-text and reference search. Takes a pre-loaded `BibleContentService`.

```dart
final search = BibleSearchService(service); // service must already be loaded

// Search verse text (case- and punctuation-insensitive)
List<SearchResult> results = search.searchVerses('God so loved');
for (final r in results) {
  print('${r.verse.id}: ${r.verse.text}');
  print('Match at position ${r.matchPosition}');
}

// Search books by name (partial, case-insensitive)
List<BibleBook> books = search.searchBooks('cor'); // 1 Corinthians, 2 Corinthians

// Look up a verse by reference string
BibleVerse? verse = search.searchByReference('John 3:16');    // exact verse
BibleVerse? v2    = search.searchByReference('1 Cor 13:4');   // numbered book
BibleVerse? none  = search.searchByReference('Hezekiah 1:1'); // null — not found
```

**Search normalization:** punctuation (`,;:.!?-—'"()[]{}`) is stripped and whitespace is collapsed before comparison, so `"repent and be"` matches `"repent, and be"`.

### ReadingPlanService

Generates verse-ID assignment lists for six reading plan types. All plans are cached after first generation. Supports `ReadingPlanState` for pause/resume/skip tracking.

```dart
final plans = ReadingPlanService(service); // service must already be loaded

// Available plan type constants
kPlanSequential    // Genesis → Revelation in canonical order
kPlanAlternating   // OT and NT chapters interleaved
kPlanChronological // Biblical events in historical order
kPlanCategoryMix   // Rotates through book categories (Law, History, Poetry, etc.)
kPlanVerseCount    // 85 verses per day (~31,102 ÷ 365)
kPlanWordCount     // ~85 verses per day targeting ~2,170 words/day

// Get today's verse IDs
final startDate  = DateTime(2026, 1, 1);
final dayNumber  = plans.getCurrentDayNumber(startDate); // e.g. 87
final assignment = plans.getTodaysAssignment(kPlanSequential, startDate, dayNumber);
// Returns List<String> of verse IDs e.g. ["Genesis-3-15", "Genesis-3-16", ...]

// Pause/resume support via ReadingPlanState
final state = ReadingPlanState.create(startDate: startDate);
// (add pause events to state as needed — see ReadingPlanState above)
final dayNumAdjusted = plans.getCurrentDayNumber(startDate, state: state);

// Calculate progress (0.0–1.0) based on which verses have been read
final readVerseIds = ['Genesis-1-1', 'Genesis-1-2']; // from your repository
double progress = plans.getPlanProgress(kPlanSequential, startDate, readVerseIds);
print('${(progress * 100).toStringAsFixed(1)}% complete');

// Check if today's assignment is done
bool done = plans.isTodaysAssignmentComplete(kPlanSequential, startDate, readVerseIds);

// Clear plan cache (e.g. when user switches plan type)
plans.clearCache();
```

### ReadingStatsService

Aggregates progress data from `BibleContentService` and `ReadingProgressRepository` to produce high-level Bible-reading statistics.

```dart
final stats = ReadingStatsService(content, progressRepo);

// Percentage of the entire Bible read (0.0–1.0)
double pct = await stats.percentBibleRead();

// Old and New Testament percentages separately
double otPct = await stats.percentOTRead();
double ntPct = await stats.percentNTRead();

// Which books have been read in their entirety
List<String> fullBooks = await stats.booksFullyRead();
// e.g. ["Genesis", "John", "Romans"]

// All chapter IDs that are fully read (every verse marked read)
List<String> chapters = await stats.chaptersCompleted();
// e.g. ["Genesis-1", "John-3", "Romans-8"]

// Average verses read per calendar day across all reading days
double avg = await stats.averageVersesPerDay();

// Longest gap between any two consecutive reading days
// Returns null if fewer than two distinct reading days exist
Duration? gap = await stats.longestGap();
if (gap != null) {
  print('Longest break: ${gap.inDays} days');
}
```

### TagService

Manages tags across all `ReadingNote` records — list, rename, merge, and delete tags without having to touch notes individually.

```dart
final tags = TagService(readingNoteRepo);

// All unique tags in use, sorted alphabetically
List<String> allTags = await tags.listAll();
// e.g. ["baptism", "grace", "prayer", "resurrection"]

// Rename a tag on every note that uses it
await tags.rename('grace', 'grace-mercy');

// Merge: replace source tag with target on all notes, no duplicates added
await tags.merge('baptism', 'sacraments');

// Delete a tag from every note that uses it
await tags.delete('old-tag');
```

### StreakCalculator

Pure, stateless streak logic. All methods are static — no constructor, no state.

```dart
// Apply a reading event and get a new ReadingStreak
ReadingStreak updated = StreakCalculator.recordActivity(
  currentStreak,
  DateTime.now(),
  hasAction: true,     // any verses were read today
  goalAchieved: true,  // daily goal was met
);

// The event date is normalized via GracePeriodHelper automatically:
// - Readings between 12:00am–1:00am count for the previous day
// - Future dates throw ArgumentError

// Rebuild streak from scratch from a sorted history list
final history = [
  (date: DateTime(2026, 3, 26), versesRead: 12, goalAchieved: true),
  (date: DateTime(2026, 3, 27), versesRead: 8,  goalAchieved: false),
  (date: DateTime(2026, 3, 28), versesRead: 15, goalAchieved: true),
];
ReadingStreak rebuilt = StreakCalculator.recalculateFromHistory(history);
// Records can be in any order — they are sorted internally

// Streak rules:
// - Same day read twice → streak unchanged
// - Consecutive day → streak increments
// - Gap of 2+ days → action streak resets to 1
// - goalAchieved: false → currentGoalStreak resets to 0
// - highestActionStreak / highestGoalStreak are never decreased
```

### GracePeriodHelper

Handles the late-night grace period: readings between 12:00am and 1:00am count for the previous calendar day.

```dart
// Get the "effective" tracking date for any DateTime
DateTime effectiveDate = GracePeriodHelper.getEffectiveDate(DateTime.now());
// At 00:30 → returns yesterday at midnight
// At 01:00 or later → returns today at midnight

// Is the current time within the grace period?
bool grace = GracePeriodHelper.isInGracePeriod(); // true if hour < 1

// The date that progress right now counts toward
DateTime trackingDay = GracePeriodHelper.getCurrentTrackingDay();

// The grace period threshold (hour 0 up to but not including hour 1)
int hour = GracePeriodHelper.gracePeriodHour; // 1
```

### ScriptureAutoDetector

Scans any plain text for Bible scripture references using a regex. No setup required — all methods are static.

```dart
// Detect all references in a string
List<DetectedScriptureRef> refs = ScriptureAutoDetector.detect(
  'For context see John 3:16, Gen 1:1-3, and 1 Cor 13:4.',
);

for (final ref in refs) {
  print(ref.book);        // "John", "Genesis", "1 Corinthians"
  print(ref.chapter);     // 3, 1, 13
  print(ref.verseStart);  // 16, 1, 4
  print(ref.verseEnd);    // null, 3, null  (non-null for ranges)
  print(ref.rawText);     // "John 3:16", "Gen 1:1-3", "1 Cor 13:4"
  print(ref.startOffset); // character offset in original string
  print(ref.endOffset);   // end offset in original string
}

// DetectedScriptureRef fields
String rawText;    // exact matched substring
String book;       // canonical book name, e.g. "1 Corinthians"
int chapter;
int verseStart;
int? verseEnd;     // non-null for ranges like "John 3:16-18"
int startOffset;   // index of first character of match in the input string
int endOffset;     // index after last character of match
```

**Recognized forms:** `John 3:16`, `Gen 1:1`, `1 Cor 13:4`, `Ps 23:1`, `Song of Solomon 3:1`, `Rev 22:21`, verse ranges `John 3:16-18`. Case-insensitive. All 66 books supported via a comprehensive abbreviation map.

### VerseOfTheDayService

Returns a deterministic "verse of the day" based on the day-of-year, independent of the calendar year. The same day number always returns the same verse, so January 1st is always the same verse regardless of whether it is 2026 or 2027.

```dart
// Use the built-in curated list (365 verse IDs)
final votd = VerseOfTheDayService(content);

// Or supply your own list
final custom = VerseOfTheDayService(content, verseIds: ['John-3-16', 'Psalms-23-1']);

// Get the verse ID for any date (deterministic: dayOfYear % list.length)
String verseId = votd.getVerseId(DateTime.now()); // e.g. "Psalms-119-105"

// Get the full BibleVerse object (null if the Bible data is not loaded)
BibleVerse? verse = await votd.getVerse(DateTime.now());
if (verse != null) {
  print(verse.text);
}

// Access the default curated list
List<String> ids = VerseOfTheDayService.defaultVerseIds; // 365 entries
```

### VerseCardFormatter

An abstract final class — all methods are static. Formats a `BibleVerse` into a `VerseCard` ready for sharing.

```dart
// format() creates a VerseCard from a loaded verse
VerseCard card = VerseCardFormatter.format(
  verse: verse,               // BibleVerse
  bookName: 'John',           // canonical book name for the reference string
  translationCode: 'KJV',
  theme: 'salvation',         // optional
  color: 0xFF1565C0,          // optional ARGB
);

print(card.shareText);
// For God so loved the world, that he gave his only begotten Son...
// — John 3:16 (KJV)
```

---

## Utils

### VerseId

Encodes and decodes the canonical verse ID format used throughout the package: `"BookName-Chapter-Verse"` with spaces removed from the book name.

```dart
// Encode
String id  = VerseId.encode('Genesis', 1, 1);          // "Genesis-1-1"
String id2 = VerseId.encode('Song of Solomon', 3, 2);  // "SongofSolomon-3-2"
String id3 = VerseId.encode('1 Corinthians', 13, 4);   // "1Corinthians-13-4"

// Chapter-level ID (no verse number)
String chId  = VerseId.chapterId('Genesis', 1);          // "Genesis-1"
String chId2 = VerseId.chapterId('Song of Solomon', 3);  // "SongofSolomon-3"

// Decode — returns a Dart record
final result = VerseId.decode('SongofSolomon-3-2');
print(result.book);    // "Song of Solomon"
print(result.chapter); // 3
print(result.verse);   // 2

// Round-trip
final encoded = VerseId.encode('2 Chronicles', 7, 14);
final decoded  = VerseId.decode(encoded);
// decoded.book == "2 Chronicles", decoded.chapter == 7, decoded.verse == 14

// Throws ArgumentError for invalid input
VerseId.decode('FakeBook-1-1'); // ArgumentError: Unknown book...
VerseId.decode('Genesis-1');    // ArgumentError: Invalid format...
```

---

## Abstract Repository Interfaces

These are the contracts each app must implement to provide storage. The package contains zero I/O — each consuming app plugs in its own persistence layer.

### BibleAssetLoader

Provides `List<BibleBook>` from any data source (asset file, filesystem, HTTP, in-memory).

```dart
abstract class BibleAssetLoader {
  Future<List<BibleBook>> loadBooks();
}

// Flutter app example (loads from rootBundle assets):
class FlutterBibleAssetLoader implements BibleAssetLoader {
  @override
  Future<List<BibleBook>> loadBooks() async {
    final raw  = await rootBundle.loadString('assets/kjv_bible.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return (data['books'] as List)
        .map((b) => BibleBook.fromJson(b as Map<String, dynamic>))
        .toList();
  }
}

// Server / CLI example (loads from filesystem):
class FileBibleAssetLoader implements BibleAssetLoader {
  final String path;
  FileBibleAssetLoader(this.path);

  @override
  Future<List<BibleBook>> loadBooks() async {
    final raw  = await File(path).readAsString();
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return (data['books'] as List)
        .map((b) => BibleBook.fromJson(b as Map<String, dynamic>))
        .toList();
  }
}

// Test double (in-memory, no I/O):
class InMemoryBibleAssetLoader implements BibleAssetLoader {
  final List<BibleBook> books;
  const InMemoryBibleAssetLoader(this.books);

  @override
  Future<List<BibleBook>> loadBooks() async => books;
}
```

### ReadingProgressRepository

Tracks which verses have been read and when.

```dart
abstract class ReadingProgressRepository {
  Future<void> markVerseRead(String verseId, {required DateTime readAt});
  Future<void> markVerseUnread(String verseId);
  Future<bool> isVerseRead(String verseId);
  Future<List<ReadingProgressEntry>> allProgress();
  Future<List<ReadingProgressEntry>> progressForBook(String bookName);
  Future<void> clear();
}

// Usage
await repo.markVerseRead('Genesis-1-1', readAt: DateTime.now());
bool read = await repo.isVerseRead('Genesis-1-1');         // true
List<ReadingProgressEntry> history = await repo.allProgress();
```

### BookmarkRepository

CRUD for bookmarks and bookmark collections.

```dart
abstract class BookmarkRepository {
  // Bookmarks
  Future<List<Bookmark>> getAll();
  Future<List<Bookmark>> getForVerse(String verseId);
  Future<List<Bookmark>> getForCollection(String? collectionId); // null = uncategorized
  Future<void> add(Bookmark bookmark);
  Future<void> update(Bookmark bookmark);
  Future<void> delete(String id);
  Future<bool> isVerseBookmarked(String verseId);

  // Collections
  Future<List<BookmarkCollection>> getCollections();
  Future<void> addCollection(BookmarkCollection collection);
  Future<void> updateCollection(BookmarkCollection collection);
  Future<void> deleteCollection(String id);
}

// Usage
final bookmark = Bookmark.create(
  verseId: 'John-3-16',
  bookId: 43,
  chapter: 3,
  verseNumber: 16,
  note: 'Key verse',
);
await repo.add(bookmark);
bool saved = await repo.isVerseBookmarked('John-3-16'); // true
```

### ReadingNoteRepository

CRUD for reading notes, with lookup by verse, chapter, or date.

```dart
abstract class ReadingNoteRepository {
  Future<List<ReadingNote>> getAll();
  Future<List<ReadingNote>> getForVerse(String verseId);
  Future<List<ReadingNote>> getForChapter(int bookId, int chapter);
  Future<List<ReadingNote>> getForDate(DateTime date);
  Future<void> add(ReadingNote note);
  Future<void> update(ReadingNote note);
  Future<void> delete(String id);
  Future<bool> hasVerseNote(String verseId);
  Future<bool> hasChapterNote(int bookId, int chapter);
}
```

### StreakRepository

Load and save the single `ReadingStreak` record.

```dart
abstract class StreakRepository {
  Future<ReadingStreak> load();
  Future<void> save(ReadingStreak streak);
}

// Typical usage pattern
final repo = MyStreakRepository();

ReadingStreak streak = await repo.load();
streak = StreakCalculator.recordActivity(
  streak,
  DateTime.now(),
  hasAction: true,
  goalAchieved: false,
);
await repo.save(streak);
```

### SermonRepository

CRUD for `SermonOutline` records, with filtering by series name and status.

```dart
abstract class SermonRepository {
  Future<List<SermonOutline>> getAll();
  Future<SermonOutline?> getById(String id);
  Future<List<SermonOutline>> getForSeries(String seriesName);
  Future<List<SermonOutline>> getByStatus(SermonStatus status);
  Future<void> add(SermonOutline outline);
  Future<void> update(SermonOutline outline);
  Future<void> delete(String id);
}

// Usage
final drafts = await repo.getByStatus(SermonStatus.draft);
final ccSeries = await repo.getForSeries('C&C');
```

### PassageCollectionRepository

CRUD for `PassageCollection` records.

```dart
abstract class PassageCollectionRepository {
  Future<List<PassageCollection>> getAll();
  Future<PassageCollection?> getById(String id);
  Future<void> add(PassageCollection collection);
  Future<void> update(PassageCollection collection);
  Future<void> delete(String id);
}
```

### ReadingSessionRepository

CRUD for `ReadingSession` records, with date-based and recency queries.

```dart
abstract class ReadingSessionRepository {
  Future<List<ReadingSession>> getAll();
  Future<ReadingSession?> getById(String id);
  Future<List<ReadingSession>> getForDate(DateTime date);
  Future<List<ReadingSession>> getRecent(int n);  // most recent n sessions
  Future<void> add(ReadingSession session);
  Future<void> update(ReadingSession session);
  Future<void> delete(String id);
}

// Usage
final todaySessions = await repo.getForDate(DateTime.now());
final lastFive      = await repo.getRecent(5);
```

### MemorizationRepository

CRUD for `MemorizationEntry` records, with filtering by verse, status, and review due date.

```dart
abstract class MemorizationRepository {
  Future<List<MemorizationEntry>> getAll();
  Future<MemorizationEntry?> getById(String id);
  Future<MemorizationEntry?> getForVerse(String verseId);
  Future<List<MemorizationEntry>> getByStatus(MemorizationStatus status);
  Future<List<MemorizationEntry>> getDueForReview(DateTime asOf);  // nextReviewDate <= asOf
  Future<void> add(MemorizationEntry entry);
  Future<void> update(MemorizationEntry entry);
  Future<void> delete(String id);
}

// Usage
final dueToday = await repo.getDueForReview(DateTime.now());
final mastered = await repo.getByStatus(MemorizationStatus.mastered);
```

### CrossReferenceRepository

Manages directional cross-references between verses. Uses the natural composite key (fromVerseId, toVerseId, type) rather than a surrogate ID.

```dart
abstract class CrossReferenceRepository {
  Future<List<CrossReference>> getFrom(String verseId);   // refs originating at verseId
  Future<List<CrossReference>> getTo(String verseId);     // refs pointing to verseId
  Future<List<CrossReference>> getForVerse(String verseId); // union of getFrom + getTo
  Future<void> add(CrossReference ref);
  Future<void> delete(String fromVerseId, String toVerseId, CrossReferenceType type);
}

// Usage
final allRefs  = await repo.getForVerse('Isaiah-53-5');
final incoming = await repo.getTo('1Peter-2-24');
```

### SearchHistoryRepository

CRUD for `SavedSearch` records (saved / recent search history).

```dart
abstract class SearchHistoryRepository {
  Future<List<SavedSearch>> getAll();
  Future<SavedSearch?> getById(String id);
  Future<void> add(SavedSearch search);
  Future<void> update(SavedSearch search);   // e.g. update lastUsedAt
  Future<void> delete(String id);
}
```

### PrayerRepository

CRUD for `PrayerRequest` records, with filtering by status.

```dart
abstract class PrayerRepository {
  Future<List<PrayerRequest>> getAll();
  Future<PrayerRequest?> getById(String id);
  Future<List<PrayerRequest>> getByStatus(PrayerStatus status);
  Future<void> add(PrayerRequest request);
  Future<void> update(PrayerRequest request);
  Future<void> delete(String id);
}

// Usage
final active   = await repo.getByStatus(PrayerStatus.active);
final answered = await repo.getByStatus(PrayerStatus.answered);
```

### StudyNoteRepository

CRUD for `StudyNote` records, with filtering by verse and tag.

```dart
abstract class StudyNoteRepository {
  Future<List<StudyNote>> getAll();
  Future<StudyNote?> getById(String id);
  Future<List<StudyNote>> getForVerse(String verseId);
  Future<List<StudyNote>> getByTag(String tag);
  Future<void> add(StudyNote note);
  Future<void> update(StudyNote note);
  Future<void> delete(String id);
}

// Usage
final baptismNotes = await repo.getByTag('baptism');
final verseNotes   = await repo.getForVerse('Romans-6-4');
```

---

## Integrating into an App

### Step 1 — Add the dependency

```yaml
# pubspec.yaml
dependencies:
  ministry_bible_core:
    path: ../ministry_bible_core
```

### Step 2 — Implement BibleAssetLoader

Each app provides one implementation that knows where its Bible JSON lives (see [BibleAssetLoader](#bibleassetloader) examples above).

### Step 3 — Implement the repository interfaces

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

### Step 4 — Wire it up

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

---

## Running the Tests

```bash
cd ministry_bible_core
dart pub get
dart test         # 514 tests
dart analyze      # zero issues
```

Coverage is measured with `dart run coverage:test_with_coverage` and currently sits at **100% line coverage (1456/1456 lines)**.
