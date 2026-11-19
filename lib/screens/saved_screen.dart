import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../utils/open_link.dart';
import '../widgets/empty_state.dart';

class SavedScreen extends StatelessWidget {
  final AppState app;

  const SavedScreen({super.key, required this.app});

  Future<void> _handleLink(BuildContext context, String url) async {
    final ok = await openLink(url);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final savedTips = app.savedTips;
    final savedPlaces = app.savedPlaces;
    final savedFacilities = app.savedFacilities;
    final total = app.totalSavedCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved & Bookmarks', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: total == 0
          ? const EmptyState(
              icon: Icons.bookmark_border,
              title: 'No Bookmarks Yet',
              message:
                  'Bookmark essential campus facilities, survival tips, or city spots using the bookmark icon to access them quickly here.',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              children: [
                Text(
                  '$total items bookmarked',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                if (savedFacilities.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.business, size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Campus Facilities (${savedFacilities.length})',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...savedFacilities.map(
                    (fac) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                          child: Icon(Icons.school, size: 18, color: theme.colorScheme.primary),
                        ),
                        title: Text(fac.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        subtitle: Text('${fac.location} · ${fac.hours}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.bookmark_remove_outlined),
                          tooltip: 'Remove',
                          onPressed: () => app.toggleSaveFacility(fac.id),
                        ),
                        onTap: () => _handleLink(
                          context,
                          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(fac.mapsQuery)}',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (savedTips.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.lightbulb, size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Survival Advice & Life Hacks (${savedTips.length})',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...savedTips.map(
                    (tip) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                          child: Icon(Icons.tips_and_updates, size: 18, color: theme.colorScheme.primary),
                        ),
                        title: Text(tip.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        subtitle: Text(tip.summary, maxLines: 2, overflow: TextOverflow.ellipsis),
                        trailing: IconButton(
                          icon: const Icon(Icons.bookmark_remove_outlined),
                          tooltip: 'Remove',
                          onPressed: () => app.toggleSaveTip(tip.id),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (savedPlaces.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.place, size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        'City & Campus Spots (${savedPlaces.length})',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...savedPlaces.map(
                    (place) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                          child: Icon(Icons.map, size: 18, color: theme.colorScheme.primary),
                        ),
                        title: Text(place.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        subtitle: Text('${place.kind} · ${place.area}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.bookmark_remove_outlined),
                          tooltip: 'Remove',
                          onPressed: () => app.toggleSavePlace(place.id),
                        ),
                        onTap: () => _handleLink(
                          context,
                          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(place.mapsQuery)}',
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
