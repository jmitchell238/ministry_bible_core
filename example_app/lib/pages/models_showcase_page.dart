import 'package:flutter/material.dart';
import 'package:ministry_bible_core/ministry_bible_core.dart';

/// Showcases every new model added in P1/P2 with live construction + JSON.
class ModelsShowcasePage extends StatefulWidget {
  const ModelsShowcasePage({super.key});

  @override
  State<ModelsShowcasePage> createState() => _ModelsShowcasePageState();
}

class _ModelsShowcasePageState extends State<ModelsShowcasePage> {
  int _selected = 0;

  static const _sections = [
    'SermonOutline',
    'ReadingGoal',
    'MemorizationEntry',
    'CrossReference',
    'PrayerRequest',
    'StudyNote',
    'ReadingPlanState',
    'BibleBooks aliases',
    'VerseId',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Left nav
        NavigationRail(
          selectedIndex: _selected,
          onDestinationSelected: (i) => setState(() => _selected = i),
          labelType: NavigationRailLabelType.all,
          destinations: _sections
              .map((s) => NavigationRailDestination(
                    icon: const Icon(Icons.circle_outlined, size: 14),
                    selectedIcon: const Icon(Icons.circle, size: 14),
                    label: Text(s, style: const TextStyle(fontSize: 11)),
                  ))
              .toList(),
        ),
        const VerticalDivider(width: 1),

        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 660),
                child: _buildSection(theme),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(ThemeData theme) {
    switch (_selected) {
      case 0:
        return _SermonOutlineDemo(theme: theme);
      case 1:
        return _ReadingGoalDemo(theme: theme);
      case 2:
        return _MemorizationDemo(theme: theme);
      case 3:
        return _CrossReferenceDemo(theme: theme);
      case 4:
        return _PrayerRequestDemo(theme: theme);
      case 5:
        return _StudyNoteDemo(theme: theme);
      case 6:
        return _ReadingPlanStateDemo(theme: theme);
      case 7:
        return _BibleBooksAliasDemo(theme: theme);
      case 8:
        return _VerseIdDemo(theme: theme);
      default:
        return const SizedBox.shrink();
    }
  }
}

// ── Individual demos ───────────────────────────────────────────────────────

class _SermonOutlineDemo extends StatefulWidget {
  final ThemeData theme;
  const _SermonOutlineDemo({required this.theme});

  @override
  State<_SermonOutlineDemo> createState() => _SermonOutlineDemoState();
}

class _SermonOutlineDemoState extends State<_SermonOutlineDemo> {
  late SermonOutline _outline;

  @override
  void initState() {
    super.initState();
    _outline = SermonOutline.create(
      title: 'The Good Shepherd',
      scriptureReferences: ['John-10-11', 'Psalms-23-1'],
      seriesName: 'Names of Jesus',
      points: [
        SermonPoint(
          heading: 'I. The Shepherd Knows His Sheep',
          body: 'He calls them by name — John 10:3',
          verseId: 'John-10-3',
        ),
        SermonPoint(
          heading: 'II. The Shepherd Lays Down His Life',
          body: 'Greater love hath no man — John 15:13',
          verseId: 'John-15-13',
        ),
        SermonPoint(
          heading: 'III. Goodness and Mercy Follow',
          body: 'All the days of my life — Psalm 23:6',
          verseId: 'Psalms-23-6',
        ),
      ],
      notes: 'Open with the contrast between hired hand and true shepherd.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ModelHeader('SermonOutline',
            'Sermon/lesson draft with points, scripture refs, and status.'),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(_outline.title,
                          style: widget.theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold)),
                    ),
                    _StatusChip(_outline.status),
                  ],
                ),
                if (_outline.seriesName != null) ...[
                  const SizedBox(height: 4),
                  Text('Series: ${_outline.seriesName}',
                      style: widget.theme.textTheme.bodySmall?.copyWith(
                          color: widget.theme.colorScheme.onSurfaceVariant)),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: _outline.scriptureReferences
                      .map((r) => Chip(
                            label:
                                Text(r, style: const TextStyle(fontSize: 11)),
                            padding: EdgeInsets.zero,
                          ))
                      .toList(),
                ),
                const Divider(height: 24),
                for (final pt in _outline.points)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pt.heading,
                            style: widget.theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold)),
                        if (pt.body != null)
                          Text(pt.body!,
                              style: widget.theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                if (_outline.notes != null) ...[
                  const Divider(height: 16),
                  Text('Notes: ${_outline.notes}',
                      style: widget.theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic)),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.tonal(
          onPressed: () => setState(() {
            _outline = _outline.copyWith(
              status: _outline.status == SermonStatus.draft
                  ? SermonStatus.delivered
                  : SermonStatus.draft,
            );
          }),
          child: Text(_outline.status == SermonStatus.draft
              ? 'Mark as Delivered'
              : 'Move back to Draft'),
        ),
        const SizedBox(height: 24),
        _CodeCard(
          title: 'SermonOutline usage',
          code: '''final outline = SermonOutline.create(
  title: 'The Good Shepherd',
  scriptureReferences: ['John-10-11', 'Psalms-23-1'],
  seriesName: 'Names of Jesus',
  points: [
    SermonPoint(
      heading: 'I. The Shepherd Knows His Sheep',
      body: 'He calls them by name',
      verseId: 'John-10-3',
    ),
  ],
);

// Mark delivered
final delivered = outline.copyWith(
  status: SermonStatus.delivered,
  date: DateTime.now(),
);

// Serialize
final json = outline.toJson();
final restored = SermonOutline.fromJson(json);''',
        ),
      ],
    );
  }
}

class _ReadingGoalDemo extends StatefulWidget {
  final ThemeData theme;
  const _ReadingGoalDemo({required this.theme});

  @override
  State<_ReadingGoalDemo> createState() => _ReadingGoalDemoState();
}

class _ReadingGoalDemoState extends State<_ReadingGoalDemo> {
  GoalType _type = GoalType.versesPerDay;
  int _target = 10;
  int _versesRead = 7;
  int _chaptersRead = 1;
  int _minutesRead = 20;

  @override
  Widget build(BuildContext context) {
    final goal = ReadingGoal.create(type: _type, target: _target);
    final achieved = goal.isAchieved(
      versesRead: _versesRead,
      chaptersRead: _chaptersRead,
      minutesRead: _minutesRead,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ModelHeader('ReadingGoal',
            'Daily goal with isAchieved() logic across three goal types.'),
        const SizedBox(height: 16),

        // Goal type selector
        SegmentedButton<GoalType>(
          segments: const [
            ButtonSegment(
                value: GoalType.versesPerDay, label: Text('Verses')),
            ButtonSegment(
                value: GoalType.chaptersPerDay, label: Text('Chapters')),
            ButtonSegment(
                value: GoalType.minutesPerDay, label: Text('Minutes')),
          ],
          selected: {_type},
          onSelectionChanged: (s) => setState(() => _type = s.first),
        ),

        const SizedBox(height: 16),

        // Target slider
        Text('Target: $_target ${_type.name.replaceAll('PerDay', '/day')}',
            style: widget.theme.textTheme.titleSmall),
        Slider(
          value: _target.toDouble(),
          min: 1,
          max: 50,
          divisions: 49,
          label: '$_target',
          onChanged: (v) => setState(() => _target = v.round()),
        ),

        // Progress inputs
        _SliderRow(
          label: 'Verses read today',
          value: _versesRead,
          max: 50,
          onChanged: (v) => setState(() => _versesRead = v),
        ),
        _SliderRow(
          label: 'Chapters read today',
          value: _chaptersRead,
          max: 20,
          onChanged: (v) => setState(() => _chaptersRead = v),
        ),
        _SliderRow(
          label: 'Minutes read today',
          value: _minutesRead,
          max: 120,
          onChanged: (v) => setState(() => _minutesRead = v),
        ),

        const SizedBox(height: 16),

        // Result
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: achieved
                ? widget.theme.colorScheme.primaryContainer
                : widget.theme.colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                achieved ? Icons.check_circle : Icons.cancel,
                color: achieved
                    ? widget.theme.colorScheme.primary
                    : widget.theme.colorScheme.error,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                achieved ? 'Goal achieved!' : 'Not yet achieved',
                style: widget.theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        _CodeCard(
          title: 'ReadingGoal usage',
          code: '''final goal = ReadingGoal.create(
  type: GoalType.versesPerDay,
  target: 10,
);

// Check if met
bool done = goal.isAchieved(versesRead: 12); // true
bool done2 = goal.isAchieved(versesRead: 8); // false

// Chapters goal
final chapGoal = ReadingGoal.create(
  type: GoalType.chaptersPerDay,
  target: 3,
);
bool met = chapGoal.isAchieved(
  versesRead: 0,
  chaptersRead: 3,
); // true''',
        ),
      ],
    );
  }
}

class _MemorizationDemo extends StatelessWidget {
  final ThemeData theme;
  const _MemorizationDemo({required this.theme});

  @override
  Widget build(BuildContext context) {
    final entries = [
      MemorizationEntry.create(
        verseId: 'John-3-16',
        status: MemorizationStatus.mastered,
        nextReviewDate: DateTime.now().add(const Duration(days: 30)),
      )..let((e) => e.copyWith(reviewCount: 12)),
      MemorizationEntry.create(
        verseId: 'Philippians-4-13',
        status: MemorizationStatus.reviewing,
        nextReviewDate: DateTime.now().add(const Duration(days: 3)),
      ),
      MemorizationEntry.create(verseId: 'Psalms-23-1'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ModelHeader('MemorizationEntry',
            'SRS-style verse memorization with learning/reviewing/mastered status.'),
        const SizedBox(height: 16),
        for (final e in entries)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: _MemStatusIcon(e.status),
              title: Text(e.verseId),
              subtitle: Text('Status: ${e.status.name}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Reviews: ${e.reviewCount}',
                      style: theme.textTheme.bodySmall),
                  if (e.nextReviewDate != null)
                    Text(
                      'Due: ${_shortDate(e.nextReviewDate!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 24),
        _CodeCard(
          title: 'MemorizationEntry usage',
          code: '''// Start learning
final entry = MemorizationEntry.create(
  verseId: 'John-3-16',
);
// entry.status == MemorizationStatus.learning
// entry.reviewCount == 0

// After a successful review
final reviewed = entry.copyWith(
  status: MemorizationStatus.reviewing,
  reviewCount: 1,
  lastReviewedAt: DateTime.now(),
  nextReviewDate: DateTime.now().add(Duration(days: 3)),
);

// Mastered
final mastered = reviewed.copyWith(
  status: MemorizationStatus.mastered,
  reviewCount: 10,
  nextReviewDate: DateTime.now().add(Duration(days: 30)),
);''',
        ),
      ],
    );
  }

  String _shortDate(DateTime d) => '${d.month}/${d.day}/${d.year}';
}

class _CrossReferenceDemo extends StatelessWidget {
  final ThemeData theme;
  const _CrossReferenceDemo({required this.theme});

  @override
  Widget build(BuildContext context) {
    final refs = [
      CrossReference(
        fromVerseId: 'Matthew-5-17',
        toVerseId: 'Isaiah-53-5',
        type: CrossReferenceType.fulfillment,
        note: 'Christ fulfills the law and the prophets',
      ),
      CrossReference(
        fromVerseId: 'John-3-16',
        toVerseId: 'Romans-5-8',
        type: CrossReferenceType.parallel,
      ),
      CrossReference(
        fromVerseId: 'Matthew-27-46',
        toVerseId: 'Psalms-22-1',
        type: CrossReferenceType.quotation,
        note: 'Direct quotation from the cross',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ModelHeader('CrossReference',
            'Links two verse IDs with a relationship type and optional note.'),
        const SizedBox(height: 16),
        for (final r in refs)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(r.fromVerseId,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.arrow_forward, size: 16),
                      ),
                      Text(r.toVerseId,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      _TypeChip(r.type),
                    ],
                  ),
                  if (r.note != null) ...[
                    const SizedBox(height: 4),
                    Text(r.note!,
                        style: theme.textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic)),
                  ],
                ],
              ),
            ),
          ),
        const SizedBox(height: 24),
        _CodeCard(
          title: 'CrossReference usage',
          code: '''// No UUID — natural key is from+to+type
final ref = CrossReference(
  fromVerseId: 'Matthew-5-17',
  toVerseId: 'Isaiah-53-5',
  type: CrossReferenceType.fulfillment,
  note: 'Fulfillment of the law',
);

// Types: parallel, fulfillment, quotation, thematic
final parallel = CrossReference(
  fromVerseId: 'John-3-16',
  toVerseId: 'Romans-5-8',
  type: CrossReferenceType.parallel,
);

// Clear note via copyWith
final noNote = ref.copyWith(clearNote: true);''',
        ),
      ],
    );
  }
}

class _PrayerRequestDemo extends StatefulWidget {
  final ThemeData theme;
  const _PrayerRequestDemo({required this.theme});

  @override
  State<_PrayerRequestDemo> createState() => _PrayerRequestDemoState();
}

class _PrayerRequestDemoState extends State<_PrayerRequestDemo> {
  List<PrayerRequest> _requests = [
    PrayerRequest.create(
      content: 'Wisdom for the sermon series on John.',
      verseId: 'James-1-5',
    ),
    PrayerRequest.create(
      content: 'Healing for a church member.',
      verseId: 'James-5-16',
    ),
    PrayerRequest.create(
      content: 'Peace for the congregation during transition.',
      verseId: 'Philippians-4-7',
    ),
  ];

  void _markAnswered(PrayerRequest req) {
    setState(() {
      _requests = _requests.map((r) {
        if (r.id == req.id) {
          return r.copyWith(
            status: PrayerStatus.answered,
            answeredAt: DateTime.now(),
          );
        }
        return r;
      }).toList();
    });
  }

  void _archive(PrayerRequest req) {
    setState(() {
      _requests = _requests.map((r) {
        if (r.id == req.id) {
          return r.copyWith(status: PrayerStatus.archived);
        }
        return r;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ModelHeader('PrayerRequest',
            'Prayer item with active/answered/archived status and optional scripture.'),
        const SizedBox(height: 16),
        for (final req in _requests)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: _PrayerStatusIcon(req.status),
              title: Text(req.content),
              subtitle: req.verseId != null ? Text(req.verseId!) : null,
              trailing: req.status == PrayerStatus.active
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check_circle_outline,
                              color: Colors.green),
                          tooltip: 'Mark answered',
                          onPressed: () => _markAnswered(req),
                        ),
                        IconButton(
                          icon: const Icon(Icons.archive_outlined),
                          tooltip: 'Archive',
                          onPressed: () => _archive(req),
                        ),
                      ],
                    )
                  : Chip(
                      label: Text(req.status.name,
                          style: const TextStyle(fontSize: 11)),
                    ),
            ),
          ),
        const SizedBox(height: 24),
        _CodeCard(
          title: 'PrayerRequest usage',
          code: '''final prayer = PrayerRequest.create(
  content: 'Wisdom for the sermon series.',
  verseId: 'James-1-5',
);
// prayer.status == PrayerStatus.active

// Mark answered
final answered = prayer.copyWith(
  status: PrayerStatus.answered,
  answeredAt: DateTime.now(),
);

// Archive
final archived = prayer.copyWith(
  status: PrayerStatus.archived,
);

// Statuses: active, answered, archived''',
        ),
      ],
    );
  }
}

class _StudyNoteDemo extends StatelessWidget {
  final ThemeData theme;
  const _StudyNoteDemo({required this.theme});

  @override
  Widget build(BuildContext context) {
    final note = StudyNote.create(
      content:
          'The Greek word "agape" here denotes unconditional, sacrificial love '
          'distinct from philia (friendship) or eros (romantic). '
          'Compare with 1 Corinthians 13:4-7 for the full characterization.',
      verseId: 'John-3-16',
      passageRef: 'John 3:16',
      source: 'Matthew Henry\'s Commentary',
      tags: ['love', 'Greek', 'atonement'],
      usedInSermon: true,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ModelHeader('StudyNote',
            'Reusable ministry research note, distinct from ReadingNote. '
            'Tracks source/attribution and whether it\'s been used in a sermon.'),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        note.passageRef ?? note.verseId ?? 'Study Note',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (note.usedInSermon)
                      const Chip(
                        label: Text('Used in sermon',
                            style: TextStyle(fontSize: 11)),
                        avatar: Icon(Icons.mic, size: 14),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(note.content,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(height: 1.5)),
                const SizedBox(height: 8),
                if (note.source != null)
                  Text('— ${note.source}',
                      style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: note.tags
                      .map((t) =>
                          Chip(label: Text(t), padding: EdgeInsets.zero))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _CodeCard(
          title: 'StudyNote usage',
          code: '''final note = StudyNote.create(
  content: 'Agape here is unconditional love...',
  verseId: 'John-3-16',
  passageRef: 'John 3:16',
  source: 'Matthew Henry\'s Commentary',
  tags: ['love', 'Greek', 'atonement'],
  usedInSermon: true,
);

// Mark as used in a sermon
final used = note.copyWith(usedInSermon: true);

// Clear attribution
final noSource = note.copyWith(clearSource: true);''',
        ),
      ],
    );
  }
}

class _ReadingPlanStateDemo extends StatefulWidget {
  final ThemeData theme;
  const _ReadingPlanStateDemo({required this.theme});

  @override
  State<_ReadingPlanStateDemo> createState() => _ReadingPlanStateDemoState();
}

class _ReadingPlanStateDemoState extends State<_ReadingPlanStateDemo> {
  final _start = DateTime(2026, 1, 1);
  final List<ReadingPlanEvent> _events = [];
  bool _paused = false;

  ReadingPlanState get _state =>
      ReadingPlanState(startDate: _start, events: _events);

  @override
  Widget build(BuildContext context) {
    final effectiveDay = _state.effectiveDayNumber(DateTime.now());
    final isPaused = _state.isPaused(DateTime.now());
    final skipped = _state.skippedDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ModelHeader('ReadingPlanState',
            'Tracks pause/resume/skip events. effectiveDayNumber() '
            'excludes days the plan was paused.'),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Stat('Start date', '${_start.year}-01-01'),
                _Stat('Calendar days elapsed',
                    '${DateTime.now().difference(_start).inDays}'),
                _Stat('Effective day number', '$effectiveDay'),
                _Stat('Currently paused', isPaused ? 'Yes' : 'No'),
                _Stat('Skipped days', '${skipped.length}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            FilledButton.tonal(
              onPressed: () => setState(() {
                if (_paused) {
                  _events.add(ReadingPlanEvent(
                    type: ReadingPlanEventType.resumed,
                    date: DateTime.now(),
                  ));
                } else {
                  _events.add(ReadingPlanEvent(
                    type: ReadingPlanEventType.paused,
                    date: DateTime.now(),
                  ));
                }
                _paused = !_paused;
              }),
              child: Text(_paused ? 'Resume' : 'Pause'),
            ),
            OutlinedButton(
              onPressed: () => setState(() {
                _events.add(ReadingPlanEvent(
                  type: ReadingPlanEventType.skipped,
                  date: DateTime.now(),
                ));
              }),
              child: const Text('Skip today'),
            ),
            TextButton(
              onPressed: () => setState(() {
                _events.clear();
                _paused = false;
              }),
              child: const Text('Reset'),
            ),
          ],
        ),
        if (_events.isNotEmpty) ...[
          const SizedBox(height: 12),
          for (final e in _events)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(
                    e.type == ReadingPlanEventType.paused
                        ? Icons.pause
                        : e.type == ReadingPlanEventType.resumed
                            ? Icons.play_arrow
                            : Icons.skip_next,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(e.type.name,
                      style: context.textTheme.bodySmall),
                ],
              ),
            ),
        ],
        const SizedBox(height: 24),
        _CodeCard(
          title: 'ReadingPlanState usage',
          code: '''final state = ReadingPlanState.create(
  startDate: DateTime(2026, 1, 1),
);

// Add events
final withPause = state.copyWith(events: [
  ...state.events,
  ReadingPlanEvent(
    type: ReadingPlanEventType.paused,
    date: DateTime(2026, 1, 10),
  ),
  ReadingPlanEvent(
    type: ReadingPlanEventType.resumed,
    date: DateTime(2026, 1, 15),
  ),
]);

// Effective day excludes the 5 paused days
int day = withPause.effectiveDayNumber(DateTime.now());

bool paused = state.isPaused(DateTime.now());
List<DateTime> skipped = state.skippedDays;''',
        ),
      ],
    );
  }
}

class _BibleBooksAliasDemo extends StatefulWidget {
  final ThemeData theme;
  const _BibleBooksAliasDemo({required this.theme});

  @override
  State<_BibleBooksAliasDemo> createState() => _BibleBooksAliasDemoState();
}

class _BibleBooksAliasDemoState extends State<_BibleBooksAliasDemo> {
  final _controller = TextEditingController(text: 'Song of Songs');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = BibleBooks.findBook(_controller.text);
    final theme = widget.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ModelHeader('BibleBooks aliases',
            'findBook() checks common aliases and alternate spellings before prefix matching.'),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'Type a book name or alias',
            border: OutlineInputBorder(),
            hintText: 'e.g. Psalm, Revelations, 1st John',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: result != null
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(result != null ? Icons.check : Icons.close,
                  color: result != null
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error),
              const SizedBox(width: 8),
              Text(
                result != null
                    ? 'Canonical name: $result'
                    : 'No match found',
                style: theme.textTheme.titleSmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'Psalm', 'Revelations', 'Song of Songs',
            '1st John', '2nd Kings', '3rd John', 'SoS', 'Gen',
          ].map((alias) => ActionChip(
                label: Text(alias),
                onPressed: () {
                  _controller.text = alias;
                  setState(() {});
                },
              )).toList(),
        ),
        const SizedBox(height: 24),
        _CodeCard(
          title: 'BibleBooks alias search',
          code: '''// Aliases resolved before prefix matching
BibleBooks.findBook('Psalm');          // "Psalms"
BibleBooks.findBook('Revelations');    // "Revelation"
BibleBooks.findBook('Song of Songs'); // "Song of Solomon"
BibleBooks.findBook('SoS');           // "Song of Solomon"
BibleBooks.findBook('1st John');       // "1 John"
BibleBooks.findBook('2nd Kings');      // "2 Kings"
BibleBooks.findBook('3rd John');       // "3 John"

// Prefix matching still works
BibleBooks.findBook('gen');  // "Genesis"
BibleBooks.findBook('Rev');  // "Revelation"

// Case-insensitive
BibleBooks.findBook('psalm');        // "Psalms"
BibleBooks.findBook('REVELATIONS'); // "Revelation"

// null for unknown
BibleBooks.findBook('Hezekiah'); // null''',
        ),
      ],
    );
  }
}

class _VerseIdDemo extends StatefulWidget {
  final ThemeData theme;
  const _VerseIdDemo({required this.theme});

  @override
  State<_VerseIdDemo> createState() => _VerseIdDemoState();
}

class _VerseIdDemoState extends State<_VerseIdDemo> {
  final _bookCtrl = TextEditingController(text: 'Song of Solomon');
  final _chCtrl = TextEditingController(text: '3');
  final _vsCtrl = TextEditingController(text: '2');
  final _decodeCtrl = TextEditingController(text: 'SongofSolomon-3-2');

  @override
  void dispose() {
    _bookCtrl.dispose();
    _chCtrl.dispose();
    _vsCtrl.dispose();
    _decodeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ch = int.tryParse(_chCtrl.text) ?? 1;
    final vs = int.tryParse(_vsCtrl.text) ?? 1;
    final encoded = _bookCtrl.text.isNotEmpty
        ? VerseId.encode(_bookCtrl.text, ch, vs)
        : '';

    String? decoded;
    String? decodeError;
    if (_decodeCtrl.text.isNotEmpty) {
      try {
        final r = VerseId.decode(_decodeCtrl.text);
        decoded = '${r.book} ${r.chapter}:${r.verse}';
      } catch (e) {
        decodeError = e.toString().replaceFirst('Invalid argument(s): ', '');
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ModelHeader('VerseId utility',
            'Encodes/decodes the canonical verse ID format used throughout the package.'),
        const SizedBox(height: 16),

        // Encoder
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Encode', style: widget.theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _bookCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Book', border: OutlineInputBorder()),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _chCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Ch', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _vsCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Vs', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (encoded.isNotEmpty)
                  SelectableText(encoded,
                      style: widget.theme.textTheme.titleMedium?.copyWith(
                          fontFamily: 'monospace',
                          color: widget.theme.colorScheme.primary)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Decoder
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Decode', style: widget.theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                TextField(
                  controller: _decodeCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Verse ID',
                      border: OutlineInputBorder(),
                      hintText: 'e.g. John-3-16'),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                if (decoded != null)
                  SelectableText(decoded,
                      style: widget.theme.textTheme.titleMedium?.copyWith(
                          fontFamily: 'monospace',
                          color: widget.theme.colorScheme.primary))
                else if (decodeError != null)
                  Text(decodeError,
                      style: widget.theme.textTheme.bodySmall?.copyWith(
                          color: widget.theme.colorScheme.error)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
        _CodeCard(
          title: 'VerseId API',
          code: '''// Encode — strips spaces from book name
VerseId.encode('Genesis', 1, 1);          // "Genesis-1-1"
VerseId.encode('Song of Solomon', 3, 2);  // "SongofSolomon-3-2"
VerseId.encode('1 Corinthians', 13, 4);   // "1Corinthians-13-4"

// Chapter-level ID
VerseId.chapterId('Genesis', 1);          // "Genesis-1"

// Decode — returns a named record
final r = VerseId.decode('SongofSolomon-3-2');
r.book;    // "Song of Solomon"
r.chapter; // 3
r.verse;   // 2

// Throws ArgumentError for invalid input
VerseId.decode('FakeBook-1-1');  // ArgumentError
VerseId.decode('Genesis-1');     // ArgumentError (too few parts)''',
        ),
      ],
    );
  }
}

// ── Shared small widgets ───────────────────────────────────────────────────

class _ModelHeader extends StatelessWidget {
  final String name;
  final String description;
  const _ModelHeader(this.name, this.description);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name,
            style: t.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(description,
            style: t.textTheme.bodyMedium
                ?.copyWith(color: t.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label,
                style: t.textTheme.bodySmall
                    ?.copyWith(color: t.colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            flex: 3,
            child: Text(value,
                style: t.textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final ValueChanged<int> onChanged;
  const _SliderRow(
      {required this.label,
      required this.value,
      required this.max,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
            width: 160,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: 0,
            max: max.toDouble(),
            divisions: max,
            label: '$value',
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        SizedBox(
            width: 32,
            child: Text('$value',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.end)),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final SermonStatus status;
  const _StatusChip(this.status);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(status.name, style: const TextStyle(fontSize: 11)),
      avatar: Icon(
        status == SermonStatus.delivered ? Icons.mic : Icons.edit_note,
        size: 14,
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final CrossReferenceType type;
  const _TypeChip(this.type);

  @override
  Widget build(BuildContext context) {
    const colors = {
      CrossReferenceType.fulfillment: Colors.purple,
      CrossReferenceType.parallel: Colors.blue,
      CrossReferenceType.quotation: Colors.orange,
      CrossReferenceType.thematic: Colors.teal,
    };
    return Chip(
      label: Text(type.name, style: const TextStyle(fontSize: 10)),
      backgroundColor: (colors[type] ?? Colors.grey).withOpacity(0.15),
      side: BorderSide(color: colors[type] ?? Colors.grey, width: 0.5),
      padding: EdgeInsets.zero,
    );
  }
}

class _MemStatusIcon extends StatelessWidget {
  final MemorizationStatus status;
  const _MemStatusIcon(this.status);

  @override
  Widget build(BuildContext context) {
    const icons = {
      MemorizationStatus.learning: (Icons.school, Colors.orange),
      MemorizationStatus.reviewing: (Icons.refresh, Colors.blue),
      MemorizationStatus.mastered: (Icons.star, Colors.green),
    };
    final (icon, color) = icons[status]!;
    return CircleAvatar(
      backgroundColor: color.withOpacity(0.15),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _PrayerStatusIcon extends StatelessWidget {
  final PrayerStatus status;
  const _PrayerStatusIcon(this.status);

  @override
  Widget build(BuildContext context) {
    return Icon(
      status == PrayerStatus.answered
          ? Icons.check_circle
          : status == PrayerStatus.archived
              ? Icons.archive
              : Icons.volunteer_activism,
      color: status == PrayerStatus.answered
          ? Colors.green
          : status == PrayerStatus.archived
              ? Colors.grey
              : Colors.blue,
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
                style: t.textTheme.labelMedium
                    ?.copyWith(color: const Color(0xFF89b4fa))),
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

// ── Extension helpers ──────────────────────────────────────────────────────

extension _ContextExt on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
}

extension _LetExt<T> on T {
  // ignore: unused_element
  T let(void Function(T) block) {
    block(this);
    return this;
  }
}
