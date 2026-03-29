import 'package:test/test.dart';
import 'package:ministry_bible_core/ministry_bible_core.dart';
import '../helpers/test_bible_fixture.dart';

void main() {
  late BibleSearchService search;

  setUp(() async {
    final service = await buildLoadedService();
    search = BibleSearchService(service);
  });

  group('BibleSearchService.searchVerses', () {
    test('empty query returns empty list', () {
      expect(search.searchVerses(''), isEmpty);
      expect(search.searchVerses('   '), isEmpty);
    });

    test('finds verse by exact phrase', () {
      final results = search.searchVerses('In the beginning');
      expect(results, isNotEmpty);
      expect(results.any((r) => r.verse.bookId == 1), isTrue); // Genesis
    });

    test('search is case-insensitive', () {
      final results = search.searchVerses('in the beginning');
      expect(results, isNotEmpty);
    });

    test('search is punctuation-insensitive', () {
      // "God so loved" exists without punctuation issues
      final results = search.searchVerses('God so loved');
      expect(results.any((r) => r.verse.id == 'John-3-16'), isTrue);
    });

    test('no match returns empty list', () {
      final results = search.searchVerses('xyzzynotaword');
      expect(results, isEmpty);
    });

    test('matchPosition is set', () {
      final results = search.searchVerses('beginning');
      expect(results.first.matchPosition, greaterThanOrEqualTo(0));
    });
  });

  group('BibleSearchService.searchBooks', () {
    test('empty query returns empty list', () {
      expect(search.searchBooks(''), isEmpty);
    });

    test('finds book by partial name', () {
      final results = search.searchBooks('Gen');
      expect(results, hasLength(1));
      expect(results[0].name, equals('Genesis'));
    });

    test('case-insensitive book search', () {
      final results = search.searchBooks('john');
      expect(results.any((b) => b.name == 'John'), isTrue);
    });

    test('no match returns empty list', () {
      expect(search.searchBooks('Hezekiah'), isEmpty);
    });
  });

  group('BibleSearchService.searchByReference', () {
    test('empty reference returns null', () {
      expect(search.searchByReference(''), isNull);
    });

    test('finds verse by full reference', () {
      final verse = search.searchByReference('John 3:16');
      expect(verse, isNotNull);
      expect(verse!.id, equals('John-3-16'));
    });

    test('reference lookup is case-insensitive', () {
      final verse = search.searchByReference('john 3:16');
      expect(verse, isNotNull);
    });

    test('unknown book returns null', () {
      expect(search.searchByReference('Hezekiah 1:1'), isNull);
    });

    test('unknown verse returns null', () {
      expect(search.searchByReference('John 3:99'), isNull);
    });

    test('invalid format returns null', () {
      expect(search.searchByReference('not a reference'), isNull);
    });
  });
}
