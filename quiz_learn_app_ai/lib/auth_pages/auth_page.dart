import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../admin_pages/admin_home_page.dart';
import '../lecturer_pages/lecturer_home_page.dart';
import '../student_pages/student_home_page.dart';
import 'sign_in_page.dart';
import 'sign_up_page.dart';
import 'loading_page.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isSignIn = true;
  bool _isLoading = true;
  StreamSubscription<User?>? _authStateSubscription;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  void _checkCurrentUser() {
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        if (user != null) {
          _navigateToHomePage(user);
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  void _toggleView() {
    if (mounted) {
      setState(() {
        _isSignIn = !_isSignIn;
      });
    }
  }

  Future<void> _navigateToHomePage(User user) async {
    if (!mounted) return;

    final DatabaseReference database = FirebaseDatabase.instance.ref();
    try {
      DatabaseEvent event = await database.child('users').child(user.uid).once();
      Map<dynamic, dynamic>? userData = event.snapshot.value as Map?;
      String? userType = userData?['userType'];

      if (mounted) {
        if (userType == 'Admin') {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AdminHomePage()));
        } else if (userType == 'Student') {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const StudentHomePage()));
        } else if (userType == 'Lecturer') {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LecturerHomePage()));
        } else {
      
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingPage();
    } else if (_isSignIn) {
      return SignInPage(toggleView: _toggleView);
    } else {
      return SignUpPage(toggleView: _toggleView);
    }
  }
}
