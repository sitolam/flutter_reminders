import 'package:flutter/material.dart';

import '../models/reminder.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../widgets/reminder_card.dart';
import 'reminder_form.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storage = StorageService();
  List<Reminder> _reminders = <Reminder>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final List<Reminder> items = await _storage.loadAll();
    if (!mounted) return;
    setState(() {
      _reminders = items;
      _loading = false;
    });
  }

  Future<void> _persist() => _storage.saveAll(_reminders);

  Future<void> _addOrEdit([Reminder? existing]) async {
    final Reminder? result = await Navigator.of(context).push<Reminder>(
      MaterialPageRoute<Reminder>(
        builder: (_) => ReminderFormScreen(initial: existing),
      ),
    );
    if (result == null) return;

    setState(() {
      final int idx = _reminders.indexWhere((Reminder r) => r.id == result.id);
      if (idx >= 0) {
        _reminders[idx] = result;
      } else {
        _reminders.add(result);
      }
    });
    await _persist();
    await NotificationService.instance.schedule(result);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          existing == null
              ? 'Reminder created • ${result.intervalLabel.toLowerCase()}'
              : 'Reminder updated',
        ),
      ),
    );
  }

  Future<void> _toggleEnabled(Reminder r, bool enabled) async {
    final Reminder updated = r.copyWith(enabled: enabled);
    setState(() {
      final int idx = _reminders.indexWhere((Reminder x) => x.id == r.id);
      _reminders[idx] = updated;
    });
    await _persist();
    await NotificationService.instance.schedule(updated);
  }

  Future<void> _delete(Reminder r) async {
    setState(() => _reminders.removeWhere((Reminder x) => x.id == r.id));
    await _persist();
    await NotificationService.instance.cancel(r.id);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar.large(
            title: const Text('Reminders'),
            backgroundColor: cs.surface,
            actions: <Widget>[
              IconButton(
                tooltip: 'About',
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showAbout(context),
              ),
              const SizedBox(width: 4),
            ],
          ),
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_reminders.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(onAdd: () => _addOrEdit()),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
              sliver: SliverList.separated(
                itemCount: _reminders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (BuildContext ctx, int i) {
                  final Reminder r = _reminders[i];
                  return ReminderCard(
                    reminder: r,
                    onTap: () => _addOrEdit(r),
                    onToggle: (bool v) => _toggleEnabled(r, v),
                    onDelete: () => _delete(r),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrEdit(),
        icon: const Icon(Icons.add),
        label: const Text('New reminder'),
      ),
    );
  }

  void _showAbout(BuildContext ctx) {
    showAboutDialog(
      context: ctx,
      applicationName: 'Reminders',
      applicationVersion: '1.0',
      applicationIcon: Icon(
        Icons.notifications_active,
        size: 40,
        color: Theme.of(ctx).colorScheme.primary,
      ),
      children: const <Widget>[
        Text(
          'A simple Material You app for scheduling periodic '
          'reminders at a custom interval.',
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 60,
                color: cs.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text('No reminders yet', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Tap the button below to schedule\nyour first periodic reminder.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
