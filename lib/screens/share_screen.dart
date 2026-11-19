import 'package:flutter/material.dart';

import '../data/auth_service.dart';
import '../data/tip_repository.dart';
import '../models/tip.dart';

class ShareScreen extends StatefulWidget {
  final TipRepository repository;
  final AuthService authService;
  final VoidCallback? onTipPublished;

  const ShareScreen({
    super.key,
    required this.repository,
    required this.authService,
    this.onTipPublished,
  });

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  TipCategory _selectedCategory = TipCategory.firstWeeks;
  bool _isSubmitting = false;
  bool _isSigningIn = false;
  String? _authError;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      setState(() => _authError = 'Enter your university e-mail address.');
      return;
    }

    if (!isTulEmail(email)) {
      setState(() => _authError = 'Only TUL e-mails (@p.lodz.pl or subdomains) are allowed.');
      return;
    }

    setState(() {
      _isSigningIn = true;
      _authError = null;
    });

    try {
      await widget.authService.signIn(email: email, password: password);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signed in as $email')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _authError = e.toString());
      }
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  Future<void> _handleSignOut() async {
    await widget.authService.signOut();
    if (mounted) setState(() {});
  }

  Future<void> _handleSubmitTip() async {
    final user = widget.authService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in first.')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final newTip = NewTip(
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        category: _selectedCategory,
        authorName: user.displayName ?? user.email.split('@').first,
      );

      await widget.repository.addTip(newTip, userId: user.uid);

      if (mounted) {
        _titleController.clear();
        _bodyController.clear();
        setState(() => _selectedCategory = TipCategory.firstWeeks);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Your advice has been published and is now visible!'),
            duration: Duration(seconds: 3),
          ),
        );

        widget.onTipPublished?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing advice: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
    final user = widget.authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share Experience',
              style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.4),
            ),
            Text(
              'Help future students adapt to life at TUL',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          if (user == null)
            _buildSignInCard(theme)
          else ...[
            _buildUserHeader(theme, user),
            const SizedBox(height: 20),
            _buildShareForm(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildSignInCard(ThemeData theme) {
    return Card(
      color: theme.colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                  child: Icon(Icons.lock_outline, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Student Verification Required',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Only registered TUL students can publish advice and vote.',
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
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'TUL E-mail Address',
                hintText: 'student@edu.p.lodz.pl',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.password),
              ),
            ),
            if (_authError != null) ...[
              const SizedBox(height: 10),
              Text(
                _authError!,
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: _isSigningIn ? null : _handleSignIn,
                icon: _isSigningIn
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.login),
                label: const Text('Sign in with TUL E-mail'),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  _emailController.text = 'yusuf.taskin@edu.p.lodz.pl';
                  _passwordController.text = 'student123';
                  _handleSignIn();
                },
                icon: const Icon(Icons.auto_fix_high, size: 16),
                label: const Text('Quick test: Sign in as Yusuf (Demo)'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(ThemeData theme, AppUser user) {
    return Card(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(Icons.verified_user, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Verified TUL Student',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  Text(
                    user.email,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _handleSignOut,
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share a New Tip or Guide',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Write practical advice from your own experience in Łódź.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // Title field
          TextFormField(
            controller: _titleController,
            validator: NewTip.validateTitle,
            decoration: const InputDecoration(
              labelText: 'Advice Title',
              hintText: 'e.g., How to apply for dormitories online',
              prefixIcon: Icon(Icons.title),
            ),
          ),
          const SizedBox(height: 16),

          // Category dropdown
          DropdownButtonFormField<TipCategory>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category',
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items: TipCategory.values.map((cat) {
              return DropdownMenuItem(
                value: cat,
                child: Row(
                  children: [
                    Icon(_iconForCategory(cat), size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(cat.label),
                  ],
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedCategory = val);
            },
          ),
          const SizedBox(height: 16),

          // Detailed Body field using NewTip.validateBody
          TextFormField(
            controller: _bodyController,
            validator: NewTip.validateBody,
            maxLines: 7,
            decoration: const InputDecoration(
              labelText: 'Detailed Advice (minimum 15 characters)',
              hintText:
                  'Explain step-by-step: what documents are needed, where to go, common mistakes to avoid, and practical tips...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed: _isSubmitting ? null : _handleSubmitTip,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send),
              label: const Text(
                'Publish Student Advice',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
