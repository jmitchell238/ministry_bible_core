import 'package:test/test.dart';
import 'package:ministry_bible_core/ministry_bible_core.dart';
import '../helpers/in_memory_repositories.dart';

ReadingNote makeNote({
  required String id,
  List<String> tags = const [],
}) =>
    ReadingNote(
      id: id,
      type: NoteType.daily,
      content: 'content',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      tags: tags,
    );

void main() {
  late InMemoryReadingNoteRepository repo;
  late TagService service;

  setUp(() {
    repo = InMemoryReadingNoteRepository();
    service = TagService(repo);
  });

  group('TagService.listAll', () {
    test('returns empty list when no notes', () async {
      expect(await service.listAll(), isEmpty);
    });

    test('returns unique sorted tags across all notes', () async {
      await repo.add(makeNote(id: '1', tags: ['faith', 'hope']));
      await repo.add(makeNote(id: '2', tags: ['hope', 'love']));
      expect(await service.listAll(), equals(['faith', 'hope', 'love']));
    });

    test('deduplicates tags that appear in multiple notes', () async {
      await repo.add(makeNote(id: '1', tags: ['grace']));
      await repo.add(makeNote(id: '2', tags: ['grace']));
      expect(await service.listAll(), equals(['grace']));
    });
  });

  group('TagService.rename', () {
    test('renames tag on all affected notes', () async {
      await repo.add(makeNote(id: '1', tags: ['old', 'other']));
      await repo.add(makeNote(id: '2', tags: ['old']));
      await repo.add(makeNote(id: '3', tags: ['unrelated']));

      await service.rename('old', 'new');

      final all = await repo.getAll();
      final note1 = all.firstWhere((n) => n.id == '1');
      final note2 = all.firstWhere((n) => n.id == '2');
      final note3 = all.firstWhere((n) => n.id == '3');

      expect(note1.tags, containsAll(['new', 'other']));
      expect(note1.tags, isNot(contains('old')));
      expect(note2.tags, contains('new'));
      expect(note3.tags, equals(['unrelated']));
    });

    test('no-op when tag does not exist', () async {
      await repo.add(makeNote(id: '1', tags: ['faith']));
      await service.rename('nonexistent', 'new');
      final note = (await repo.getAll()).first;
      expect(note.tags, equals(['faith']));
    });
  });

  group('TagService.merge', () {
    test('replaces source with target on affected notes', () async {
      await repo.add(makeNote(id: '1', tags: ['old', 'keep']));
      await repo.add(makeNote(id: '2', tags: ['old', 'target']));

      await service.merge('old', 'target');

      final all = await repo.getAll();
      final note1 = all.firstWhere((n) => n.id == '1');
      final note2 = all.firstWhere((n) => n.id == '2');

      expect(note1.tags, contains('target'));
      expect(note1.tags, isNot(contains('old')));
      expect(note2.tags, contains('target'));
      expect(note2.tags, isNot(contains('old')));
      // should not duplicate 'target'
      expect(note2.tags.where((t) => t == 'target'), hasLength(1));
    });

    test('no-op when source tag does not exist', () async {
      await repo.add(makeNote(id: '1', tags: ['faith']));
      await service.merge('nonexistent', 'faith');
      expect((await repo.getAll()).first.tags, equals(['faith']));
    });
  });

  group('TagService.delete', () {
    test('removes tag from all notes that carry it', () async {
      await repo.add(makeNote(id: '1', tags: ['remove', 'keep']));
      await repo.add(makeNote(id: '2', tags: ['remove']));
      await repo.add(makeNote(id: '3', tags: ['keep']));

      await service.delete('remove');

      final all = await repo.getAll();
      for (final note in all) {
        expect(note.tags, isNot(contains('remove')));
      }
      final note1 = all.firstWhere((n) => n.id == '1');
      expect(note1.tags, contains('keep'));
    });

    test('no-op when tag does not exist', () async {
      await repo.add(makeNote(id: '1', tags: ['faith']));
      await service.delete('nonexistent');
      expect((await repo.getAll()).first.tags, equals(['faith']));
    });
  });
}
