import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  StudentProfilePageState createState() => StudentProfilePageState();
}

class StudentProfilePageState extends State<StudentProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance.ref();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _majorController = TextEditingController();
  final _yearOfStudyController = TextEditingController();
  final _bioController = TextEditingController();
  


  List<String> _courses = [];
  final _newCourseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

Future<void> _loadUserData() async {
  final user = _auth.currentUser;
  if (user != null) {
    try {
      final snapshot = await _database.child('students').child(user.uid).get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _nameController.text = data['name']?.toString() ?? '';
          _emailController.text = data['email']?.toString() ?? '';
          _phoneController.text = data['phone']?.toString() ?? '';
          _majorController.text = data['major']?.toString() ?? '';
          _yearOfStudyController.text = data['yearOfStudy']?.toString() ?? '';
          _bioController.text = data['bio']?.toString() ?? '';
          _courses = List<String>.from(data['courses'] ?? []);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user data: ${e.toString()}')),
        );
      }
    }
  }
}

  Future<void> _saveProfile() async {
  if (_formKey.currentState!.validate()) {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        // First, get the current data
        final snapshot = await _database.child('students').child(user.uid).get();
        Map<String, dynamic> currentData = {};
        if (snapshot.exists) {
          currentData = Map<String, dynamic>.from(snapshot.value as Map);
        }

        // Update only the fields managed in this profile page
        currentData.addAll({
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'major': _majorController.text,
          'yearOfStudy': _yearOfStudyController.text,
          'bio': _bioController.text,
          'courses': _courses,
        });

        // Save the updated data
        await _database.child('students').child(user.uid).update(currentData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile saved successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving profile: ${e.toString()}')),
          );
        }
      }
    }
  }
}
  void _addCourse() {
    if (_newCourseController.text.isNotEmpty) {
      setState(() {
        _courses.add(_newCourseController.text);
        _newCourseController.clear();
      });
    }
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[800]!, Colors.blue[400]!],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Student Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputField(
                          controller: _nameController,
                          label: 'Full Name',
                          icon: Icons.person,
                          validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email,
                          validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          icon: Icons.phone,
                          validator: (value) => value!.isEmpty ? 'Please enter your phone number' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          controller: _majorController,
                          label: 'Major',
                          icon: Icons.school,
                          validator: (value) => value!.isEmpty ? 'Please enter your Major' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          controller: _yearOfStudyController,
                          label: 'Years of Study',
                          icon: Icons.calendar_today,
                          validator: (value) => value!.isEmpty ? 'Please enter your years of study' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          controller: _bioController,
                          label: 'Bio',
                          icon: Icons.description,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24),
                        Text('Courses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[800])),
                        const SizedBox(height: 8),
                        ..._courses.map((course) => _buildCourseItem(course)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                controller: _newCourseController,
                                label: 'Add New Course',
                                icon: Icons.add_circle_outline,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add, color: Colors.blue[800]),
                              onPressed: _addCourse,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue[800],
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text('Save Profile', style: TextStyle(fontSize: 18)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildInputField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  String? Function(String?)? validator,
  int maxLines = 1,
}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blue[800]),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.blue[800]!, width: 2),
      ),
    ),
    validator: validator,
    maxLines: maxLines,
  );
}

Widget _buildCourseItem(String course) {
  return Card(
    margin: const EdgeInsets.only(bottom: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: ListTile(
      title: Text(course),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () {
          setState(() {
            _courses.remove(course);
          });
        },
      ),
    ),
  );
}

@override
void dispose() {
  _nameController.dispose();
  _emailController.dispose();
  _phoneController.dispose();
  _majorController.dispose();
  _yearOfStudyController.dispose();
  _bioController.dispose();
  _newCourseController.dispose();
  super.dispose();
}
}