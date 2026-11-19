import 'package:flutter/material.dart';

import '../data/auth_service.dart';
import '../data/tip_repository.dart';
import '../logic/tip_ranking.dart';
import '../models/tip.dart';
import 'tip_detail_screen.dart';

class CategoryTipsScreen extends StatefulWidget {
  final TipCategory category;
  final TipRepository repository;
  final AuthService authService;

  const CategoryTipsScreen({
    super.key,
    required this.category,
    required this.repository,
    required this.authService,
  });

  @override
  State<CategoryTipsScreen> createState() => _CategoryTipsScreenState();
}

class _CategoryTipsScreenState extends State<CategoryTipsScreen> {
  TipSort _sort = TipSort.mostHelpful;
  String _query = '';
  final _searchController = TextEditingController();
  List<Tip> _categoryTips = [];
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
    final list = await widget.repository.fetchTips(category: widget.category);
    if (mounted) {
      setState(() {
        _categoryTips = list;
        _isLoading = false;
      });
    }
  }

  List<Tip> get _displayTips {
    final searched = searchTips(_categoryTips, _query);
    return rankTips(searched, _sort);
  }

  void _openDetail(Tip tip) {
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
    final tips = _displayTips;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category.label,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search in ${widget.category.label}...',
                    prefixIcon: const Icon(Icons.search, size: 20),
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
                  onChanged: (val) => setState(() => _query = val),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${tips.length} tips found',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
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
                const SizedBox(height: 14),
                if (tips.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'No tips found matching "$_query"',
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                  )
                else
                  ...tips.map((tip) => _buildTipCard(theme, tip)),
              ],
            ),
    );
  }

  Widget _buildTipCard(ThemeData theme, Tip tip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _openDetail(tip),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      tip.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.thumb_up_alt_outlined,
                        size: 14,
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
                      if (tip.notHelpful > 0) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.thumb_down_alt_outlined,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${tip.notHelpful}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                tip.body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
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
                    'Read more →',
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
