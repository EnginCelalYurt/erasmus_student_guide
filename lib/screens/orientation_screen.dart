import 'package:flutter/material.dart';

import '../state/app_state.dart';

class OrientationScreen extends StatefulWidget {
  final AppState app;

  const OrientationScreen({super.key, required this.app});

  @override
  State<OrientationScreen> createState() => _OrientationScreenState();
}

class _OrientationScreenState extends State<OrientationScreen> {
  late final TextEditingController _notesController;
  late final FocusNode _notesFocus;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.app.notes);
    _notesFocus = FocusNode();
    widget.app.addListener(_syncNotes);
  }

  void _syncNotes() {
    if (_notesFocus.hasFocus) return;
    if (_notesController.text != widget.app.notes) {
      _notesController.text = widget.app.notes;
    }
  }

  @override
  void dispose() {
    widget.app.removeListener(_syncNotes);
    _notesFocus.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = widget.app;
    final total = app.checklist.length;
    final done = app.checklistDone;
    final progress = total == 0 ? 0.0 : done / total;

    final phases = <String>[];
    for (final item in app.checklist) {
      if (!phases.contains(item.phase)) phases.add(item.phase);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Orientation & Plan',
              style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.4),
            ),
            Text(
              'Checklist for enrollment, dorms & arrival notes',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          Card(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Orientation Progress',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '$done / $total completed',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    progress >= 1.0
                        ? '🎉 All onboarding steps completed! You are fully set up for university life.'
                        : 'Complete these essential steps to settle smoothly into campus and city life.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          for (final phase in phases) ...[
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                phase,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            ...app.checklist.where((c) => c.phase == phase).map((item) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  value: item.done,
                  onChanged: (_) => app.toggleChecklist(item),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      decoration: item.done ? TextDecoration.lineThrough : null,
                      color: item.done ? theme.colorScheme.onSurfaceVariant : null,
                    ),
                  ),
                  subtitle: Text(
                    item.detail,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      decoration: item.done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
          Text(
            'My Campus Notes',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Dorm room number, Wi-Fi password, coordinator contact, or personal reminders.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            focusNode: _notesFocus,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'e.g., Dean office is building B9 room 204. Need to pick up student card on Tuesday morning...',
            ),
            onChanged: (val) => app.setNotes(val),
          ),
        ],
      ),
    );
  }
}
