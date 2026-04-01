import '../models/study_note.dart';

/// Persists [StudyNote] entries used in sermon/ministry research.
abstract interface class StudyNoteRepository {
  Future<List<StudyNote>> getAll();
  Future<List<StudyNote>> getForVerse(String verseId);
  Future<List<StudyNote>> getByTag(String tag);
  Future<void> add(StudyNote note);
  Future<void> update(StudyNote note);
  Future<void> delete(String id);
}
