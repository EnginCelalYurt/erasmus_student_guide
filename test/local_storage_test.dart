import 'package:erasmus_student_guide/data/caching_tip_repository.dart';
import 'package:erasmus_student_guide/data/draft_store.dart';
import 'package:erasmus_student_guide/data/fake_auth_service.dart';
import 'package:erasmus_student_guide/data/in_memory_tip_repository.dart';
import 'package:erasmus_student_guide/data/local_store.dart';
import 'package:erasmus_student_guide/models/tip.dart';
import 'package:erasmus_student_guide/viewmodels/guide_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// An in-memory repository whose network can be switched off.
class _FlakyRepository extends InMemoryTipRepository {
  bool offline = false;

  void _check() {
    if (offline) throw Exception('no network');
  }

  @override
  Future<List<Tip>> fetchTips({TipCategory? category}) async {
    _check();
    return super.fetchTips(category: category);
  }

  @override
  Future<VoteValue?> myVote({required String tipId, required String userId}) async {
    _check();
    return super.myVote(tipId: tipId, userId: userId);
  }

  @override
  Future<Tip> vote({
    required String tipId,
    required String userId,
    required VoteValue? value,
  }) async {
    _check();
    return super.vote(tipId: tipId, userId: userId, value: value);
  }
}

void main() {
  late Map<String, String> disk;
  late _FlakyRepository server;

  CachingTipRepository openApp() => CachingTipRepository(
        inner: server,
        store: InMemoryLocalStore(disk), // same map = same device storage
      );

  setUp(() {
    disk = {};
    server = _FlakyRepository();
  });

  group('tips cache', () {
    test('after a restart without network the last loaded tips are shown', () async {
      final online = await openApp().fetchTips();
      expect(online, isNotEmpty);

      server.offline = true;
      final reopened = openApp(); // "app restarted"
      final tips = await reopened.fetchTips();

      expect(tips.map((t) => t.id), online.map((t) => t.id));
      expect(reopened.servedFromCache, isTrue);
    });

    test('a category request offline is filtered from the saved copy', () async {
      await openApp().fetchTips();
      server.offline = true;

      final tips = await openApp().fetchTips(category: TipCategory.transport);

      expect(tips, isNotEmpty);
      expect(tips.every((t) => t.category == TipCategory.transport), isTrue);
    });

    test('offline with nothing saved still fails', () async {
      server.offline = true;
      expect(openApp().fetchTips(), throwsException);
    });

    test('a damaged saved copy is ignored instead of crashing', () async {
      disk[CachingTipRepository.tipsKey] = '{not json';
      server.offline = true;
      expect(openApp().fetchTips(), throwsException);
    });

    test('back online the flag is cleared and the copy refreshed', () async {
      final repo = openApp();
      await repo.fetchTips();
      server.offline = true;
      await repo.fetchTips();
      expect(repo.servedFromCache, isTrue);

      server.offline = false;
      await repo.fetchTips();
      expect(repo.servedFromCache, isFalse);
    });

    test('a vote is reflected in the saved copy', () async {
      final repo = openApp();
      await repo.fetchTips();
      await repo.vote(tipId: 'sample-5', userId: 'u1', value: VoteValue.helpful);

      server.offline = true;
      final tips = await openApp().fetchTips();
      expect(tips.firstWhere((t) => t.id == 'sample-5').helpful, 1);
    });
  });

  group('votes cache', () {
    test('my vote survives a restart without network', () async {
      await openApp().vote(tipId: 'sample-5', userId: 'u1', value: VoteValue.helpful);

      server.offline = true;
      final vote = await openApp().myVote(tipId: 'sample-5', userId: 'u1');
      expect(vote, VoteValue.helpful);
    });

    test('votes of another user are not shown', () async {
      await openApp().vote(tipId: 'sample-5', userId: 'u1', value: VoteValue.helpful);
      await openApp().myVote(tipId: 'sample-5', userId: 'u2');

      server.offline = true;
      expect(await openApp().myVote(tipId: 'sample-5', userId: 'u2'), isNull);
    });

    test('removing a vote removes it from the saved copy', () async {
      final repo = openApp();
      await repo.vote(tipId: 'sample-5', userId: 'u1', value: VoteValue.helpful);
      await repo.vote(tipId: 'sample-5', userId: 'u1', value: null);

      server.offline = true;
      expect(await openApp().myVote(tipId: 'sample-5', userId: 'u1'), isNull);
    });

    test('a vote without network fails and saves nothing', () async {
      server.offline = true;
      final repo = openApp();
      await expectLater(
        repo.vote(tipId: 'sample-5', userId: 'u1', value: VoteValue.helpful),
        throwsException,
      );
      expect(disk.keys.where((k) => k.startsWith('cache.votes')), isEmpty);
    });
  });

  group('view model with the cache', () {
    late FakeAuthService auth;

    GuideViewModel openVm() => GuideViewModel(
          repository: openApp(),
          authService: auth,
        );

    setUp(() => auth = FakeAuthService());

    test('offline start shows saved tips and says so', () async {
      await openVm().load();

      server.offline = true;
      final vm = openVm();
      await vm.load();

      expect(vm.error, isNull);
      expect(vm.visibleTips(), isNotEmpty);
      expect(vm.showingSavedCopy, isTrue);
    });

    test('a vote without network reports failure and keeps the old count', () async {
      await auth.signIn(email: 'demo@edu.p.lodz.pl', password: 'x');
      final vm = openVm();
      await vm.load();

      server.offline = true;
      final outcome = await vm.vote('sample-5', VoteValue.helpful);

      expect(outcome, VoteOutcome.failed);
      expect(vm.tipById('sample-5')!.helpful, 0);
      expect(vm.myVote('sample-5'), isNull);
    });
  });

  group('drafts', () {
    late DraftStore drafts;

    DraftStore reopen() => DraftStore(InMemoryLocalStore(disk));

    setUp(() => drafts = reopen());

    test('a draft survives a restart', () async {
      await drafts.save('u1',
          title: 'Laundry', body: 'In the basement', category: TipCategory.dormitories);

      final draft = await reopen().load('u1');
      expect(draft!.title, 'Laundry');
      expect(draft.body, 'In the basement');
      expect(draft.category, TipCategory.dormitories);
    });

    test('drafts are kept per user', () async {
      await drafts.save('u1',
          title: 'Mine', body: 'text', category: TipCategory.transport);
      expect(await reopen().load('u2'), isNull);
    });

    test('an empty form removes the draft, clear removes it too', () async {
      await drafts.save('u1',
          title: 'Mine', body: 'text', category: TipCategory.transport);
      await drafts.save('u1',
          title: ' ', body: '', category: TipCategory.transport);
      expect(await reopen().load('u1'), isNull);

      await drafts.save('u1',
          title: 'Again', body: 'x', category: TipCategory.transport);
      await drafts.clear('u1');
      expect(await reopen().load('u1'), isNull);
    });
  });

  test('SharedPreferencesStore writes, reads and removes values', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await SharedPreferencesStore.open();

    await store.write('k', 'v');
    expect(await store.read('k'), 'v');
    // A second handle sees the same data, like after an app restart.
    expect(await (await SharedPreferencesStore.open()).read('k'), 'v');

    await store.remove('k');
    expect(await store.read('k'), isNull);
  });
}
