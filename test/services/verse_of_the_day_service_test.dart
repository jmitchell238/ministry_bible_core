import 'package:test/test.dart';
import 'package:ministry_bible_core/ministry_bible_core.dart';
import '../helpers/test_bible_fixture.dart';

void main() {
  late BibleContentService content;

  setUp(() async {
    content = await buildLoadedService(); // Genesis (5 verses) + John (4 verses)
  });

  // A small custom list drawn entirely from the test fixture
  const fixtureVerses = [
    'Genesis-1-1',
    'Genesis-1-2',
    'Genesis-1-3',
    'John-3-16',
  ];

  group('VerseOfTheDayService — default list', () {
    late VerseOfTheDayService service;

    setUp(() => service = VerseOfTheDayService(content));

    test('defaultVerseIds contains at least 365 entries', () {
      expect(VerseOfTheDayService.defaultVerseIds.length, greaterThanOrEqualTo(365));
    });

    test('all default verse IDs match canonical format Book-chapter-verse', () {
      // Book names may start with a digit (1Samuel, 2Kings) or letter (Genesis)
      final pattern = RegExp(r'^[0-9A-Z][a-zA-Z0-9]*-\d+-\d+$');
      for (final id in VerseOfTheDayService.defaultVerseIds) {
        expect(pattern.hasMatch(id), isTrue, reason: 'Bad format: $id');
      }
    });

    test('getVerseId returns a non-empty string', () {
      expect(service.getVerseId(DateTime(2026, 1, 1)), isNotEmpty);
    });

    test('same date always returns the same verse id', () {
      final date = DateTime(2026, 6, 15);
      expect(service.getVerseId(date), equals(service.getVerseId(date)));
    });

    test('year does not affect result — only day of year', () {
      final d1 = DateTime(2025, 3, 31);
      final d2 = DateTime(2026, 3, 31);
      expect(service.getVerseId(d1), equals(service.getVerseId(d2)));
    });
  });

  group('VerseOfTheDayService — custom list', () {
    late VerseOfTheDayService service;

    setUp(() => service = VerseOfTheDayService(content, verseIds: fixtureVerses));

    test('cycles through custom list by day of year', () {
      // Day 0 (Jan 1) → index 0 % 4 = 0 → Genesis-1-1
      // Day 4 (Jan 5) → index 4 % 4 = 0 → Genesis-1-1
      final day0 = DateTime(2026, 1, 1);
      final day1 = DateTime(2026, 1, 2);
      final day4 = DateTime(2026, 1, 5);

      expect(service.getVerseId(day0), equals(fixtureVerses[0]));
      expect(service.getVerseId(day1), equals(fixtureVerses[1]));
      expect(service.getVerseId(day4), equals(fixtureVerses[0]));
    });

    test('different dates return different verses when list is larger than 1', () {
      final ids = List.generate(4, (i) =>
          service.getVerseId(DateTime(2026, 1, i + 1)));
      expect(ids.toSet().length, greaterThan(1));
    });

    test('getVerse returns BibleVerse when verse exists in content service', () {
      final verse = service.getVerse(DateTime(2026, 1, 1)); // Genesis-1-1
      expect(verse, isNotNull);
      expect(verse!.id, equals('Genesis-1-1'));
    });

    test('getVerse returns null when verse is not in content service', () {
      // John-3-16 is day index 3 (Jan 4 = day 3)
      final notInFixture = VerseOfTheDayService(
        content,
        verseIds: ['Revelation-22-21'], // not in test fixture
      );
      expect(notInFixture.getVerse(DateTime(2026, 1, 1)), isNull);
    });
  });

  group('VerseOfTheDayService — edge cases', () {
    test('single-entry list always returns that verse', () {
      final service = VerseOfTheDayService(content, verseIds: ['Genesis-2-1']);
      for (int i = 0; i < 10; i++) {
        expect(
          service.getVerseId(DateTime(2026, 1, i + 1)),
          equals('Genesis-2-1'),
        );
      }
    });

    test('Dec 31 (day 364) returns a valid verse from default list', () {
      final service = VerseOfTheDayService(content);
      final dec31 = DateTime(2026, 12, 31);
      expect(service.getVerseId(dec31), isNotEmpty);
    });
  });
}
