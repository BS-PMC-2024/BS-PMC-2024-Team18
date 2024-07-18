import 'package:flutter/material.dart';

import 'package:quiz_learn_app_ai/services/firebase_service.dart';

class LecturerProfilePage extends StatefulWidget {
  const LecturerProfilePage({super.key});

  @override
  LecturerProfilePageState createState() => LecturerProfilePageState();
}

class LecturerProfilePageState extends State<LecturerProfilePage> {
  final _formKey = GlobalKey<FormState>();

   final FirebaseService _firebaseService = FirebaseService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _workplaceController = TextEditingController();
  final _qualificationsController = TextEditingController();
  final _bioController = TextEditingController();

  List<String> _courses = [];
  final _newCourseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

Future<void> _loadUserData() async {
    try {
      final userData = await _firebaseService.loadUserData_2();
      setState(() {
        _nameController.text = userData['name'];
        _emailController.text = userData['email'];
        _phoneController.text = userData['phone'];
        _workplaceController.text = userData['workplace'];
        _qualificationsController.text = userData['qualifications'];
        _bioController.text = userData['bio'];
        _courses = userData['courses'];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user data: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _firebaseService.saveProfile({
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'workplace': _workplaceController.text,
          'qualifications': _qualificationsController.text,
          'bio': _bioController.text,
          'courses': _courses,
        });

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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFeb8671), // #eb8671
          Color(0xFFea7059), // #ea7059
          Color(0xFFef7d5d), // #ef7d5d
          Color(0xFFf8a567), // #f8a567
          Color(0xFFfecc63), // #fecc63
          Color(0xFFa7c484), // #a7c484
          Color(0xFF5b9f8d), // #5b9f8d
          Color(0xFF257b8c), // #257b8c
          Color(0xFFad3d75), // #ad3d75
          Color(0xFF1fd1d5), // #1fd1d5
          Color(0xFF2e7cbc), // #2e7cbc
          Color(0xFF3d5488), // #3d5488
          Color(0xFF99497f), // #99497f
          Color(0xFF23b7c1), // #23b7c1
        ],
      ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
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
                          _buildProfileHeader(),
                          const SizedBox(height: 24),
                          _buildInputFields(),
                          const SizedBox(height: 24),
                          _buildCoursesSection(),
                          const SizedBox(height: 24),
                          _buildSaveButton(),
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

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          const Text(
            'Lecturer Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue[100],
            child: Icon(Icons.person, size: 60, color: Colors.blue[800]),
          ),
          const SizedBox(height: 16),
          Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputFields() {
    return Column(
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
          controller: _workplaceController,
          label: 'Workplace',
          icon: Icons.work,
          validator: (value) => value!.isEmpty ? 'Please enter your workplace' : null,
        ),
        const SizedBox(height: 16),
        _buildInputField(
          controller: _qualificationsController,
          label: 'Qualifications',
          icon: Icons.school,
          validator: (value) => value!.isEmpty ? 'Please enter your qualifications' : null,
        ),
        const SizedBox(height: 16),
        _buildInputField(
          controller: _bioController,
          label: 'Bio',
          icon: Icons.description,
          maxLines: 3,
        ),
      ],
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.blue[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.blue[800]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.blue[50],
      ),
      validator: validator,
      maxLines: maxLines,
    );
  }

  Widget _buildCoursesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Courses',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[800]),
        ),
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
      ],
    );
  }

  Widget _buildCourseItem(String course) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: ListTile(
        leading: Icon(Icons.book, color: Colors.blue[800]),
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

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveProfile,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue[800],
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        minimumSize: const Size(double.infinity, 50),
      ),
      child: const Text('Save Profile', style: TextStyle(fontSize: 18)),
    );
  }


  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _workplaceController.dispose();
    _qualificationsController.dispose();
    _bioController.dispose();
    _newCourseController.dispose();
    super.dispose();
  }
}