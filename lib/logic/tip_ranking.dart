import 'dart:math';

import '../models/tip.dart';

enum TipSort { mostHelpful, newest }

const minVotesToHide = 5;

/// Lower bound of the Wilson score interval (95% confidence).
double wilsonScore(int helpful, int notHelpful) {
  assert(helpful >= 0 && notHelpful >= 0);
  final n = helpful + notHelpful;
  if (n == 0) return 0;
  const z = 1.96;
  final p = helpful / n;
  final z2 = z * z;
  return (p + z2 / (2 * n) - z * sqrt((p * (1 - p) + z2 / (4 * n)) / n)) /
      (1 + z2 / n);
}

bool isHidden(Tip tip) {
  return tip.totalVotes >= minVotesToHide && tip.notHelpful > tip.helpful;
}

List<Tip> rankTips(List<Tip> tips, TipSort sort) {
  final visible = tips.where((t) => !isHidden(t)).toList();
  switch (sort) {
    case TipSort.mostHelpful:
      visible.sort((a, b) {
        final byScore = wilsonScore(b.helpful, b.notHelpful)
            .compareTo(wilsonScore(a.helpful, a.notHelpful));
        return byScore != 0 ? byScore : b.createdAt.compareTo(a.createdAt);
      });
    case TipSort.newest:
      visible.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
  return visible;
}

List<Tip> searchTips(List<Tip> tips, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return List.of(tips);
  return tips
      .where((t) =>
          t.title.toLowerCase().contains(q) || t.body.toLowerCase().contains(q))
      .toList();
}
