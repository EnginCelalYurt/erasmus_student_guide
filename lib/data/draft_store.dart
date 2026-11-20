import 'dart:convert';

import '../models/tip.dart';
import 'local_store.dart';

/// Keeps an unfinished "share a tip" form on the device so that closing the
/// app does not lose what the user typed. Drafts are kept per user.
class DraftStore {
  DraftStore(this._store);

  final LocalStore _store;

  static String _key(String userId) => 'draft.$userId';

  Future<void> save(String userId, {
    required String title,
    required String body,
    required TipCategory category,
  }) {
    if (title.trim().isEmpty && body.trim().isEmpty) return clear(userId);
    return _store.write(
      _key(userId),
      jsonEncode({'title': title, 'body': body, 'category': category.name}),
    );
  }

  Future<TipDraft?> load(String userId) async {
    try {
      final raw = await _store.read(_key(userId));
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return TipDraft(
        title: json['title'] as String,
        body: json['body'] as String,
        category: TipCategory.values.byName(json['category'] as String),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clear(String userId) => _store.remove(_key(userId));
}

class TipDraft {
  const TipDraft({
    required this.title,
    required this.body,
    required this.category,
  });

  final String title;
  final String body;
  final TipCategory category;
}
