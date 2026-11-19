import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/guide_topic.dart';
import '../state/app_state.dart';
import '../utils/open_link.dart';

class SurvivalGuideScreen extends StatefulWidget {
  final AppState app;

  const SurvivalGuideScreen({super.key, required this.app});

  @override
  State<SurvivalGuideScreen> createState() => _SurvivalGuideScreenState();
}

class _SurvivalGuideScreenState extends State<SurvivalGuideScreen> {
  String _category = 'all';
  String _query = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _iconFor(String category) {
    return switch (category.toLowerCase()) {
      'housing' || 'dorms' => Icons.apartment_outlined,
      'transport' => Icons.tram_outlined,
      'health' || 'emergency' => Icons.local_hospital_outlined,
      'social' || 'people' => Icons.groups_outlined,
      'daily' => Icons.local_cafe_outlined,
      'admin' => Icons.badge_outlined,
      _ => Icons.lightbulb_outline,
    };
  }

  Future<void> _launch(String url) async {
    final ok = await openLink(url);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open that link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = [
      'all',
      ...{for (final tip in widget.app.tips) tip.category},
    ];
    final q = _query.toLowerCase().trim();
    final tips = widget.app.tips.where((tip) {
      final catOk = _category == 'all' || tip.category == _category;
      final searchOk = q.isEmpty ||
          tip.title.toLowerCase().contains(q) ||
          tip.summary.toLowerCase().contains(q) ||
          tip.detailedAdvice.toLowerCase().contains(q) ||
          tip.tags.any((tag) => tag.contains(q));
      return catOk && searchOk;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student Life & Guide',
              style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.4),
            ),
            Text(
              'Essential advice, dorms, transport & local survival',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search dorms, tram ticket, BLIK, Wi-Fi...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map(
                (cat) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    avatar: cat == 'all' ? null : Icon(_iconFor(cat), size: 16),
                    label: Text(cat),
                    selected: _category == cat,
                    onSelected: (_) => setState(() => _category = cat),
                  ),
                ),
              ).toList(),
            ),
          ),
          const SizedBox(height: 14),
          Material(
            color: theme.colorScheme.errorContainer.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(10),
            child: ListTile(
              leading: const Icon(Icons.emergency_outlined),
              title: const Text('112 Emergency Help', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('Tap to call · Long-press copies number (multilingual operator)'),
              trailing: const Icon(Icons.phone),
              onTap: () => _launch('tel:112'),
              onLongPress: () async {
                await Clipboard.setData(const ClipboardData(text: '112'));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('112 copied to clipboard')),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          if (tips.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Text('No advice found matching your query.'),
              ),
            )
          else
            ...tips.map(
              (tip) => _TipItem(
                tip: tip,
                icon: _iconFor(tip.category),
                isSaved: widget.app.isTipSaved(tip.id),
                onToggleSave: () => widget.app.toggleSaveTip(tip.id),
                onAction: _launch,
              ),
            ),
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final SurvivalTip tip;
  final IconData icon;
  final bool isSaved;
  final VoidCallback onToggleSave;
  final Future<void> Function(String url) onAction;

  const _TipItem({
    required this.tip,
    required this.icon,
    required this.isSaved,
    required this.onToggleSave,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            child: Icon(icon, size: 18, color: theme.colorScheme.primary),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  tip.title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
              IconButton(
                iconSize: 20,
                tooltip: isSaved ? 'Remove Bookmark' : 'Save Tip',
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: isSaved ? theme.colorScheme.primary : null,
                ),
                onPressed: onToggleSave,
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              tip.summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                tip.detailedAdvice,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: tip.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '#$tag',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }).toList(),
            ),
            if (tip.actionUrl != null && tip.actionLabel != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonalIcon(
                  onPressed: () => onAction(tip.actionUrl!),
                  icon: const Icon(Icons.open_in_new, size: 15),
                  label: Text(tip.actionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
