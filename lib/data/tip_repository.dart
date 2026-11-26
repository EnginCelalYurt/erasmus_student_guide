import '../models/tip.dart';

/// The server refused the action, for example because the signed-in user has
/// not confirmed their TUL e-mail yet.
class TipPermissionException implements Exception {
  const TipPermissionException();
}

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
