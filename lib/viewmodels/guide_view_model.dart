import 'package:flutter/foundation.dart';

import '../data/auth_service.dart';
import '../data/caching_tip_repository.dart';
import '../data/tip_repository.dart';
import '../logic/tip_ranking.dart';
import '../models/tip.dart';

enum VoteOutcome { saved, signInRequired, failed }

/// Application state for the guide screens.
///
/// Screens keep only temporary interface state (search text, sort choice)
/// and read tips, loading state and the user's votes from here. Data access
/// goes through [TipRepository]; screens never call the repository directly.
class GuideViewModel extends ChangeNotifier {
  GuideViewModel({
    required this._repository,
    required this._authService,
  });

  final TipRepository _repository;
  final AuthService _authService;

  List<Tip> _tips = [];
  // The signed-in user's votes, cleared whenever a different user signs in.
  final Map<String, VoteValue?> _myVotes = {};
  String? _myVotesOwner;
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  AppUser? get currentUser => _authService.currentUser;
  bool get isSignedIn => currentUser != null;

  /// True when the tips on screen are the copy saved on the device because
  /// the server could not be reached.
  bool get showingSavedCopy {
    final repo = _repository;
    return repo is CachingTipRepository && repo.servedFromCache;
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _tips = await _repository.fetchTips();
    } catch (_) {
      _error = 'Could not load tips. Pull down to try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tips the user should see: optionally one category, matching [query],
  /// ranked by [sort]. Low-rated tips are hidden by [rankTips].
  List<Tip> visibleTips({
    TipCategory? category,
    String query = '',
    TipSort sort = TipSort.mostHelpful,
  }) {
    final inCategory = category == null
        ? _tips
        : _tips.where((t) => t.category == category).toList();
    return rankTips(searchTips(inCategory, query), sort);
  }

  /// Number of tips a category screen will actually show (hidden tips excluded).
  int visibleCount(TipCategory category) {
    return _tips.where((t) => t.category == category && !isHidden(t)).length;
  }

  Tip? tipById(String id) {
    for (final tip in _tips) {
      if (tip.id == id) return tip;
    }
    return null;
  }

  VoteValue? myVote(String tipId) {
    _forgetVotesOfOtherUser();
    return _myVotes[tipId];
  }

  Future<void> loadMyVote(String tipId) async {
    _forgetVotesOfOtherUser();
    final user = currentUser;
    if (user == null || _myVotes.containsKey(tipId)) return;
    try {
      _myVotes[tipId] =
          await _repository.myVote(tipId: tipId, userId: user.uid);
      notifyListeners();
    } catch (_) {
      // No network and no saved copy: show no vote; the user can still retry.
    }
  }

  /// Tapping the same vote again removes it; tapping the other one switches it.
  Future<VoteOutcome> vote(String tipId, VoteValue value) async {
    _forgetVotesOfOtherUser();
    final user = currentUser;
    if (user == null) return VoteOutcome.signInRequired;

    try {
      final previous = _myVotes.containsKey(tipId)
          ? _myVotes[tipId]
          : await _repository.myVote(tipId: tipId, userId: user.uid);
      final next = previous == value ? null : value;
      final updated = await _repository.vote(
        tipId: tipId,
        userId: user.uid,
        value: next,
      );
      _myVotes[tipId] = next;
      _replaceTip(updated);
      notifyListeners();
      return VoteOutcome.saved;
    } catch (_) {
      return VoteOutcome.failed;
    }
  }

  /// Publishes a tip for the signed-in user. Throws [AuthException] when signed out.
  Future<Tip> addTip(NewTip tip) async {
    final user = currentUser;
    if (user == null) {
      throw const AuthException('Sign in with your TUL e-mail to share a tip.');
    }
    final created = await _repository.addTip(tip, userId: user.uid);
    _tips = [created, ..._tips];
    notifyListeners();
    return created;
  }

  void _forgetVotesOfOtherUser() {
    final uid = currentUser?.uid;
    if (uid != _myVotesOwner) {
      _myVotes.clear();
      _myVotesOwner = uid;
    }
  }

  void _replaceTip(Tip updated) {
    _tips = [
      for (final tip in _tips) tip.id == updated.id ? updated : tip,
    ];
  }
}
