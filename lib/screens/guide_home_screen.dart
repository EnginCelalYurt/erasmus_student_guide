import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/auth_service.dart';
import '../data/draft_store.dart';
import '../logic/tip_ranking.dart';
import '../models/tip.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../utils/open_link.dart';
import '../viewmodels/guide_view_model.dart';
import '../widgets/empty_state.dart';
import 'category_tips_screen.dart';
import 'share_tip_screen.dart';
import 'tip_detail_screen.dart';

class GuideHomeScreen extends StatefulWidget {
  final GuideViewModel viewModel;
  final AppState? app;
  final DraftStore? draftStore;

  const GuideHomeScreen({
    super.key,
    required this.viewModel,
    this.app,
    this.draftStore,
  });

  @override
  State<GuideHomeScreen> createState() => _GuideHomeScreenState();
}

class _GuideHomeScreenState extends State<GuideHomeScreen> {
  // Temporary interface state; tips and votes live in the view model.
  TipSort _sort = TipSort.mostHelpful;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  GuideViewModel get _vm => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _vm.load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _call112() async {
    final ok = await openLink('tel:112');
    if (!ok && mounted) {
      await Clipboard.setData(const ClipboardData(text: '112'));
      if (!mounted) return;
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

  Color _colorForCategory(TipCategory category) {
    return switch (category) {
      TipCategory.dormitories => const Color(0xFFEA580C),
      TipCategory.transport => const Color(0xFF2563EB),
      TipCategory.emergency => const Color(0xFFDC2626),
      TipCategory.studentLife => const Color(0xFF9333EA),
      TipCategory.dailyLife => const Color(0xFF0D9488),
      TipCategory.firstWeeks => const Color(0xFFD97706),
    };
  }

  String _initialsForEmail(String email) {
    final prefix = email.split('@').first.trim();
    if (prefix.isEmpty) return 'TU';
    if (prefix.length == 1) return prefix.toUpperCase();
    return prefix.substring(0, 2).toUpperCase();
  }

  void _openCategory(TipCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryTipsScreen(
          category: category,
          viewModel: _vm,
          app: widget.app,
        ),
      ),
    );
  }

  void _openTipDetail(Tip tip) {
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

  void _openShareTip() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShareTipScreen(
          viewModel: _vm,
          draftStore: widget.draftStore,
        ),
      ),
    );
  }

  Future<void> _showSignInDialog() {
    return showDialog<void>(
      context: context,
      builder: (_) => _SignInDialog(viewModel: _vm),
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
    final user = _vm.currentUser;
    final tips = _vm.visibleTips(query: _searchQuery, sort: _sort);

    return Scaffold(
      floatingActionButton: _vm.isSignedIn
          ? FloatingActionButton.extended(
              tooltip: 'Share a new tip',
              onPressed: _openShareTip,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Share tip'),
            )
          : null,
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
              user != null
                  ? 'Signed in as ${user.email}'
                  : (_vm.usingSampleData
                      ? 'Demo · Fictional sample data'
                      : 'Politechnika Łódzka Campus Guide'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          if (widget.app != null)
            IconButton(
              tooltip: 'Theme',
              icon: Icon(
                switch (widget.app!.themeMode) {
                  ThemeMode.system => Icons.brightness_auto,
                  ThemeMode.light => Icons.light_mode,
                  ThemeMode.dark => Icons.dark_mode,
                },
              ),
              onPressed: widget.app!.cycleTheme,
            ),
          if (user == null)
            TextButton.icon(
              onPressed: _showSignInDialog,
              icon: const Icon(Icons.login, size: 18),
              label: const Text('Sign in'),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: PopupMenuButton<String>(
                tooltip: 'Account menu',
                offset: const Offset(0, 44),
                onSelected: (value) {
                  if (value == 'share') {
                    _openShareTip();
                  } else if (value == 'sign_out') {
                    _vm.signOut();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    enabled: false,
                    child: Text(
                      user.email,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 10),
                        Text('Share tip'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'sign_out',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 18),
                        SizedBox(width: 10),
                        Text('Sign out'),
                      ],
                    ),
                  ),
                ],
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    _initialsForEmail(user.email),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_vm.isLoading)
            Semantics(
              label: 'Loading tips',
              child: const LinearProgressIndicator(minHeight: 3),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _vm.load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 36),
                children: [
                  // 1. Offline banner with Retry
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

                  // 2. 112 Emergency Banner
                  _build112Banner(theme),
                  const SizedBox(height: 14),

                  // 2. Search Field (calling searchTips)
                  TextField(
                    controller: _searchController,
                    decoration: AppTheme.searchDecoration(
                      context,
                      hintText: 'Search dorms, tram, BLIK, 112...',
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
                  const SizedBox(height: 16),

                  // 3 & 4. Responsive Layout: Top Advice on left + compact Categories on right (wide),
                  // or compact horizontal Categories strip above Top Advice (narrow).
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth >= 820) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildAdviceSection(theme, tips)),
                            const SizedBox(width: 20),
                            SizedBox(
                              width: 260,
                              child: _buildCategoriesSidebar(theme),
                            ),
                          ],
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Explore by Category',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildCategoriesHorizontal(theme),
                          const SizedBox(height: 18),
                          _buildAdviceSection(theme, tips),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceSection(ThemeData theme, List<Tip> tips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
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
            icon: _searchQuery.trim().isEmpty
                ? Icons.lightbulb_outline
                : Icons.search_off,
            title: _searchQuery.trim().isEmpty
                ? 'No Tips Yet'
                : 'No Matching Tips',
            message: _searchQuery.trim().isEmpty
                ? 'Check back soon for advice from TUL students.'
                : 'No tips found for "$_searchQuery".',
            actionLabel: _searchQuery.trim().isNotEmpty ? 'Clear search' : null,
            onAction: _searchQuery.trim().isNotEmpty
                ? () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  }
                : null,
          )
        else
          ...tips.map((tip) => _buildTipCard(theme, tip)),
      ],
    );
  }

  Widget _build112Banner(ThemeData theme) {
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: 'Call 112 Emergency Helpline, free multilingual operator. Long press to copy number.',
      child: Material(
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
                        Flexible(
                          child: Text(
                            '112 Emergency Helpline',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: theme.colorScheme.onErrorContainer,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'FREE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onErrorContainer,
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
    ),
    );
  }

  Widget _buildCategoriesHorizontal(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < TipCategory.values.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            _buildCompactCategoryCard(theme, TipCategory.values[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoriesSidebar(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explore by Category',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < TipCategory.values.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: _buildCompactCategoryCard(theme, TipCategory.values[i], expand: true),
          ),
        ],
      ],
    );
  }

  Widget _buildCompactCategoryCard(
    ThemeData theme,
    TipCategory cat, {
    bool expand = false,
  }) {
    final count = _vm.visibleCount(cat);
    final catColor = _colorForCategory(cat);

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: '${cat.label}, ${count == 1 ? '1 tip' : '$count tips'}',
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openCategory(cat),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _iconForCategory(cat),
                    size: 16,
                    color: catColor,
                  ),
                ),
                const SizedBox(width: 8),
                if (expand)
                  Expanded(
                    child: Text(
                      cat.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                else
                  Text(
                    cat.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTipCard(ThemeData theme, Tip tip) {
    final saved = widget.app?.isTipSaved(tip.id) ?? false;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
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
                  if (widget.app != null) ...[
                    const SizedBox(width: 4),
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

class _SignInDialog extends StatefulWidget {
  final GuideViewModel viewModel;

  const _SignInDialog({required this.viewModel});

  @override
  State<_SignInDialog> createState() => _SignInDialogState();
}

class _SignInDialogState extends State<_SignInDialog> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorText;
  bool _busy = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  Future<void> _submit() => _run(
    action: widget.viewModel.signIn,
    failureText: 'Sign-in failed. Try again.',
  );

  Future<void> _register() => _run(
    action: widget.viewModel.register,
    failureText: 'Could not create the account. Try again.',
    successMessage:
        'Account created. Check your TUL e-mail and confirm the address '
        'to vote and share tips.',
  );

  Future<void> _run({
    required Future<void> Function({
      required String email,
      required String password,
    })
    action,
    required String failureText,
    String? successMessage,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _busy = true;
      _errorText = null;
    });
    try {
      await action(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (successMessage != null) {
        messenger.showSnackBar(SnackBar(content: Text(successMessage)));
      }
      if (mounted) Navigator.pop(context);
    } on AuthException catch (e) {
      if (mounted) setState(() => _errorText = e.message);
    } catch (_) {
      if (mounted) setState(() => _errorText = failureText);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('TUL Student Sign-In'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Use your @edu.p.lodz.pl address to vote and share tips.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            enabled: !_busy,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'TUL e-mail',
              hintText: '123456@edu.p.lodz.pl',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _passwordController,
            enabled: !_busy,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
            ),
            onSubmitted: (_) => _busy ? null : _submit(),
          ),
          if (_errorText != null) ...[
            const SizedBox(height: 10),
            Text(
              _errorText!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
                TextButton(
          onPressed: _busy ? null : _register,
          child: const Text('Create account'),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: Text(_busy ? 'Please wait...' : 'Sign in'),
        ),
      ],
    );
  }
}
