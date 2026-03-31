import 'package:test/test.dart';
import 'package:ministry_bible_core/ministry_bible_core.dart';

ScripturePassage makePassage({
  String book = 'John',
  int chapter = 3,
  int verseStart = 16,
  int verseEnd = 16,
}) =>
    ScripturePassage(
      book: book,
      chapter: chapter,
      verseStart: verseStart,
      verseEnd: verseEnd,
      translationCode: 'KJV',
      verses: const [],
    );

void main() {
  final fixed = DateTime(2026, 1, 1);

  PassageCollection makeCollection({
    String id = 'col-1',
    String name = 'Salvation Passages',
    String? description,
    List<ScripturePassage>? passages,
    int? color,
  }) =>
      PassageCollection(
        id: id,
        name: name,
        description: description,
        passages: passages ?? [makePassage()],
        color: color,
        createdAt: fixed,
        updatedAt: fixed,
      );

  group('PassageCollection', () {
    test('constructor stores all fields', () {
      final p = makePassage();
      final c = PassageCollection(
        id: 'x',
        name: 'Test',
        description: 'desc',
        passages: [p],
        color: 0xFFFF0000,
        createdAt: fixed,
        updatedAt: fixed,
      );
      expect(c.id, equals('x'));
      expect(c.name, equals('Test'));
      expect(c.description, equals('desc'));
      expect(c.passages, hasLength(1));
      expect(c.color, equals(0xFFFF0000));
    });

    test('nullable fields default to null', () {
      final c = PassageCollection(
        id: 'x',
        name: 'T',
        passages: const [],
        createdAt: fixed,
        updatedAt: fixed,
      );
      expect(c.description, isNull);
      expect(c.color, isNull);
    });

    group('PassageCollection.create', () {
      test('generates id and timestamps', () {
        final before = DateTime.now().subtract(const Duration(seconds: 1));
        final c = PassageCollection.create(name: 'New');
        expect(c.id, isNotEmpty);
        expect(c.createdAt.isAfter(before), isTrue);
      });

      test('uses provided optional fields', () {
        final p = makePassage();
        final c = PassageCollection.create(
          name: 'Test',
          description: 'desc',
          passages: [p],
          color: 0xFF0000FF,
        );
        expect(c.description, equals('desc'));
        expect(c.passages, hasLength(1));
        expect(c.color, equals(0xFF0000FF));
      });

      test('passages list is a copy, not alias', () {
        final list = [makePassage()];
        final c = PassageCollection.create(name: 'T', passages: list);
        list.add(makePassage(chapter: 4));
        expect(c.passages, hasLength(1));
      });
    });

    group('fromJson / toJson', () {
      test('round-trip with all fields', () {
        final c = makeCollection(
          description: 'desc',
          passages: [makePassage(), makePassage(chapter: 4)],
          color: 0xFFFF0000,
        );
        final restored = PassageCollection.fromJson(c.toJson());
        expect(restored, equals(c));
      });

      test('round-trip with null optional fields', () {
        final c = makeCollection();
        final restored = PassageCollection.fromJson(c.toJson());
        expect(restored.description, isNull);
        expect(restored.color, isNull);
      });
    });

    group('copyWith', () {
      test('changes specified fields', () {
        final c = makeCollection(name: 'Old');
        final copy = c.copyWith(name: 'New');
        expect(copy.name, equals('New'));
        expect(copy.id, equals(c.id));
      });

      test('with no args returns equal copy', () {
        final c = makeCollection(description: 'desc', color: 0xFF0000FF);
        expect(c.copyWith(), equals(c));
      });

      test('clearDescription sets to null', () {
        final c = makeCollection(description: 'desc');
        expect(c.copyWith(clearDescription: true).description, isNull);
      });

      test('clearColor sets to null', () {
        final c = makeCollection(color: 0xFFFF0000);
        expect(c.copyWith(clearColor: true).color, isNull);
      });

      test('passages list defaults do not alias original', () {
        final c = makeCollection(passages: [makePassage()]);
        final copy = c.copyWith();
        expect(copy.passages, equals(c.passages));
      });
    });

    group('equality', () {
      test('same values are equal', () {
        final c1 = makeCollection();
        final c2 = makeCollection();
        expect(c1, equals(c2));
        expect(c1.hashCode, equals(c2.hashCode));
      });

      test('different name is not equal', () {
        expect(makeCollection(name: 'A'), isNot(equals(makeCollection(name: 'B'))));
      });

      test('different passages list is not equal', () {
        final c1 = makeCollection(passages: [makePassage()]);
        final c2 = makeCollection(passages: [makePassage(chapter: 4)]);
        expect(c1, isNot(equals(c2)));
      });
    });

    test('toString contains name and passage count', () {
      final c = makeCollection(name: 'My Set');
      expect(c.toString(), contains('My Set'));
      expect(c.toString(), contains('passages: 1'));
    });
  });
}
