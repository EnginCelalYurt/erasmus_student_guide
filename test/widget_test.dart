import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erasmus_student_guide/data/fake_auth_service.dart';
import 'package:erasmus_student_guide/data/in_memory_tip_repository.dart';
import 'package:erasmus_student_guide/logic/tip_ranking.dart';
import 'package:erasmus_student_guide/main.dart';
import 'package:erasmus_student_guide/models/tip.dart';
import 'package:erasmus_student_guide/screens/share_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Yusuf Task Unit Tests - InMemoryTipRepository & FakeAuthService', () {
    late InMemoryTipRepository repo;
    late FakeAuthService auth;

    setUp(() {
      repo = InMemoryTipRepository();
      auth = FakeAuthService();
    });

    test('FakeAuthService sign in enforces TUL email domain', () async {
      expect(auth.currentUser, isNull);

      // Non-TUL email fails
      expect(
        () => auth.signIn(email: 'user@gmail.com', password: '123'),
        throwsA(isA<Exception>()),
      );

      // TUL email succeeds
      await auth.signIn(email: 'student@p.lodz.pl', password: '123');
      expect(auth.currentUser?.email, 'student@p.lodz.pl');
    });

    test('rankTips orders by Wilson score in mostHelpful', () async {
      final tips = await repo.fetchTips();
      final ranked = rankTips(tips, TipSort.mostHelpful);

      for (var i = 0; i < ranked.length - 1; i++) {
        final scoreA = wilsonScore(ranked[i].helpful, ranked[i].notHelpful);
        final scoreB = wilsonScore(ranked[i + 1].helpful, ranked[i + 1].notHelpful);
        expect(scoreA >= scoreB, isTrue);
      }
    });

    test('rankTips orders by newest createdAt descending', () async {
      final tips = await repo.fetchTips();
      final ranked = rankTips(tips, TipSort.newest);

      for (var i = 0; i < ranked.length - 1; i++) {
        expect(
          ranked[i].createdAt.isAfter(ranked[i + 1].createdAt) ||
              ranked[i].createdAt.isAtSameMomentAs(ranked[i + 1].createdAt),
          isTrue,
        );
      }
    });

    test('searchTips filters correctly by keyword', () async {
      final tips = await repo.fetchTips();

      final dormResults = searchTips(tips, 'dorm');
      expect(dormResults.any((t) => t.category == TipCategory.dormitories), isTrue);

      final emergencyResults = searchTips(tips, '112');
      expect(emergencyResults.any((t) => t.category == TipCategory.emergency), isTrue);

      final noResults = searchTips(tips, 'nonexistentquery12345');
      expect(noResults.isEmpty, isTrue);
    });

    test('NewTip.validateBody enforces validation rules', () {
      expect(NewTip.validateBody(null), isNotNull);
      expect(NewTip.validateBody('   '), isNotNull);
      expect(NewTip.validateBody('Short text'), isNotNull);
      expect(
        NewTip.validateBody('This is a comprehensive and helpful tip for students arriving in Lodz.'),
        isNull,
      );
    });

    test('NewTip.validateTitle enforces validation rules', () {
      expect(NewTip.validateTitle(null), isNotNull);
      expect(NewTip.validateTitle(''), isNotNull);
      expect(NewTip.validateTitle('Valid Tip Title'), isNull);
    });

    test('addTip successfully stores a new tip in repository', () async {
      const newTip = NewTip(
        title: 'New Student Orientation Walk',
        body: 'Meet your buddy at Piotrkowska fountain at 18:00 on Monday for a campus tour.',
        category: TipCategory.firstWeeks,
        authorName: 'Yusuf',
      );

      final created = await repo.addTip(newTip, userId: 'usr_yusuf');
      expect(created.id, isNotEmpty);
      expect(created.title, 'New Student Orientation Walk');

      final all = await repo.fetchTips();
      expect(all.first.id, created.id);
    });
  });

  group('Yusuf Task Widget Tests - Guide Home & Share Screen', () {
    testWidgets('Guide Home displays 112 banner, categories and search', (tester) async {
      await tester.pumpWidget(const UniversityGuideApp());
      await tester.pump();

      expect(find.text('University Guide'), findsOneWidget);
      expect(find.textContaining('112 Emergency'), findsOneWidget);
      expect(find.text('Dormitories'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
    });

    testWidgets('Tapping Share shows sign-in or form', (tester) async {
      await tester.pumpWidget(const UniversityGuideApp());
      await tester.pump();

      await tester.tap(find.text('Share').first);
      await tester.pumpAndSettle();

      expect(find.text('Share Experience'), findsOneWidget);
      expect(find.text('Student Verification Required'), findsOneWidget);
      expect(find.text('Sign in with TUL E-mail'), findsOneWidget);
    });
  });
}
