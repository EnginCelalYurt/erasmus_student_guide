import 'package:erasmus_student_guide/data/fake_auth_service.dart';
import 'package:erasmus_student_guide/data/in_memory_tip_repository.dart';
import 'package:erasmus_student_guide/screens/tip_detail_screen.dart';
import 'package:erasmus_student_guide/viewmodels/guide_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeAuthService auth;
  late GuideViewModel vm;

  setUp(() async {
    auth = FakeAuthService();
    vm = GuideViewModel(repository: InMemoryTipRepository(), authService: auth);
    await vm.load();
  });

  Future<void> openTip(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: TipDetailScreen(tipId: 'sample-1', viewModel: vm),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('signed-out vote shows the sign-in message', (tester) async {
    await openTip(tester);
    await tester.tap(find.text('Helpful (24)'));
    await tester.pump();

    expect(find.text('Sign in with your TUL e-mail to vote.'), findsOneWidget);
    expect(find.text('Helpful (24)'), findsOneWidget);
  });

  testWidgets('signed-in vote updates the button count', (tester) async {
    await auth.signIn(email: 'demo@edu.p.lodz.pl', password: 'x');
    await openTip(tester);
    await tester.tap(find.text('Helpful (24)'));
    await tester.pumpAndSettle();

    expect(find.text('Helpful (25)'), findsOneWidget);
  });
}
