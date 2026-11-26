import 'package:erasmus_student_guide/data/fake_auth_service.dart';
import 'package:erasmus_student_guide/data/in_memory_tip_repository.dart';
import 'package:erasmus_student_guide/data/tip_repository.dart';
import 'package:erasmus_student_guide/models/tip.dart';
import 'package:erasmus_student_guide/screens/tip_detail_screen.dart';
import 'package:erasmus_student_guide/viewmodels/guide_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Refuses votes the way the server does for an unconfirmed e-mail address.
class _RefusingRepository extends InMemoryTipRepository {
  @override
  Future<Tip> vote({
    required String tipId,
    required String userId,
    required VoteValue? value,
  }) async {
    throw const TipPermissionException();
  }
}

void main() {
  late FakeAuthService auth;

  setUp(() => auth = FakeAuthService());

  group('refused vote', () {
    test('is reported as not allowed and changes nothing', () async {
      final vm = GuideViewModel(
        repository: _RefusingRepository(),
        authService: auth,
      );
      await vm.load();
      await auth.signIn(email: 'demo@edu.p.lodz.pl', password: 'x');

      final outcome = await vm.vote('sample-5', VoteValue.helpful);

      expect(outcome, VoteOutcome.notAllowed);
      expect(vm.tipById('sample-5')!.helpful, 0);
      expect(vm.myVote('sample-5'), isNull);
    });

    testWidgets('tells the user to confirm the e-mail', (tester) async {
      final vm = GuideViewModel(
        repository: _RefusingRepository(),
        authService: auth,
      );
      await vm.load();
      await auth.signIn(email: 'demo@edu.p.lodz.pl', password: 'x');
      await tester.pumpWidget(MaterialApp(
        home: TipDetailScreen(tipId: 'sample-1', viewModel: vm),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Helpful (24)'));
      await tester.pump();

      expect(find.textContaining('Confirm your TUL e-mail first'), findsOneWidget);
      expect(find.textContaining('Check your connection'), findsNothing);
    });
  });

  group('sign-in changes made outside the view model', () {
    test('a restored or ended session notifies the screens', () async {
      final vm = GuideViewModel(
        repository: InMemoryTipRepository(),
        authService: auth,
      );
      var notified = 0;
      vm.addListener(() => notified++);

      // Not through vm.signIn: like a session restored by Firebase.
      await auth.signIn(email: 'demo@edu.p.lodz.pl', password: 'x');
      await Future<void>.delayed(Duration.zero);
      expect(vm.isSignedIn, isTrue);
      expect(notified, 1);

      await auth.signOut();
      await Future<void>.delayed(Duration.zero);
      expect(vm.isSignedIn, isFalse);
      expect(notified, 2);
    });

    test('after dispose changes are ignored', () async {
      final vm = GuideViewModel(
        repository: InMemoryTipRepository(),
        authService: auth,
      );
      vm.dispose();

      await auth.signIn(email: 'demo@edu.p.lodz.pl', password: 'x');
      await Future<void>.delayed(Duration.zero);
      // Reaching this line means no "used after dispose" error was raised.
    });
  });
}
