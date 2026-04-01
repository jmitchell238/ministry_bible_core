import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ministry_bible_core/ministry_bible_core.dart';

class VerseOfDayPage extends StatefulWidget {
  final BibleContentService content;
  const VerseOfDayPage({super.key, required this.content});

  @override
  State<VerseOfDayPage> createState() => _VerseOfDayPageState();
}

class _VerseOfDayPageState extends State<VerseOfDayPage> {
  late VerseOfTheDayService _service;
  DateTime _selectedDate = DateTime.now();
  String? _copiedText;

  @override
  void initState() {
    super.initState();
    _service = VerseOfTheDayService(widget.content);
  }

  void _changeDate(int deltaDays) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: deltaDays));
      _copiedText = null;
    });
  }

  void _copyCard(VerseCard card) {
    Clipboard.setData(ClipboardData(text: card.shareText));
    setState(() => _copiedText = card.shareText);
  }

  @override
  Widget build(BuildContext context) {
    final verseId = _service.getVerseId(_selectedDate);
    final verse = _service.getVerse(_selectedDate);
    final theme = Theme.of(context);
    final isToday = _isSameDay(_selectedDate, DateTime.now());

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Date picker row ──────────────────────────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () => _changeDate(-1),
                          tooltip: 'Previous day',
                        ),
                        Column(
                          children: [
                            Text(
                              isToday ? 'Today' : _formatDate(_selectedDate),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Day ${_dayOfYear(_selectedDate) + 1} of year',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () => _changeDate(1),
                          tooltip: 'Next day',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Verse card ───────────────────────────────────────────
                if (verse != null) ...[
                  _VerseCardWidget(
                    verse: verse,
                    onCopy: _copyCard,
                  ),
                ] else ...[
                  // verse not in sample data — show the ID only
                  Card(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.menu_book,
                                  color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Text('Verse of the Day',
                                  style: theme.textTheme.titleSmall),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            verseId,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This verse is in the curated list but not in the demo dataset.\n'
                            'In a real app, your BibleAssetLoader would supply the full Bible.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // ── Code explainer ───────────────────────────────────────
                _CodeCard(
                  title: 'How it works',
                  code: '''final service = VerseOfTheDayService(content);

// Same date → always same verse (year-independent)
String id = service.getVerseId(DateTime.now());

// Resolve to a BibleVerse from your loaded content
BibleVerse? verse = service.getVerse(DateTime.now());

// Custom curated list
final custom = VerseOfTheDayService(
  content,
  verseIds: ['John-3-16', 'Psalms-23-1'],
);''',
                ),

                const SizedBox(height: 16),

                // ── Default list stats ───────────────────────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Built-in verse list',
                            style: theme.textTheme.titleSmall),
                        const SizedBox(height: 8),
                        _Stat('Total verses in default list',
                            '${VerseOfTheDayService.defaultVerseIds.length}'),
                        _Stat('Today\'s verse ID', verseId),
                        _Stat('Deterministic?',
                            'Yes — day ${_dayOfYear(_selectedDate)} % ${VerseOfTheDayService.defaultVerseIds.length} = ${_dayOfYear(_selectedDate) % VerseOfTheDayService.defaultVerseIds.length}'),
                      ],
                    ),
                  ),
                ),

                // ── Copy confirmation ────────────────────────────────────
                if (_copiedText != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: theme.colorScheme.primary, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Copied to clipboard:\n$_copiedText',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  int _dayOfYear(DateTime d) =>
      d.difference(DateTime(d.year, 1, 1)).inDays;

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

// ── Verse card widget ──────────────────────────────────────────────────────

class _VerseCardWidget extends StatefulWidget {
  final BibleVerse verse;
  final void Function(VerseCard) onCopy;

  const _VerseCardWidget({required this.verse, required this.onCopy});

  @override
  State<_VerseCardWidget> createState() => _VerseCardWidgetState();
}

class _VerseCardWidgetState extends State<_VerseCardWidget> {
  String _theme = 'default';
  String _color = '#4a90d9';

  static const _themes = ['default', 'sunrise', 'night', 'parchment'];
  static const _colors = {
    'Ocean blue': '#4a90d9',
    'Forest green': '#2d7a4f',
    'Sunset orange': '#d96b4a',
    'Royal purple': '#7b4ad9',
    'Crimson': '#c0392b',
  };

  VerseCard _buildCard() {
    final bookName = _bookNameFromVerse(widget.verse);
    return VerseCardFormatter.format(
      verse: widget.verse,
      bookName: bookName,
      translationCode: 'KJV',
      theme: _theme,
      color: _color,
    );
  }

  String _bookNameFromVerse(BibleVerse verse) {
    // Reverse-decode book name from verse id prefix
    final prefix = verse.id.split('-').first;
    return BibleBooks.all.firstWhere(
      (b) => b.replaceAll(' ', '') == prefix,
      orElse: () => prefix,
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = _buildCard();
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.menu_book, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Verse of the Day',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    )),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '"${card.verseText}"',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '— ${card.reference} (${card.translationCode})',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 32),

            // Theme & color controls
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in _themes)
                  ChoiceChip(
                    label: Text(t),
                    selected: _theme == t,
                    onSelected: (_) => setState(() => _theme = t),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in _colors.entries)
                  FilterChip(
                    label: Text(entry.key),
                    selected: _color == entry.value,
                    onSelected: (_) => setState(() => _color = entry.value),
                    avatar: CircleAvatar(
                      backgroundColor: _hexColor(entry.value),
                      radius: 8,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Share text preview + copy button
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('shareText output:',
                      style: theme.textTheme.labelSmall),
                  const SizedBox(height: 4),
                  SelectableText(
                    card.shareText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => onCopy(card),
              icon: const Icon(Icons.copy, size: 18),
              label: const Text('Copy to clipboard'),
            ),
          ],
        ),
      ),
    );
  }

  void onCopy(VerseCard card) => widget.onCopy(card);

  Color _hexColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}

// ── Shared small widgets ───────────────────────────────────────────────────

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label,
                style: t.textTheme.bodySmall?.copyWith(
                  color: t.colorScheme.onSurfaceVariant,
                )),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(value,
                style: t.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
          ),
        ],
      ),
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
                style: t.textTheme.labelMedium?.copyWith(
                  color: const Color(0xFF89b4fa),
                )),
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
