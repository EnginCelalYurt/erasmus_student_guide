import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../logic/vote_counts.dart';
import '../models/tip.dart';
import 'sample_tips.dart';
import 'tip_repository.dart';

/// Local database & persistent storage repository for Week 6.
/// Distinguishes persistent data (survives app restart) from temporary interface state.
class LocalTipRepository implements TipRepository {
  static const _tipsKey = 'erasmus_guide_local_tips_v2';
  static const _votesKey = 'erasmus_guide_local_votes_v2';

  final List<Tip> _memoryTips = [];
  final Map<String, Map<String, VoteValue>> _memoryVotes = {};
  bool _isInitialized = false;

  /// Loads locally stored tips and user votes from SharedPreferences.
  Future<void> init() async {
    if (_isInitialized) return;

    _memoryTips
      ..clear()
      ..addAll(sampleTips);

    final prefs = await SharedPreferences.getInstance();

    // 1. Read persistent user-created tips
    final rawTipsJson = prefs.getString(_tipsKey);
    if (rawTipsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(rawTipsJson);
        for (final item in decoded) {
          final map = item as Map<String, dynamic>;
          final tip = _tipFromJson(map);
          // Insert user tips at the beginning
          _memoryTips.insert(0, tip);
        }
      } catch (_) {
        // Corrupted storage fallback to sample tips
      }
    }

    // 2. Read persistent user votes
    final rawVotesJson = prefs.getString(_votesKey);
    if (rawVotesJson != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(rawVotesJson);
        for (final tipEntry in decoded.entries) {
          final tipId = tipEntry.key;
          final userMap = tipEntry.value as Map<String, dynamic>;
          final tipVotes = _memoryVotes.putIfAbsent(tipId, () => {});
          for (final userEntry in userMap.entries) {
            final userId = userEntry.key;
            final voteStr = userEntry.value as String;
            final voteVal = voteStr == 'helpful'
                ? VoteValue.helpful
                : VoteValue.notHelpful;
            tipVotes[userId] = voteVal;
          }
        }
      } catch (_) {
        // Fallback
      }
    }

    _isInitialized = true;
  }

  /// Persists user-created tips to SharedPreferences
  Future<void> _persistUserTips() async {
    final prefs = await SharedPreferences.getInstance();
    final sampleIds = sampleTips.map((s) => s.id).toSet();
    final userTips = _memoryTips.where((t) => !sampleIds.contains(t.id)).toList();

    final jsonList = userTips.map((t) => _tipToJson(t)).toList();
    await prefs.setString(_tipsKey, jsonEncode(jsonList));
  }

  /// Persists user votes to SharedPreferences
  Future<void> _persistVotes() async {
    final prefs = await SharedPreferences.getInstance();
    final export = <String, Map<String, String>>{};
    for (final tipEntry in _memoryVotes.entries) {
      final userMap = <String, String>{};
      for (final userEntry in tipEntry.value.entries) {
        userMap[userEntry.key] = userEntry.value.name;
      }
      export[tipEntry.key] = userMap;
    }
    await prefs.setString(_votesKey, jsonEncode(export));
  }

  @override
  Future<List<Tip>> fetchTips({TipCategory? category}) async {
    await init();
    if (category == null) {
      return List.unmodifiable(_memoryTips);
    }
    return _memoryTips.where((t) => t.category == category).toList();
  }

  @override
  Future<Tip> addTip(NewTip tip, {required String userId}) async {
    await init();

    final created = Tip(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      title: tip.title.trim(),
      body: tip.body.trim(),
      category: tip.category,
      authorName: tip.authorName,
      createdAt: DateTime.now(),
      helpful: 0,
      notHelpful: 0,
    );

    _memoryTips.insert(0, created);
    await _persistUserTips();
    return created;
  }

  /// Allows deleting a locally created tip (CRUD: Delete)
  Future<bool> deleteTip(String tipId, {required String userId}) async {
    await init();
    final index = _memoryTips.indexWhere((t) => t.id == tipId);
    if (index >= 0) {
      // Only delete custom non-sample tips
      final isSample = sampleTips.any((s) => s.id == tipId);
      if (!isSample) {
        _memoryTips.removeAt(index);
        _memoryVotes.remove(tipId);
        await _persistUserTips();
        await _persistVotes();
        return true;
      }
    }
    return false;
  }

  @override
  Future<VoteValue?> myVote({
    required String tipId,
    required String userId,
  }) async {
    await init();
    return _memoryVotes[tipId]?[userId];
  }

  @override
  Future<Tip> vote({
    required String tipId,
    required String userId,
    required VoteValue? value,
  }) async {
    await init();

    final index = _memoryTips.indexWhere((t) => t.id == tipId);
    if (index < 0) throw ArgumentError('Unknown tip: $tipId');

    final userVotes = _memoryVotes.putIfAbsent(tipId, () => {});
    final previous = userVotes[userId];

    final counts = applyVote(
      helpful: _memoryTips[index].helpful,
      notHelpful: _memoryTips[index].notHelpful,
      previous: previous,
      next: value,
    );

    if (value == null) {
      userVotes.remove(userId);
    } else {
      userVotes[userId] = value;
    }

    final updated = _memoryTips[index].copyWith(
      helpful: counts.helpful,
      notHelpful: counts.notHelpful,
    );
    _memoryTips[index] = updated;

    await _persistVotes();
    return updated;
  }

  // JSON Helpers
  Map<String, dynamic> _tipToJson(Tip tip) => {
        'id': tip.id,
        'title': tip.title,
        'body': tip.body,
        'category': tip.category.name,
        'authorName': tip.authorName,
        'createdAt': tip.createdAt.toIso8601String(),
        'helpful': tip.helpful,
        'notHelpful': tip.notHelpful,
      };

  Tip _tipFromJson(Map<String, dynamic> json) => Tip(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        category: TipCategory.values.firstWhere(
          (c) => c.name == json['category'],
          orElse: () => TipCategory.firstWeeks,
        ),
        authorName: json['authorName'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        helpful: (json['helpful'] as num?)?.toInt() ?? 0,
        notHelpful: (json['notHelpful'] as num?)?.toInt() ?? 0,
      );
}
