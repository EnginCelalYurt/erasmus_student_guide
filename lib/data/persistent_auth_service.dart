import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_service.dart';

/// Persistent local authentication service for Week 6.
/// Automatically restores user login state after application restarts.
class PersistentAuthService implements AuthService {
  static const _authEmailKey = 'erasmus_guide_auth_email_v2';

  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _user;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString(_authEmailKey);
    if (savedEmail != null && isTulEmail(savedEmail)) {
      _user = AppUser(
        uid: savedEmail.trim().toLowerCase(),
        email: savedEmail.trim(),
        displayName: savedEmail.split('@').first,
      );
      _controller.add(_user);
    }
    _isInitialized = true;
  }

  @override
  AppUser? get currentUser => _user;

  @override
  Stream<AppUser?> get authStateChanges => _controller.stream;

  @override
  Future<void> signIn({required String email, required String password}) async {
    await init();
    if (!isTulEmail(email)) {
      throw const AuthException('Use your TUL e-mail address (@p.lodz.pl).');
    }

    final trimmedEmail = email.trim();
    _user = AppUser(
      uid: trimmedEmail.toLowerCase(),
      email: trimmedEmail,
      displayName: trimmedEmail.split('@').first,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authEmailKey, trimmedEmail);

    _controller.add(_user);
  }

  @override
  Future<void> signOut() async {
    await init();
    _user = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authEmailKey);

    _controller.add(null);
  }
}
