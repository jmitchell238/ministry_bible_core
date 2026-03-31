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

  /// Find a book by case-insensitive prefix match. Returns null if not found.
  static String? findBook(String partial) {
    if (partial.isEmpty) return null;
    final lower = partial.toLowerCase();
    try {
      return all.firstWhere(
        (book) => book.toLowerCase().startsWith(lower),
      );
    } catch (_) {
      return null;
    }
  }
}
