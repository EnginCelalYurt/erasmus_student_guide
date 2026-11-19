import 'dart:async';
import 'package:flutter/foundation.dart';

import '../data/auth_service.dart';
import '../data/tip_repository.dart';
import '../logic/tip_ranking.dart';
import '../models/tip.dart';

/// ViewModel separating UI from Application State and Data Access Layer.
/// Follows standard Flutter ChangeNotifier ViewModel architecture for Week 5.
class GuideViewModel extends ChangeNotifier {
  final TipRepository _repository;
  final AuthService _authService;

  GuideViewModel({
    required TipRepository repository,
    required AuthService authService,
  })  : _repository = repository,
        _authService = authService {
    _authSubscription = _authService.authStateChanges.listen((_) {
      notifyListeners();
    });
  }

  StreamSubscription<AppUser?>? _authSubscription;

  List<Tip> _rawTips = [];
  bool _isLoading = false;
  String _searchQuery = '';
  TipSort _currentSort = TipSort.mostHelpful;
  TipCategory? _selectedCategory;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  TipSort get currentSort => _currentSort;
  TipCategory? get selectedCategory => _selectedCategory;
  String? get errorMessage => _errorMessage;

  AppUser? get currentUser => _authService.currentUser;
  bool get isAuthenticated => _authService.currentUser != null;

  /// Visible, ranked and filtered tips according to category, search and sort.
  List<Tip> get tips {
    // 1. Filter by category if selected
    final categoryFiltered = _selectedCategory == null
        ? _rawTips
        : _rawTips.where((t) => t.category == _selectedCategory).toList();

    // 2. Filter by search query
    final searchFiltered = searchTips(categoryFiltered, _searchQuery);

    // 3. Rank according to Wilson score or Newest
    return rankTips(searchFiltered, _currentSort);
  }

  /// Initial or refresh load of tips from repository.
  Future<void> loadTips() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _rawTips = await _repository.fetchTips();
    } catch (e) {
      _errorMessage = 'Failed to load tips: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// User action: filter by category
  void setCategory(TipCategory? category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
  }

  /// User action: update search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// User action: toggle sort order between Most helpful & Newest
  void setSort(TipSort sort) {
    if (_currentSort == sort) return;
    _currentSort = sort;
    notifyListeners();
  }

  /// User action: vote on a tip (Wilson score state change)
  Future<Tip?> vote({required String tipId, required VoteValue? value}) async {
    final user = currentUser;
    if (user == null) {
      _errorMessage = 'Must be signed in to vote.';
      notifyListeners();
      return null;
    }

    try {
      final updated = await _repository.vote(
        tipId: tipId,
        userId: user.uid,
        value: value,
      );

      // Update in local cache
      final index = _rawTips.indexWhere((t) => t.id == tipId);
      if (index >= 0) {
        _rawTips[index] = updated;
      }
      notifyListeners();
      return updated;
    } catch (e) {
      _errorMessage = 'Vote failed: $e';
      notifyListeners();
      return null;
    }
  }

  /// Check user's current vote on a tip
  Future<VoteValue?> getMyVote(String tipId) async {
    final user = currentUser;
    if (user == null) return null;
    return _repository.myVote(tipId: tipId, userId: user.uid);
  }

  /// User action: publish a new tip via the repository
  Future<Tip?> publishTip(NewTip newTip) async {
    final user = currentUser;
    if (user == null) {
      _errorMessage = 'Must be signed in to publish advice.';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final created = await _repository.addTip(newTip, userId: user.uid);
      _rawTips.insert(0, created);
      notifyListeners();
      return created;
    } catch (e) {
      _errorMessage = 'Publishing failed: $e';
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// User action: sign in with TUL email
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signIn(email: email, password: password);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// User action: sign out
  Future<void> signOut() async {
    await _authService.signOut();
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
