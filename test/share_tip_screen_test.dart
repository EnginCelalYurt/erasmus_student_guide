import 'package:erasmus_student_guide/data/draft_store.dart';
import 'package:erasmus_student_guide/data/fake_auth_service.dart';
import 'package:erasmus_student_guide/data/in_memory_tip_repository.dart';
import 'package:erasmus_student_guide/data/local_store.dart';
import 'package:erasmus_student_guide/models/tip.dart';
import 'package:erasmus_student_guide/screens/share_tip_screen.dart';
import 'package:erasmus_student_guide/viewmodels/guide_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeAuthService auth;
  late GuideViewModel vm;
  late Map<String, String> disk;
  late DraftStore draftStore;

  setUp(() async {
    auth = FakeAuthService();
    await auth.signIn(email: '123456@edu.p.lodz.pl', password: 'pw');
    vm = GuideViewModel(repository: InMemoryTipRepository(), authService: auth);
    await vm.load();
    disk = {};
    draftStore = DraftStore(InMemoryLocalStore(disk));
  });

  Widget buildForm() {
    return MaterialApp(
      home: ShareTipScreen(viewModel: vm, draftStore: draftStore),
    );
  }

  testWidgets('saves and continues a draft across reopening', (tester) async {
    await tester.pumpWidget(buildForm());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Tram ticket app');
    await tester.pump();
    await tester.ensureVisible(find.byType(TextFormField).at(1));
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Use Jakdojade or Migawka for student passes.',
    );
    await tester.pumpAndSettle();

    expect(find.text('Draft saved automatically'), findsOneWidget);

    // Simulate closing and reopening the share form.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(buildForm());
    await tester.pumpAndSettle();

    expect(find.text('Tram ticket app'), findsOneWidget);
    expect(
      find.text('Use Jakdojade or Migawka for student passes.'),
      findsOneWidget,
    );
    expect(find.text('Draft saved automatically'), findsOneWidget);
  });

  testWidgets('delete draft clears form fields and stored draft', (tester) async {
    await draftStore.save(
      auth.currentUser!.uid,
      title: 'Old draft title',
      body: 'Some unfinished advice text.',
      category: TipCategory.transport,
    );

    await tester.pumpWidget(buildForm());
    await tester.pumpAndSettle();

    expect(find.text('Old draft title'), findsOneWidget);

    await tester.tap(find.text('Delete draft'));
    await tester.pumpAndSettle();

    expect(find.text('Old draft title'), findsNothing);
    expect(find.text('Some unfinished advice text.'), findsNothing);
    expect(await draftStore.load(auth.currentUser!.uid), isNull);
  });

  testWidgets('keeps form state on screen rotation', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(buildForm());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Rotation test');
    await tester.pump();
    await tester.ensureVisible(find.byType(TextFormField).at(1));
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'This text should stay after rotating to landscape.',
    );
    await tester.pumpAndSettle();

    // Rotate to landscape.
    tester.view.physicalSize = const Size(800, 400);
    await tester.pumpAndSettle();

    expect(find.text('Rotation test'), findsOneWidget);
    await tester.ensureVisible(find.byType(TextFormField).at(1));
    expect(
      find.text('This text should stay after rotating to landscape.'),
      findsOneWidget,
    );
  });

  testWidgets('shows and clears empty and invalid-input validation messages', (tester) async {
    await tester.pumpWidget(buildForm());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Publish Tip'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a title.'), findsOneWidget);
    expect(find.text('Write at least 15 characters.'), findsOneWidget);

    // Fix title and body; validation messages should clear.
    await tester.enterText(find.byType(TextFormField).at(0), 'Valid Title');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'This advice has more than fifteen characters.',
    );
    await tester.pumpAndSettle();

    expect(find.text('Enter a title.'), findsNothing);
    expect(find.text('Write at least 15 characters.'), findsNothing);
  });

  testWidgets('publishing a valid tip adds it and clears the draft', (tester) async {
    await tester.pumpWidget(buildForm());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'BLIK everywhere');
    await tester.pump();
    await tester.ensureVisible(find.byType(TextFormField).at(1));
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Get a Polish bank account or Revolut with BLIK for fast payments.',
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Publish Tip'));
    await tester.tap(find.text('Publish Tip'));
    await tester.pumpAndSettle();

    expect(vm.visibleTips().any((t) => t.title == 'BLIK everywhere'), isTrue);
    expect(await draftStore.load(auth.currentUser!.uid), isNull);
  });
}
