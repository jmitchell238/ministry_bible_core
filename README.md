# ministry_bible_core

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

---

## Contents

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
- [Services](#services)
  - [BibleContentService](#biblecontentservice)
  - [BibleSearchService](#biblesearchservice)
  - [ReadingPlanService](#readingplanservice)
  - [StreakCalculator](#streakcalculator)
  - [GracePeriodHelper](#graceperiodhelper)
  - [ScriptureAutoDetector](#scriptureautodetector)
- [Utils](#utils)
  - [VerseId](#verseid)
- [Abstract Repository Interfaces](#abstract-repository-interfaces)
  - [BibleAssetLoader](#bibleassetloader)
  - [ReadingProgressRepository](#readingprogressrepository)
  - [BookmarkRepository](#bookmarkrepository)
  - [ReadingNoteRepository](#readingnoterepository)
  - [StreakRepository](#streakrepository)
- [Integrating into an App](#integrating-into-an-app)

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
| **Models** | `BibleVerse`, `BibleChapter`, `BibleBook`, `ScripturePassage`, `SearchResult`, `Bookmark`, `BookmarkCollection`, `ReadingNote` (`NoteType`), `ReadingStreak`, `ReadingProgressEntry` |
| **Services** | `BibleContentService`, `BibleSearchService`, `ReadingPlanService`, `StreakCalculator`, `GracePeriodHelper`, `ScriptureAutoDetector` |
| **Interfaces** | `BibleAssetLoader`, `ReadingProgressRepository`, `BookmarkRepository`, `ReadingNoteRepository`, `StreakRepository` |
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

All 66 canonical book names in canonical order, with helpers.

```dart
// All 66 names in order
List<String> all = BibleBooks.all;

// Total count
int count = BibleBooks.count; // 66

// Exact-match lookup
bool valid = BibleBooks.contains('Genesis'); // true
bool invalid = BibleBooks.contains('genesis'); // false (case-sensitive)

// Case-insensitive prefix search — returns first match or null
String? book = BibleBooks.findBook('gen'); // "Genesis"
String? book2 = BibleBooks.findBook('1 co'); // "1 Corinthians"
String? notFound = BibleBooks.findBook('xyz'); // null
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
final json    = passage.toJson();
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
String dayKey     = ReadingNote.generateDailyKey(DateTime.now());    // "2026-03-28"
String chapterKey = ReadingNote.generateChapterKey(1, 3);             // "1-3"
String verseKey   = ReadingNote.generateVerseKey('Genesis-1-1');      // "Genesis-1-1"

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
final json    = streak.toJson();
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

final json    = entry.toJson();
final restored = ReadingProgressEntry.fromJson(json);
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
String? text = service.verseText('John', 3, 16);  // null if not found
List<int> nums = service.versesInChapter('John', 3); // [1, 2, ..., 36]
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
BibleVerse? verse = search.searchByReference('John 3:16');  // exact verse
BibleVerse? v2    = search.searchByReference('1 Cor 13:4'); // numbered book
BibleVerse? none  = search.searchByReference('Hezekiah 1:1'); // null — not found
```

**Search normalization:** punctuation (`,;:.!?-—'"()[]{}`) is stripped and whitespace is collapsed before comparison, so `"repent and be"` matches `"repent, and be"`.

### ReadingPlanService

Generates verse-ID assignment lists for six reading plan types. All plans are cached after first generation.

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

// Calculate progress (0.0–1.0) based on which verses have been read
final readVerseIds = ['Genesis-1-1', 'Genesis-1-2']; // from your repository
double progress = plans.getPlanProgress(kPlanSequential, startDate, readVerseIds);
print('${(progress * 100).toStringAsFixed(1)}% complete');

// Check if today's assignment is done
bool done = plans.isTodaysAssignmentComplete(kPlanSequential, startDate, readVerseIds);

// Clear plan cache (e.g. when user switches plan type)
plans.clearCache();
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

---

## Utils

### VerseId

Encodes and decodes the canonical verse ID format used throughout the package: `"BookName-Chapter-Verse"` with spaces removed from the book name.

```dart
// Encode
String id = VerseId.encode('Genesis', 1, 1);            // "Genesis-1-1"
String id2 = VerseId.encode('Song of Solomon', 3, 2);   // "SongofSolomon-3-2"
String id3 = VerseId.encode('1 Corinthians', 13, 4);    // "1Corinthians-13-4"

// Chapter-level ID (no verse number)
String chId = VerseId.chapterId('Genesis', 1);           // "Genesis-1"
String chId2 = VerseId.chapterId('Song of Solomon', 3);  // "SongofSolomon-3"

// Decode — returns a Dart record
final result = VerseId.decode('SongofSolomon-3-2');
print(result.book);    // "Song of Solomon"
print(result.chapter); // 3
print(result.verse);   // 2

// Round-trip
final encoded = VerseId.encode('2 Chronicles', 7, 14);
final decoded = VerseId.decode(encoded);
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
    final raw = await rootBundle.loadString('assets/kjv_bible.json');
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
    final raw = await File(path).readAsString();
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
bool read = await repo.isVerseRead('Genesis-1-1'); // true
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

A JSON-file-based app (e.g. MinistryBase) would create `Json*Repository` classes.

### Step 4 — Wire it up

```dart
// App startup
final loader  = FlutterBibleAssetLoader();
final content = BibleContentService(loader);
await content.load();

final search  = BibleSearchService(content);
final plans   = ReadingPlanService(content);

// Repository implementations (app-specific)
final progress = HiveReadingProgressRepository();
final streaks  = HiveStreakRepository();

// Record a reading session
await progress.markVerseRead('John-3-16', readAt: DateTime.now());

ReadingStreak streak = await streaks.load();
streak = StreakCalculator.recordActivity(
  streak,
  DateTime.now(),
  hasAction: true,
  goalAchieved: true,
);
await streaks.save(streak);
```

---

## Running the tests

```bash
cd ministry_bible_core
dart pub get
dart test         # 184 tests
dart analyze      # zero issues
```
