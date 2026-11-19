import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/auth_service.dart';
import '../data/tip_repository.dart';
import '../logic/tip_ranking.dart';
import '../models/tip.dart';
import '../utils/open_link.dart';
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
  TipSort _sort = TipSort.mostHelpful;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  List<Tip> _allTips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTips();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTips() async {
    setState(() => _isLoading = true);
    final tips = await widget.repository.fetchTips();
    if (mounted) {
      setState(() {
        _allTips = tips;
        _isLoading = false;
      });
    }
  }

  List<Tip> get _processedTips {
    final searched = searchTips(_allTips, _searchQuery);
    return rankTips(searched, _sort);
  }

  Future<void> _call112() async {
    final ok = await openLink('tel:112');
    if (!ok && mounted) {
      await Clipboard.setData(const ClipboardData(text: '112'));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('112 Emergency number copied')),
      );
    }
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
            const Text(
              'University Guide',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: -0.4,
              ),
            ),
            Text(
              user != null ? 'Signed in as ${user.email}' : 'Politechnika Łódzka Campus Guide',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTips,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 36),
                children: [
                  // 1. 112 Emergency Banner
                  _build112Banner(theme),
                  const SizedBox(height: 14),

                  // 2. Search Field (calling searchTips)
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search dorms, tram, BLIK, 112...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
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
                  const SizedBox(height: 20),

                  // 3. Categories Grid
                  Text(
                    'Explore by Category',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildCategoriesGrid(theme),
                  const SizedBox(height: 24),

                  // 4. Most Helpful / Newest Rank Selector (Wilson score)
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
                          ),
                          ButtonSegment(
                            value: TipSort.newest,
                            label: Text('Newest'),
                            icon: Icon(Icons.schedule, size: 14),
                          ),
                        ],
                        selected: {_sort},
                        onSelectionChanged: (set) => setState(() => _sort = set.first),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 5. Tips List (Ranked & Searched)
                  if (tips.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'No tips found for "$_searchQuery"',
                          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
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

  Widget _build112Banner(ThemeData theme) {
    return Material(
      color: theme.colorScheme.errorContainer.withValues(alpha: 0.75),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _call112,
        onLongPress: () async {
          await Clipboard.setData(const ClipboardData(text: '112'));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('112 Emergency number copied')),
            );
          }
        },
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
                      'Police, ambulance & fire · Multilingual · Tap to call',
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
            final count = _allTips.where((t) => t.category == cat).length;

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
                              '$count tips',
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
