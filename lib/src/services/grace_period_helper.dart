/// Helper for managing grace period logic in Bible reading tracking.
///
/// The grace period allows readings between 12:00am–1:00am to count for
/// the previous day, preventing streaks from breaking for late-night readers.
class GracePeriodHelper {
  GracePeriodHelper._();

  /// Times from 12:00am (hour 0) up to (but not including) 1:00am count
  /// as the previous day.
  static const int gracePeriodHour = 1;

  /// Returns the effective tracking date for [dateTime], accounting for the
  /// grace period. Always returns a midnight-normalized DateTime.
  ///
  /// Examples:
  /// - 2026-01-02 00:30 → 2026-01-01 00:00 (grace period — counts as prev day)
  /// - 2026-01-02 01:00 → 2026-01-02 00:00 (after grace period)
  /// - 2026-01-02 23:50 → 2026-01-02 00:00 (normal)
  static DateTime getEffectiveDate(DateTime dateTime) {
    if (dateTime.hour < gracePeriodHour) {
      final previousDay = dateTime.subtract(const Duration(days: 1));
      return _normalizeToMidnight(previousDay);
    }
    return _normalizeToMidnight(dateTime);
  }

  /// Whether the current time is within the grace period.
  static bool isInGracePeriod() => DateTime.now().hour < gracePeriodHour;

  /// The current "tracking day" — the date that progress right now counts
  /// toward. During grace period this is yesterday; otherwise today.
  static DateTime getCurrentTrackingDay() =>
      getEffectiveDate(DateTime.now());

  // ── Private ────────────────────────────────────────────────────────────────

  static DateTime _normalizeToMidnight(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);
}
