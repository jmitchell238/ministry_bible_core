import 'package:flutter/material.dart';
import 'package:ministry_bible_core/ministry_bible_core.dart';

class BibleBrowserPage extends StatefulWidget {
  final BibleContentService content;
  const BibleBrowserPage({super.key, required this.content});

  @override
  State<BibleBrowserPage> createState() => _BibleBrowserPageState();
}

class _BibleBrowserPageState extends State<BibleBrowserPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Browse state
  BibleBook? _selectedBook;
  BibleChapter? _selectedChapter;

  // Search state
  final _searchController = TextEditingController();
  List<SearchResult> _searchResults = [];
  bool _searched = false;

  // Auto-detect state
  final _detectController = TextEditingController(
    text: 'For context, see John 3:16, Gen 1:1-3, and Phil 4:13.',
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedBook = widget.content.getAllBooks().first;
    _selectedChapter = _selectedBook!.chapters.first;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _detectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.auto_stories), text: 'Browse'),
              Tab(icon: Icon(Icons.search), text: 'Search'),
              Tab(icon: Icon(Icons.auto_fix_high), text: 'Auto-detect'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBrowseTab(theme),
                _buildSearchTab(theme),
                _buildAutoDetectTab(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Browse tab ─────────────────────────────────────────────────────────────

  Widget _buildBrowseTab(ThemeData theme) {
    final books = widget.content.getAllBooks();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book selector
              DropdownButtonFormField<BibleBook>(
                value: _selectedBook,
                decoration: const InputDecoration(
                  labelText: 'Book',
                  border: OutlineInputBorder(),
                ),
                items: books
                    .map((b) => DropdownMenuItem(value: b, child: Text(b.name)))
                    .toList(),
                onChanged: (b) => setState(() {
                  _selectedBook = b;
                  _selectedChapter = b?.chapters.first;
                }),
              ),
              const SizedBox(height: 12),

              // Chapter selector
              if (_selectedBook != null)
                DropdownButtonFormField<BibleChapter>(
                  value: _selectedChapter,
                  decoration: const InputDecoration(
                    labelText: 'Chapter',
                    border: OutlineInputBorder(),
                  ),
                  items: _selectedBook!.chapters
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text('Chapter ${c.number}'),
                          ))
                      .toList(),
                  onChanged: (c) => setState(() => _selectedChapter = c),
                ),

              const SizedBox(height: 24),

              // Verse list
              if (_selectedChapter != null) ...[
                _SectionHeader(
                  '${_selectedBook!.name} ${_selectedChapter!.number}',
                  subtitle:
                      '${_selectedChapter!.verses.length} verses · ${_selectedBook!.testament}',
                ),
                const SizedBox(height: 12),
                for (final verse in _selectedChapter!.verses)
                  _VerseRow(verse: verse),

                const SizedBox(height: 24),
                _CodeCard(
                  title: 'BibleContentService API',
                  code: '''// All books
final books = content.getAllBooks();

// By ID or name
final genesis = content.getBook(1);
final john    = content.getBookByName('john');

// Chapter and verses
final chapter = content.getChapter(43, 3); // John 3
final verses  = content.getVerses(43, 3);

// Name-based text lookup
final text = content.verseText('John', 3, 16);

// Counts
print(content.getTotalVerseCount()); // 31,102 full Bible
print(content.getTotalWordCount());''',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Search tab ─────────────────────────────────────────────────────────────

  Widget _buildSearchTab(ThemeData theme) {
    final searchSvc = BibleSearchService(widget.content);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search verse text',
                        hintText: 'e.g. God so loved',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onSubmitted: (_) => _runSearch(searchSvc),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () => _runSearch(searchSvc),
                    child: const Text('Search'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['God', 'light', 'shepherd', 'Word', 'peace']
                    .map((q) => ActionChip(
                          label: Text(q),
                          onPressed: () {
                            _searchController.text = q;
                            _runSearch(searchSvc);
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),

              if (_searched) ...[
                Text(
                  _searchResults.isEmpty
                      ? 'No results for "${_searchController.text}"'
                      : '${_searchResults.length} result${_searchResults.length == 1 ? '' : 's'} for "${_searchController.text}"',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                for (final r in _searchResults)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          r.verse.id.split('-').first.substring(0, 2),
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                      title: Text(r.verse.text),
                      subtitle: Text(r.verse.id.replaceAll('-', ' ')),
                    ),
                  ),
              ],

              const SizedBox(height: 24),
              _CodeCard(
                title: 'BibleSearchService API',
                code: '''final search = BibleSearchService(content);

// Full-text search (punctuation- and case-insensitive)
final results = search.searchVerses('God so loved');
for (final r in results) {
  print(r.verse.id);        // "John-3-16"
  print(r.verse.text);      // full verse text
  print(r.matchPosition);   // char offset of match
}

// Search books by partial name
final books = search.searchBooks('cor'); // 1 & 2 Corinthians

// Exact verse reference lookup
final verse = search.searchByReference('John 3:16');''',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _runSearch(BibleSearchService svc) {
    final q = _searchController.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _searched = true;
      _searchResults = svc.searchVerses(q);
    });
  }

  // ── Auto-detect tab ────────────────────────────────────────────────────────

  Widget _buildAutoDetectTab(ThemeData theme) {
    final refs = ScriptureAutoDetector.detect(_detectController.text);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _detectController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Paste any text with scripture references',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),

              _SectionHeader(
                'Detected references',
                subtitle: '${refs.length} found',
              ),
              const SizedBox(height: 12),

              if (refs.isEmpty)
                Text(
                  'No scripture references detected.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              else
                for (final ref in refs)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.menu_book_outlined),
                      title: Text(
                          '${ref.book} ${ref.chapter}:${ref.verseStart}'
                          '${ref.verseEnd != null ? '–${ref.verseEnd}' : ''}'),
                      subtitle: Text('Matched: "${ref.rawText}"'),
                      trailing: Text(
                        'offset ${ref.startOffset}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),

              const SizedBox(height: 24),
              _CodeCard(
                title: 'ScriptureAutoDetector API',
                code: '''// Detect all references in any string — no setup needed
final refs = ScriptureAutoDetector.detect(
  'See John 3:16 and Gen 1:1-3.',
);

for (final ref in refs) {
  print(ref.book);        // "John", "Genesis"
  print(ref.chapter);     // 3, 1
  print(ref.verseStart);  // 16, 1
  print(ref.verseEnd);    // null, 3
  print(ref.rawText);     // "John 3:16", "Gen 1:1-3"
  print(ref.startOffset); // character position in input
}''',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────────────────────

class _VerseRow extends StatelessWidget {
  final BibleVerse verse;
  const _VerseRow({required this.verse});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '${verse.number}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(verse.text, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _SectionHeader(this.title, {this.subtitle});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        if (subtitle != null)
          Text(subtitle!, style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _CodeCard extends StatelessWidget {
  final String title;
  final String code;
  const _CodeCard({required this.title, required this.code});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      color: const Color(0xFF1e1e2e),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: t.textTheme.labelMedium?.copyWith(color: const Color(0xFF89b4fa))),
            const SizedBox(height: 8),
            SelectableText(
              code,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: Color(0xFFcdd6f4),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
