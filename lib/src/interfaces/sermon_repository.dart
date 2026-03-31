import '../models/sermon_outline.dart';

/// Abstract contract for persisting sermon and lesson outlines.
abstract class SermonRepository {
  Future<List<SermonOutline>> getAll();

  /// Returns all sermons belonging to [seriesName].
  Future<List<SermonOutline>> getForSeries(String seriesName);

  /// Returns all sermons with the given [status].
  Future<List<SermonOutline>> getByStatus(SermonStatus status);

  Future<void> add(SermonOutline sermon);
  Future<void> update(SermonOutline sermon);
  Future<void> delete(String id);
}
