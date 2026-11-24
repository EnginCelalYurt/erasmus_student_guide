import 'package:flutter/material.dart';

import '../models/guide_topic.dart';
import '../state/app_state.dart';
import '../utils/open_link.dart';

class CityPlacesScreen extends StatefulWidget {
  final AppState app;

  const CityPlacesScreen({super.key, required this.app});

  @override
  State<CityPlacesScreen> createState() => _CityPlacesScreenState();
}

class _CityPlacesScreenState extends State<CityPlacesScreen> {
  String _kind = 'all';
  String _query = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _iconForKind(String kind) {
    return switch (kind.toLowerCase()) {
      'campus' => Icons.school_outlined,
      'sports' => Icons.fitness_center_outlined,
      'social & dining' => Icons.restaurant_outlined,
      'shopping & leisure' || 'shopping & essentials' => Icons.shopping_bag_outlined,
      'transport' => Icons.train_outlined,
      'culture' => Icons.museum_outlined,
      'parks' => Icons.park_outlined,
      _ => Icons.place_outlined,
    };
  }

  Future<void> _openMap(String mapsQuery) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(mapsQuery)}';
    final ok = await openLink(url);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open map link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final kinds = [
      'all',
      ...{for (final p in widget.app.places) p.kind},
    ];
    final q = _query.toLowerCase().trim();

    final filtered = widget.app.places.where((p) {
      final kindOk = _kind == 'all' || p.kind == _kind;
      final searchOk = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.area.toLowerCase().contains(q) ||
          p.note.toLowerCase().contains(q);
      return kindOk && searchOk;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'City & Campus Spots',
              style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.4),
            ),
            Text(
              'Student hangouts, transit hubs & essentials in Łódź',
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
              hintText: 'Search Piotrkowska, station, park, mall...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
            ),
            onChanged: (val) => setState(() => _query = val),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: kinds.map(
                (k) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    avatar: k == 'all' ? null : Icon(_iconForKind(k), size: 15),
                    label: Text(k),
                    selected: _kind == k,
                    onSelected: (_) => setState(() => _kind = k),
                  ),
                ),
              ).toList(),
            ),
          ),
          const SizedBox(height: 14),
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Text('No location found.')),
            )
          else
            ...filtered.map(
              (place) => _PlaceListItem(
                place: place,
                icon: _iconForKind(place.kind),
                isSaved: widget.app.isPlaceSaved(place.id),
                onToggleSave: () => widget.app.toggleSavePlace(place.id),
                onOpenMap: () => _openMap(place.mapsQuery),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlaceListItem extends StatelessWidget {
  final CityPlace place;
  final IconData icon;
  final bool isSaved;
  final VoidCallback onToggleSave;
  final VoidCallback onOpenMap;

  const _PlaceListItem({
    required this.place,
    required this.icon,
    required this.isSaved,
    required this.onToggleSave,
    required this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  child: Icon(icon, size: 18, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              place.kind.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '· ${place.area}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            iconSize: 20,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: isSaved ? 'Remove Bookmark' : 'Save Place',
                            icon: Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_border,
                              color: isSaved ? theme.colorScheme.primary : null,
                            ),
                            onPressed: onToggleSave,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        place.name,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              place.note,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: onOpenMap,
                icon: const Icon(Icons.directions, size: 16),
                label: const Text('Open in Google Maps'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
