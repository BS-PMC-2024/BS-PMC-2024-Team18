// This is a Flutter widget test for the isValidEmail function.

import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_learn_app_ai/auth_pages/sign_in_page.dart';


void main() {
  test('Test isValidEmail function', () {
    // Test valid emails
    expect(SignInPage.isValidEmail('test@example.com'), true);
    expect(SignInPage.isValidEmail('user123@mail.co.uk'), true);
    expect(SignInPage.isValidEmail('firstname.lastname@email.org'), true);

    // Test invalid emails
    expect(SignInPage.isValidEmail('invalid-email'), false);
    expect(SignInPage.isValidEmail('user@domain'), false);
    expect(SignInPage.isValidEmail('email@com.'), false);
    expect(SignInPage.isValidEmail('123@456.789'), false);
  });
}
