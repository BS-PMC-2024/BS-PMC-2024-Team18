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
        decoration: const BoxDecoration(
         color: Colors.white24
        ),
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 150,
              ),
              Container(
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                      30.0), // Adjust the radius as needed
                  border: Border.all(), // Add additional styling if needed
                ),
                child: TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    suffixIcon: Icon(
                      Icons.email,
                      color: Colors.black,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Container(
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                      30.0), // Adjust the radius as needed
                  border: Border.all(), // Add additional styling if needed
                ),
                child: TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                    suffixIcon: Icon(
                      Icons.password,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
             DropdownButton<String>(
                value: selectedUserType,
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
              if (isAdminSelected && !isAdminPasswordCorrect) ...[
                const SizedBox(height: 16.0),
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    border: Border.all(),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: adminPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Admin Password',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: checkAdminPassword,
                        child: const Text('Check'),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  String email = emailController.text.trim();
                  String password = passwordController.text.trim();
                  FocusScope.of(context).unfocus();
                  // Validate that email and password are not empty
                  if (email.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter both email and password.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else if (!isValidEmail(email)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid email address.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else if (password.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Password must be at least 6 characters.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    // Proceed with sign-up if fields are not empty and pass validation
                  await signUpWithEmailPassword();
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        30.0), // Adjust the value for curviness
                  ),
                  minimumSize: const Size(
                      double.infinity, 50.0), // Adjust the width and height
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
                  const Text(
                    'Already have an account?',
                    style: TextStyle(color: Colors.black),
                  ),
                  TextButton(
                             onPressed: () => widget.toggleView(),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}