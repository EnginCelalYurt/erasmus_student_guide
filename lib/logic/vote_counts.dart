import '../models/tip.dart';

class VoteCounts {
  const VoteCounts(this.helpful, this.notHelpful);

  final int helpful;
  final int notHelpful;
}

/// Counts after one user's vote changes from [previous] to [next].
/// A null side means "no vote". Used by every repository so they agree.
VoteCounts applyVote({
  required int helpful,
  required int notHelpful,
  required VoteValue? previous,
  required VoteValue? next,
}) {
  var h = helpful;
  var n = notHelpful;
  if (previous == VoteValue.helpful) h--;
  if (previous == VoteValue.notHelpful) n--;
  if (next == VoteValue.helpful) h++;
  if (next == VoteValue.notHelpful) n++;
  assert(h >= 0 && n >= 0, 'Vote counts cannot go below zero');
  return VoteCounts(h, n);
}
