import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erasmus_student_guide/data/local_tip_repository.dart';
import 'package:erasmus_student_guide/data/persistent_auth_service.dart';
import 'package:erasmus_student_guide/logic/tip_ranking.dart';
import 'package:erasmus_student_guide/main.dart';
import 'package:erasmus_student_guide/models/tip.dart';
import 'package:erasmus_student_guide/viewmodels/guide_view_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Week 6 Local Data Storage & Persistence Tests', () {
    test('LocalTipRepository persists and restores created tips across app restarts', () async {
      // First session: Add a tip
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

      // Simulate app restart: Create a brand new repository instance
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

      // Cast vote
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

      // Sign in
      await authSession1.signIn(
        email: 'yusuf.taskin@edu.p.lodz.pl',
        password: 'anyPassword123',
      );
      expect(authSession1.currentUser?.email, 'yusuf.taskin@edu.p.lodz.pl');

      // Simulate app restart
      final authSession2 = PersistentAuthService();
      await authSession2.init();

      expect(authSession2.currentUser, isNotNull);
      expect(authSession2.currentUser?.email, 'yusuf.taskin@edu.p.lodz.pl');

      // Sign out clears local storage
      await authSession2.signOut();
      expect(authSession2.currentUser, isNull);

      // Reopening again remains signed out
      final authSession3 = PersistentAuthService();
      await authSession3.init();
      expect(authSession3.currentUser, isNull);
    });

    test('LocalTipRepository CRUD: Delete a custom user tip', () async {
      final repo = LocalTipRepository();
      await repo.init();

      const tempTip = NewTip(
        title: 'Temporary Tip to Delete',
        body: 'This tip is created for testing the delete CRUD action in Week 6.',
        category: TipCategory.studentLife,
      );

      final created = await repo.addTip(tempTip, userId: 'usr_test');
      expect((await repo.fetchTips()).any((t) => t.id == created.id), isTrue);

      final deleted = await repo.deleteTip(created.id, userId: 'usr_test');
      expect(deleted, isTrue);
      expect((await repo.fetchTips()).any((t) => t.id == created.id), isFalse);
    });
  });

  group('Week 6 ViewModel & State Tests', () {
    test('GuideViewModel integrates seamlessly with persistent repository', () async {
      final repo = LocalTipRepository();
      final auth = PersistentAuthService();
      await repo.init();
      await auth.init();

      final vm = GuideViewModel(repository: repo, authService: auth);
      await vm.loadTips();

      expect(vm.tips.isNotEmpty, isTrue);

      // Category filter state test
      vm.setCategory(TipCategory.transport);
      expect(vm.tips.every((t) => t.category == TipCategory.transport), isTrue);

      // Search state test
      vm.setSearchQuery('Jakdojade');
      expect(vm.tips.any((t) => t.title.contains('Jakdojade')), isTrue);
    });
  });

  group('Week 6 UI Smoke Tests', () {
    testWidgets('App launches and displays main navigation tabs', (tester) async {
      await tester.pumpWidget(const UniversityGuideApp());
      await tester.pump();

      expect(find.text('University Guide'), findsOneWidget);
      expect(find.text('Guide'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Campus'), findsOneWidget);
      expect(find.text('Checklist'), findsOneWidget);
    });
  });
}
