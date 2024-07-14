import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
 

 //flutter test test/sign_in_test_2.dart to run mock: flutter pub run build_runner build 
 //flutter test test/question_generator_test.dart
  //flutter test test/sign_up_page_test.dart
void main() {
  test('Mock Google Sign-In and Firebase Auth', () async {
    if (kDebugMode) {
      print("Test starting");
    }

    // Mock sign in with Google.
    final googleSignIn = MockGoogleSignIn();
    final signInAccount = await googleSignIn.signIn();
    final googleAuth = await signInAccount!.authentication;
    // ignore: unused_local_variable
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in.
    final user = MockUser(
      isAnonymous: false,
      uid: 'someuid',
      email: 'bob@somedomain.com',
      displayName: 'Bob',
    );
    final auth = MockFirebaseAuth(mockUser: user);
    final result = await auth.signInWithEmailAndPassword( email: "bob@somedomain.com", password: "123456");
    final user2 = result.user;

    expect(user2!.displayName, 'Bob'); // Example assertion

    if (kDebugMode) {
      print("Display Name: ${user2.displayName}");
    }
  });
}


