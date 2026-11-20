import 'package:flutter/material.dart';

import '../logic/tip_ranking.dart';
import '../models/tip.dart';
import '../viewmodels/guide_view_model.dart';

class TipDetailScreen extends StatefulWidget {
  final String tipId;
  final GuideViewModel viewModel;

  const TipDetailScreen({
    super.key,
    required this.tipId,
    required this.viewModel,
  });

  @override
  State<TipDetailScreen> createState() => _TipDetailScreenState();
}

class _TipDetailScreenState extends State<TipDetailScreen> {
  GuideViewModel get _vm => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _vm.loadMyVote(widget.tipId);
  }

  Future<void> _castVote(VoteValue value) async {
    final outcome = await _vm.vote(widget.tipId, value);
    if (!mounted) return;
    final message = switch (outcome) {
      VoteOutcome.signInRequired => 'Sign in with your TUL e-mail to vote.',
      VoteOutcome.failed => 'Could not save your vote. Check your connection.',
      VoteOutcome.saved => null,
    };
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) => _buildScreen(context),
    );
  }

  Widget _buildScreen(BuildContext context) {
    final theme = Theme.of(context);
    final tip = _vm.tipById(widget.tipId);
    if (tip == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('This tip is no longer available.')),
      );
    }
    final myVote = _vm.myVote(widget.tipId);
    final score = wilsonScore(tip.helpful, tip.notHelpful);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tip.category.label,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                child: Icon(
                  _iconForCategory(tip.category),
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tip.category.label.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Shared by ${tip.authorName} · ${_formatDate(tip.createdAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            tip.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            tip.body,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.6,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),
          Text(
            'Was this advice helpful?',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Wilson score: ${(score * 100).toStringAsFixed(1)}% · ${tip.helpful} helpful · ${tip.notHelpful} not helpful',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: myVote == VoteValue.helpful
                          ? theme.colorScheme.primaryContainer
                          : null,
                      side: BorderSide(
                        color: myVote == VoteValue.helpful
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                      ),
                    ),
                    onPressed: () => _castVote(VoteValue.helpful),
                    icon: Icon(
                      myVote == VoteValue.helpful
                          ? Icons.thumb_up
                          : Icons.thumb_up_outlined,
                      size: 16,
                      color: myVote == VoteValue.helpful
                          ? theme.colorScheme.primary
                          : null,
                    ),
                    label: Text(
                      'Helpful (${tip.helpful})',
                      style: TextStyle(
                        color: myVote == VoteValue.helpful
                            ? theme.colorScheme.primary
                            : null,
                        fontWeight: myVote == VoteValue.helpful
                            ? FontWeight.w700
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: myVote == VoteValue.notHelpful
                          ? theme.colorScheme.errorContainer.withValues(alpha: 0.5)
                          : null,
                      side: BorderSide(
                        color: myVote == VoteValue.notHelpful
                            ? theme.colorScheme.error
                            : theme.colorScheme.outlineVariant,
                      ),
                    ),
                    onPressed: () => _castVote(VoteValue.notHelpful),
                    icon: Icon(
                      myVote == VoteValue.notHelpful
                          ? Icons.thumb_down
                          : Icons.thumb_down_outlined,
                      size: 16,
                      color: myVote == VoteValue.notHelpful
                          ? theme.colorScheme.error
                          : null,
                    ),
                    label: Text(
                      'Not helpful (${tip.notHelpful})',
                      style: TextStyle(
                        color: myVote == VoteValue.notHelpful
                            ? theme.colorScheme.error
                            : null,
                        fontWeight: myVote == VoteValue.notHelpful
                            ? FontWeight.w700
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}.${dt.month}.${dt.year}';
  }
}
