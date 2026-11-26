import 'package:flutter_test/flutter_test.dart';

import 'package:erasmus_student_guide/data/auth_service.dart';
import 'package:erasmus_student_guide/data/fake_auth_service.dart';

void main() {
  test('resendVerification fails when signed out', () async {
    final auth = FakeAuthService();
    expect(auth.resendVerification(), throwsA(isA<AuthException>()));
  });

  test('resendVerification works for a signed-in user', () async {
    final auth = FakeAuthService();
    await auth.signIn(email: '123456@edu.p.lodz.pl', password: 'secret1');
    await auth.resendVerification();
    expect(auth.resendCount, 1);
  });
}