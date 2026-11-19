import '../models/tip.dart';

abstract class TipRepository {
  Future<List<Tip>> fetchTips({TipCategory? category});

  Future<Tip> addTip(NewTip tip, {required String userId});

  Future<VoteValue?> myVote({required String tipId, required String userId});

  /// Sets, changes or (with a null [value]) removes the user's vote and
  /// returns the updated tip. One vote per user and tip.
  Future<Tip> vote({
    required String tipId,
    required String userId,
    required VoteValue? value,
  });
}
