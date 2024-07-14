import 'package:quiz_learn_app_ai/auth_pages/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Mock classes
class MockAuth extends Mock implements FirebaseAuth {
  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      super.noSuchMethod(
        Invocation.method(#createUserWithEmailAndPassword, [], {#email: email, #password: password}),
        returnValue: Future.value(MockUserCredential()),
      ) as Future<UserCredential>;

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      super.noSuchMethod(
        Invocation.method(#signInWithEmailAndPassword, [], {#email: email, #password: password}),
        returnValue: Future.value(MockUserCredential()),
      ) as Future<UserCredential>;

  @override
  Future<void> signOut() =>
      super.noSuchMethod(
        Invocation.method(#signOut, []),
        returnValue: Future<void>.value(),
      ) as Future<void>;
}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}

void main() {
  final MockAuth mockFirebaseAuth = MockAuth();
  final Auth auth = Auth(auth: mockFirebaseAuth);
  final MockUserCredential mockUserCredential = MockUserCredential();
  final MockUser mockUser = MockUser();

  setUp(() {
    // Ensure the mockUserCredential returns a mockUser
    when(mockUserCredential.user).thenReturn(mockUser);
  });

  tearDown(() {});

  test('create account', () async {
    when(mockFirebaseAuth.createUserWithEmailAndPassword(
      email: "michał12@mail.com", 
      password: "123456789"
    )).thenAnswer((_) async => mockUserCredential);

    expect(await auth.createAccount(email: "michał12@mail.com", password: "123456789"), "Success");
  });

  test("create account error", () async {
    when(mockFirebaseAuth.createUserWithEmailAndPassword(
      email: "michał12@mail.com", 
      password: "123456789"
    )).thenThrow(FirebaseAuthException(
      message: "Something went wrong", 
      code: "500"
    ));

    expect(await auth.createAccount(email: "michał12@mail.com", password: "123456789"), "Something went wrong");
  });

  test('login user', () async {
    when(mockFirebaseAuth.signInWithEmailAndPassword(
      email: "tomek@mail.com", 
      password: "123456789"
    )).thenAnswer((_) async => mockUserCredential);

    expect(await auth.login(email: "tomek@mail.com", password: "123456789"), "Success");
  });

  test('login user error', () async {
    when(mockFirebaseAuth.signInWithEmailAndPassword(
      email: "tomek@mail.com", 
      password: "123456789"
    )).thenThrow(FirebaseAuthException(
      message: "Something went wrong", 
      code: "500"
    ));

    expect(await auth.login(email: "tomek@mail.com", password: "123456789"), "Something went wrong");
  });

  test('logout', () async {
    when(mockFirebaseAuth.signOut()).thenAnswer((_) async => Future.value(null));

    expect(await auth.signOut(), "Success");
  });
}
