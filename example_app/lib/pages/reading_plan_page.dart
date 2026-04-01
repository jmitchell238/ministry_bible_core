import 'package:flutter/material.dart';
import 'package:ministry_bible_core/ministry_bible_core.dart';

class ReadingPlanPage extends StatefulWidget {
  final BibleContentService content;
  const ReadingPlanPage({super.key, required this.content});

  @override
  State<ReadingPlanPage> createState() => _ReadingPlanPageState();
}

class _ReadingPlanPageState extends State<ReadingPlanPage> {
  late ReadingPlanService _planService;
  String _planType = kPlanSequential;
  final DateTime _startDate = DateTime(2026, 1, 1);

  // Pause/resume demo
  bool _isPaused = false;
  DateTime? _pausedAt;
  final List<ReadingPlanEvent> _events = [];

  @override
  void initState() {
    super.initState();
    _planService = ReadingPlanService(widget.content);
  }

  ReadingPlanState get _planState =>
      ReadingPlanState(startDate: _startDate, events: _events);

  int get _effectiveDay =>
      _planState.effectiveDayNumber(DateTime.now());

  void _togglePause() {
    setState(() {
      if (_isPaused) {
        _events.add(ReadingPlanEvent(
          type: ReadingPlanEventType.resumed,
          date: DateTime.now(),
        ));
        _isPaused = false;
        _pausedAt = null;
      } else {
        _pausedAt = DateTime.now();
        _events.add(ReadingPlanEvent(
          type: ReadingPlanEventType.paused,
          date: _pausedAt!,
        ));
        _isPaused = true;
      }
    });
  }

  void _skipToday() {
    setState(() {
      _events.add(ReadingPlanEvent(
        type: ReadingPlanEventType.skipped,
        date: DateTime.now(),
      ));
    });
  }

  void _resetState() {
    setState(() {
      _events.clear();
      _isPaused = false;
      _pausedAt = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final day = _effectiveDay;
    final assignment = _planService.getTodaysAssignment(_planType, _startDate, day);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Plan selector ────────────────────────────────────────
              DropdownButtonFormField<String>(
                value: _planType,
                decoration: const InputDecoration(
                  labelText: 'Reading plan',
                  border: OutlineInputBorder(),
                ),
                items: [
                  _planItem(kPlanSequential, 'Sequential (Gen → Rev)'),
                  _planItem(kPlanAlternating, 'Alternating (OT + NT)'),
                  _planItem(kPlanChronological, 'Chronological'),
                  _planItem(kPlanCategoryMix, 'Category Mix'),
                  _planItem(kPlanVerseCount, '85 Verses / Day'),
                  _planItem(kPlanWordCount, 'Word Count Target'),
                ],
                onChanged: (v) => setState(() {
                  _planType = v!;
                  _planService.clearCache();
                }),
              ),

              const SizedBox(height: 24),

              // ── Current day status ───────────────────────────────────
              Card(
                color: _isPaused
                    ? theme.colorScheme.errorContainer
                    : theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        _isPaused ? Icons.pause_circle : Icons.play_circle,
                        size: 48,
                        color: _isPaused
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isPaused ? 'Plan paused' : 'Day $day',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _isPaused
                                  ? 'Paused days won\'t count toward your day number'
                                  : '${assignment.length} verses in today\'s assignment',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Pause / skip controls ────────────────────────────────
              Row(
                children: [
                  FilledButton.tonal(
                    onPressed: _togglePause,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_isPaused ? Icons.play_arrow : Icons.pause, size: 18),
                        const SizedBox(width: 6),
                        Text(_isPaused ? 'Resume' : 'Pause plan'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _skipToday,
                    icon: const Icon(Icons.skip_next, size: 18),
                    label: const Text('Skip today'),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _resetState,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Reset'),
                  ),
                ],
              ),

              // ── Event log ────────────────────────────────────────────
              if (_events.isNotEmpty) ...[
                const SizedBox(height: 16),
                _SectionHeader('Event log', subtitle: '${_events.length} events'),
                const SizedBox(height: 8),
                for (final e in _events.reversed)
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
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(e.type.name,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            )),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(e.date),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],

              const SizedBox(height: 24),

              // ── Today's assignment ───────────────────────────────────
              _SectionHeader(
                'Day $day assignment',
                subtitle: '${assignment.length} verses',
              ),
              const SizedBox(height: 8),
              if (assignment.isEmpty)
                Text('Plan complete!',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ))
              else
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: assignment
                      .take(20)
                      .map((id) => Chip(
                            label: Text(id,
                                style: const TextStyle(fontSize: 11)),
                            padding: EdgeInsets.zero,
                          ))
                      .toList()
                    ..addAll(assignment.length > 20
                        ? [
                            Chip(
                              label: Text(
                                  '+${assignment.length - 20} more',
                                  style: const TextStyle(fontSize: 11)),
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                            )
                          ]
                        : []),
                ),

              const SizedBox(height: 24),

              _CodeCard(
                title: 'ReadingPlanService + ReadingPlanState',
                code: '''final plans = ReadingPlanService(content);

// Basic usage — get today\'s assignment
final day = plans.getCurrentDayNumber(startDate);
final verses = plans.getTodaysAssignment(
  kPlanSequential, startDate, day,
);

// Pause / resume support
final state = ReadingPlanState(
  startDate: startDate,
  events: [
    ReadingPlanEvent(
      type: ReadingPlanEventType.paused,
      date: pauseDate,
    ),
    ReadingPlanEvent(
      type: ReadingPlanEventType.resumed,
      date: resumeDate,
    ),
  ],
);

// Day number excludes paused days
final effectiveDay = plans.getCurrentDayNumber(
  startDate,
  state: state,  // optional
);

// Check progress
double progress = plans.getPlanProgress(
  kPlanSequential, startDate, readVerseIds,
);''',
              ),
            ],
          ),
        ),
      ),
    );
  }

  DropdownMenuItem<String> _planItem(String value, String label) =>
      DropdownMenuItem(value: value, child: Text(label));

  String _formatTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}:${d.second.toString().padLeft(2, '0')}';
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
        Text(title,
            style: t.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        if (subtitle != null)
          Text(subtitle!,
              style: t.textTheme.bodySmall
                  ?.copyWith(color: t.colorScheme.onSurfaceVariant)),
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
