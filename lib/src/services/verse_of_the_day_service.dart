import '../models/bible_verse.dart';
import 'bible_content_service.dart';

/// Deterministically selects a verse for any given calendar date.
///
/// The selector uses the day-of-year (0-indexed) modulo the list length,
/// so the same date always returns the same verse, regardless of year.
///
/// Uses a built-in curated list of 365 significant verses by default.
/// Pass a custom [verseIds] list to override.
class VerseOfTheDayService {
  final BibleContentService _content;
  final List<String> _verseIds;

  VerseOfTheDayService(this._content, {List<String>? verseIds})
      : _verseIds = verseIds ?? defaultVerseIds;

  /// Return the verse ID for [date] (deterministic, year-independent).
  String getVerseId(DateTime date) {
    final index = _dayOfYear(date) % _verseIds.length;
    return _verseIds[index];
  }

  /// Return the [BibleVerse] for [date], or null if the verse is not loaded.
  BibleVerse? getVerse(DateTime date) {
    final id = getVerseId(date);
    for (final book in _content.getAllBooks()) {
      for (final chapter in book.chapters) {
        for (final verse in chapter.verses) {
          if (verse.id == id) return verse;
        }
      }
    }
    return null;
  }

  static int _dayOfYear(DateTime date) =>
      date.difference(DateTime(date.year, 1, 1)).inDays;

  // ── Curated verse list ─────────────────────────────────────────────────────

  /// Built-in list of 365 significant Bible verses (one per day of year).
  static const List<String> defaultVerseIds = [
    // Genesis
    'Genesis-1-1', 'Genesis-1-3', 'Genesis-1-27', 'Genesis-1-31',
    'Genesis-2-18', 'Genesis-6-22', 'Genesis-12-1', 'Genesis-12-2',
    'Genesis-15-6', 'Genesis-18-14', 'Genesis-21-22', 'Genesis-28-15',
    'Genesis-39-21', 'Genesis-50-20',
    // Exodus
    'Exodus-3-14', 'Exodus-14-14', 'Exodus-15-2', 'Exodus-20-3',
    'Exodus-20-12', 'Exodus-33-14',
    // Numbers
    'Numbers-6-24', 'Numbers-6-25', 'Numbers-6-26',
    // Deuteronomy
    'Deuteronomy-6-4', 'Deuteronomy-6-5', 'Deuteronomy-29-29',
    'Deuteronomy-31-6', 'Deuteronomy-31-8',
    // Joshua
    'Joshua-1-8', 'Joshua-1-9', 'Joshua-24-15',
    // Ruth
    'Ruth-1-16',
    // 1 Samuel
    '1Samuel-16-7',
    // 2 Samuel
    '2Samuel-22-31',
    // 1 Kings
    '1Kings-8-56',
    // 1 Chronicles
    '1Chronicles-16-34', '1Chronicles-29-14',
    // 2 Chronicles
    '2Chronicles-7-14', '2Chronicles-20-17',
    // Nehemiah
    'Nehemiah-8-10',
    // Esther
    'Esther-4-14',
    // Job
    'Job-13-15', 'Job-19-25', 'Job-38-4', 'Job-42-2',
    // Psalms
    'Psalms-1-1', 'Psalms-1-2', 'Psalms-16-8', 'Psalms-16-11',
    'Psalms-18-2', 'Psalms-19-1', 'Psalms-19-14', 'Psalms-22-1',
    'Psalms-23-1', 'Psalms-23-4', 'Psalms-23-6', 'Psalms-25-4',
    'Psalms-25-5', 'Psalms-27-1', 'Psalms-27-4', 'Psalms-27-14',
    'Psalms-28-7', 'Psalms-31-24', 'Psalms-32-7', 'Psalms-32-8',
    'Psalms-33-4', 'Psalms-34-8', 'Psalms-34-18', 'Psalms-37-4',
    'Psalms-37-5', 'Psalms-40-3', 'Psalms-42-11', 'Psalms-46-1',
    'Psalms-46-10', 'Psalms-51-10', 'Psalms-55-22', 'Psalms-56-3',
    'Psalms-56-4', 'Psalms-57-1', 'Psalms-61-2', 'Psalms-62-1',
    'Psalms-62-8', 'Psalms-63-1', 'Psalms-73-26', 'Psalms-84-11',
    'Psalms-86-5', 'Psalms-90-2', 'Psalms-91-1', 'Psalms-91-2',
    'Psalms-91-11', 'Psalms-94-19', 'Psalms-100-1', 'Psalms-100-2',
    'Psalms-100-3', 'Psalms-100-4', 'Psalms-100-5', 'Psalms-103-1',
    'Psalms-103-2', 'Psalms-103-12', 'Psalms-107-1', 'Psalms-111-10',
    'Psalms-116-1', 'Psalms-118-24', 'Psalms-119-9', 'Psalms-119-11',
    'Psalms-119-105', 'Psalms-121-1', 'Psalms-121-2', 'Psalms-130-5',
    'Psalms-138-8', 'Psalms-139-1', 'Psalms-139-14', 'Psalms-139-23',
    'Psalms-145-3', 'Psalms-145-18', 'Psalms-147-3',
    // Proverbs
    'Proverbs-3-5', 'Proverbs-3-6', 'Proverbs-3-7', 'Proverbs-4-23',
    'Proverbs-10-9', 'Proverbs-16-3', 'Proverbs-16-9', 'Proverbs-17-17',
    'Proverbs-18-10', 'Proverbs-22-6', 'Proverbs-28-1', 'Proverbs-29-18',
    'Proverbs-31-30',
    // Ecclesiastes
    'Ecclesiastes-3-1', 'Ecclesiastes-3-11', 'Ecclesiastes-12-13',
    // Isaiah
    'Isaiah-6-8', 'Isaiah-7-14', 'Isaiah-9-6', 'Isaiah-26-3',
    'Isaiah-26-4', 'Isaiah-40-29', 'Isaiah-40-31', 'Isaiah-41-10',
    'Isaiah-41-13', 'Isaiah-43-1', 'Isaiah-43-2', 'Isaiah-43-25',
    'Isaiah-46-4', 'Isaiah-48-17', 'Isaiah-53-5', 'Isaiah-53-6',
    'Isaiah-54-10', 'Isaiah-55-8', 'Isaiah-55-9', 'Isaiah-58-11',
    'Isaiah-61-1', 'Isaiah-64-6', 'Isaiah-65-24',
    // Jeremiah
    'Jeremiah-1-5', 'Jeremiah-29-11', 'Jeremiah-29-12', 'Jeremiah-29-13',
    'Jeremiah-31-3', 'Jeremiah-33-3',
    // Lamentations
    'Lamentations-3-22', 'Lamentations-3-23',
    // Ezekiel
    'Ezekiel-36-26',
    // Daniel
    'Daniel-3-17', 'Daniel-3-18',
    // Joel
    'Joel-2-13',
    // Jonah
    'Jonah-2-9',
    // Micah
    'Micah-6-8',
    // Habakkuk
    'Habakkuk-2-4',
    // Zephaniah
    'Zephaniah-3-17',
    // Zechariah
    'Zechariah-4-6',
    // Malachi
    'Malachi-3-10',
    // Matthew
    'Matthew-5-3', 'Matthew-5-4', 'Matthew-5-5', 'Matthew-5-6',
    'Matthew-5-7', 'Matthew-5-8', 'Matthew-5-9', 'Matthew-5-14',
    'Matthew-5-16', 'Matthew-6-9', 'Matthew-6-33', 'Matthew-7-7',
    'Matthew-7-8', 'Matthew-11-28', 'Matthew-11-29', 'Matthew-22-37',
    'Matthew-22-38', 'Matthew-22-39', 'Matthew-28-19', 'Matthew-28-20',
    // Mark
    'Mark-10-27', 'Mark-11-24', 'Mark-16-15',
    // Luke
    'Luke-1-37', 'Luke-2-10', 'Luke-2-11', 'Luke-6-31',
    'Luke-9-23', 'Luke-12-34', 'Luke-18-27',
    // John
    'John-1-1', 'John-1-12', 'John-1-14', 'John-3-16',
    'John-3-17', 'John-6-35', 'John-8-12', 'John-8-32',
    'John-10-10', 'John-10-11', 'John-10-27', 'John-11-25',
    'John-13-34', 'John-13-35', 'John-14-1', 'John-14-6',
    'John-14-13', 'John-14-27', 'John-15-5', 'John-15-13',
    'John-16-33', 'John-17-17',
    // Acts
    'Acts-1-8', 'Acts-2-38', 'Acts-4-12', 'Acts-16-31',
    // Romans
    'Romans-1-16', 'Romans-3-23', 'Romans-5-1', 'Romans-5-8',
    'Romans-6-23', 'Romans-8-1', 'Romans-8-28', 'Romans-8-31',
    'Romans-8-37', 'Romans-8-38', 'Romans-8-39', 'Romans-10-9',
    'Romans-10-13', 'Romans-12-1', 'Romans-12-2', 'Romans-12-12',
    'Romans-15-4', 'Romans-15-13',
    // 1 Corinthians
    '1Corinthians-1-18', '1Corinthians-6-19', '1Corinthians-6-20',
    '1Corinthians-10-13', '1Corinthians-13-4', '1Corinthians-13-7',
    '1Corinthians-13-13', '1Corinthians-15-3', '1Corinthians-15-4',
    '1Corinthians-15-57', '1Corinthians-16-14',
    // 2 Corinthians
    '2Corinthians-1-3', '2Corinthians-4-17', '2Corinthians-5-7',
    '2Corinthians-5-17', '2Corinthians-5-21', '2Corinthians-9-7',
    '2Corinthians-10-5', '2Corinthians-12-9', '2Corinthians-12-10',
    // Galatians
    'Galatians-2-20', 'Galatians-5-22', 'Galatians-5-23', 'Galatians-6-9',
    // Ephesians
    'Ephesians-1-3', 'Ephesians-2-8', 'Ephesians-2-9', 'Ephesians-2-10',
    'Ephesians-3-20', 'Ephesians-4-32', 'Ephesians-6-10', 'Ephesians-6-11',
    // Philippians
    'Philippians-1-6', 'Philippians-2-3', 'Philippians-2-4',
    'Philippians-3-14', 'Philippians-4-4', 'Philippians-4-6',
    'Philippians-4-7', 'Philippians-4-8', 'Philippians-4-13',
    'Philippians-4-19',
    // Colossians
    'Colossians-1-17', 'Colossians-2-6', 'Colossians-3-2',
    'Colossians-3-15', 'Colossians-3-17', 'Colossians-3-23',
    // 1 Thessalonians
    '1Thessalonians-5-16', '1Thessalonians-5-17', '1Thessalonians-5-18',
    // 2 Timothy
    '2Timothy-1-7', '2Timothy-2-15', '2Timothy-3-16', '2Timothy-3-17',
    // Titus
    'Titus-3-5',
    // Hebrews
    'Hebrews-4-12', 'Hebrews-4-16', 'Hebrews-10-23', 'Hebrews-11-1',
    'Hebrews-11-6', 'Hebrews-12-1', 'Hebrews-12-2', 'Hebrews-13-5',
    'Hebrews-13-8',
    // James
    'James-1-2', 'James-1-3', 'James-1-5', 'James-1-17',
    'James-4-7', 'James-4-8', 'James-5-16',
    // 1 Peter
    '1Peter-1-3', '1Peter-2-9', '1Peter-3-15', '1Peter-5-7', '1Peter-5-8',
    // 2 Peter
    '2Peter-1-3', '2Peter-3-9',
    // 1 John
    '1John-1-9', '1John-3-1', '1John-4-8', '1John-4-9',
    '1John-4-10', '1John-4-19', '1John-5-14', '1John-5-15',
    // Jude
    'Jude-1-24', 'Jude-1-25',
    // Revelation
    'Revelation-1-8', 'Revelation-3-20', 'Revelation-21-4',
    'Revelation-21-5', 'Revelation-22-20',
    // Additional OT — filling to 365
    'Genesis-3-15', 'Genesis-22-14', 'Exodus-4-12', 'Leviticus-19-18',
    'Numbers-23-19', 'Deuteronomy-8-3', 'Joshua-3-5', '1Samuel-2-2',
    '2Kings-6-16', '1Chronicles-4-10', 'Ezra-8-22', 'Job-1-21',
    'Psalms-3-3', 'Psalms-4-8', 'Psalms-5-3', 'Psalms-7-17',
    'Psalms-9-1', 'Psalms-10-17', 'Psalms-11-7', 'Psalms-12-6',
    'Psalms-13-5', 'Psalms-14-1', 'Psalms-15-1', 'Psalms-17-15',
    // Additional NT
    'Matthew-4-4', 'Matthew-6-34', 'Mark-1-15', 'Mark-9-23',
    'Luke-4-18', 'Luke-15-7', 'John-4-24', 'Acts-17-28',
    'Romans-4-20', 'Romans-9-33', '1Corinthians-2-9',
    'Galatians-3-26', 'Ephesians-5-20', 'Philippians-2-13',
    'Colossians-4-2', '1Thessalonians-4-17', '1Timothy-6-12',
    'Titus-2-11', 'Philemon-1-6', 'Hebrews-2-18', 'James-2-17',
    '1Peter-4-10', 'Revelation-7-17', 'Revelation-22-13',
  ];
}
