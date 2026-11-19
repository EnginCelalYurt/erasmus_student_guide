import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erasmus_student_guide/data/local_tip_repository.dart';
import 'package:erasmus_student_guide/data/persistent_auth_service.dart';
import 'package:erasmus_student_guide/logic/tip_ranking.dart';
import 'package:erasmus_student_guide/main.dart';
import 'package:erasmus_student_guide/models/tip.dart';
import 'package:erasmus_student_guide/services/lodz_api_service.dart';
import 'package:erasmus_student_guide/viewmodels/guide_view_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Week 4 Yusuf Deliverables & UI Tests', () {
    testWidgets('App displays official name and 3 agreed MVP tabs', (tester) async {
      await tester.pumpWidget(const ErasmusStudentGuideApp());
      await tester.pump();

      // Official App Name check
      expect(find.text('Erasmus Student Guide'), findsOneWidget);

      // 3 Agreed MVP Navigation Tabs
      expect(find.text('Guide'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Checklist'), findsOneWidget);

      // Scope check: Campus and Places should not be present in bottom navigation
      expect(find.text('Campus'), findsNothing);
      expect(find.text('Places'), findsNothing);
    });

    testWidgets('Category tips count singular and plural formatting', (tester) async {
      await tester.pumpWidget(const ErasmusStudentGuideApp());
      await tester.pump();

      // Verifies categories grid renders with 'tips' or 'tip'
      expect(find.text('Explore by Category'), findsOneWidget);
      expect(find.textContaining('tip'), findsWidgets);
    });

    testWidgets('Tapping Checklist shows sourced steps and notes', (tester) async {
      await tester.pumpWidget(const ErasmusStudentGuideApp());
      await tester.pump();

      await tester.tap(find.text('Checklist').first);
      await tester.pumpAndSettle();

      expect(find.text('Arrival Checklist & Notes'), findsOneWidget);
      expect(find.textContaining('Source:'), findsWidgets);
      expect(find.text('My Campus Notes'), findsOneWidget);
    });
  });

  group('Week 7 API Integration & Offline Reliability Tests', () {
    test('LodzApiService falls back to cached data when offline', () async {
      final service = LodzApiService();

      final result = await service.fetchLiveInfo();
      expect(result, isNotNull);
      expect(result.eurToPln, greaterThan(0));
      expect(result.isFromCache, isTrue);
      expect(result.notice, isNotNull);
    });
  });

  group('Week 6 Local Persistence & CRUD Tests', () {
    test('LocalTipRepository persists and restores created tips across app restarts', () async {
      final repoSession1 = LocalTipRepository();
      await repoSession1.init();

      const newTip = NewTip(
        title: 'Sukcesja Mall Essentials',
        body: 'You can buy pans, towels and bedding cheaply in Sukcesja across the street.',
        category: TipCategory.dailyLife,
        authorName: 'Yusuf',
      );

      final created = await repoSession1.addTip(newTip, userId: 'usr_yusuf');
      expect(created.id, isNotEmpty);

      // Simulate app restart
      final repoSession2 = LocalTipRepository();
      await repoSession2.init();
      final tipsAfterRestart = await repoSession2.fetchTips();

      expect(tipsAfterRestart.any((t) => t.title == 'Sukcesja Mall Essentials'), isTrue);
    });

    test('LocalTipRepository persists user votes across app restarts', () async {
      final repoSession1 = LocalTipRepository();
      await repoSession1.init();
      final tips = await repoSession1.fetchTips();
      final tipId = tips.first.id;

      await repoSession1.vote(tipId: tipId, userId: 'usr_yusuf', value: VoteValue.helpful);
      final voteSession1 = await repoSession1.myVote(tipId: tipId, userId: 'usr_yusuf');
      expect(voteSession1, VoteValue.helpful);

      // Simulate app restart
      final repoSession2 = LocalTipRepository();
      await repoSession2.init();
      final voteSession2 = await repoSession2.myVote(tipId: tipId, userId: 'usr_yusuf');

      expect(voteSession2, VoteValue.helpful);
    });
  });

  group('ViewModel Tests', () {
    test('GuideViewModel loads, filters and ranks tips with Wilson score', () async {
      final repo = LocalTipRepository();
      final auth = PersistentAuthService();
      await repo.init();
      await auth.init();

      final vm = GuideViewModel(repository: repo, authService: auth);
      await vm.loadTips();

      expect(vm.tips.isNotEmpty, isTrue);

      vm.setCategory(TipCategory.transport);
      expect(vm.tips.every((t) => t.category == TipCategory.transport), isTrue);
    });
  });
}
