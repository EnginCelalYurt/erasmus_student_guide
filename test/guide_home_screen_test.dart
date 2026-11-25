import 'dart:async';

import 'package:erasmus_student_guide/data/caching_tip_repository.dart';
import 'package:erasmus_student_guide/data/fake_auth_service.dart';
import 'package:erasmus_student_guide/data/in_memory_tip_repository.dart';
import 'package:erasmus_student_guide/data/local_store.dart';
import 'package:erasmus_student_guide/models/tip.dart';
import 'package:erasmus_student_guide/screens/guide_home_screen.dart';
import 'package:erasmus_student_guide/viewmodels/guide_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _ControllableTipRepository extends InMemoryTipRepository {
  bool failNext = false;
  Completer<List<Tip>>? pendingFetch;

  @override
  Future<List<Tip>> fetchTips({TipCategory? category}) async {
    if (pendingFetch != null) {
      return pendingFetch!.future;
    }
    if (failNext) {
      throw Exception('network error');
    }
    return super.fetchTips(category: category);
  }
}

void main() {
  testWidgets('shows non-blocking loading indicator while fetching', (tester) async {
    final repo = _ControllableTipRepository();
    repo.pendingFetch = Completer<List<Tip>>();
    final vm = GuideViewModel(repository: repo, authService: FakeAuthService());

    await tester.pumpWidget(MaterialApp(home: GuideHomeScreen(viewModel: vm)));
    await tester.pump();

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('112 Emergency Helpline'), findsOneWidget);
    expect(find.text('Dormitories'), findsOneWidget);

    repo.pendingFetch!.complete([]);
    repo.pendingFetch = null;
    await tester.pumpAndSettle();

    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.text('No Tips Yet'), findsOneWidget);
  });

  testWidgets('shows error state with Retry and recovers on tap', (tester) async {
    final repo = _ControllableTipRepository()..failNext = true;
    final vm = GuideViewModel(repository: repo, authService: FakeAuthService());

    await tester.pumpWidget(MaterialApp(home: GuideHomeScreen(viewModel: vm)));
    await tester.pumpAndSettle();

    expect(find.text('Could Not Load Tips'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    repo.failNext = false;
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Could Not Load Tips'), findsNothing);
    expect(find.textContaining('Top Advice'), findsOneWidget);
  });

  testWidgets('shows "Offline, may be outdated" banner with Retry when cached', (tester) async {
    final repo = _ControllableTipRepository();
    final cache = CachingTipRepository(
      inner: repo,
      store: InMemoryLocalStore(),
    );
    await cache.fetchTips();
    repo.failNext = true;

    final vm = GuideViewModel(repository: cache, authService: FakeAuthService());
    await tester.pumpWidget(MaterialApp(home: GuideHomeScreen(viewModel: vm)));
    await tester.pumpAndSettle();

    expect(find.text('Offline, may be outdated'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    repo.failNext = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Offline, may be outdated'), findsNothing);
  });

  testWidgets('shows empty search state with Clear search action', (tester) async {
    final vm = GuideViewModel(
      repository: InMemoryTipRepository(),
      authService: FakeAuthService(),
    );
    await tester.pumpWidget(MaterialApp(home: GuideHomeScreen(viewModel: vm)));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'zzznomatch999');
    await tester.pumpAndSettle();

    expect(find.text('No Matching Tips'), findsOneWidget);
    expect(find.text('Clear search'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear search'));
    await tester.pumpAndSettle();

    expect(find.text('No Matching Tips'), findsNothing);
    expect(find.textContaining('Top Advice'), findsOneWidget);
  });

  testWidgets('exposes TalkBack semantics on 112 emergency banner', (tester) async {
    final vm = GuideViewModel(
      repository: InMemoryTipRepository(),
      authService: FakeAuthService(),
    );
    await tester.pumpWidget(MaterialApp(home: GuideHomeScreen(viewModel: vm)));
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel(
        'Call 112 Emergency Helpline, free multilingual operator. Long press to copy number.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('labels fictional sample data and supports TUL sign-in flow', (tester) async {
    final vm = GuideViewModel(
      repository: InMemoryTipRepository(),
      authService: FakeAuthService(),
    );
    await tester.pumpWidget(MaterialApp(home: GuideHomeScreen(viewModel: vm)));
    await tester.pumpAndSettle();

    expect(find.text('Demo · Fictional sample data'), findsOneWidget);
    expect(find.text('Share tip'), findsNothing);

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    final dialogFields = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(dialogFields.at(0), 'user@gmail.com');
    await tester.enterText(dialogFields.at(1), 'pass123');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Use your TUL e-mail address.'), findsOneWidget);

    await tester.enterText(dialogFields.at(0), '123456@edu.p.lodz.pl');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Signed in as 123456@edu.p.lodz.pl'), findsOneWidget);
    expect(find.text('Share tip'), findsOneWidget);
  });
}
