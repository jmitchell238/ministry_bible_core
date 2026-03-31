import 'package:test/test.dart';
import 'package:ministry_bible_core/ministry_bible_core.dart';

void main() {
  CrossReference makeRef({
    String from = 'Matthew-5-17',
    String to = 'Isaiah-53-5',
    CrossReferenceType type = CrossReferenceType.fulfillment,
    String? note,
  }) =>
      CrossReference(
        fromVerseId: from,
        toVerseId: to,
        type: type,
        note: note,
      );

  group('CrossReferenceType', () {
    test('has all four values', () {
      expect(CrossReferenceType.values, hasLength(4));
      expect(CrossReferenceType.values, contains(CrossReferenceType.parallel));
      expect(CrossReferenceType.values, contains(CrossReferenceType.fulfillment));
      expect(CrossReferenceType.values, contains(CrossReferenceType.quotation));
      expect(CrossReferenceType.values, contains(CrossReferenceType.thematic));
    });
  });

  group('CrossReference', () {
    test('constructor stores all fields', () {
      final r = makeRef(note: 'Fulfillment of Isaiah');
      expect(r.fromVerseId, equals('Matthew-5-17'));
      expect(r.toVerseId, equals('Isaiah-53-5'));
      expect(r.type, equals(CrossReferenceType.fulfillment));
      expect(r.note, equals('Fulfillment of Isaiah'));
    });

    test('note defaults to null', () {
      expect(makeRef().note, isNull);
    });

    group('fromJson / toJson', () {
      test('round-trip with note', () {
        final r = makeRef(note: 'See also');
        expect(CrossReference.fromJson(r.toJson()), equals(r));
      });

      test('round-trip with null note', () {
        final r = makeRef();
        final restored = CrossReference.fromJson(r.toJson());
        expect(restored.note, isNull);
      });

      test('round-trip for all four type values', () {
        for (final t in CrossReferenceType.values) {
          final r = makeRef(type: t);
          expect(CrossReference.fromJson(r.toJson()).type, equals(t));
        }
      });
    });

    group('copyWith', () {
      test('changes specified fields', () {
        final r = makeRef(type: CrossReferenceType.parallel);
        final copy = r.copyWith(
          type: CrossReferenceType.quotation,
          note: 'New note',
        );
        expect(copy.type, equals(CrossReferenceType.quotation));
        expect(copy.note, equals('New note'));
        expect(copy.fromVerseId, equals(r.fromVerseId));
      });

      test('with no args returns equal copy', () {
        expect(makeRef(note: 'n').copyWith(), equals(makeRef(note: 'n')));
      });

      test('clearNote sets to null', () {
        final r = makeRef(note: 'some note');
        expect(r.copyWith(clearNote: true).note, isNull);
      });
    });

    group('equality', () {
      test('same values are equal', () {
        expect(makeRef(), equals(makeRef()));
        expect(makeRef().hashCode, equals(makeRef().hashCode));
      });

      test('different type is not equal', () {
        expect(
          makeRef(type: CrossReferenceType.parallel),
          isNot(equals(makeRef(type: CrossReferenceType.thematic))),
        );
      });

      test('different fromVerseId is not equal', () {
        expect(makeRef(from: 'A-1-1'), isNot(equals(makeRef(from: 'B-1-1'))));
      });

      test('different toVerseId is not equal', () {
        expect(makeRef(to: 'A-1-1'), isNot(equals(makeRef(to: 'B-1-1'))));
      });

      test('different note is not equal', () {
        expect(makeRef(note: 'a'), isNot(equals(makeRef(note: 'b'))));
      });
    });

    test('toString contains verse ids and type', () {
      final r = makeRef();
      expect(r.toString(), contains('Matthew-5-17'));
      expect(r.toString(), contains('Isaiah-53-5'));
      expect(r.toString(), contains('fulfillment'));
    });
  });
}
