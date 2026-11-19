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

  Future<void> signOut();
}

// Aldiyar: confirm the real student domain; subdomains of p.lodz.pl are accepted.
bool isTulEmail(String email) {
  final parts = email.trim().toLowerCase().split('@');
  if (parts.length != 2 || parts[0].isEmpty) return false;
  final domain = parts[1];
  return domain == 'p.lodz.pl' || domain.endsWith('.p.lodz.pl');
}
