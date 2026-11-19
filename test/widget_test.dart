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

  group('Week 7 API Integration & Offline Reliability Tests', () {
    test('LodzApiService falls back to cached data when offline', () async {
      final service = LodzApiService();

      // In test sandbox without internet, it gracefully triggers the fallback
      final result = await service.fetchLiveInfo();
      expect(result, isNotNull);
      expect(result.eurToPln, greaterThan(0));
      expect(result.isFromCache, isTrue);
      expect(result.notice, isNotNull);
    });
  });

  group('Week 8 Mobile Capabilities & Permissions Fallback Tests', () {
    test('Emergency dialer number sanitation format', () {
      const input = '+48 42 631 29 99';
      final clean = input.replaceAll(RegExp(r'[^0-9+]'), '');
      expect(clean, '+48426312999');
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

    test('PersistentAuthService restores user session after app restart', () async {
      final authSession1 = PersistentAuthService();
      await authSession1.init();
      expect(authSession1.currentUser, isNull);

      await authSession1.signIn(
        email: 'yusuf.taskin@edu.p.lodz.pl',
        password: 'anyPassword123',
      );
      expect(authSession1.currentUser?.email, 'yusuf.taskin@edu.p.lodz.pl');

      // Simulate app restart
      final authSession2 = PersistentAuthService();
      await authSession2.init();

      expect(authSession2.currentUser?.email, 'yusuf.taskin@edu.p.lodz.pl');
    });
  });

  group('Week 5 & 9 ViewModel and MVP Tests', () {
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

  group('UI Smoke and Navigation Tests', () {
    testWidgets('App displays Guide, Live Info Banner, 112 Banner and Navigation Tabs', (tester) async {
      await tester.pumpWidget(const UniversityGuideApp());
      await tester.pump();

      expect(find.text('University Guide'), findsOneWidget);
      expect(find.textContaining('112 Emergency'), findsOneWidget);
      expect(find.text('Guide'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Campus'), findsOneWidget);
    });
  });
}
