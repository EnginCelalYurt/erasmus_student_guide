class AppUser {
  const AppUser({required this.uid, required this.email, this.displayName});

  final String uid;
  final String email;
  final String? displayName;
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract class AuthService {
  AppUser? get currentUser;

  Stream<AppUser?> get authStateChanges;

  Future<void> signIn({required String email, required String password});
      Future<void> register({required String email, required String password});

  Future<void> signOut();
}

// Student addresses look like 123456@edu.p.lodz.pl (staff use p.lodz.pl).
bool isTulEmail(String email) {
  final parts = email.trim().toLowerCase().split('@');
  if (parts.length != 2 || parts[0].isEmpty) return false;
  return parts[1] == 'edu.p.lodz.pl';
}
