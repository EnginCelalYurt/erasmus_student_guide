import 'package:erasmus_student_guide/logic/tip_ranking.dart';
import 'package:erasmus_student_guide/models/tip.dart';
import 'package:flutter_test/flutter_test.dart';

Tip tip(String id, {int helpful = 0, int notHelpful = 0, int day = 1, String title = 'Title'}) {
  return Tip(
    id: id,
    title: title,
    body: 'Body text for $id',
    category: TipCategory.transport,
    authorName: 'Test',
    createdAt: DateTime(2026, 11, day),
    helpful: helpful,
    notHelpful: notHelpful,
  );
}

void main() {
  group('wilsonScore', () {
    test('30 helpful / 1 not helpful ranks above 1 / 0', () {
      expect(wilsonScore(30, 1), greaterThan(wilsonScore(1, 0)));
    });

    test('no votes gives 0', () {
      expect(wilsonScore(0, 0), 0);
    });

    test('more votes with the same ratio score higher', () {
      expect(wilsonScore(90, 10), greaterThan(wilsonScore(9, 1)));
    });
  });

  group('isHidden', () {
    test('hidden at 5 votes when not helpful outnumbers helpful', () {
      expect(isHidden(tip('a', helpful: 1, notHelpful: 4)), isTrue);
    });

    test('not hidden below 5 votes', () {
      expect(isHidden(tip('a', helpful: 1, notHelpful: 3)), isFalse);
    });

    test('not hidden when votes are tied', () {
      expect(isHidden(tip('a', helpful: 3, notHelpful: 3)), isFalse);
    });

    test('500 helpful / 6 not helpful stays visible', () {
      expect(isHidden(tip('a', helpful: 500, notHelpful: 6)), isFalse);
    });
  });

  group('rankTips', () {
    final tips = [
      tip('old-popular', helpful: 30, notHelpful: 1, day: 1),
      tip('new-lucky', helpful: 1, day: 9),
      tip('hidden', helpful: 1, notHelpful: 6, day: 5),
      tip('newest', day: 10),
    ];

    test('most helpful orders by Wilson score and drops hidden tips', () {
      final ids = rankTips(tips, TipSort.mostHelpful).map((t) => t.id).toList();
      expect(ids, ['old-popular', 'new-lucky', 'newest']);
    });

    test('newest orders by date and drops hidden tips', () {
      final ids = rankTips(tips, TipSort.newest).map((t) => t.id).toList();
      expect(ids, ['newest', 'new-lucky', 'old-popular']);
    });
  });

  group('searchTips', () {
    final tips = [
      tip('a', title: 'Take the tram'),
      tip('b', title: 'Dorm rules'),
    ];

    test('matches title case-insensitively', () {
      expect(searchTips(tips, 'TRAM').map((t) => t.id), ['a']);
    });

    test('matches body text', () {
      expect(searchTips(tips, 'body text for b').map((t) => t.id), ['b']);
    });

    test('empty query returns everything', () {
      expect(searchTips(tips, '  ').length, 2);
    });

    test('no match returns an empty list', () {
      expect(searchTips(tips, 'zzz'), isEmpty);
    });
  });

  group('NewTip validation', () {
    test('body shorter than 15 characters is rejected', () {
      expect(NewTip.validateBody('too short'), isNotNull);
    });

    test('body of 15 characters is accepted', () {
      expect(NewTip.validateBody('a' * 15), isNull);
    });

    test('empty title is rejected', () {
      expect(NewTip.validateTitle('   '), isNotNull);
    });
  });
}
