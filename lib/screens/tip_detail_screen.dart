import 'package:flutter/material.dart';

import '../data/auth_service.dart';
import '../data/tip_repository.dart';
import '../logic/tip_ranking.dart';
import '../models/tip.dart';

class TipDetailScreen extends StatefulWidget {
  final Tip tip;
  final TipRepository repository;
  final AuthService authService;

  const TipDetailScreen({
    super.key,
    required this.tip,
    required this.repository,
    required this.authService,
  });

  @override
  State<TipDetailScreen> createState() => _TipDetailScreenState();
}

class _TipDetailScreenState extends State<TipDetailScreen> {
  late Tip _tip;
  VoteValue? _myVote;
  bool _isLoadingVote = true;

  @override
  void initState() {
    super.initState();
    _tip = widget.tip;
    _checkMyVote();
  }

  Future<void> _checkMyVote() async {
    final user = widget.authService.currentUser;
    if (user != null) {
      final vote = await widget.repository.myVote(
        tipId: _tip.id,
        userId: user.uid,
      );
      if (mounted) {
        setState(() {
          _myVote = vote;
          _isLoadingVote = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoadingVote = false);
    }
  }

  /// Toggles, changes, or removes the user's vote according to repo contract.
  Future<void> _castVote(VoteValue value) async {
    final user = widget.authService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign in with your TUL e-mail to vote on student advice.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // If tapping the already-selected vote, remove it (null). Otherwise, set or change it.
    final newVote = _myVote == value ? null : value;
    final updated = await widget.repository.vote(
      tipId: _tip.id,
      userId: user.uid,
      value: newVote,
    );

    if (mounted) {
      setState(() {
        _tip = updated;
        _myVote = newVote;
      });

      final feedbackText = newVote == null
          ? 'Vote removed.'
          : (newVote == VoteValue.helpful
              ? 'Marked as helpful. Thank you!'
              : 'Marked as not helpful.');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(feedbackText), duration: const Duration(seconds: 2)),
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
    final theme = Theme.of(context);
    final score = wilsonScore(_tip.helpful, _tip.notHelpful);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _tip.category.label,
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
                  _iconForCategory(_tip.category),
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
                        _tip.category.label.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Shared by ${_tip.authorName} · ${_formatDate(_tip.createdAt)}',
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
            _tip.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _tip.body,
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
          const SizedBox(height: 4),
          Text(
            'Wilson confidence score: ${(score * 100).toStringAsFixed(1)}% · ${_tip.helpful} helpful · ${_tip.notHelpful} not helpful',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          if (_isLoadingVote)
            const SizedBox(
              height: 44,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    button: true,
                    label: _myVote == VoteValue.helpful
                        ? 'Remove your helpful vote. Currently ${_tip.helpful} helpful votes.'
                        : 'Vote helpful. Currently ${_tip.helpful} helpful votes.',
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _myVote == VoteValue.helpful
                            ? theme.colorScheme.primaryContainer
                            : null,
                        side: BorderSide(
                          color: _myVote == VoteValue.helpful
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant,
                          width: _myVote == VoteValue.helpful ? 2 : 1,
                        ),
                      ),
                      onPressed: () => _castVote(VoteValue.helpful),
                      icon: Icon(
                        _myVote == VoteValue.helpful ? Icons.thumb_up : Icons.thumb_up_outlined,
                        size: 16,
                        color: _myVote == VoteValue.helpful ? theme.colorScheme.primary : null,
                      ),
                      label: Text(
                        'Helpful (${_tip.helpful})',
                        style: TextStyle(
                          color: _myVote == VoteValue.helpful ? theme.colorScheme.primary : null,
                          fontWeight: _myVote == VoteValue.helpful ? FontWeight.w800 : null,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Semantics(
                    button: true,
                    label: _myVote == VoteValue.notHelpful
                        ? 'Remove your not helpful vote. Currently ${_tip.notHelpful} not helpful votes.'
                        : 'Vote not helpful. Currently ${_tip.notHelpful} not helpful votes.',
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _myVote == VoteValue.notHelpful
                            ? theme.colorScheme.errorContainer.withValues(alpha: 0.6)
                            : null,
                        side: BorderSide(
                          color: _myVote == VoteValue.notHelpful
                              ? theme.colorScheme.error
                              : theme.colorScheme.outlineVariant,
                          width: _myVote == VoteValue.notHelpful ? 2 : 1,
                        ),
                      ),
                      onPressed: () => _castVote(VoteValue.notHelpful),
                      icon: Icon(
                        _myVote == VoteValue.notHelpful ? Icons.thumb_down : Icons.thumb_down_outlined,
                        size: 16,
                        color: _myVote == VoteValue.notHelpful ? theme.colorScheme.error : null,
                      ),
                      label: Text(
                        'Not helpful (${_tip.notHelpful})',
                        style: TextStyle(
                          color: _myVote == VoteValue.notHelpful ? theme.colorScheme.error : null,
                          fontWeight: _myVote == VoteValue.notHelpful ? FontWeight.w800 : null,
                        ),
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
