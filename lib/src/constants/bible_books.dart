/// All 66 books of the Bible in canonical order.
abstract final class BibleBooks {

  static const List<String> all = [
    // Old Testament - Pentateuch
    'Genesis',
    'Exodus',
    'Leviticus',
    'Numbers',
    'Deuteronomy',

    // Old Testament - Historical
    'Joshua',
    'Judges',
    'Ruth',
    '1 Samuel',
    '2 Samuel',
    '1 Kings',
    '2 Kings',
    '1 Chronicles',
    '2 Chronicles',
    'Ezra',
    'Nehemiah',
    'Esther',

    // Old Testament - Wisdom & Poetry
    'Job',
    'Psalms',
    'Proverbs',
    'Ecclesiastes',
    'Song of Solomon',

    // Old Testament - Major Prophets
    'Isaiah',
    'Jeremiah',
    'Lamentations',
    'Ezekiel',
    'Daniel',

    // Old Testament - Minor Prophets
    'Hosea',
    'Joel',
    'Amos',
    'Obadiah',
    'Jonah',
    'Micah',
    'Nahum',
    'Habakkuk',
    'Zephaniah',
    'Haggai',
    'Zechariah',
    'Malachi',

    // New Testament - Gospels
    'Matthew',
    'Mark',
    'Luke',
    'John',

    // New Testament - History
    'Acts',

    // New Testament - Pauline Epistles
    'Romans',
    '1 Corinthians',
    '2 Corinthians',
    'Galatians',
    'Ephesians',
    'Philippians',
    'Colossians',
    '1 Thessalonians',
    '2 Thessalonians',
    '1 Timothy',
    '2 Timothy',
    'Titus',
    'Philemon',

    // New Testament - General Epistles
    'Hebrews',
    'James',
    '1 Peter',
    '2 Peter',
    '1 John',
    '2 John',
    '3 John',
    'Jude',

    // New Testament - Prophecy
    'Revelation',
  ];

  /// Total number of books.
  static int get count => all.length;

  /// Whether [bookName] is a valid canonical book name.
  static bool contains(String bookName) => all.contains(bookName);

  /// Known aliases and alternate spellings mapped to canonical book names.
  static const Map<String, String> _aliases = {
    'psalm': 'Psalms',
    'revelations': 'Revelation',
    'song of songs': 'Song of Solomon',
    'sos': 'Song of Solomon',
    '1st samuel': '1 Samuel',
    '2nd samuel': '2 Samuel',
    '1st kings': '1 Kings',
    '2nd kings': '2 Kings',
    '1st chronicles': '1 Chronicles',
    '2nd chronicles': '2 Chronicles',
    '1st corinthians': '1 Corinthians',
    '2nd corinthians': '2 Corinthians',
    '1st thessalonians': '1 Thessalonians',
    '2nd thessalonians': '2 Thessalonians',
    '1st timothy': '1 Timothy',
    '2nd timothy': '2 Timothy',
    '1st peter': '1 Peter',
    '2nd peter': '2 Peter',
    '1st john': '1 John',
    '2nd john': '2 John',
    '3rd john': '3 John',
  };

  /// Find a book by alias or case-insensitive prefix match.
  ///
  /// Checks known aliases first (e.g. "Psalm" → "Psalms",
  /// "Revelations" → "Revelation", "1st John" → "1 John"),
  /// then falls back to prefix matching. Returns null if not found.
  static String? findBook(String partial) {
    if (partial.isEmpty) return null;
    final lower = partial.toLowerCase();

    final aliasMatch = _aliases[lower];
    if (aliasMatch != null) return aliasMatch;

    try {
      return all.firstWhere(
        (book) => book.toLowerCase().startsWith(lower),
      );
    } catch (_) {
      return null;
    }
  }
}
