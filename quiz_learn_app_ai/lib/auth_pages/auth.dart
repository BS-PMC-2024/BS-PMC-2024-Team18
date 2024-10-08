import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth? auth;

  Auth({this.auth});

  Stream<User?> get user => auth!.authStateChanges();

  Future<String> createAccount({String? email, String? password}) async {
    try {
      await auth!.createUserWithEmailAndPassword(email: email!.trim(), password: password!.trim());
      return "Success";
    } on FirebaseAuthException catch (e) {
      return e.message!;
    } catch (error) {
      return "Something went wrong. Try again.";
    }
  }

  Future<String> login({String? email, String? password}) async {
    try {
      await auth!.signInWithEmailAndPassword(email: email!.trim(), password: password!.trim());
      return "Success";
    } on FirebaseAuthException catch (e) {
      return e.message!;
    } catch (error) {
      return "Something went wrong. Try again.";
    }
  }

  Future<String> signOut() async {
    try {
      await auth!.signOut();
      return "Success";
    } on FirebaseAuthException catch (e) {
      return e.message!;
    } catch (error) {
      return "Something went wrong. Try again.";
    }
  }
}