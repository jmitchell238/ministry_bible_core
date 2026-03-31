import '../models/cross_reference.dart';

/// Abstract contract for persisting and querying cross-references.
abstract class CrossReferenceRepository {
  /// Returns all cross-references originating from [verseId].
  Future<List<CrossReference>> getFrom(String verseId);

  /// Returns all cross-references pointing to [verseId].
  Future<List<CrossReference>> getTo(String verseId);

  /// Returns all cross-references involving [verseId] in either direction.
  Future<List<CrossReference>> getForVerse(String verseId);

  Future<void> add(CrossReference ref);
  Future<void> delete(String fromVerseId, String toVerseId, CrossReferenceType type);
}
