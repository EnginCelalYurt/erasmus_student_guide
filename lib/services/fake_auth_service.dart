class UserProfile {
  final String id;
  final String name;
  final String email;
  final String university;
  final bool isVerifiedStudent;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.university,
    this.isVerifiedStudent = true,
  });
}

abstract class AuthService {
  UserProfile? get currentUser;
  bool get isAuthenticated;
  Future<void> signIn({required String email, required String password});
  Future<void> signOut();
}

class FakeAuthService implements AuthService {
  UserProfile? _user = const UserProfile(
    id: 'usr_yusuf',
    name: 'Yusuf Taskin',
    email: 'yusuf.taskin@edu.p.lodz.pl',
    university: 'Politechnika Łódzka',
    isVerifiedStudent: true,
  );

  @override
  UserProfile? get currentUser => _user;

  @override
  bool get isAuthenticated => _user != null;

  @override
  Future<void> signIn({required String email, required String password}) async {
    _user = UserProfile(
      id: 'usr_${email.split('@').first}',
      name: email.split('@').first,
      email: email,
      university: 'Politechnika Łódzka',
      isVerifiedStudent: email.endsWith('.edu.pl') || email.endsWith('.lodz.pl'),
    );
  }

  @override
  Future<void> signOut() async {
    _user = null;
  }
}
