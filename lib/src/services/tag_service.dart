import '../interfaces/reading_note_repository.dart';

/// Manages the tag strings used across [ReadingNote] objects.
///
/// Tags are plain strings stored directly on notes; this service derives
/// the tag list from notes and provides bulk rename, merge, and delete
/// operations so consumers do not need to implement that logic themselves.
class TagService {
  TagService(this._notes);

  final ReadingNoteRepository _notes;

  /// Returns all unique tag strings across all notes, sorted alphabetically.
  Future<List<String>> listAll() async {
    final all = await _notes.getAll();
    final tags = <String>{};
    for (final note in all) {
      tags.addAll(note.tags);
    }
    return tags.toList()..sort();
  }

  /// Renames [oldTag] to [newTag] on every note that carries [oldTag].
  Future<void> rename(String oldTag, String newTag) async {
    final affected = await _notes.getForTag(oldTag);
    for (final note in affected) {
      final updated = note.copyWith(
        tags: note.tags.map((t) => t == oldTag ? newTag : t).toList(),
        updatedAt: DateTime.now(),
      );
      await _notes.update(updated);
    }
  }

  /// Merges [source] into [target]: adds [target] to every note that has
  /// [source], then removes [source] from those notes.
  Future<void> merge(String source, String target) async {
    final affected = await _notes.getForTag(source);
    for (final note in affected) {
      final newTags = [
        ...note.tags.where((t) => t != source),
        if (!note.tags.contains(target)) target,
      ];
      final updated = note.copyWith(tags: newTags, updatedAt: DateTime.now());
      await _notes.update(updated);
    }
  }

  /// Removes [tag] from every note that carries it.
  Future<void> delete(String tag) async {
    final affected = await _notes.getForTag(tag);
    for (final note in affected) {
      final updated = note.copyWith(
        tags: note.tags.where((t) => t != tag).toList(),
        updatedAt: DateTime.now(),
      );
      await _notes.update(updated);
    }
  }
}
