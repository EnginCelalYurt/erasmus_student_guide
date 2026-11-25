import 'package:flutter/material.dart';

import '../logic/tip_ranking.dart';
import '../models/tip.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../viewmodels/guide_view_model.dart';
import '../widgets/empty_state.dart';
import 'tip_detail_screen.dart';

class CategoryTipsScreen extends StatefulWidget {
  final TipCategory category;
  final GuideViewModel viewModel;
  final AppState? app;

  const CategoryTipsScreen({
    super.key,
    required this.category,
    required this.viewModel,
    this.app,
  });

  @override
  State<CategoryTipsScreen> createState() => _CategoryTipsScreenState();
}

class _CategoryTipsScreenState extends State<CategoryTipsScreen> {
  // Temporary interface state; tips and votes live in the view model.
  TipSort _sort = TipSort.mostHelpful;
  String _query = '';
  final _searchController = TextEditingController();

  GuideViewModel get _vm => widget.viewModel;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetail(Tip tip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TipDetailScreen(
          tipId: tip.id,
          viewModel: _vm,
          app: widget.app,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_vm, if (widget.app != null) widget.app!]),
      builder: (context, _) => _buildScreen(context),
    );
  }

  Widget _buildScreen(BuildContext context) {
    final theme = Theme.of(context);
    final tips = _vm.visibleTips(
      category: widget.category,
      query: _query,
      sort: _sort,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category.label,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          if (_vm.isLoading)
            Semantics(
              label: 'Loading category tips',
              child: const LinearProgressIndicator(minHeight: 3),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _vm.load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  if (_vm.showingSavedCopy) ...[
                    Material(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                          children: [
                            Icon(
                              Icons.cloud_off_outlined,
                              size: 18,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Offline, may be outdated',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSecondaryContainer,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _vm.isLoading ? null : _vm.load,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  TextField(
                  controller: _searchController,
                  decoration: AppTheme.searchDecoration(
                    context,
                    hintText: 'Search in ${widget.category.label}...',
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
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Text(
                      tips.length == 1 ? '1 tip found' : '${tips.length} tips found',
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
                if (_vm.error != null)
                  EmptyState(
                    icon: Icons.cloud_off_outlined,
                    title: 'Could Not Load Tips',
                    message: _vm.error!,
                    actionLabel: 'Retry',
                    onAction: _vm.load,
                  )
                else if (tips.isEmpty && !_vm.isLoading)
                  EmptyState(
                    icon: _query.trim().isEmpty
                        ? Icons.lightbulb_outline
                        : Icons.search_off,
                    title: _query.trim().isEmpty
                        ? 'No Tips Yet'
                        : 'No Matching Tips',
                    message: _query.trim().isEmpty
                        ? 'No tips in this category yet.'
                        : 'No tips found matching "$_query".',
                    actionLabel: _query.trim().isNotEmpty ? 'Clear search' : null,
                    onAction: _query.trim().isNotEmpty
                        ? () {
                            _searchController.clear();
                            setState(() => _query = '');
                          }
                        : null,
                  )
                else
                  ...tips.map((tip) => _buildTipCard(theme, tip)),
              ],
            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(ThemeData theme, Tip tip) {
    final saved = widget.app?.isTipSaved(tip.id) ?? false;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
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
                      if (widget.app != null) ...[
                        const SizedBox(width: 2),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          tooltip: saved ? 'Remove from Saved' : 'Save tip',
                          icon: Icon(
                            saved ? Icons.bookmark : Icons.bookmark_border,
                            size: 18,
                            color: saved
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () => widget.app!.toggleSaveTip(tip.id),
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
