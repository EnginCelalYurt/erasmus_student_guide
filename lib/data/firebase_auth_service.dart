import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service.dart';

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  AppUser? _toAppUser(User? user) {
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
    );
  }

  @override
  AppUser? get currentUser => _toAppUser(_auth.currentUser);

  @override
  Stream<AppUser?> get authStateChanges =>
      _auth.authStateChanges().map(_toAppUser);

  @override
  Future<void> signIn({required String email, required String password}) async {
    _checkEmail(email);
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e.code));
    }
  }

  @override
  Future<void> register({
    required String email,
    required String password,
  }) async {
    _checkEmail(email);
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e.code));
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  void _checkEmail(String email) {
    if (!isTulEmail(email)) {
      throw const AuthException('Use your TUL e-mail address.');
    }
  }

  String _messageFor(String code) {
    switch (code) {
      case 'invalid-email':
        return 'This e-mail address is not valid.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Wrong e-mail or password.';
      case 'email-already-in-use':
        return 'An account with this e-mail already exists.';
      case 'weak-password':
        return 'Password is too weak (use at least 6 characters).';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return 'Sign-in failed. Please try again.';
    }
  }
}