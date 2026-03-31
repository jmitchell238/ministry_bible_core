import 'package:test/test.dart';
import 'package:ministry_bible_core/ministry_bible_core.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

final _fixedDate = DateTime(2026, 3, 30, 10, 0);
final _fixedCreated = DateTime(2026, 1, 1);
final _fixedUpdated = DateTime(2026, 3, 30);

SermonPoint makePoint({
  String heading = 'Introduction',
  String? body,
  String? verseId,
}) =>
    SermonPoint(heading: heading, body: body, verseId: verseId);

SermonOutline makeOutline({
  String id = 'sermon-1',
  String title = 'The Love of God',
  DateTime? date,
  String? seriesName,
  List<String>? scriptureReferences,
  List<SermonPoint>? points,
  SermonStatus status = SermonStatus.draft,
  String? notes,
}) =>
    SermonOutline(
      id: id,
      title: title,
      date: date ?? _fixedDate,
      seriesName: seriesName,
      scriptureReferences: scriptureReferences ?? ['John-3-16'],
      points: points ?? [makePoint()],
      status: status,
      notes: notes,
      createdAt: _fixedCreated,
      updatedAt: _fixedUpdated,
    );

// ── SermonStatus ──────────────────────────────────────────────────────────────

void main() {
  group('SermonStatus', () {
    test('has draft and delivered values', () {
      expect(SermonStatus.values, contains(SermonStatus.draft));
      expect(SermonStatus.values, contains(SermonStatus.delivered));
      expect(SermonStatus.values, hasLength(2));
    });

    test('name returns correct string', () {
      expect(SermonStatus.draft.name, equals('draft'));
      expect(SermonStatus.delivered.name, equals('delivered'));
    });
  });

  // ── SermonPoint ─────────────────────────────────────────────────────────────

  group('SermonPoint', () {
    test('constructor stores all fields', () {
      final p = SermonPoint(
        heading: 'Main Point',
        body: 'God is love.',
        verseId: '1John-4-8',
      );
      expect(p.heading, equals('Main Point'));
      expect(p.body, equals('God is love.'));
      expect(p.verseId, equals('1John-4-8'));
    });

    test('nullable fields default to null', () {
      final p = SermonPoint(heading: 'Empty');
      expect(p.body, isNull);
      expect(p.verseId, isNull);
    });

    group('fromJson / toJson', () {
      test('round-trip with all fields', () {
        final p = SermonPoint(
          heading: 'Faith',
          body: 'Faith is the substance...',
          verseId: 'Hebrews-11-1',
        );
        final json = p.toJson();
        final restored = SermonPoint.fromJson(json);
        expect(restored, equals(p));
      });

      test('round-trip with null optional fields', () {
        final p = SermonPoint(heading: 'Point 1');
        final json = p.toJson();
        final restored = SermonPoint.fromJson(json);
        expect(restored.heading, equals('Point 1'));
        expect(restored.body, isNull);
        expect(restored.verseId, isNull);
      });

      test('toJson includes all keys', () {
        final p = SermonPoint(heading: 'H', body: 'B', verseId: 'V');
        final json = p.toJson();
        expect(json.containsKey('heading'), isTrue);
        expect(json.containsKey('body'), isTrue);
        expect(json.containsKey('verseId'), isTrue);
      });
    });

    group('copyWith', () {
      test('changes specified fields', () {
        final p = makePoint(heading: 'Old', body: 'Old body', verseId: 'Gen-1-1');
        final copy = p.copyWith(heading: 'New');
        expect(copy.heading, equals('New'));
        expect(copy.body, equals('Old body'));
        expect(copy.verseId, equals('Gen-1-1'));
      });

      test('with no args returns equal copy', () {
        final p = makePoint(heading: 'H', body: 'B', verseId: 'John-3-16');
        final copy = p.copyWith();
        expect(copy, equals(p));
      });

      test('clearBody sets body to null', () {
        final p = makePoint(body: 'some body');
        final copy = p.copyWith(clearBody: true);
        expect(copy.body, isNull);
      });

      test('clearVerseId sets verseId to null', () {
        final p = makePoint(verseId: 'John-3-16');
        final copy = p.copyWith(clearVerseId: true);
        expect(copy.verseId, isNull);
      });
    });

    group('equality', () {
      test('same values are equal', () {
        final p1 = makePoint(heading: 'H', body: 'B', verseId: 'John-3-16');
        final p2 = makePoint(heading: 'H', body: 'B', verseId: 'John-3-16');
        expect(p1, equals(p2));
        expect(p1.hashCode, equals(p2.hashCode));
      });

      test('different heading is not equal', () {
        final p1 = makePoint(heading: 'A');
        final p2 = makePoint(heading: 'B');
        expect(p1, isNot(equals(p2)));
      });

      test('different body is not equal', () {
        final p1 = makePoint(body: 'one');
        final p2 = makePoint(body: 'two');
        expect(p1, isNot(equals(p2)));
      });

      test('different verseId is not equal', () {
        final p1 = makePoint(verseId: 'John-3-16');
        final p2 = makePoint(verseId: 'Gen-1-1');
        expect(p1, isNot(equals(p2)));
      });
    });

    test('toString contains heading', () {
      final p = makePoint(heading: 'Grace');
      expect(p.toString(), contains('Grace'));
    });
  });

  // ── SermonOutline ────────────────────────────────────────────────────────────

  group('SermonOutline', () {
    test('constructor stores all fields', () {
      final s = makeOutline(
        title: 'Test Sermon',
        seriesName: 'Series A',
        notes: 'My notes',
        status: SermonStatus.delivered,
      );
      expect(s.title, equals('Test Sermon'));
      expect(s.seriesName, equals('Series A'));
      expect(s.notes, equals('My notes'));
      expect(s.status, equals(SermonStatus.delivered));
      expect(s.date, equals(_fixedDate));
      expect(s.createdAt, equals(_fixedCreated));
      expect(s.updatedAt, equals(_fixedUpdated));
    });

    test('nullable fields default to null', () {
      final s = SermonOutline(
        id: 'x',
        title: 'T',
        scriptureReferences: const [],
        points: const [],
        status: SermonStatus.draft,
        createdAt: _fixedCreated,
        updatedAt: _fixedUpdated,
      );
      expect(s.date, isNull);
      expect(s.seriesName, isNull);
      expect(s.notes, isNull);
    });

    group('SermonOutline.create', () {
      test('generates non-empty id and sets timestamps', () {
        final before = DateTime.now().subtract(const Duration(seconds: 1));
        final s = SermonOutline.create(title: 'New Sermon');
        expect(s.id, isNotEmpty);
        expect(s.createdAt.isAfter(before), isTrue);
        expect(s.updatedAt.isAfter(before), isTrue);
        expect(s.status, equals(SermonStatus.draft));
      });

      test('uses provided optional fields', () {
        final date = DateTime(2026, 4, 6);
        final s = SermonOutline.create(
          title: 'Easter Sermon',
          date: date,
          seriesName: 'Easter Series',
          scriptureReferences: ['John-11-25'],
          points: [makePoint(heading: 'Resurrection')],
          status: SermonStatus.delivered,
          notes: 'Preached Easter morning',
        );
        expect(s.title, equals('Easter Sermon'));
        expect(s.date, equals(date));
        expect(s.seriesName, equals('Easter Series'));
        expect(s.scriptureReferences, equals(['John-11-25']));
        expect(s.points, hasLength(1));
        expect(s.status, equals(SermonStatus.delivered));
        expect(s.notes, equals('Preached Easter morning'));
      });

      test('lists are copies, not aliases', () {
        final refs = ['John-3-16'];
        final pts = [makePoint()];
        final s = SermonOutline.create(
          title: 'T',
          scriptureReferences: refs,
          points: pts,
        );
        refs.add('Gen-1-1');
        pts.add(makePoint(heading: 'Extra'));
        expect(s.scriptureReferences, hasLength(1));
        expect(s.points, hasLength(1));
      });
    });

    group('fromJson / toJson', () {
      test('round-trip with all fields', () {
        final s = makeOutline(
          seriesName: 'Last Things',
          notes: 'Great study',
          status: SermonStatus.delivered,
          scriptureReferences: ['Rev-21-1', 'Rev-22-1'],
          points: [
            makePoint(heading: 'New Heaven', body: 'desc', verseId: 'Rev-21-1'),
            makePoint(heading: 'New Earth'),
          ],
        );
        final json = s.toJson();
        final restored = SermonOutline.fromJson(json);
        expect(restored, equals(s));
      });

      test('round-trip with null optional fields', () {
        final s = SermonOutline(
          id: 'x',
          title: 'Standalone',
          scriptureReferences: const [],
          points: const [],
          status: SermonStatus.draft,
          createdAt: _fixedCreated,
          updatedAt: _fixedUpdated,
        );
        final json = s.toJson();
        final restored = SermonOutline.fromJson(json);
        expect(restored.date, isNull);
        expect(restored.seriesName, isNull);
        expect(restored.notes, isNull);
      });

      test('fromJson parses date correctly', () {
        final s = makeOutline(date: DateTime(2026, 3, 29));
        final json = s.toJson();
        final restored = SermonOutline.fromJson(json);
        expect(restored.date, equals(DateTime(2026, 3, 29)));
      });

      test('fromJson parses both SermonStatus values', () {
        final draft = makeOutline(status: SermonStatus.draft);
        final delivered = makeOutline(status: SermonStatus.delivered);
        expect(
          SermonOutline.fromJson(draft.toJson()).status,
          equals(SermonStatus.draft),
        );
        expect(
          SermonOutline.fromJson(delivered.toJson()).status,
          equals(SermonStatus.delivered),
        );
      });

      test('toJson includes all keys', () {
        final json = makeOutline().toJson();
        for (final key in [
          'id', 'title', 'date', 'seriesName', 'scriptureReferences',
          'points', 'status', 'notes', 'createdAt', 'updatedAt',
        ]) {
          expect(json.containsKey(key), isTrue, reason: 'missing key: $key');
        }
      });
    });

    group('copyWith', () {
      test('changes specified fields', () {
        final s = makeOutline(title: 'Old Title', status: SermonStatus.draft);
        final copy = s.copyWith(
          title: 'New Title',
          status: SermonStatus.delivered,
        );
        expect(copy.title, equals('New Title'));
        expect(copy.status, equals(SermonStatus.delivered));
        expect(copy.id, equals(s.id));
      });

      test('with no args returns equal copy', () {
        final s = makeOutline(
          seriesName: 'Series',
          notes: 'notes',
          scriptureReferences: ['John-3-16'],
          points: [makePoint()],
        );
        final copy = s.copyWith();
        expect(copy, equals(s));
      });

      test('list defaults do not alias original', () {
        final s = makeOutline(scriptureReferences: ['John-3-16']);
        final copy = s.copyWith();
        expect(copy.scriptureReferences, equals(s.scriptureReferences));
      });

      test('clearDate sets date to null', () {
        final s = makeOutline(date: _fixedDate);
        final copy = s.copyWith(clearDate: true);
        expect(copy.date, isNull);
      });

      test('clearSeriesName sets seriesName to null', () {
        final s = makeOutline(seriesName: 'Series A');
        final copy = s.copyWith(clearSeriesName: true);
        expect(copy.seriesName, isNull);
      });

      test('clearNotes sets notes to null', () {
        final s = makeOutline(notes: 'some notes');
        final copy = s.copyWith(clearNotes: true);
        expect(copy.notes, isNull);
      });

      test('can update scriptureReferences and points', () {
        final s = makeOutline();
        final newRefs = ['Gen-1-1', 'John-3-16'];
        final newPoints = [makePoint(heading: 'P1'), makePoint(heading: 'P2')];
        final copy = s.copyWith(
          scriptureReferences: newRefs,
          points: newPoints,
        );
        expect(copy.scriptureReferences, equals(newRefs));
        expect(copy.points, hasLength(2));
      });
    });

    group('equality', () {
      test('same values are equal', () {
        final s1 = makeOutline();
        final s2 = makeOutline();
        expect(s1, equals(s2));
        expect(s1.hashCode, equals(s2.hashCode));
      });

      test('different title is not equal', () {
        final s1 = makeOutline(title: 'A');
        final s2 = makeOutline(title: 'B');
        expect(s1, isNot(equals(s2)));
      });

      test('different status is not equal', () {
        final s1 = makeOutline(status: SermonStatus.draft);
        final s2 = makeOutline(status: SermonStatus.delivered);
        expect(s1, isNot(equals(s2)));
      });

      test('different scriptureReferences is not equal', () {
        final s1 = makeOutline(scriptureReferences: ['John-3-16']);
        final s2 = makeOutline(scriptureReferences: ['Gen-1-1']);
        expect(s1, isNot(equals(s2)));
      });

      test('different points is not equal', () {
        final s1 = makeOutline(points: [makePoint(heading: 'A')]);
        final s2 = makeOutline(points: [makePoint(heading: 'B')]);
        expect(s1, isNot(equals(s2)));
      });
    });

    test('toString contains title and status', () {
      final s = makeOutline(title: 'Grace Alone');
      expect(s.toString(), contains('Grace Alone'));
      expect(s.toString(), contains('draft'));
    });
  });
}
