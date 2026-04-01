import 'package:test/test.dart';
import 'package:ministry_bible_core/ministry_bible_core.dart';

void main() {
  final fixed = DateTime(2026, 1, 1);
  final used = DateTime(2026, 2, 1);

  SavedSearch makeSearch({
    String id = 'ss-1',
    String query = 'faith hope love',
    String? label,
    DateTime? lastUsedAt,
  }) =>
      SavedSearch(
        id: id,
        query: query,
        label: label,
        createdAt: fixed,
        lastUsedAt: lastUsedAt,
      );

  group('SavedSearch', () {
    test('constructor stores all fields', () {
      final s = makeSearch(label: 'Favorite', lastUsedAt: used);
      expect(s.id, equals('ss-1'));
      expect(s.query, equals('faith hope love'));
      expect(s.label, equals('Favorite'));
      expect(s.createdAt, equals(fixed));
      expect(s.lastUsedAt, equals(used));
    });

    test('label defaults to null', () {
      expect(makeSearch().label, isNull);
    });

    test('lastUsedAt defaults to null', () {
      expect(makeSearch().lastUsedAt, isNull);
    });

    group('SavedSearch.create', () {
      test('generates id and sets createdAt', () {
        final before = DateTime.now().subtract(const Duration(seconds: 1));
        final s = SavedSearch.create(query: 'grace');
        expect(s.id, isNotEmpty);
        expect(s.createdAt.isAfter(before), isTrue);
      });

      test('uses provided label', () {
        final s = SavedSearch.create(query: 'mercy', label: 'My label');
        expect(s.label, equals('My label'));
      });

      test('lastUsedAt is null on create', () {
        expect(SavedSearch.create(query: 'peace').lastUsedAt, isNull);
      });
    });

    group('fromJson / toJson', () {
      test('round-trip with label and lastUsedAt', () {
        final s = makeSearch(label: 'Saved', lastUsedAt: used);
        expect(SavedSearch.fromJson(s.toJson()), equals(s));
      });

      test('round-trip with null optionals', () {
        final s = makeSearch();
        final restored = SavedSearch.fromJson(s.toJson());
        expect(restored.label, isNull);
        expect(restored.lastUsedAt, isNull);
      });

      test('toJson includes all keys', () {
        final json = makeSearch(label: 'x', lastUsedAt: used).toJson();
        for (final key in ['id', 'query', 'label', 'createdAt', 'lastUsedAt']) {
          expect(json.containsKey(key), isTrue, reason: 'missing: $key');
        }
      });
    });

    group('copyWith', () {
      test('changes specified fields', () {
        final s = makeSearch();
        final copy = s.copyWith(query: 'new query', label: 'new label');
        expect(copy.query, equals('new query'));
        expect(copy.label, equals('new label'));
        expect(copy.id, equals(s.id));
      });

      test('with no args returns equal copy', () {
        final s = makeSearch(label: 'lbl', lastUsedAt: used);
        expect(s.copyWith(), equals(s));
      });

      test('clearLabel sets to null', () {
        final s = makeSearch(label: 'some label');
        expect(s.copyWith(clearLabel: true).label, isNull);
      });

      test('clearLastUsedAt sets to null', () {
        final s = makeSearch(lastUsedAt: used);
        expect(s.copyWith(clearLastUsedAt: true).lastUsedAt, isNull);
      });
    });

    group('equality', () {
      test('same values are equal', () {
        expect(makeSearch(), equals(makeSearch()));
        expect(makeSearch().hashCode, equals(makeSearch().hashCode));
      });

      test('different query is not equal', () {
        expect(makeSearch(query: 'a'), isNot(equals(makeSearch(query: 'b'))));
      });

      test('different label is not equal', () {
        expect(makeSearch(label: 'a'), isNot(equals(makeSearch(label: 'b'))));
      });

      test('different lastUsedAt is not equal', () {
        expect(makeSearch(lastUsedAt: used), isNot(equals(makeSearch())));
      });
    });

    test('toString contains query', () {
      expect(makeSearch().toString(), contains('faith hope love'));
    });
  });
}
