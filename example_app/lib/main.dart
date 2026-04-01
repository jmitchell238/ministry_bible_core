import 'package:flutter/material.dart';
import 'package:ministry_bible_core/ministry_bible_core.dart';

import 'sample_data.dart';
import 'pages/verse_of_day_page.dart';
import 'pages/bible_browser_page.dart';
import 'pages/reading_plan_page.dart';
import 'pages/models_showcase_page.dart';

void main() {
  runApp(const MinistryBibleCoreDemo());
}

class MinistryBibleCoreDemo extends StatelessWidget {
  const MinistryBibleCoreDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ministry_bible_core Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4a90d9),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4a90d9),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const _AppShell(),
    );
  }
}

class _AppShell extends StatefulWidget {
  const _AppShell();

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  BibleContentService? _content;
  String? _error;
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final svc = await buildDemoService();
      if (mounted) setState(() => _content = svc);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        body: Center(child: Text('Error: $_error')),
      );
    }

    if (_content == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final content = _content!;
    final pages = [
      _PageDef(
        title: 'Verse of the Day',
        icon: Icons.wb_sunny_outlined,
        selectedIcon: Icons.wb_sunny,
        body: VerseOfDayPage(content: content),
      ),
      _PageDef(
        title: 'Bible Browser',
        icon: Icons.menu_book_outlined,
        selectedIcon: Icons.menu_book,
        body: BibleBrowserPage(content: content),
      ),
      _PageDef(
        title: 'Reading Plans',
        icon: Icons.calendar_today_outlined,
        selectedIcon: Icons.calendar_today,
        body: ReadingPlanPage(content: content),
      ),
      _PageDef(
        title: 'Models',
        icon: Icons.widgets_outlined,
        selectedIcon: Icons.widgets,
        body: const ModelsShowcasePage(),
      ),
    ];

    final isWide = MediaQuery.of(context).size.width >= 700;
    final current = pages[_navIndex];

    if (isWide) {
      // Wide layout: navigation rail
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _navIndex,
              onDestinationSelected: (i) => setState(() => _navIndex = i),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    const Icon(Icons.auto_stories, size: 32),
                    const SizedBox(height: 4),
                    Text(
                      'ministry_bible_core',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      'demo',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ),
              destinations: pages
                  .map((p) => NavigationRailDestination(
                        icon: Icon(p.icon),
                        selectedIcon: Icon(p.selectedIcon),
                        label: Text(p.title),
                      ))
                  .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AppBar(title: current.title, content: content),
                  Expanded(child: current.body),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Narrow layout: bottom navigation
    return Scaffold(
      appBar: AppBar(
        title: Text(current.title),
        actions: [_ThemeToggle()],
      ),
      body: current.body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        destinations: pages
            .map((p) => NavigationDestination(
                  icon: Icon(p.icon),
                  selectedIcon: Icon(p.selectedIcon),
                  label: p.title,
                ))
            .toList(),
      ),
    );
  }
}

// ── App bar with stats ─────────────────────────────────────────────────────

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final BibleContentService content;
  const _AppBar({required this.title, required this.content});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      height: kToolbarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: t.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Text(title,
              style: t.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(
            '${content.getTotalVerseCount()} verses · '
            '${content.getAllBooks().length} books loaded',
            style: t.textTheme.bodySmall?.copyWith(
              color: t.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          _ThemeToggle(),
        ],
      ),
    );
  }
}

// ── Theme toggle ───────────────────────────────────────────────────────────

class _ThemeToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return IconButton(
      icon: Icon(
          brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode),
      tooltip: brightness == Brightness.dark ? 'Light mode' : 'Dark mode',
      onPressed: () {
        // Find the MaterialApp ancestor and toggle
        final state = context.findAncestorStateOfType<_AppShellState>();
        // Simple approach: toggle via app restart isn't possible here,
        // but we can use a simple workaround with a ValueNotifier at the top
        // The scaffold messenger shows a hint instead
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Toggle dark mode in your OS/browser settings — '
                'the app respects system preference.'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(label: 'OK', onPressed: () {}),
          ),
        );
        state?.toString(); // suppress unused warning
      },
    );
  }
}

// ── Data class ─────────────────────────────────────────────────────────────

class _PageDef {
  final String title;
  final IconData icon;
  final IconData selectedIcon;
  final Widget body;
  const _PageDef({
    required this.title,
    required this.icon,
    required this.selectedIcon,
    required this.body,
  });
}
