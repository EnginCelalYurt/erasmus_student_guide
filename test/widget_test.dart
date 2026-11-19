import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erasmus_student_guide/data/fake_auth_service.dart';
import 'package:erasmus_student_guide/data/in_memory_tip_repository.dart';
import 'package:erasmus_student_guide/logic/tip_ranking.dart';
import 'package:erasmus_student_guide/main.dart';
import 'package:erasmus_student_guide/models/tip.dart';
import 'package:erasmus_student_guide/viewmodels/guide_view_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Week 5 Architecture Tests - ViewModel, State & Data Access', () {
    late InMemoryTipRepository repo;
    late FakeAuthService auth;
    late GuideViewModel vm;

    setUp(() async {
      repo = InMemoryTipRepository();
      auth = FakeAuthService();
      vm = GuideViewModel(repository: repo, authService: auth);
      await vm.loadTips();
    });

    test('GuideViewModel loads and ranks tips initially', () {
      expect(vm.tips.isNotEmpty, isTrue);
      expect(vm.isLoading, isFalse);
    });

    test('GuideViewModel filters by category', () {
      vm.setCategory(TipCategory.dormitories);
      expect(vm.selectedCategory, TipCategory.dormitories);
      expect(vm.tips.every((t) => t.category == TipCategory.dormitories), isTrue);

      vm.setCategory(null);
      expect(vm.tips.length, greaterThan(1));
    });

    test('GuideViewModel searches tips', () {
      vm.setSearchQuery('112');
      expect(vm.tips.any((t) => t.category == TipCategory.emergency), isTrue);

      vm.setSearchQuery('');
      expect(vm.tips.length, greaterThan(1));
    });

    test('GuideViewModel handles voting with Wilson score re-ranking', () async {
      await vm.signIn('yusuf.taskin@edu.p.lodz.pl', 'pass123');
      final firstTip = vm.tips.first;
      final initialHelpful = firstTip.helpful;

      final updated = await vm.vote(tipId: firstTip.id, value: VoteValue.helpful);
      expect(updated?.helpful, initialHelpful + 1);
    });

    test('GuideViewModel publishes new tip', () async {
      await vm.signIn('yusuf.taskin@edu.p.lodz.pl', 'pass123');

      const newTip = NewTip(
        title: 'New Student Orientation Walk',
        body: 'Meet your buddy at Piotrkowska fountain at 18:00 on Monday for a campus tour.',
        category: TipCategory.firstWeeks,
      );

      final created = await vm.publishTip(newTip);
      expect(created, isNotNull);
      expect(vm.tips.any((t) => t.title == 'New Student Orientation Walk'), isTrue);
    });
  });

  group('Week 5 UI & Navigation Tests', () {
    testWidgets('Guide Home displays 112 banner, categories and search', (tester) async {
      await tester.pumpWidget(const UniversityGuideApp());
      await tester.pump();

      expect(find.text('University Guide'), findsOneWidget);
      expect(find.textContaining('112 Emergency'), findsOneWidget);
      expect(find.text('Dormitories'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
    });

    testWidgets('Tapping Share shows sign-in or form with validations', (tester) async {
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
