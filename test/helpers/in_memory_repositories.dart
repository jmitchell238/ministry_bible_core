import 'package:ministry_bible_core/ministry_bible_core.dart';

// ── InMemoryReadingNoteRepository ─────────────────────────────────────────────

class InMemoryReadingNoteRepository implements ReadingNoteRepository {
  final List<ReadingNote> _notes = [];

  @override
  Future<List<ReadingNote>> getAll() async => List.from(_notes);

  @override
  Future<List<ReadingNote>> getForVerse(String verseId) async =>
      _notes.where((n) => n.verseId == verseId).toList();

  @override
  Future<List<ReadingNote>> getForChapter(int bookId, int chapter) async =>
      _notes
          .where((n) => n.bookId == bookId && n.chapter == chapter)
          .toList();

  @override
  Future<List<ReadingNote>> getForDate(DateTime date) async {
    final key = ReadingNote.generateDailyKey(date);
    return _notes
        .where((n) =>
            n.date != null && ReadingNote.generateDailyKey(n.date!) == key)
        .toList();
  }

  @override
  Future<List<ReadingNote>> getForTag(String tag) async =>
      _notes.where((n) => n.tags.contains(tag)).toList();

  @override
  Future<void> add(ReadingNote note) async => _notes.add(note);

  @override
  Future<void> update(ReadingNote note) async {
    final idx = _notes.indexWhere((n) => n.id == note.id);
    if (idx >= 0) _notes[idx] = note;
  }

  @override
  Future<void> delete(String id) async =>
      _notes.removeWhere((n) => n.id == id);

  @override
  Future<bool> hasVerseNote(String verseId) async =>
      _notes.any((n) => n.verseId == verseId);

  @override
  Future<bool> hasChapterNote(int bookId, int chapter) async =>
      _notes.any((n) => n.bookId == bookId && n.chapter == chapter);
}

// ── InMemoryReadingProgressRepository ────────────────────────────────────────

class InMemoryReadingProgressRepository implements ReadingProgressRepository {
  final List<ReadingProgressEntry> _entries = [];

  @override
  Future<void> markVerseRead(String verseId, {required DateTime readAt}) async {
    _entries.removeWhere((e) => e.verseId == verseId);
    _entries.add(ReadingProgressEntry(verseId: verseId, readAt: readAt));
  }

  @override
  Future<void> markVerseUnread(String verseId) async =>
      _entries.removeWhere((e) => e.verseId == verseId);

  @override
  Future<bool> isVerseRead(String verseId) async =>
      _entries.any((e) => e.verseId == verseId);

  @override
  Future<List<ReadingProgressEntry>> allProgress() async =>
      List.from(_entries);

  @override
  Future<List<ReadingProgressEntry>> progressForBook(
      String bookName) async {
    final stripped = bookName.replaceAll(' ', '');
    return _entries
        .where((e) => e.verseId.startsWith('$stripped-'))
        .toList();
  }

  @override
  Future<void> clear() async => _entries.clear();
}
