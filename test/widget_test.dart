import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erasmus_student_guide/main.dart';
import 'package:erasmus_student_guide/models/tip.dart';
import 'package:erasmus_student_guide/repositories/tip_repository.dart';
import 'package:erasmus_student_guide/services/fake_auth_service.dart';

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

    test('FakeAuthService is authenticated with default student profile', () {
      expect(auth.isAuthenticated, isTrue);
      expect(auth.currentUser?.name, 'Yusuf Taskin');
      expect(auth.currentUser?.email, contains('edu.p.lodz.pl'));
    });

    test('rankTips orders by most helpful descending', () async {
      final tips = await repo.getTips();
      final ranked = repo.rankTips(tips, TipSort.mostHelpful);

      for (var i = 0; i < ranked.length - 1; i++) {
        expect(ranked[i].helpfulCount >= ranked[i + 1].helpfulCount, isTrue);
      }
    });

    test('rankTips orders by newest createdAt descending', () async {
      final tips = await repo.getTips();
      final ranked = repo.rankTips(tips, TipSort.newest);

      for (var i = 0; i < ranked.length - 1; i++) {
        expect(
          ranked[i].createdAt.isAfter(ranked[i + 1].createdAt) ||
              ranked[i].createdAt.isAtSameMomentAs(ranked[i + 1].createdAt),
          isTrue,
        );
      }
    });

    test('searchTips filters correctly by keyword', () async {
      final tips = await repo.getTips();

      final dormResults = repo.searchTips(tips, 'dorm');
      expect(dormResults.any((t) => t.category == 'Housing'), isTrue);

      final emergencyResults = repo.searchTips(tips, '112');
      expect(emergencyResults.any((t) => t.category == 'Health'), isTrue);

      final noResults = repo.searchTips(tips, 'nonexistentquery12345');
      expect(noResults.isEmpty, isTrue);
    });

    test('NewTip.validateBody enforces validation rules', () {
      // Empty or null
      expect(NewTip.validateBody(null), isNotNull);
      expect(NewTip.validateBody('   '), isNotNull);

      // Too short (< 15 chars)
      expect(NewTip.validateBody('Short text'), isNotNull);

      // Valid body
      expect(
        NewTip.validateBody('This is a comprehensive and helpful tip for students arriving in Lodz.'),
        isNull,
      );

      // Too long (> 2500 chars)
      final longBody = 'A' * 2501;
      expect(NewTip.validateBody(longBody), isNotNull);
    });

    test('NewTip.validateTitle enforces validation rules', () {
      expect(NewTip.validateTitle(null), isNotNull);
      expect(NewTip.validateTitle('ab'), isNotNull);
      expect(NewTip.validateTitle('Valid Tip Title'), isNull);
    });
  });

  group('Yusuf Task Widget Tests - Guide Home & Navigation', () {
    testWidgets('Guide Home displays 112 banner, categories and search', (tester) async {
      await tester.pumpWidget(const UniversityGuideApp());
      await tester.pump();

      // Verify Guide Home elements
      expect(find.text('University Guide'), findsOneWidget);
      expect(find.textContaining('112 Emergency'), findsOneWidget);
      expect(find.text('Housing'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('Health'), findsOneWidget);
      expect(find.text('Most helpful'), findsOneWidget);
      expect(find.text('Newest'), findsOneWidget);
    });

    testWidgets('Tapping on a category opens CategoryTipsScreen', (tester) async {
      await tester.pumpWidget(const UniversityGuideApp());
      await tester.pump();

      await tester.tap(find.text('Housing').first);
      await tester.pumpAndSettle();

      expect(find.text('Housing'), findsWidgets);
      expect(find.textContaining('Osiedle Akademickie'), findsWidgets);
    });
  });
}
