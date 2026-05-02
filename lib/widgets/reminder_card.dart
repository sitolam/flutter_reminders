import 'package:flutter/material.dart';

import '../models/reminder.dart';

class ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  IconData get _icon {
    switch (reminder.intervalUnit) {
      case IntervalUnit.minutes:
        return Icons.timer_outlined;
      case IntervalUnit.hours:
        return Icons.schedule_outlined;
      case IntervalUnit.days:
        return Icons.calendar_today_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final bool disabled = !reminder.enabled;

    return Card.filled(
      color: disabled ? cs.surfaceContainerLow : cs.surfaceContainerHigh,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: disabled
                      ? cs.surfaceContainerHighest
                      : cs.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _icon,
                  color: disabled
                      ? cs.onSurfaceVariant
                      : cs.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: disabled ? cs.onSurfaceVariant : cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reminder.intervalLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    if (reminder.note != null &&
                        reminder.note!.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 4),
                      Text(
                        reminder.note!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: reminder.enabled,
                onChanged: onToggle,
              ),
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline),
                color: cs.onSurfaceVariant,
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext ctx) async {
    final bool? ok = await showDialog<bool>(
      context: ctx,
      builder: (BuildContext c) => AlertDialog(
        title: const Text('Delete reminder?'),
        content: Text('"${reminder.title}" will be removed.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) onDelete();
  }
}
