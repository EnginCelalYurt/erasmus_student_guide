import 'package:erasmus_student_guide/logic/vote_counts.dart';
import 'package:erasmus_student_guide/models/tip.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  VoteCounts apply(VoteValue? previous, VoteValue? next) {
    return applyVote(helpful: 5, notHelpful: 2, previous: previous, next: next);
  }

  test('first helpful vote adds one helpful', () {
    final c = apply(null, VoteValue.helpful);
    expect((c.helpful, c.notHelpful), (6, 2));
  });

  test('first not-helpful vote adds one not helpful', () {
    final c = apply(null, VoteValue.notHelpful);
    expect((c.helpful, c.notHelpful), (5, 3));
  });

  test('changing helpful to not helpful moves the vote', () {
    final c = apply(VoteValue.helpful, VoteValue.notHelpful);
    expect((c.helpful, c.notHelpful), (4, 3));
  });

  test('changing not helpful to helpful moves the vote', () {
    final c = apply(VoteValue.notHelpful, VoteValue.helpful);
    expect((c.helpful, c.notHelpful), (6, 1));
  });

  test('removing a vote subtracts it', () {
    final c = apply(VoteValue.helpful, null);
    expect((c.helpful, c.notHelpful), (4, 2));
  });

  test('repeating the same vote changes nothing', () {
    final c = apply(VoteValue.helpful, VoteValue.helpful);
    expect((c.helpful, c.notHelpful), (5, 2));
  });

  test('no vote to no vote changes nothing', () {
    final c = apply(null, null);
    expect((c.helpful, c.notHelpful), (5, 2));
  });
}
