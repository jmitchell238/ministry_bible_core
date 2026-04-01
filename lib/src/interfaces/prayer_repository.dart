import '../models/prayer_request.dart';

/// Persists [PrayerRequest] entries.
abstract interface class PrayerRepository {
  Future<List<PrayerRequest>> getAll();
  Future<List<PrayerRequest>> getByStatus(PrayerStatus status);
  Future<void> add(PrayerRequest request);
  Future<void> update(PrayerRequest request);
  Future<void> delete(String id);
}
