import 'package:erasmus_student_guide/data/fake_auth_service.dart';
import 'package:erasmus_student_guide/data/in_memory_tip_repository.dart';
import 'package:erasmus_student_guide/screens/tip_detail_screen.dart';
import 'package:erasmus_student_guide/utils/share_tip.dart';
import 'package:erasmus_student_guide/viewmodels/guide_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  late FakeAuthService auth;
  late GuideViewModel vm;

  setUp(() async {
    auth = FakeAuthService();
    vm = GuideViewModel(repository: InMemoryTipRepository(), authService: auth);
    await vm.load();
  });

  Future<void> openTip(WidgetTester tester, {ShareTextFn? shareFn}) async {
    await tester.pumpWidget(MaterialApp(
      home: TipDetailScreen(
        tipId: 'sample-1',
        viewModel: vm,
        shareFn: shareFn,
      ),
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

  testWidgets('tapping share invokes platform share with tip text', (tester) async {
    String? sharedText;
    String? sharedSubject;
    await openTip(
      tester,
      shareFn: (text, {subject}) async {
        sharedText = text;
        sharedSubject = subject;
        return ShareResultStatus.success;
      },
    );

    await tester.tap(find.byTooltip('Share tip'));
    await tester.pumpAndSettle();

    final tip = vm.tipById('sample-1')!;
    expect(sharedSubject, tip.title);
    expect(sharedText, contains(tip.title));
    expect(sharedText, contains(tip.body));
  });

  testWidgets('share falls back to clipboard when unavailable', (tester) async {
    String? copiedText;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copiedText = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );

    await openTip(
      tester,
      shareFn: (text, {subject}) async => ShareResultStatus.unavailable,
    );

    await tester.tap(find.byTooltip('Share tip'));
    await tester.pumpAndSettle();

    final tip = vm.tipById('sample-1')!;
    expect(copiedText, contains(tip.title));
    expect(copiedText, contains(tip.body));
    expect(find.text('Tip copied to clipboard'), findsOneWidget);
  });
}
