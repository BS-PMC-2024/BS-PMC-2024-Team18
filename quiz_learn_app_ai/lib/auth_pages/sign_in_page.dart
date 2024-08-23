import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Import GoogleSignIn package
import 'package:quiz_learn_app_ai/admin_pages/admin_home_page.dart';
import 'package:quiz_learn_app_ai/lecturer_pages/lecturer_home_page.dart';
import 'package:quiz_learn_app_ai/student_pages/student_home_page.dart';
import 'package:quiz_learn_app_ai/auth_pages/auth.dart';


class SignInPage extends StatefulWidget {
  final Function toggleView;

  const SignInPage({super.key, required this.toggleView});

  @override
  State<SignInPage> createState() => _SignInPageState();

   static bool isValidEmail(String email) {
    // Define a regular expression for a valid email
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');

    // Check if the provided email matches the regular expression
    return emailRegex.hasMatch(email);
  }

}

class _SignInPageState extends State<SignInPage> {
  final Auth auth = Auth(auth: FirebaseAuth.instance);
      final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  int _maxLoginAttempts = 5;
Duration _lockoutDuration = const Duration(minutes: 30);
int _loginAttempts = 0;
bool _isLocked = false;
DateTime? _lockoutTime;

Future<void> _loadAdminSettings() async {
  try {
    DatabaseEvent event = await _database.child('adminSettings').once();
    Map? settings = event.snapshot.value as Map?;
    if (settings != null) {
      setState(() {
        _maxLoginAttempts = settings['maxLoginAttempts'] ?? 5;
        _lockoutDuration = Duration(minutes: settings['lockoutDurationMinutes'] ?? 30);
      });
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error loading admin settings: $e');
    }
  }
}
@override
void initState() {
  super.initState();
  _loadAdminSettings();
}
// Updated sign-in method to include user type navigation and error handling
Future<void> signInWithEmailAndPassword() async {
    if (_isLocked) {
    if (DateTime.now().isAfter(_lockoutTime!)) {
      setState(() {
        _isLocked = false;
        _loginAttempts = 0;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account is locked. Please try again later.')),
      );
      return;
    }
  }
  try {
    // Attempt to log in using provided email and password
    String result = await auth.login(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    // Check if login was successful
    if (result == "Success") {
      User? user = auth.auth!.currentUser;

      if (user != null) {
        // Fetch user type from the database
        DatabaseEvent event = await _database.child('users').child(user.uid).once();
        Map<dynamic, dynamic>? userData = event.snapshot.value as Map?;
        String? userType = userData?['userType'];

        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signed in successfully')),
          );

          // Navigate to the appropriate home page based on user type
          if (userType == 'Admin') {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AdminHomePage()));
          } else if (userType == 'Student') {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const StudentHomePage()));
          } else if (userType == 'Lecturer') {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LecturerHomePage()));
          } 
        }
      }
    } else {
      // Show error message if login failed
      if (mounted) {
          _loginAttempts++;
  if (_loginAttempts >= _maxLoginAttempts) {
    setState(() {
      _isLocked = true;
      _lockoutTime = DateTime.now().add(_lockoutDuration);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Too many failed attempts. Account locked for ${_lockoutDuration.inMinutes} minutes.')),
    );
  }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $result')),
        );
      }
    }
  } catch (e) {
    // Handle and display any errors that occurred during the sign-in process
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}
Future<String?> showUserTypeSelectionDialog() async {
  String? selectedUserType;
  final adminPasswordController = TextEditingController();

  await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Choose User Type'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.school),
                  title: const Text('Student'),
                  onTap: () {
                    selectedUserType = 'Student';
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.assignment),
                  title: const Text('Lecturer'),
                  onTap: () {
                    selectedUserType = 'Lecturer';
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings),
                  title: const Text('Admin'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Enter Admin Password'),
                          content: TextField(
                            controller: adminPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(hintText: "Enter password"),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('Submit'),
                              onPressed: () {
                                if (adminPasswordController.text == "gilIsLove") {
                                  selectedUserType = 'Admin';
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Incorrect admin password.')),
                                  );
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );

  return selectedUserType;
}


Future<void> signInWithGoogle() async {
  try {
    await GoogleSignIn().signOut();

    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential = await _auth.signInWithCredential(credential);

    // Check if user exists in database
    DatabaseEvent event = await _database.child('users').child(userCredential.user!.uid).once();
    Map<dynamic, dynamic>? userData = event.snapshot.value as Map?;

    String? userType;
    if (userData == null) {
      // New user, show dialog to choose user type
      userType = await showUserTypeSelectionDialog();

      if (userType != null) {
        // Save user type to database
        await _database.child('users').child(userCredential.user!.uid).set({
          'userType': userType,
          'email': userCredential.user!.email,
        });
      } else {
        // User cancelled the dialog
        throw Exception('User type selection cancelled');
      }
    } else {
      // Existing user, fetch user type
      userType = userData['userType'] as String?;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed in successfully with Google')),
      );

      // Navigate to the appropriate home page
      switch (userType) {
        case 'Admin':
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AdminHomePage()));
          break;
        case 'Student':
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const StudentHomePage()));
          break;
        case 'Lecturer':
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LecturerHomePage()));
          break;
        default:
          throw Exception('Invalid user type');
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


  Future<void> sendPasswordResetEmail(String email, BuildContext context) async {
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
                      if (emailController.text.isNotEmpty && SignInPage.isValidEmail(emailController.text.trim())) {
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
                const SizedBox(height:8.0),
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
                ElevatedButton.icon(
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    await signInWithGoogle();
                  },
                  icon: const Icon(Icons.login),
                  label: const Text(
                    'Sign in with Google',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red[700],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    minimumSize: const Size(double.infinity, 50.0),
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
