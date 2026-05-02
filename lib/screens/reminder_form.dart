import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/reminder.dart';

class ReminderFormScreen extends StatefulWidget {
  final Reminder? initial;
  const ReminderFormScreen({super.key, this.initial});

  @override
  State<ReminderFormScreen> createState() => _ReminderFormScreenState();
}

class _ReminderFormScreenState extends State<ReminderFormScreen> {
  late final TextEditingController _title;
  late final TextEditingController _note;
  late final TextEditingController _valueCtrl;
  late int _value;
  late IntervalUnit _unit;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final Reminder? r = widget.initial;
    _title = TextEditingController(text: r?.title ?? '');
    _note = TextEditingController(text: r?.note ?? '');
    _value = r?.intervalValue ?? 1;
    _unit = r?.intervalUnit ?? IntervalUnit.hours;
    _valueCtrl = TextEditingController(text: _value.toString());
  }

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final int id = widget.initial?.id ??
        DateTime.now().millisecondsSinceEpoch.remainder(1 << 31);

    final Reminder result = Reminder(
      id: id,
      title: _title.text.trim(),
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      intervalValue: _value,
      intervalUnit: _unit,
      enabled: widget.initial?.enabled ?? true,
      createdAt: widget.initial?.createdAt ?? DateTime.now(),
    );
    Navigator.of(context).pop(result);
  }

  String _unitLabel() {
    switch (_unit) {
      case IntervalUnit.minutes:
        return _value == 1 ? 'minute' : 'minutes';
      case IntervalUnit.hours:
        return _value == 1 ? 'hour' : 'hours';
      case IntervalUnit.days:
        return _value == 1 ? 'day' : 'days';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final bool isEdit = widget.initial != null;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit reminder' : 'New reminder'),
        backgroundColor: cs.surface,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: <Widget>[
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g. Take a break',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notifications_active_outlined),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (String? v) =>
                  v == null || v.trim().isEmpty ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _note,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'e.g. Stretch and drink water',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes_outlined),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
            ),
            const SizedBox(height: 28),
            Text('Repeat every', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 110,
                  child: TextFormField(
                    controller: _valueCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Interval',
                    ),
                    onChanged: (String v) {
                      final int? parsed = int.tryParse(v);
                      if (parsed != null && parsed > 0) {
                        setState(() => _value = parsed);
                      }
                    },
                    validator: (String? v) {
                      final int? n = int.tryParse(v ?? '');
                      if (n == null || n <= 0) {
                        return 'Enter a positive number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SegmentedButton<IntervalUnit>(
                    segments: const <ButtonSegment<IntervalUnit>>[
                      ButtonSegment<IntervalUnit>(
                        value: IntervalUnit.minutes,
                        label: Text('Min'),
                      ),
                      ButtonSegment<IntervalUnit>(
                        value: IntervalUnit.hours,
                        label: Text('Hr'),
                      ),
                      ButtonSegment<IntervalUnit>(
                        value: IntervalUnit.days,
                        label: Text('Day'),
                      ),
                    ],
                    selected: <IntervalUnit>{_unit},
                    onSelectionChanged: (Set<IntervalUnit> s) =>
                        setState(() => _unit = s.first),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const _QuickPresets(),
            const SizedBox(height: 24),
            Card.filled(
              color: cs.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.info_outline, color: cs.onSecondaryContainer),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You\'ll be reminded every $_value ${_unitLabel()} '
                        'until you turn it off.',
                        style: TextStyle(color: cs.onSecondaryContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: Text(isEdit ? 'Save changes' : 'Create reminder'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders a strip of preset chips like "15 min", "1 hr", etc. Tapping
/// one fills the interval fields above.
class _QuickPresets extends StatelessWidget {
  const _QuickPresets();

  static const List<({String label, int value, IntervalUnit unit})> _presets =
      <({String label, int value, IntervalUnit unit})>[
    (label: '15 min', value: 15, unit: IntervalUnit.minutes),
    (label: '30 min', value: 30, unit: IntervalUnit.minutes),
    (label: '1 hr', value: 1, unit: IntervalUnit.hours),
    (label: '2 hr', value: 2, unit: IntervalUnit.hours),
    (label: '4 hr', value: 4, unit: IntervalUnit.hours),
    (label: 'Daily', value: 1, unit: IntervalUnit.days),
  ];

  @override
  Widget build(BuildContext context) {
    final _ReminderFormScreenState? state =
        context.findAncestorStateOfType<_ReminderFormScreenState>();
    if (state == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _presets.map(
          (({String label, int value, IntervalUnit unit}) p) {
            final bool selected =
                state._value == p.value && state._unit == p.unit;
            return FilterChip(
              label: Text(p.label),
              selected: selected,
              onSelected: (_) {
                state.setState(() {
                  state._value = p.value;
                  state._unit = p.unit;
                  state._valueCtrl.text = p.value.toString();
                });
              },
            );
          },
        ).toList(),
      ),
    );
  }
}
