import 'package:flutter/material.dart';

import '../models/tip.dart';
import '../repositories/tip_repository.dart';
import '../services/fake_auth_service.dart';
import '../utils/open_link.dart';

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
  late Tip _currentTip;

  @override
  void initState() {
    super.initState();
    _currentTip = widget.tip;
  }

  IconData _iconForCategory(String category) {
    return switch (category.toLowerCase()) {
      'housing' => Icons.apartment,
      'transport' => Icons.tram,
      'health' => Icons.local_hospital,
      'social' => Icons.groups,
      'daily' => Icons.local_cafe,
      'admin' => Icons.badge,
      _ => Icons.lightbulb,
    };
  }

  Future<void> _handleHelpful() async {
    if (_currentTip.isMarkedHelpful) return;
    await widget.repository.markHelpful(_currentTip.id);
    setState(() {
      _currentTip = _currentTip.copyWith(
        helpfulCount: _currentTip.helpfulCount + 1,
        isMarkedHelpful: true,
      );
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you! Marked as helpful.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _launchAction(String url) async {
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
    final user = widget.authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentTip.category,
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
                  _iconForCategory(_currentTip.category),
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
                        _currentTip.category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Shared by ${_currentTip.author}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _currentTip.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _currentTip.summary,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Detailed Advice',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            _currentTip.body,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.6,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 20),
          if (_currentTip.tags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _currentTip.tags.map((tag) {
                return Chip(
                  label: Text('#$tag'),
                  padding: EdgeInsets.zero,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.primary,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
          if (_currentTip.actionUrl != null && _currentTip.actionLabel != null) ...[
            FilledButton.tonalIcon(
              onPressed: () => _launchAction(_currentTip.actionUrl!),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: Text(_currentTip.actionLabel!),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
          ],
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_currentTip.helpfulCount} students found this helpful',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (user != null)
                    Text(
                      'Signed in as ${user.name}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              FilledButton.icon(
                onPressed: _currentTip.isMarkedHelpful ? null : _handleHelpful,
                icon: Icon(
                  _currentTip.isMarkedHelpful ? Icons.thumb_up : Icons.thumb_up_outlined,
                  size: 16,
                ),
                label: Text(
                  _currentTip.isMarkedHelpful ? 'Helpful' : 'Mark Helpful',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
