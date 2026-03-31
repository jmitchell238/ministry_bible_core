/// Result of detecting a scripture reference in plain text.
class DetectedScriptureRef {
  final String rawText;
  final String book;
  final int chapter;
  final int verseStart;
  final int? verseEnd;
  final int startOffset;
  final int endOffset;

  const DetectedScriptureRef({
    required this.rawText,
    required this.book,
    required this.chapter,
    required this.verseStart,
    this.verseEnd,
    required this.startOffset,
    required this.endOffset,
  });
}

/// Scans plain text for Bible scripture references using a regex and
/// returns [DetectedScriptureRef] objects for each match.
///
/// Matches forms like:
///   "John 3:16"  "Gen 1:1-3"  "1 Cor 13:4"  "Ps 23:1"
///
/// Numbered books may appear as "1 John", "1John", "1 Cor", "1Cor", etc.
abstract final class ScriptureAutoDetector {

  // ── Abbreviation → canonical book name ───────────────────────────────────

  static const Map<String, String> _abbrevMap = {
    // Old Testament
    'genesis': 'Genesis',
    'gen': 'Genesis',
    'exodus': 'Exodus',
    'exo': 'Exodus',
    'ex': 'Exodus',
    'leviticus': 'Leviticus',
    'lev': 'Leviticus',
    'lv': 'Leviticus',
    'numbers': 'Numbers',
    'num': 'Numbers',
    'nm': 'Numbers',
    'deuteronomy': 'Deuteronomy',
    'deut': 'Deuteronomy',
    'deu': 'Deuteronomy',
    'dt': 'Deuteronomy',
    'joshua': 'Joshua',
    'josh': 'Joshua',
    'jos': 'Joshua',
    'judges': 'Judges',
    'judg': 'Judges',
    'jdg': 'Judges',
    'jg': 'Judges',
    'ruth': 'Ruth',
    'rth': 'Ruth',
    'rt': 'Ruth',
    'ezra': 'Ezra',
    'ezr': 'Ezra',
    'nehemiah': 'Nehemiah',
    'neh': 'Nehemiah',
    'esther': 'Esther',
    'esth': 'Esther',
    'est': 'Esther',
    'job': 'Job',
    'psalms': 'Psalms',
    'psalm': 'Psalms',
    'psa': 'Psalms',
    'ps': 'Psalms',
    'proverbs': 'Proverbs',
    'prov': 'Proverbs',
    'pro': 'Proverbs',
    'prv': 'Proverbs',
    'ecclesiastes': 'Ecclesiastes',
    'eccl': 'Ecclesiastes',
    'ecc': 'Ecclesiastes',
    'song of solomon': 'Song of Solomon',
    'song': 'Song of Solomon',
    'sos': 'Song of Solomon',
    'ss': 'Song of Solomon',
    'isaiah': 'Isaiah',
    'isa': 'Isaiah',
    'jeremiah': 'Jeremiah',
    'jer': 'Jeremiah',
    'lamentations': 'Lamentations',
    'lam': 'Lamentations',
    'ezekiel': 'Ezekiel',
    'ezek': 'Ezekiel',
    'eze': 'Ezekiel',
    'daniel': 'Daniel',
    'dan': 'Daniel',
    'hosea': 'Hosea',
    'hos': 'Hosea',
    'joel': 'Joel',
    'jl': 'Joel',
    'amos': 'Amos',
    'obadiah': 'Obadiah',
    'obad': 'Obadiah',
    'oba': 'Obadiah',
    'jonah': 'Jonah',
    'jon': 'Jonah',
    'micah': 'Micah',
    'mic': 'Micah',
    'nahum': 'Nahum',
    'nah': 'Nahum',
    'habakkuk': 'Habakkuk',
    'hab': 'Habakkuk',
    'zephaniah': 'Zephaniah',
    'zeph': 'Zephaniah',
    'zep': 'Zephaniah',
    'haggai': 'Haggai',
    'hag': 'Haggai',
    'zechariah': 'Zechariah',
    'zech': 'Zechariah',
    'zec': 'Zechariah',
    'malachi': 'Malachi',
    'mal': 'Malachi',
    // New Testament
    'matthew': 'Matthew',
    'matt': 'Matthew',
    'mt': 'Matthew',
    'mark': 'Mark',
    'mk': 'Mark',
    'luke': 'Luke',
    'lk': 'Luke',
    'john': 'John',
    'jn': 'John',
    'acts': 'Acts',
    'act': 'Acts',
    'romans': 'Romans',
    'rom': 'Romans',
    'rm': 'Romans',
    'galatians': 'Galatians',
    'gal': 'Galatians',
    'ephesians': 'Ephesians',
    'eph': 'Ephesians',
    'philippians': 'Philippians',
    'phil': 'Philippians',
    'php': 'Philippians',
    'colossians': 'Colossians',
    'col': 'Colossians',
    'titus': 'Titus',
    'tit': 'Titus',
    'philemon': 'Philemon',
    'phlm': 'Philemon',
    'phm': 'Philemon',
    'hebrews': 'Hebrews',
    'heb': 'Hebrews',
    'james': 'James',
    'jas': 'James',
    'jude': 'Jude',
    'revelation': 'Revelation',
    'rev': 'Revelation',
    // Numbered books — resolved after prefix extraction
    'corinthians': 'Corinthians',
    'cor': 'Corinthians',
    'co': 'Corinthians',
    'thessalonians': 'Thessalonians',
    'thess': 'Thessalonians',
    'th': 'Thessalonians',
    'timothy': 'Timothy',
    'tim': 'Timothy',
    'ti': 'Timothy',
    'peter': 'Peter',
    'pet': 'Peter',
    'pe': 'Peter',
    'samuel': 'Samuel',
    'sam': 'Samuel',
    'sa': 'Samuel',
    'kings': 'Kings',
    'kgs': 'Kings',
    'ki': 'Kings',
    'chronicles': 'Chronicles',
    'chr': 'Chronicles',
    'ch': 'Chronicles',
    // "John" as a numbered book (1 John, 2 John, 3 John) is handled separately
  };

  // Build the book alternatives sorted longest → shortest (avoids partial match).
  static final _bookAlts = () {
    final keys = _abbrevMap.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    return keys.map(RegExp.escape).join('|');
  }();

  // Full pattern:
  //   optional-num-prefix book-name spaces chapter:verse(-end)?
  static final _pattern = RegExp(
    r'(?<!\w)(?:(?<num>[123])\s+)?(?<book>' +
        _bookAlts +
        r')\s+(?<chapter>\d+):(?<vstart>\d+)(?:-(?<vend>\d+))?(?!\w)',
    caseSensitive: false,
  );

  /// Scans [text] and returns all detected scripture references in order.
  static List<DetectedScriptureRef> detect(String text) {
    final results = <DetectedScriptureRef>[];
    for (final match in _pattern.allMatches(text)) {
      final numStr = match.namedGroup('num');
      final bookRaw = match.namedGroup('book')!.toLowerCase();
      final chapterStr = match.namedGroup('chapter')!;
      final vstartStr = match.namedGroup('vstart')!;
      final vendStr = match.namedGroup('vend');

      final stem = _abbrevMap[bookRaw];
      if (stem == null) continue;

      final String book;
      if (numStr != null) {
        // e.g. stem = "Corinthians" → "1 Corinthians"
        // Special case: "John" as unnumbered maps to John; numbered → "1 John"
        final base = bookRaw == 'john' ? 'John' : stem;
        book = '$numStr $base';
      } else {
        book = stem;
      }

      results.add(DetectedScriptureRef(
        rawText: match[0]!,
        book: book,
        chapter: int.parse(chapterStr),
        verseStart: int.parse(vstartStr),
        verseEnd: vendStr != null ? int.parse(vendStr) : null,
        startOffset: match.start,
        endOffset: match.end,
      ));
    }
    return results;
  }
}
