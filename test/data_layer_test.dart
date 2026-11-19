import 'package:erasmus_student_guide/data/auth_service.dart';
import 'package:erasmus_student_guide/data/fake_auth_service.dart';
import 'package:erasmus_student_guide/data/in_memory_tip_repository.dart';
import 'package:erasmus_student_guide/models/tip.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InMemoryTipRepository', () {
    late InMemoryTipRepository repo;

    setUp(() => repo = InMemoryTipRepository());

    test('fetchTips filters by category', () async {
      final tips = await repo.fetchTips(category: TipCategory.emergency);
      expect(tips, isNotEmpty);
      expect(tips.every((t) => t.category == TipCategory.emergency), isTrue);
    });

    test('a published tip appears for other users', () async {
      await repo.addTip(
        const NewTip(
          title: 'Laundry',
          body: 'Laundry rooms are in the dorm basement.',
          category: TipCategory.dormitories,
        ),
        userId: 'u1',
      );
      final tips = await repo.fetchTips();
      expect(tips.first.title, 'Laundry');
    });

    test('voting twice the same way counts once', () async {
      final before = (await repo.fetchTips()).firstWhere((t) => t.id == 'sample-5');
      await repo.vote(tipId: 'sample-5', userId: 'u1', value: VoteValue.helpful);
      final after = await repo.vote(
        tipId: 'sample-5',
        userId: 'u1',
        value: VoteValue.helpful,
      );
      expect(after.helpful, before.helpful + 1);
    });

    test('changing a vote moves it to the other side', () async {
      await repo.vote(tipId: 'sample-5', userId: 'u1', value: VoteValue.helpful);
      final changed = await repo.vote(
        tipId: 'sample-5',
        userId: 'u1',
        value: VoteValue.notHelpful,
      );
      expect(changed.helpful, 0);
      expect(changed.notHelpful, 1);
      expect(await repo.myVote(tipId: 'sample-5', userId: 'u1'), VoteValue.notHelpful);
    });

    test('removing a vote restores the counts', () async {
      await repo.vote(tipId: 'sample-5', userId: 'u1', value: VoteValue.helpful);
      final removed = await repo.vote(tipId: 'sample-5', userId: 'u1', value: null);
      expect(removed.helpful, 0);
      expect(await repo.myVote(tipId: 'sample-5', userId: 'u1'), isNull);
    });

    test('different users vote independently', () async {
      await repo.vote(tipId: 'sample-5', userId: 'u1', value: VoteValue.helpful);
      final tip = await repo.vote(
        tipId: 'sample-5',
        userId: 'u2',
        value: VoteValue.helpful,
      );
      expect(tip.helpful, 2);
    });
  });

  group('isTulEmail', () {
    test('accepts TUL addresses and subdomains', () {
      expect(isTulEmail('jan@p.lodz.pl'), isTrue);
      expect(isTulEmail('Jan@EDU.P.LODZ.PL'), isTrue);
    });

    test('rejects other addresses', () {
      expect(isTulEmail('jan@gmail.com'), isFalse);
      expect(isTulEmail('jan@fakep.lodz.pl'), isFalse);
      expect(isTulEmail('p.lodz.pl'), isFalse);
      expect(isTulEmail('@p.lodz.pl'), isFalse);
    });
  });

  group('FakeAuthService', () {
    test('rejects non-TUL e-mail with an error message', () async {
      final auth = FakeAuthService();
      expect(
        () => auth.signIn(email: 'jan@gmail.com', password: 'x'),
        throwsA(isA<AuthException>()),
      );
      expect(auth.currentUser, isNull);
    });

    test('signs in and out with a TUL e-mail', () async {
      final auth = FakeAuthService();
      await auth.signIn(email: 'jan@edu.p.lodz.pl', password: 'x');
      expect(auth.currentUser, isNotNull);
      await auth.signOut();
      expect(auth.currentUser, isNull);
    });
  });
}
