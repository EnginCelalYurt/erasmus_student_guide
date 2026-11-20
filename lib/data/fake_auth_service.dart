import 'dart:async';

import 'auth_service.dart';

class FakeAuthService implements AuthService {
  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _user;

  @override
  AppUser? get currentUser => _user;

  @override
  Stream<AppUser?> get authStateChanges => _controller.stream;

  @override
  Future<void> signIn({required String email, required String password}) async {
    if (!isTulEmail(email)) {
      throw const AuthException('Use your TUL e-mail address.');
    }
    _user = AppUser(uid: email.trim().toLowerCase(), email: email.trim());
    _controller.add(_user);
  }

  @override
  Future<void> register({
    required String email,
    required String password,
  }) {
    return signIn(email: email, password: password);
  }
  @override
  Future<void> signOut() async {
    _user = null;
    _controller.add(null);
  }
}
