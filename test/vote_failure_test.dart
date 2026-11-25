import 'package:erasmus_student_guide/data/caching_tip_repository.dart';
import 'package:erasmus_student_guide/data/fake_auth_service.dart';
import 'package:erasmus_student_guide/data/in_memory_tip_repository.dart';
import 'package:erasmus_student_guide/data/local_store.dart';
import 'package:erasmus_student_guide/models/tip.dart';
import 'package:erasmus_student_guide/screens/tip_detail_screen.dart';
import 'package:erasmus_student_guide/viewmodels/guide_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Repository whose requests can be made to fail in different ways, the way
/// the Firestore repository fails: a thrown error, or a tip that does not exist
/// (`FirestoreTipRepository.vote` throws an [ArgumentError] for that).
class _UnreliableRepository extends InMemoryTipRepository {
  bool offline = false;
  bool tipMissing = false;

  void _check() {
    if (offline) throw Exception('network down');
  }

  @override
  Future<List<Tip>> fetchTips({TipCategory? category}) async {
    _check();
    return super.fetchTips(category: category);
  }

  @override
  Future<VoteValue?> myVote({required String tipId, required String userId}) async {
    _check();
    return super.myVote(tipId: tipId, userId: userId);
  }

  @override
  Future<Tip> vote({
    required String tipId,
    required String userId,
    required VoteValue? value,
  }) async {
    _check();
    if (tipMissing) throw ArgumentError('Unknown tip: $tipId');
    return super.vote(tipId: tipId, userId: userId, value: value);
  }
}

void main() {
  late FakeAuthService auth;
  late _UnreliableRepository server;
  late GuideViewModel vm;

  setUp(() async {
    auth = FakeAuthService();
    await auth.signIn(email: 'demo@edu.p.lodz.pl', password: 'x');
    server = _UnreliableRepository();
    vm = GuideViewModel(repository: server, authService: auth);
    await vm.load();
  });

  group('failed request', () {
    test('a failed vote changes no count and no highlighted button', () async {
      server.offline = true;

      final outcome = await vm.vote('sample-5', VoteValue.helpful);

      expect(outcome, VoteOutcome.failed);
      expect(vm.tipById('sample-5')!.helpful, 0);
      expect(vm.myVote('sample-5'), isNull);
    });

    test('a failed vote does not notify listeners about a change', () async {
      server.offline = true;
      var notified = 0;
      vm.addListener(() => notified++);

      await vm.vote('sample-5', VoteValue.helpful);

      expect(notified, 0);
    });

    test('removing a vote that fails keeps the old vote', () async {
      await vm.vote('sample-5', VoteValue.helpful);
      server.offline = true;

      final outcome = await vm.vote('sample-5', VoteValue.helpful);

      expect(outcome, VoteOutcome.failed);
      expect(vm.myVote('sample-5'), VoteValue.helpful);
      expect(vm.tipById('sample-5')!.helpful, 1);
    });
  });

  group('unexpected response', () {
    test('a tip that no longer exists on the server gives a failure, not a crash',
        () async {
      server.tipMissing = true;

      final outcome = await vm.vote('sample-5', VoteValue.helpful);

      expect(outcome, VoteOutcome.failed);
      expect(vm.tipById('sample-5')!.helpful, 0);
    });

    test('a saved copy with an unknown category is ignored', () async {
      final disk = <String, String>{
        CachingTipRepository.tipsKey:
            '[{"id":"x","title":"t","body":"body body body","category":"moon",'
                '"authorName":"a","createdAt":"2026-11-01T10:00:00.000",'
                '"helpful":1,"notHelpful":0}]',
      };
      final repo = CachingTipRepository(
        inner: _UnreliableRepository()..offline = true,
        store: InMemoryLocalStore(disk),
      );

      await expectLater(repo.fetchTips(), throwsException);
    });
  });

  group('lost connection', () {
    test('after the connection comes back the same vote succeeds once', () async {
      server.offline = true;
      expect(await vm.vote('sample-5', VoteValue.helpful), VoteOutcome.failed);

      server.offline = false;
      expect(await vm.vote('sample-5', VoteValue.helpful), VoteOutcome.saved);

      expect(vm.tipById('sample-5')!.helpful, 1);
      expect(vm.myVote('sample-5'), VoteValue.helpful);
    });

    test('a connection lost between two votes keeps the first one', () async {
      await vm.vote('sample-5', VoteValue.helpful);
      server.offline = true;
      await vm.vote('sample-5', VoteValue.notHelpful);

      expect(vm.myVote('sample-5'), VoteValue.helpful);
      expect(vm.tipById('sample-5')!.helpful, 1);
      expect(vm.tipById('sample-5')!.notHelpful, 0);
    });
  });

  group('what the user sees', () {
    testWidgets('a failed vote shows the connection message and keeps the count',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TipDetailScreen(tipId: 'sample-1', viewModel: vm),
      ));
      await tester.pumpAndSettle();

      server.offline = true;
      await tester.tap(find.text('Helpful (24)'));
      await tester.pump();

      expect(find.text('Could not save your vote. Check your connection.'),
          findsOneWidget);
      expect(find.text('Helpful (24)'), findsOneWidget);
    });
  });
}
