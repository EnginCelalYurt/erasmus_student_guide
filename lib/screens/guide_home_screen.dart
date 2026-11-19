import 'package:flutter/material.dart';

import '../data/auth_service.dart';
import '../data/tip_repository.dart';
import '../logic/tip_ranking.dart';
import '../models/tip.dart';
import '../services/lodz_api_service.dart';
import '../services/mobile_capabilities_service.dart';
import 'category_tips_screen.dart';
import 'tip_detail_screen.dart';

class GuideHomeScreen extends StatefulWidget {
  final TipRepository repository;
  final AuthService authService;

  const GuideHomeScreen({
    super.key,
    required this.repository,
    required this.authService,
  });

  @override
  State<GuideHomeScreen> createState() => _GuideHomeScreenState();
}

class _GuideHomeScreenState extends State<GuideHomeScreen> {
  final LodzApiService _apiService = LodzApiService();
  TipSort _sort = TipSort.mostHelpful;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  List<Tip> _allTips = [];
  bool _isLoadingTips = true;

  LodzLiveInfo? _liveInfo;
  bool _isLoadingLiveInfo = true;

  @override
  void initState() {
    super.initState();
    _loadTips();
    _loadLiveApiData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTips() async {
    setState(() => _isLoadingTips = true);
    final tips = await widget.repository.fetchTips();
    if (mounted) {
      setState(() {
        _allTips = tips;
        _isLoadingTips = false;
      });
    }
  }

  Future<void> _loadLiveApiData({bool forceRefresh = false}) async {
    setState(() => _isLoadingLiveInfo = true);

    try {
      final info = await _apiService.fetchLiveInfo(forceRefresh: forceRefresh);
      if (mounted) {
        setState(() {
          _liveInfo = info;
          _isLoadingLiveInfo = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingLiveInfo = false);
      }
    }
  }

  List<Tip> get _processedTips {
    final searched = searchTips(_allTips, _searchQuery);
    return rankTips(searched, _sort);
  }

  IconData _iconForCategory(TipCategory category) {
    return switch (category) {
      TipCategory.dormitories => Icons.apartment,
      TipCategory.transport => Icons.tram,
      TipCategory.emergency => Icons.local_hospital,
      TipCategory.studentLife => Icons.groups,
      TipCategory.dailyLife => Icons.local_cafe,
      TipCategory.firstWeeks => Icons.flag_outlined,
    };
  }

  void _openCategory(TipCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryTipsScreen(
          category: category,
          repository: widget.repository,
          authService: widget.authService,
        ),
      ),
    ).then((_) => _loadTips());
  }

  void _openTipDetail(Tip tip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TipDetailScreen(
          tip: tip,
          repository: widget.repository,
          authService: widget.authService,
        ),
      ),
    ).then((_) => _loadTips());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = widget.authService.currentUser;
    final tips = _processedTips;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Official App Name per Week 4 specification
            const Text(
              'Erasmus Student Guide',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: -0.4,
              ),
            ),
            Text(
              user != null ? 'Signed in as ${user.email}' : 'Politechnika Łódzka · Student-powered guide',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: _isLoadingTips
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _loadTips();
                await _loadLiveApiData(forceRefresh: true);
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 36),
                children: [
                  // Live API Widget with cached offline indicators
                  _buildLiveInfoCard(theme),
                  const SizedBox(height: 12),

                  // 112 Emergency Banner with mobile capability and clipboard fallback
                  _build112Banner(theme),
                  const SizedBox(height: 14),

                  // Search Field with accessibility semantics
                  Semantics(
                    label: 'Search tips and guides across all categories',
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search dorms, tram, BLIK, 112...',
                        prefixIcon: const Icon(Icons.search),
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
                  ),
                  const SizedBox(height: 20),

                  // Categories Grid with updated visible counts
                  Text(
                    'Explore by Category',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildCategoriesGrid(theme),
                  const SizedBox(height: 24),

                  // Wilson Score / Newest Sorting Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'Search Results (${tips.length})'
                            : 'Top Advice (${tips.length})',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SegmentedButton<TipSort>(
                        segments: const [
                          ButtonSegment(
                            value: TipSort.mostHelpful,
                            label: Text('Most helpful'),
                            icon: Icon(Icons.thumb_up_outlined, size: 14),
                            tooltip: 'Sort by Wilson score interval',
                          ),
                          ButtonSegment(
                            value: TipSort.newest,
                            label: Text('Newest'),
                            icon: Icon(Icons.schedule, size: 14),
                            tooltip: 'Sort by newest created first',
                          ),
                        ],
                        selected: {_sort},
                        onSelectionChanged: (set) => setState(() => _sort = set.first),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Tips List with clear empty states
                  if (tips.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off_outlined,
                              size: 40,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No tips matching "$_searchQuery"',
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Try searching for "dorm", "tram", or "document", or share your own advice in the Share tab.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...tips.map((tip) => _buildTipCard(theme, tip)),
                ],
              ),
            ),
    );
  }

  Widget _buildLiveInfoCard(ThemeData theme) {
    if (_isLoadingLiveInfo) {
      return Card(
        color: theme.colorScheme.surfaceContainerLowest,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 12),
              Text('Checking live Łódź exchange rates & weather...'),
            ],
          ),
        ),
      );
    }

    final info = _liveInfo;
    if (info == null) return const SizedBox.shrink();

    return Card(
      color: info.isFromCache
          ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6)
          : theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  info.isFromCache ? Icons.cloud_off : Icons.wifi,
                  size: 16,
                  color: info.isFromCache
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  info.isFromCache ? 'CACHED OFFLINE DATA' : 'LIVE ŁÓDŹ CAMPUS INFO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: info.isFromCache
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.primary,
                  ),
                ),
                const Spacer(),
                Semantics(
                  button: true,
                  label: 'Refresh live exchange rates and weather',
                  child: InkWell(
                    onTap: () => _loadLiveApiData(forceRefresh: true),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh, size: 14, color: theme.colorScheme.primary),
                        const SizedBox(width: 2),
                        Text(
                          'Refresh',
                          style: TextStyle(fontSize: 11, color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.euro, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '1 EUR = ${info.eurToPln.toStringAsFixed(2)} PLN',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.thermostat, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        'Łódź: ${info.temperatureC.toStringAsFixed(1)}°C',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (info.notice != null) ...[
              const SizedBox(height: 6),
              Text(
                info.notice!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _build112Banner(ThemeData theme) {
    return Semantics(
      label: 'Emergency 112 helpline. Tap to call or long press to copy to clipboard.',
      child: Material(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.75),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.3)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => MobileCapabilitiesService.dialOrCopyEmergencyNumber(
            context: context,
            phoneNumber: '112',
            serviceLabel: 'General Emergency',
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone_in_talk,
                    color: Colors.white,
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
                          Text(
                            '112 Emergency Helpline',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'FREE',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Police, ambulance & fire · Direct dial with clipboard fallback',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onErrorContainer.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onErrorContainer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid(ThemeData theme) {
    final categories = TipCategory.values;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 500 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 2.1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];

            // Week 4 requirement: Count only visible (non-hidden) tips
            final visibleCount = _allTips
                .where((t) => t.category == cat && !isHidden(t))
                .length;

            // Week 4 requirement: "1 tip" vs "N tips" formatting
            final countLabel = visibleCount == 1 ? '1 tip' : '$visibleCount tips';

            return Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _openCategory(cat),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                        child: Icon(
                          _iconForCategory(cat),
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              cat.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              countLabel,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTipCard(ThemeData theme, Tip tip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _openTipDetail(tip),
        child: Padding(
          padding: const EdgeInsets.all(14),
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
                      tip.category.label.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.thumb_up_alt_outlined,
                    size: 13,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${tip.helpful}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                tip.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tip.body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'By ${tip.authorName}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'View advice →',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
