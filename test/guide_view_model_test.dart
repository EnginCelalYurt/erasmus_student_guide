import 'package:erasmus_student_guide/data/auth_service.dart';
import 'package:erasmus_student_guide/data/fake_auth_service.dart';
import 'package:erasmus_student_guide/data/in_memory_tip_repository.dart';
import 'package:erasmus_student_guide/data/tip_repository.dart';
import 'package:erasmus_student_guide/logic/tip_ranking.dart';
import 'package:erasmus_student_guide/models/tip.dart';
import 'package:erasmus_student_guide/viewmodels/guide_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

class _FailingRepository extends InMemoryTipRepository {
  @override
  Future<List<Tip>> fetchTips({TipCategory? category}) async {
    throw Exception('network down');
  }
}

void main() {
  late FakeAuthService auth;
  late GuideViewModel vm;

  GuideViewModel build(TipRepository repo) =>
      GuideViewModel(repository: repo, authService: auth);

  setUp(() async {
    auth = FakeAuthService();
    vm = build(InMemoryTipRepository());
    await vm.load();
  });

  test('load shows sample tips without the hidden one', () {
    expect(vm.isLoading, isFalse);
    expect(vm.error, isNull);
    expect(vm.visibleTips().length, 5);
    expect(vm.visibleTips().any((t) => t.id == 'sample-6'), isFalse);
  });

  test('category counts only include tips the category screen shows', () {
    expect(vm.visibleCount(TipCategory.dailyLife), 0);
    expect(vm.visibleCount(TipCategory.firstWeeks), 1);
  });

  test('search, category and sort are applied together', () {
    final transport = vm.visibleTips(category: TipCategory.transport, query: 'tram');
    expect(transport.map((t) => t.id), ['sample-2']);

    final newest = vm.visibleTips(sort: TipSort.newest);
    expect(newest.first.id, 'sample-5');
  });

  test('voting while signed out asks to sign in and changes nothing', () async {
    final outcome = await vm.vote('sample-5', VoteValue.helpful);
    expect(outcome, VoteOutcome.signInRequired);
    expect(vm.tipById('sample-5')!.helpful, 0);
  });

  test('a vote updates the counts and notifies every screen', () async {
    await auth.signIn(email: 'demo@edu.p.lodz.pl', password: 'x');
    var notified = 0;
    vm.addListener(() => notified++);

    final outcome = await vm.vote('sample-5', VoteValue.helpful);

    expect(outcome, VoteOutcome.saved);
    expect(vm.tipById('sample-5')!.helpful, 1);
    expect(vm.myVote('sample-5'), VoteValue.helpful);
    expect(notified, greaterThan(0));
  });

  test('tapping the same vote again removes it, the other one switches it', () async {
    await auth.signIn(email: 'demo@edu.p.lodz.pl', password: 'x');
    await vm.vote('sample-5', VoteValue.helpful);

    await vm.vote('sample-5', VoteValue.notHelpful);
    expect(vm.tipById('sample-5')!.helpful, 0);
    expect(vm.tipById('sample-5')!.notHelpful, 1);

    await vm.vote('sample-5', VoteValue.notHelpful);
    expect(vm.tipById('sample-5')!.notHelpful, 0);
    expect(vm.myVote('sample-5'), isNull);
  });

  test('a new user does not inherit the previous user\'s vote', () async {
    await auth.signIn(email: 'a@edu.p.lodz.pl', password: 'x');
    await vm.vote('sample-5', VoteValue.helpful);

    await auth.signIn(email: 'b@edu.p.lodz.pl', password: 'x');
    expect(vm.myVote('sample-5'), isNull);
    await vm.vote('sample-5', VoteValue.helpful);
    expect(vm.tipById('sample-5')!.helpful, 2);
  });

  test('enough not-helpful votes hide a tip from lists and counts', () async {
    for (var i = 0; i < 5; i++) {
      await auth.signIn(email: 'user$i@edu.p.lodz.pl', password: 'x');
      await vm.vote('sample-5', VoteValue.notHelpful);
    }
    expect(vm.visibleTips().any((t) => t.id == 'sample-5'), isFalse);
    expect(vm.visibleCount(TipCategory.firstWeeks), 0);
  });

  test('sharing a tip needs sign-in, then shows it at the top', () async {
    const tip = NewTip(
      title: 'Laundry',
      body: 'Laundry rooms are in the dorm basement.',
      category: TipCategory.dormitories,
    );
    expect(() => vm.addTip(tip), throwsA(isA<AuthException>()));

    await auth.signIn(email: 'demo@edu.p.lodz.pl', password: 'x');
    await vm.addTip(tip);
    expect(vm.visibleTips(sort: TipSort.newest).first.title, 'Laundry');
  });

  test('a failed load shows an error instead of crashing', () async {
    final failing = build(_FailingRepository());
    await failing.load();
    expect(failing.isLoading, isFalse);
    expect(failing.error, isNotNull);
    expect(failing.visibleTips(), isEmpty);
  });
}
