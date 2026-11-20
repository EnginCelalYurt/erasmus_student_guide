import 'dart:convert';

import '../models/tip.dart';
import 'local_store.dart';
import 'tip_json.dart';
import 'tip_repository.dart';

/// Wraps another [TipRepository] and keeps a copy of the last loaded tips and
/// of the user's votes on the device. When the wrapped repository fails
/// (no network), the saved copy is shown instead.
class CachingTipRepository implements TipRepository {
  CachingTipRepository({
    required this._inner,
    required this._store,
  });

  static const tipsKey = 'cache.tips';
  static String votesKey(String userId) => 'cache.votes.$userId';

  final TipRepository _inner;
  final LocalStore _store;

  /// True when the last [fetchTips] could not reach the server and returned
  /// the saved copy.
  bool servedFromCache = false;

  @override
  Future<List<Tip>> fetchTips({TipCategory? category}) async {
    try {
      final tips = await _inner.fetchTips(category: category);
      servedFromCache = false;
      if (category == null) await _saveTips(tips);
      return tips;
    } catch (_) {
      final saved = await _loadTips();
      if (saved == null) rethrow;
      servedFromCache = true;
      return category == null
          ? saved
          : saved.where((t) => t.category == category).toList();
    }
  }

  @override
  Future<Tip> addTip(NewTip tip, {required String userId}) async {
    final created = await _inner.addTip(tip, userId: userId);
    final saved = await _loadTips();
    if (saved != null) await _saveTips([created, ...saved]);
    return created;
  }

  @override
  Future<VoteValue?> myVote({
    required String tipId,
    required String userId,
  }) async {
    try {
      final value = await _inner.myVote(tipId: tipId, userId: userId);
      await _saveVote(userId, tipId, value);
      return value;
    } catch (_) {
      final votes = await _loadVotes(userId);
      if (votes == null) rethrow;
      return _voteFromName(votes[tipId]);
    }
  }

  @override
  Future<Tip> vote({
    required String tipId,
    required String userId,
    required VoteValue? value,
  }) async {
    // A vote needs the server (one vote per user is counted there), so a
    // failure is passed on and nothing is saved locally.
    final updated = await _inner.vote(tipId: tipId, userId: userId, value: value);
    await _saveVote(userId, tipId, value);
    final saved = await _loadTips();
    if (saved != null) {
      await _saveTips([for (final t in saved) t.id == updated.id ? updated : t]);
    }
    return updated;
  }

  Future<void> _saveTips(List<Tip> tips) => _store.write(
        tipsKey,
        jsonEncode([for (final t in tips) tipToJson(t)]),
      );

  Future<List<Tip>?> _loadTips() async {
    try {
      final raw = await _store.read(tipsKey);
      if (raw == null) return null;
      return [
        for (final item in jsonDecode(raw) as List)
          tipFromJson(item as Map<String, dynamic>),
      ];
    } catch (_) {
      // Damaged copy: ignore it rather than crash.
      return null;
    }
  }

  Future<void> _saveVote(String userId, String tipId, VoteValue? value) async {
    final votes = await _loadVotes(userId) ?? {};
    if (value == null) {
      votes.remove(tipId);
    } else {
      votes[tipId] = value.name;
    }
    await _store.write(votesKey(userId), jsonEncode(votes));
  }

  Future<Map<String, String>?> _loadVotes(String userId) async {
    try {
      final raw = await _store.read(votesKey(userId));
      if (raw == null) return null;
      return Map<String, String>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }

  VoteValue? _voteFromName(String? name) {
    for (final v in VoteValue.values) {
      if (v.name == name) return v;
    }
    return null;
  }
}
