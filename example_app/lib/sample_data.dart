import 'package:ministry_bible_core/ministry_bible_core.dart';

// ---------------------------------------------------------------------------
// Small in-memory KJV sample (public domain) used by the demo app.
// Three books: Genesis, Psalms, John — enough to exercise every service.
// ---------------------------------------------------------------------------

class DemoAssetLoader implements BibleAssetLoader {
  @override
  Future<List<BibleBook>> loadBooks() async => _books;
}

BibleVerse _v(
  int bookId,
  String bookName,
  int chapter,
  int number,
  String text,
) =>
    BibleVerse(
      id: '${bookName.replaceAll(' ', '')}-$chapter-$number',
      bookId: bookId,
      chapter: chapter,
      number: number,
      text: text,
      wordCount: text.split(' ').length,
    );

final List<BibleBook> _books = [
  // ── Genesis (book 1, OT) ─────────────────────────────────────────────────
  BibleBook(
    id: 1,
    name: 'Genesis',
    testament: 'OT',
    chapters: [
      BibleChapter(bookId: 1, number: 1, verses: [
        _v(1, 'Genesis', 1, 1, 'In the beginning God created the heaven and the earth.'),
        _v(1, 'Genesis', 1, 2, 'And the earth was without form, and void; and darkness was upon the face of the deep.'),
        _v(1, 'Genesis', 1, 3, 'And God said, Let there be light: and there was light.'),
        _v(1, 'Genesis', 1, 4, 'And God saw the light, that it was good: and God divided the light from the darkness.'),
        _v(1, 'Genesis', 1, 26, 'And God said, Let us make man in our image, after our likeness.'),
        _v(1, 'Genesis', 1, 27, 'So God created man in his own image, in the image of God created he him.'),
        _v(1, 'Genesis', 1, 31, 'And God saw every thing that he had made, and, behold, it was very good.'),
      ]),
      BibleChapter(bookId: 1, number: 50, verses: [
        _v(1, 'Genesis', 50, 20, 'But as for you, ye thought evil against me; but God meant it unto good.'),
      ]),
    ],
  ),

  // ── Psalms (book 19, OT) ─────────────────────────────────────────────────
  BibleBook(
    id: 19,
    name: 'Psalms',
    testament: 'OT',
    chapters: [
      BibleChapter(bookId: 19, number: 23, verses: [
        _v(19, 'Psalms', 23, 1, 'The LORD is my shepherd; I shall not want.'),
        _v(19, 'Psalms', 23, 2, 'He maketh me to lie down in green pastures: he leadeth me beside the still waters.'),
        _v(19, 'Psalms', 23, 3, 'He restoreth my soul: he leadeth me in the paths of righteousness for his name\'s sake.'),
        _v(19, 'Psalms', 23, 4, 'Yea, though I walk through the valley of the shadow of death, I will fear no evil.'),
        _v(19, 'Psalms', 23, 5, 'Thou preparest a table before me in the presence of mine enemies.'),
        _v(19, 'Psalms', 23, 6, 'Surely goodness and mercy shall follow me all the days of my life.'),
      ]),
      BibleChapter(bookId: 19, number: 46, verses: [
        _v(19, 'Psalms', 46, 1, 'God is our refuge and strength, a very present help in trouble.'),
        _v(19, 'Psalms', 46, 10, 'Be still, and know that I am God: I will be exalted among the heathen.'),
      ]),
      BibleChapter(bookId: 19, number: 119, verses: [
        _v(19, 'Psalms', 119, 9, 'Wherewithal shall a young man cleanse his way? by taking heed thereto according to thy word.'),
        _v(19, 'Psalms', 119, 11, 'Thy word have I hid in mine heart, that I might not sin against thee.'),
        _v(19, 'Psalms', 119, 105, 'Thy word is a lamp unto my feet, and a light unto my path.'),
      ]),
    ],
  ),

  // ── John (book 43, NT) ────────────────────────────────────────────────────
  BibleBook(
    id: 43,
    name: 'John',
    testament: 'NT',
    chapters: [
      BibleChapter(bookId: 43, number: 1, verses: [
        _v(43, 'John', 1, 1, 'In the beginning was the Word, and the Word was with God, and the Word was God.'),
        _v(43, 'John', 1, 2, 'The same was in the beginning with God.'),
        _v(43, 'John', 1, 14, 'And the Word was made flesh, and dwelt among us, and we beheld his glory.'),
      ]),
      BibleChapter(bookId: 43, number: 3, verses: [
        _v(43, 'John', 3, 16, 'For God so loved the world, that he gave his only begotten Son, that whosoever believeth in him should not perish, but have everlasting life.'),
        _v(43, 'John', 3, 17, 'For God sent not his Son into the world to condemn the world; but that the world through him might be saved.'),
      ]),
      BibleChapter(bookId: 43, number: 14, verses: [
        _v(43, 'John', 14, 1, 'Let not your heart be troubled: ye believe in God, believe also in me.'),
        _v(43, 'John', 14, 6, 'Jesus saith unto him, I am the way, the truth, and the life.'),
        _v(43, 'John', 14, 27, 'Peace I leave with you, my peace I give unto you: not as the world giveth, give I unto you.'),
      ]),
    ],
  ),

  // ── Philippians (book 50, NT) ─────────────────────────────────────────────
  BibleBook(
    id: 50,
    name: 'Philippians',
    testament: 'NT',
    chapters: [
      BibleChapter(bookId: 50, number: 4, verses: [
        _v(50, 'Philippians', 4, 4, 'Rejoice in the Lord alway: and again I say, Rejoice.'),
        _v(50, 'Philippians', 4, 6, 'Be careful for nothing; but in every thing by prayer and supplication with thanksgiving.'),
        _v(50, 'Philippians', 4, 7, 'And the peace of God, which passeth all understanding, shall keep your hearts and minds through Christ Jesus.'),
        _v(50, 'Philippians', 4, 8, 'Finally, brethren, whatsoever things are true, whatsoever things are honest, think on these things.'),
        _v(50, 'Philippians', 4, 13, 'I can do all things through Christ which strengtheneth me.'),
        _v(50, 'Philippians', 4, 19, 'But my God shall supply all your need according to his riches in glory by Christ Jesus.'),
      ]),
    ],
  ),
];

/// Pre-loaded BibleContentService using the demo data.
Future<BibleContentService> buildDemoService() async {
  final svc = BibleContentService(DemoAssetLoader());
  await svc.load();
  return svc;
}
