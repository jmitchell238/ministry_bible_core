import '../models/reading_note.dart';

/// Abstract contract for persisting reading notes.
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

  /// Returns all notes that carry [tag] in their tags list.
  Future<List<ReadingNote>> getForTag(String tag);
}
