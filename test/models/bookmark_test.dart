import 'package:test/test.dart';
import 'package:ministry_bible_core/ministry_bible_core.dart';

void main() {
  final fixedDate = DateTime(2026, 1, 15, 12, 0);

  Bookmark makeBookmark({
    String id = 'test-id',
    String verseId = 'Genesis-1-1',
    int bookId = 1,
    int chapter = 1,
    int verseNumber = 1,
    String note = '',
    String? collectionId,
    int? color,
  }) =>
      Bookmark(
        id: id,
        verseId: verseId,
        bookId: bookId,
        chapter: chapter,
        verseNumber: verseNumber,
        note: note,
        collectionId: collectionId,
        createdAt: fixedDate,
        color: color,
      );

  group('Bookmark', () {
    test('fromJson/toJson round-trip', () {
      final b = makeBookmark(note: 'my note', collectionId: 'col-1', color: 0xFF0000FF);
      final json = b.toJson();
      final restored = Bookmark.fromJson(json);
      expect(restored, equals(b));
    });

    test('fromJson defaults note to empty string when absent', () {
      final json = {
        'id': 'id',
        'verseId': 'Genesis-1-1',
        'bookId': 1,
        'chapter': 1,
        'verseNumber': 1,
        'createdAt': fixedDate.toIso8601String(),
      };
      final b = Bookmark.fromJson(json);
      expect(b.note, equals(''));
      expect(b.collectionId, isNull);
      expect(b.color, isNull);
    });

    test('Bookmark.create generates id and sets createdAt', () {
      final b = Bookmark.create(
        verseId: 'John-3-16',
        bookId: 43,
        chapter: 3,
        verseNumber: 16,
        note: 'key verse',
      );
      expect(b.id, isNotEmpty);
      expect(b.verseId, equals('John-3-16'));
      expect(b.note, equals('key verse'));
      expect(b.collectionId, isNull);
    });

    test('copyWith changes specified fields', () {
      final b = makeBookmark();
      final copy = b.copyWith(note: 'updated', color: 0xFFFF0000);
      expect(copy.note, equals('updated'));
      expect(copy.id, equals(b.id));
    });

    test('clearCollectionId sets to null', () {
      final b = makeBookmark(collectionId: 'col-1');
      final copy = b.copyWith(clearCollectionId: true);
      expect(copy.collectionId, isNull);
    });

    test('equality — same values equal', () {
      final b1 = makeBookmark();
      final b2 = makeBookmark();
      expect(b1, equals(b2));
    });

    test('equality — different note is not equal', () {
      final b1 = makeBookmark(note: '');
      final b2 = makeBookmark(note: 'note');
      expect(b1, isNot(equals(b2)));
    });

    test('toString contains key fields', () {
      final b = makeBookmark(verseId: 'John-3-16');
      expect(b.toString(), contains('John-3-16'));
    });
  });

  group('BookmarkCollection', () {
    test('fromJson/toJson round-trip', () {
      final c = BookmarkCollection(
        id: 'col-1',
        name: 'Favorites',
        description: 'My faves',
        createdAt: fixedDate,
        color: 0xFFFF0000,
      );
      final json = c.toJson();
      final restored = BookmarkCollection.fromJson(json);
      expect(restored, equals(c));
    });

    test('BookmarkCollection.create generates id', () {
      final c = BookmarkCollection.create(name: 'Prayer');
      expect(c.id, isNotEmpty);
      expect(c.name, equals('Prayer'));
      expect(c.description, isNull);
    });

    test('copyWith', () {
      final c = BookmarkCollection(
        id: 'col-1',
        name: 'Old',
        createdAt: fixedDate,
      );
      final copy = c.copyWith(name: 'New');
      expect(copy.name, equals('New'));
      expect(copy.id, equals(c.id));
    });

    test('clearDescription sets to null', () {
      final c = BookmarkCollection(
        id: 'col-1',
        name: 'Test',
        description: 'desc',
        createdAt: fixedDate,
      );
      final copy = c.copyWith(clearDescription: true);
      expect(copy.description, isNull);
    });

    test('equality', () {
      final c1 = BookmarkCollection(
        id: 'col-1',
        name: 'Favorites',
        createdAt: fixedDate,
      );
      final c2 = BookmarkCollection(
        id: 'col-1',
        name: 'Favorites',
        createdAt: fixedDate,
      );
      expect(c1, equals(c2));
    });
  });

  group('ReadingNote', () {
    test('fromJson/toJson round-trip — daily note', () {
      final note = ReadingNote(
        id: 'note-1',
        type: NoteType.daily,
        content: 'Today I read...',
        createdAt: fixedDate,
        updatedAt: fixedDate,
        date: DateTime(2026, 1, 15),
        tags: ['prayer', 'reflection'],
        isPinned: false,
      );
      final json = note.toJson();
      final restored = ReadingNote.fromJson(json);
      expect(restored, equals(note));
    });

    test('fromJson/toJson round-trip — verse note', () {
      final note = ReadingNote(
        id: 'note-2',
        type: NoteType.verse,
        content: 'Key observation',
        createdAt: fixedDate,
        updatedAt: fixedDate,
        verseId: 'John-3-16',
        isPinned: true,
      );
      final json = note.toJson();
      final restored = ReadingNote.fromJson(json);
      expect(restored, equals(note));
      expect(restored.isPinned, isTrue);
    });

    test('ReadingNote.create generates id and timestamps', () {
      final note = ReadingNote.create(
        type: NoteType.chapter,
        content: 'Genesis 1 notes',
        bookId: 1,
        chapter: 1,
      );
      expect(note.id, isNotEmpty);
      expect(note.type, equals(NoteType.chapter));
      expect(note.bookId, equals(1));
    });

    test('generateDailyKey formats YYYY-MM-DD', () {
      expect(ReadingNote.generateDailyKey(DateTime(2026, 3, 5)), equals('2026-03-05'));
      expect(ReadingNote.generateDailyKey(DateTime(2026, 12, 31)), equals('2026-12-31'));
    });

    test('generateChapterKey', () {
      expect(ReadingNote.generateChapterKey(1, 3), equals('1-3'));
    });

    test('generateVerseKey', () {
      expect(ReadingNote.generateVerseKey('Genesis-1-1'), equals('Genesis-1-1'));
    });

    test('getDisplayReference — daily', () {
      final note = ReadingNote(
        id: 'n',
        type: NoteType.daily,
        content: 'x',
        createdAt: fixedDate,
        updatedAt: fixedDate,
        date: DateTime(2026, 1, 15),
      );
      expect(note.getDisplayReference(), equals('Jan 15, 2026'));
    });

    test('getDisplayReference — chapter', () {
      final note = ReadingNote(
        id: 'n',
        type: NoteType.chapter,
        content: 'x',
        createdAt: fixedDate,
        updatedAt: fixedDate,
        bookId: 1,
        chapter: 3,
      );
      expect(note.getDisplayReference(), contains('Chapter 3'));
    });

    test('getDisplayReference — verse', () {
      final note = ReadingNote(
        id: 'n',
        type: NoteType.verse,
        content: 'x',
        createdAt: fixedDate,
        updatedAt: fixedDate,
        verseId: 'John-3-16',
      );
      expect(note.getDisplayReference(), equals('John 3:16'));
    });

    test('copyWith updates tags without aliasing', () {
      final note = ReadingNote(
        id: 'n',
        type: NoteType.daily,
        content: 'x',
        createdAt: fixedDate,
        updatedAt: fixedDate,
        tags: ['a'],
      );
      final copy = note.copyWith(tags: ['a', 'b']);
      expect(copy.tags, equals(['a', 'b']));
      expect(note.tags, equals(['a'])); // original unchanged
    });

    test('tags defaults to empty list', () {
      final note = ReadingNote(
        id: 'n',
        type: NoteType.daily,
        content: 'x',
        createdAt: fixedDate,
        updatedAt: fixedDate,
      );
      expect(note.tags, isEmpty);
    });

    test('equality', () {
      final n1 = ReadingNote(
        id: 'n',
        type: NoteType.daily,
        content: 'content',
        createdAt: fixedDate,
        updatedAt: fixedDate,
        tags: ['a'],
      );
      final n2 = ReadingNote(
        id: 'n',
        type: NoteType.daily,
        content: 'content',
        createdAt: fixedDate,
        updatedAt: fixedDate,
        tags: ['a'],
      );
      expect(n1, equals(n2));
    });

    test('formatDate', () {
      expect(ReadingNote.formatDate(DateTime(2026, 3, 5)), equals('Mar 5, 2026'));
    });

    test('hashCode is consistent', () {
      final n1 = ReadingNote(
        id: 'n',
        type: NoteType.daily,
        content: 'x',
        createdAt: fixedDate,
        updatedAt: fixedDate,
      );
      final n2 = ReadingNote(
        id: 'n',
        type: NoteType.daily,
        content: 'x',
        createdAt: fixedDate,
        updatedAt: fixedDate,
      );
      expect(n1.hashCode, equals(n2.hashCode));
    });

    test('toString contains key fields', () {
      final note = ReadingNote(
        id: 'note-1',
        type: NoteType.verse,
        content: 'my note',
        createdAt: fixedDate,
        updatedAt: fixedDate,
        verseId: 'John-3-16',
      );
      expect(note.toString(), contains('note-1'));
      expect(note.toString(), contains('my note'));
    });

    test('copyWith with no args returns equal copy', () {
      final note = ReadingNote(
        id: 'n',
        type: NoteType.chapter,
        content: 'x',
        createdAt: fixedDate,
        updatedAt: fixedDate,
        bookId: 1,
        chapter: 3,
        tags: ['faith'],
        isPinned: true,
      );
      final copy = note.copyWith();
      expect(copy.id, equals(note.id));
      expect(copy.bookId, equals(note.bookId));
      expect(copy.chapter, equals(note.chapter));
      expect(copy.tags, equals(note.tags));
      expect(copy.isPinned, equals(note.isPinned));
    });

    test('getDisplayReference — verse with short verseId falls back to verseId', () {
      final note = ReadingNote(
        id: 'n',
        type: NoteType.verse,
        content: 'x',
        createdAt: fixedDate,
        updatedAt: fixedDate,
        verseId: 'John-3',
      );
      expect(note.getDisplayReference(), equals('John-3'));
    });

    test('getDisplayReference — verse with null verseId returns Verse Note', () {
      final note = ReadingNote(
        id: 'n',
        type: NoteType.verse,
        content: 'x',
        createdAt: fixedDate,
        updatedAt: fixedDate,
      );
      expect(note.getDisplayReference(), equals('Verse Note'));
    });

    test('getDisplayReference — daily with null date returns Daily Note', () {
      final note = ReadingNote(
        id: 'n',
        type: NoteType.daily,
        content: 'x',
        createdAt: fixedDate,
        updatedAt: fixedDate,
      );
      expect(note.getDisplayReference(), equals('Daily Note'));
    });

    test('getDisplayReference — chapter with null bookId returns Chapter Note', () {
      final note = ReadingNote(
        id: 'n',
        type: NoteType.chapter,
        content: 'x',
        createdAt: fixedDate,
        updatedAt: fixedDate,
        chapter: 3,
      );
      expect(note.getDisplayReference(), equals('Chapter Note'));
    });
  });

  group('Bookmark value semantics', () {
    final fixedDate = DateTime(2026, 1, 15, 12, 0);

    test('hashCode is consistent', () {
      final b1 = Bookmark(
        id: 'b',
        verseId: 'Genesis-1-1',
        bookId: 1,
        chapter: 1,
        verseNumber: 1,
        note: '',
        createdAt: fixedDate,
      );
      final b2 = Bookmark(
        id: 'b',
        verseId: 'Genesis-1-1',
        bookId: 1,
        chapter: 1,
        verseNumber: 1,
        note: '',
        createdAt: fixedDate,
      );
      expect(b1.hashCode, equals(b2.hashCode));
    });

    test('toString contains key fields', () {
      final b = Bookmark(
        id: 'bm-1',
        verseId: 'John-3-16',
        bookId: 43,
        chapter: 3,
        verseNumber: 16,
        note: 'favorite',
        createdAt: fixedDate,
      );
      expect(b.toString(), contains('John-3-16'));
      expect(b.toString(), contains('bm-1'));
    });
  });

  group('BookmarkCollection value semantics', () {
    final fixedDate = DateTime(2026, 1, 15, 12, 0);

    test('hashCode is consistent', () {
      final c1 = BookmarkCollection(
        id: 'col',
        name: 'Favorites',
        createdAt: fixedDate,
      );
      final c2 = BookmarkCollection(
        id: 'col',
        name: 'Favorites',
        createdAt: fixedDate,
      );
      expect(c1.hashCode, equals(c2.hashCode));
    });

    test('toString contains key fields', () {
      final c = BookmarkCollection(
        id: 'col-1',
        name: 'My Collection',
        createdAt: fixedDate,
      );
      expect(c.toString(), contains('col-1'));
      expect(c.toString(), contains('My Collection'));
    });
  });
}
