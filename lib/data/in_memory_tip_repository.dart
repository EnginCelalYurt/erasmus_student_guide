import '../logic/vote_counts.dart';
import '../models/tip.dart';
import 'sample_tips.dart';
import 'tip_repository.dart';

class InMemoryTipRepository implements TipRepository {
  InMemoryTipRepository({List<Tip>? seed}) : _tips = List.of(seed ?? sampleTips);

  final List<Tip> _tips;
  final Map<String, Map<String, VoteValue>> _votes = {};
  int _nextId = 1;

  @override
  Future<List<Tip>> fetchTips({TipCategory? category}) async {
    return _tips.where((t) => category == null || t.category == category).toList();
  }

  @override
  Future<Tip> addTip(NewTip tip, {required String userId}) async {
    final created = Tip(
      id: 'new-${_nextId++}',
      title: tip.title.trim(),
      body: tip.body.trim(),
      category: tip.category,
      authorName: tip.authorName,
      createdAt: DateTime.now(),
    );
    _tips.insert(0, created);
    return created;
  }

  @override
  Future<VoteValue?> myVote({
    required String tipId,
    required String userId,
  }) async {
    return _votes[tipId]?[userId];
  }

  @override
  Future<Tip> vote({
    required String tipId,
    required String userId,
    required VoteValue? value,
  }) async {
    final index = _tips.indexWhere((t) => t.id == tipId);
    if (index < 0) throw ArgumentError('Unknown tip: $tipId');

    final userVotes = _votes.putIfAbsent(tipId, () => {});
    final counts = applyVote(
      helpful: _tips[index].helpful,
      notHelpful: _tips[index].notHelpful,
      previous: userVotes[userId],
      next: value,
    );

    if (value == null) {
      userVotes.remove(userId);
    } else {
      userVotes[userId] = value;
    }

    final updated = _tips[index].copyWith(
      helpful: counts.helpful,
      notHelpful: counts.notHelpful,
    );
    _tips[index] = updated;
    return updated;
  }
}
