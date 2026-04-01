import 'package:test/test.dart';
import 'package:ministry_bible_core/ministry_bible_core.dart';

void main() {
  final fixed = DateTime(2026, 1, 1);

  StudyNote makeNote({
    String id = 'sn-1',
    String? verseId,
    String? passageRef,
    String content = 'Key observation about this text.',
    String? source,
    List<String> tags = const [],
    bool usedInSermon = false,
  }) =>
      StudyNote(
        id: id,
        verseId: verseId,
        passageRef: passageRef,
        content: content,
        source: source,
        tags: tags,
        usedInSermon: usedInSermon,
        createdAt: fixed,
        updatedAt: fixed,
      );

  group('StudyNote', () {
    test('constructor stores all fields', () {
      final n = makeNote(
        verseId: 'Isaiah-53-5',
        passageRef: 'Isaiah 53:1-12',
        source: 'Matthew Henry',
        tags: ['prophecy', 'atonement'],
        usedInSermon: true,
      );
      expect(n.id, equals('sn-1'));
      expect(n.verseId, equals('Isaiah-53-5'));
      expect(n.passageRef, equals('Isaiah 53:1-12'));
      expect(n.content, equals('Key observation about this text.'));
      expect(n.source, equals('Matthew Henry'));
      expect(n.tags, equals(['prophecy', 'atonement']));
      expect(n.usedInSermon, isTrue);
      expect(n.createdAt, equals(fixed));
    });

    test('optional fields default correctly', () {
      final n = makeNote();
      expect(n.verseId, isNull);
      expect(n.passageRef, isNull);
      expect(n.source, isNull);
      expect(n.tags, isEmpty);
      expect(n.usedInSermon, isFalse);
    });

    group('StudyNote.create', () {
      test('generates id and sets timestamps', () {
        final before = DateTime.now().subtract(const Duration(seconds: 1));
        final n = StudyNote.create(content: 'Test observation');
        expect(n.id, isNotEmpty);
        expect(n.createdAt.isAfter(before), isTrue);
        expect(n.updatedAt.isAfter(before), isTrue);
      });

      test('usedInSermon defaults to false', () {
        expect(StudyNote.create(content: 'x').usedInSermon, isFalse);
      });

      test('uses provided fields', () {
        final n = StudyNote.create(
          content: 'Deep dive',
          verseId: 'John-3-16',
          source: 'Calvin',
          tags: ['grace'],
          usedInSermon: true,
        );
        expect(n.verseId, equals('John-3-16'));
        expect(n.source, equals('Calvin'));
        expect(n.tags, equals(['grace']));
        expect(n.usedInSermon, isTrue);
      });
    });

    group('fromJson / toJson', () {
      test('round-trip with all fields', () {
        final n = makeNote(
          verseId: 'Romans-8-28',
          passageRef: 'Romans 8:28-30',
          source: 'Spurgeon',
          tags: ['sovereignty', 'comfort'],
          usedInSermon: true,
        );
        expect(StudyNote.fromJson(n.toJson()), equals(n));
      });

      test('round-trip with null optionals', () {
        final n = makeNote();
        final restored = StudyNote.fromJson(n.toJson());
        expect(restored.verseId, isNull);
        expect(restored.passageRef, isNull);
        expect(restored.source, isNull);
      });

      test('toJson includes all keys', () {
        final json = makeNote().toJson();
        for (final key in [
          'id', 'verseId', 'passageRef', 'content', 'source',
          'tags', 'usedInSermon', 'createdAt', 'updatedAt',
        ]) {
          expect(json.containsKey(key), isTrue, reason: 'missing: $key');
        }
      });
    });

    group('copyWith', () {
      test('changes specified fields', () {
        final n = makeNote(usedInSermon: false);
        final copy = n.copyWith(usedInSermon: true, source: 'Wesley');
        expect(copy.usedInSermon, isTrue);
        expect(copy.source, equals('Wesley'));
        expect(copy.id, equals(n.id));
      });

      test('with no args returns equal copy', () {
        final n = makeNote(
          verseId: 'Gen-1-1',
          source: 'Henry',
          tags: ['creation'],
          usedInSermon: true,
        );
        expect(n.copyWith(), equals(n));
      });

      test('clearVerseId sets to null', () {
        final n = makeNote(verseId: 'Gen-1-1');
        expect(n.copyWith(clearVerseId: true).verseId, isNull);
      });

      test('clearPassageRef sets to null', () {
        final n = makeNote(passageRef: 'Gen 1:1-5');
        expect(n.copyWith(clearPassageRef: true).passageRef, isNull);
      });

      test('clearSource sets to null', () {
        final n = makeNote(source: 'Henry');
        expect(n.copyWith(clearSource: true).source, isNull);
      });
    });

    group('equality', () {
      test('same values are equal', () {
        expect(makeNote(), equals(makeNote()));
        expect(makeNote().hashCode, equals(makeNote().hashCode));
      });

      test('different content is not equal', () {
        expect(makeNote(content: 'a'), isNot(equals(makeNote(content: 'b'))));
      });

      test('different tags is not equal', () {
        expect(
          makeNote(tags: ['a']),
          isNot(equals(makeNote(tags: ['b']))),
        );
      });

      test('different usedInSermon is not equal', () {
        expect(
          makeNote(usedInSermon: true),
          isNot(equals(makeNote(usedInSermon: false))),
        );
      });
    });

    test('toString contains content', () {
      expect(makeNote().toString(), contains('Key observation about this text.'));
    });
  });
}
