import 'package:ministry_bible_core/ministry_bible_core.dart';

void main() {
  // Detect scripture references in text
  final refs = ScriptureAutoDetector.detect('Read John 3:16 and Gen 1:1 today.');
  for (final ref in refs) {
    print('${ref.book} ${ref.chapter}:${ref.verseStart} — "${ref.rawText}"');
  }

  // Encode/decode verse IDs
  final id = VerseId.encode('Song of Solomon', 3, 2);
  print('Verse ID: $id'); // SongofSolomon-3-2
  final decoded = VerseId.decode(id);
  print('Decoded: ${decoded.book} ${decoded.chapter}:${decoded.verse}');
}
