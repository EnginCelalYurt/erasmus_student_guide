import 'package:flutter/material.dart';

import '../models/university.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../utils/open_link.dart';

class CampusScreen extends StatefulWidget {
  final AppState app;

  const CampusScreen({super.key, required this.app});

  @override
  State<CampusScreen> createState() => _CampusScreenState();
}

class _CampusScreenState extends State<CampusScreen> {
  int _activeTab = 0; // 0: Facilities, 1: Campuses & Faculties, 2: Clubs
  String _facilityFilter = 'all';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _iconForCategory(String category) {
    return switch (category.toLowerCase()) {
      'library' => Icons.local_library_outlined,
      'sports' => Icons.pool_outlined,
      'dorms' => Icons.apartment_outlined,
      'admin' => Icons.badge_outlined,
      'dining' => Icons.restaurant_outlined,
      'medical' => Icons.local_hospital_outlined,
      _ => Icons.business_outlined,
    };
  }

  Future<void> _handleLink(String url) async {
    final ok = await openLink(url);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link on this device.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uni = widget.app.university;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              uni.name,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: -0.4,
              ),
            ),
            Text(
              '${uni.nativeName} · ${uni.city}, ${uni.country}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Theme',
            icon: Icon(
              switch (widget.app.themeMode) {
                ThemeMode.system => Icons.brightness_auto,
                ThemeMode.light => Icons.light_mode,
                ThemeMode.dark => Icons.dark_mode,
              },
            ),
            onPressed: widget.app.cycleTheme,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          _buildHeroCard(theme, uni),
          const SizedBox(height: 16),
          _buildEmergencyBar(theme, uni),
          const SizedBox(height: 20),
          _buildSectionSelector(theme),
          const SizedBox(height: 16),
          if (_activeTab == 0) _buildFacilitiesSection(theme)
          else if (_activeTab == 1) _buildCampusesSection(theme, uni)
          else _buildClubsSection(theme, uni),
        ],
      ),
    );
  }

  Widget _buildHeroCard(ThemeData theme, UniversityProfile uni) {
    return Card(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.school, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Campus & University Directory',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Est. ${uni.establishedYear} · ${uni.studentCount} students',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              uni.description,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _handleLink(uni.websiteUrl),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('Official Portal (p.lodz.pl)'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyBar(ThemeData theme, UniversityProfile uni) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.support_agent, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              'Quick Contacts & Helpline',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 82,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: uni.emergencyContacts.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final contact = uni.emergencyContacts[index];
              return Material(
                color: contact.isHighlight
                    ? theme.colorScheme.errorContainer.withValues(alpha: 0.6)
                    : theme.colorScheme.surfaceContainerLowest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: contact.isHighlight
                        ? theme.colorScheme.error.withValues(alpha: 0.3)
                        : theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _handleLink('tel:${contact.phone.replaceAll(' ', '')}'),
                  child: Container(
                    width: 190,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          contact.label,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: contact.isHighlight
                                ? theme.colorScheme.onErrorContainer
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          contact.phone,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          contact.subtitle,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionSelector(ThemeData theme) {
    return SegmentedButton<int>(
      segments: const [
        ButtonSegment(
          value: 0,
          label: Text('Facilities'),
          icon: Icon(Icons.place_outlined),
        ),
        ButtonSegment(
          value: 1,
          label: Text('Campuses'),
          icon: Icon(Icons.domain_outlined),
        ),
        ButtonSegment(
          value: 2,
          label: Text('Clubs'),
          icon: Icon(Icons.diversity_3_outlined),
        ),
      ],
      selected: {_activeTab},
      onSelectionChanged: (set) => setState(() => _activeTab = set.first),
    );
  }

  Widget _buildFacilitiesSection(ThemeData theme) {
    final categories = ['all', 'Library', 'Dining', 'Dorms', 'Sports', 'Admin', 'Medical'];
    final q = _searchQuery.toLowerCase().trim();

    final filtered = widget.app.university.facilities.where((fac) {
      final matchCat = _facilityFilter == 'all' || fac.category == _facilityFilter;
      final matchSearch = q.isEmpty ||
          fac.name.toLowerCase().contains(q) ||
          fac.description.toLowerCase().contains(q) ||
          fac.location.toLowerCase().contains(q) ||
          fac.studentTips.toLowerCase().contains(q);
      return matchCat && matchSearch;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          decoration: AppTheme.searchDecoration(
            context,
            hintText: 'Search library, gym, canteen, medical...',
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    tooltip: 'Clear search',
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
          ),
          onChanged: (val) => setState(() => _searchQuery = val),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((cat) {
              final isSel = _facilityFilter == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  avatar: cat == 'all' ? null : Icon(_iconForCategory(cat), size: 15),
                  label: Text(cat),
                  selected: isSel,
                  onSelected: (_) => setState(() => _facilityFilter = cat),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),
        if (filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 36),
            child: Center(
              child: Text(
                'No campus facility found matching your search.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ...filtered.map((fac) => _buildFacilityCard(theme, fac)),
      ],
    );
  }

  Widget _buildFacilityCard(ThemeData theme, CampusFacility fac) {
    final isSaved = widget.app.isFacilitySaved(fac.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  child: Icon(
                    _iconForCategory(fac.category),
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              fac.category.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            iconSize: 20,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: isSaved
                                ? 'Remove ${fac.name} from saved'
                                : 'Bookmark ${fac.name}',
                            icon: Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_border,
                              color: isSaved ? theme.colorScheme.primary : null,
                            ),
                            onPressed: () => widget.app.toggleSaveFacility(fac.id),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fac.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 15, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    fac.location,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time_outlined, size: 15, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    fac.hours,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(fac.description, style: theme.textTheme.bodyMedium?.copyWith(height: 1.4)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.tips_and_updates_outlined, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fac.studentTips,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _handleLink(
                    'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(fac.mapsQuery)}',
                  ),
                  icon: const Icon(Icons.map_outlined, size: 16),
                  label: const Text('Map'),
                ),
                if (fac.actionUrl != null && fac.actionLabel != null) ...[
                  const SizedBox(width: 4),
                  FilledButton.tonalIcon(
                    onPressed: () => _handleLink(fac.actionUrl!),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: Text(fac.actionLabel!),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampusesSection(ThemeData theme, UniversityProfile uni) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'University Campuses & Faculties',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          'Politechnika Łódzka is organized across central sectors connected by trams and green parks.',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        ...uni.campuses.map(
          (campus) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.domain, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          campus.name,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    campus.address,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(campus.description, style: theme.textTheme.bodyMedium?.copyWith(height: 1.4)),
                  const SizedBox(height: 12),
                  Text(
                    'Faculties & Centers here:',
                    style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  ...campus.faculties.map(
                    (fac) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(child: Text(fac, style: theme.textTheme.bodySmall)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _handleLink(
                        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(campus.mapsQuery)}',
                      ),
                      icon: const Icon(Icons.directions, size: 16),
                      label: const Text('Get Directions'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClubsSection(ThemeData theme, UniversityProfile uni) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Student Clubs & Societies',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          'Join international student networks, robotics labs, or campus radio teams.',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        ...uni.clubs.map(
          (club) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          club.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          club.name,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(club.description, style: theme.textTheme.bodyMedium?.copyWith(height: 1.4)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.link, size: 16, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          club.contact,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
