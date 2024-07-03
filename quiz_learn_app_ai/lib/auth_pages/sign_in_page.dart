import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_learn_app_ai/admin_pages/admin_home_page.dart';
import 'package:quiz_learn_app_ai/lecturer_pages/lecturer_home_page.dart';
import 'package:quiz_learn_app_ai/student_pages/student_home_page.dart';

class SignInPage extends StatefulWidget {
  final Function toggleView;

  const SignInPage({super.key, required this.toggleView});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

    final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;

Future<void> signInWithEmailAndPassword() async {
  try {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
    
    // Fetch user type from database
    DatabaseEvent event = await _database.child('users').child(userCredential.user!.uid).once();
    Map<dynamic, dynamic>? userData = event.snapshot.value as Map?;
    String? userType = userData?['userType'];

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed in successfully')),
      );
      
      // Navigate to the appropriate home page
      if (userType == 'Admin') {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AdminHomePage()));
      } else if (userType == 'Student') {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const StudentHomePage()));
      } else if (userType == 'Lecturer') {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LecturerHomePage()));
      }
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}


  Future<void> sendPasswordResetEmail(
      String email, BuildContext context) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // Show a message to the user that the password reset email has been sent
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset email has been sent to $email.'),
          ),
        );
      }
    } catch (e) {
      // Handle errors, e.g., email not found
      // ignore: avoid_print
      print(e.toString());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    }
  }


    bool isValidEmail(String email) {
    // Define a regular expression for a valid email
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');

    // Check if the provided email matches the regular expression
    return emailRegex.hasMatch(email);
  }

  
@override
Widget build(BuildContext context) {
  return Scaffold(
    resizeToAvoidBottomInset: false,
    body: Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[800]!, Colors.blue[400]!],
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80.0),
              Text(
                'CampusQuest AI',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10.0),
              const Text(
                'Elevate Your Learning Journey',
                style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 50.0),
              _buildInputField(
                controller: emailController,
                label: 'Email',
                icon: Icons.email,
              ),
              const SizedBox(height: 16.0),
              _buildInputField(
                controller: passwordController,
                label: 'Password',
                icon: Icons.lock,
                isPassword: true,
              ),
              const SizedBox(height: 5.0),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    if (emailController.text.isNotEmpty && isValidEmail(emailController.text.trim())) {
                      sendPasswordResetEmail(emailController.text.trim(), context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Enter A Valid Email")),
                      );
                    }
                  },
                  child: const Text('Forgot Password?', style: TextStyle(color: Colors.white70)),
                ),
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  if (emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter both email and password.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    await signInWithEmailAndPassword();
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue[800],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  minimumSize: const Size(double.infinity, 50.0),
                ),
                child: const Text(
                  'Log in',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don\'t have an account?', style: TextStyle(color: Colors.white70)),
                  TextButton(
                    onPressed: () => widget.toggleView(),
                    child: const Text('Sign Up', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildInputField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  bool isPassword = false,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(30.0),
    ),
    child: TextField(
      controller: controller,
      obscureText: isPassword ? !isPasswordVisible : false,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white70,
                ),
                onPressed: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
              )
            : null,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      ),
    ),
  );
}

}