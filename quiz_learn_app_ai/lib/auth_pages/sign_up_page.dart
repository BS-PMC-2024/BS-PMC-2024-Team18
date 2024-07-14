import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:quiz_learn_app_ai/admin_pages/admin_home_page.dart';
import 'package:quiz_learn_app_ai/lecturer_pages/lecturer_home_page.dart';
import 'package:quiz_learn_app_ai/student_pages/student_home_page.dart';
class SignUpPage extends StatefulWidget {
  final Function toggleView;

  const SignUpPage({super.key, required this.toggleView});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
    final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
   final TextEditingController adminPasswordController = TextEditingController();
  String selectedUserType = 'Student';
  bool isAdminPasswordCorrect = false;
  bool isAdminSelected = false;


Future<void> signUpWithEmailPassword() async {
  try {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    );

    // Add user data to Realtime Database
    await _database.child('users').child(userCredential.user!.uid).set({
      'email': emailController.text,
      'userType': selectedUserType,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User created successfully')),
      );
      
      // Navigate to the appropriate home page
      if (selectedUserType == 'Admin') {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AdminHomePage()));
      } else if (selectedUserType == 'Student') {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const StudentHomePage()));
      } else if (selectedUserType == 'Lecturer') {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LecturerHomePage()));
      }
    }
  } catch (e) {
        if(mounted){
           ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An unexpected error occurred: $e')),
    );
        }
    if (kDebugMode) {
      print('Unexpected error: $e');
    }
   
  }
}


void checkAdminPassword() {
    if (adminPasswordController.text == "gilIsLove") {
      setState(() {
        isAdminPasswordCorrect = true;
        selectedUserType = 'Admin';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin password correct. Admin type selected.')),
      );
    } else {
      setState(() {
        isAdminPasswordCorrect = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect admin password.')),
      );
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
                'Join the Learning Revolution',
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
              const SizedBox(height: 16.0),
              _buildDropdown(),
              if (isAdminSelected && !isAdminPasswordCorrect) ...[
                const SizedBox(height: 16.0),
                _buildAdminPasswordField(),
              ],
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () async {
                  String email = emailController.text.trim();
                  String password = passwordController.text.trim();
                  FocusScope.of(context).unfocus();
                  if (email.isEmpty || password.isEmpty) {
                    _showErrorSnackBar('Please enter both email and password.');
                  } else if (!isValidEmail(email)) {
                    _showErrorSnackBar('Please enter a valid email address.');
                  } else if (password.length < 6) {
                    _showErrorSnackBar('Password must be at least 6 characters.');
                  } else {
                    await signUpWithEmailPassword();
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
                  'Sign Up',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?', style: TextStyle(color: Colors.white70)),
                  TextButton(
                    onPressed: () => widget.toggleView(),
                    child: const Text('Sign In', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      ),
    ),
  );
}

Widget _buildDropdown() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(30.0),
    ),
    child: DropdownButton<String>(
      value: selectedUserType,
      dropdownColor: Colors.blue[700],
      style: const TextStyle(color: Colors.white),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
      isExpanded: true,
      underline: const SizedBox(),
      items: <String>['Student', 'Lecturer', 'Admin']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            if (newValue == 'Admin') {
              isAdminSelected = true;
              selectedUserType = isAdminPasswordCorrect ? 'Admin' : 'Student';
            } else {
              isAdminSelected = false;
              selectedUserType = newValue;
            }
          });
        }
      },
    ),
  );
}

Widget _buildAdminPasswordField() {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(30.0),
    ),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: adminPasswordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Admin Password',
              labelStyle: TextStyle(color: Colors.white70),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
            ),
          ),
        ),
        TextButton(
          onPressed: checkAdminPassword,
          child: const Text('Check', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

void _showErrorSnackBar(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ),
  );
}

}