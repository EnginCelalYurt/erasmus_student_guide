import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import '../data/auth_service.dart';
import '../data/draft_store.dart';
import '../models/tip.dart';
import '../viewmodels/guide_view_model.dart';

class ShareTipScreen extends StatefulWidget {
  final GuideViewModel viewModel;
  final DraftStore? draftStore;

  const ShareTipScreen({
    super.key,
    required this.viewModel,
    this.draftStore,
  });

  @override
  State<ShareTipScreen> createState() => _ShareTipScreenState();
}

class _ShareTipScreenState extends State<ShareTipScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  TipCategory _category = TipCategory.firstWeeks;
  bool _hasDraft = false;
  bool _isSubmitting = false;
  String? _submitError;

  GuideViewModel get _vm => widget.viewModel;
  String? get _userId => _vm.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _bodyController = TextEditingController();
    _loadDraft();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _loadDraft() async {
    final store = widget.draftStore;
    final uid = _userId;
    if (store == null || uid == null) return;

    final draft = await store.load(uid);
    if (!mounted || draft == null) return;

    // Only restore if the user hasn't started typing yet.
    if (_titleController.text.isEmpty && _bodyController.text.isEmpty) {
      setState(() {
        _titleController.text = draft.title;
        _bodyController.text = draft.body;
        _category = draft.category;
        _hasDraft = true;
      });
    }
  }

  Future<void> _saveDraft() async {
    final store = widget.draftStore;
    final uid = _userId;
    if (store == null || uid == null) return;

    final title = _titleController.text;
    final body = _bodyController.text;
    await store.save(
      uid,
      title: title,
      body: body,
      category: _category,
    );
    if (!mounted) return;
    final nonEmpty = title.trim().isNotEmpty || body.trim().isNotEmpty;
    if (_hasDraft != nonEmpty) {
      setState(() => _hasDraft = nonEmpty);
    }
  }

  Future<void> _deleteDraft() async {
    _formKey.currentState?.reset();
    _titleController.clear();
    _bodyController.clear();
    final store = widget.draftStore;
    final uid = _userId;
    if (store != null && uid != null) {
      await store.clear(uid);
    }
    if (!mounted) return;
    setState(() {
      _category = TipCategory.firstWeeks;
      _hasDraft = false;
      _submitError = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Draft deleted.')),
    );
  }

  Future<void> _submit() async {
    setState(() => _submitError = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    try {
      final user = _vm.currentUser;
      final author = user?.displayName?.trim().isNotEmpty == true
          ? user!.displayName!.trim()
          : (user?.email.split('@').first ?? 'TUL student');

      await _vm.addTip(
        NewTip(
          title: _titleController.text.trim(),
          body: _bodyController.text.trim(),
          category: _category,
          authorName: author,
        ),
      );

      final store = widget.draftStore;
      final uid = user?.uid;
      if (store != null && uid != null) {
        await store.clear(uid);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tip published!')),
      );
      Navigator.pop(context, true);
        } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _submitError = e.message);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      setState(
        () => _submitError = e.code == 'permission-denied'
            ? 'Confirm your TUL e-mail first (check the spam folder), '
                'then sign out and sign in again.'
            : 'Could not publish your tip. Check your connection.',
      );
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _submitError = 'Could not publish your tip. Check your connection.',
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyLen = _bodyController.text.trim().length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Share a Tip',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          if (_hasDraft)
            IconButton(
              tooltip: 'Delete draft',
              icon: const Icon(Icons.delete_outline),
              onPressed: _isSubmitting ? null : _deleteDraft,
            ),
        ],
      ),
      body: !_vm.isSignedIn
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 48,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Sign in with your TUL e-mail to share a tip.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            )
          : Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  if (_hasDraft) ...[
                    Material(
                      color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_note,
                              size: 18,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Draft saved automatically',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSecondaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _isSubmitting ? null : _deleteDraft,
                              child: const Text('Delete draft'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    'Category',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<TipCategory>(
                    initialValue: _category,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: TipCategory.values
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.label),
                          ),
                        )
                        .toList(),
                    onChanged: _isSubmitting
                        ? null
                        : (val) {
                            if (val == null) return;
                            setState(() => _category = val);
                            _saveDraft();
                          },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Title',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _titleController,
                    enabled: !_isSubmitting,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'e.g. How to get your Migawka tram card',
                    ),
                    validator: NewTip.validateTitle,
                    onChanged: (_) => _saveDraft(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your advice',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '$bodyLen / ${NewTip.minBodyLength} min chars',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: bodyLen >= NewTip.minBodyLength
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _bodyController,
                    enabled: !_isSubmitting,
                    minLines: 4,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      hintText:
                          'Share practical details that would help incoming Erasmus students...',
                    ),
                    validator: NewTip.validateBody,
                    onChanged: (_) {
                      setState(() {});
                      _saveDraft();
                    },
                  ),
                  if (_submitError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _submitError!,
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    label: Text(_isSubmitting ? 'Publishing...' : 'Publish Tip'),
                  ),
                ],
              ),
            ),
    );
  }
}
