import '../models/passage_collection.dart';

/// Abstract contract for persisting passage collections.
abstract class PassageCollectionRepository {
  Future<List<PassageCollection>> getAll();
  Future<void> add(PassageCollection collection);
  Future<void> update(PassageCollection collection);
  Future<void> delete(String id);
}
