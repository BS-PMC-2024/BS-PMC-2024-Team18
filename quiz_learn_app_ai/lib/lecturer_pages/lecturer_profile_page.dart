import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class LecturerProfilePage extends StatefulWidget {
  const LecturerProfilePage({super.key});

  @override
  LecturerProfilePageState createState() => LecturerProfilePageState();
}

class LecturerProfilePageState extends State<LecturerProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance.ref();

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
  final user = _auth.currentUser;
  if (user != null) {
    try {
      final snapshot = await _database.child('lecturers').child(user.uid).get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _nameController.text = data['name']?.toString() ?? '';
          _emailController.text = data['email']?.toString() ?? '';
          _phoneController.text = data['phone']?.toString() ?? '';
          _workplaceController.text = data['workplace']?.toString() ?? '';
          _qualificationsController.text = data['qualifications']?.toString() ?? '';
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
        final snapshot = await _database.child('lecturers').child(user.uid).get();
        Map<String, dynamic> currentData = {};
        if (snapshot.exists) {
          currentData = Map<String, dynamic>.from(snapshot.value as Map);
        }

        // Update only the fields managed in this profile page
        currentData.addAll({
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'workplace': _workplaceController.text,
          'qualifications': _qualificationsController.text,
          'bio': _bioController.text,
          'courses': _courses,
        });

        // Save the updated data
        await _database.child('lecturers').child(user.uid).update(currentData);

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
      appBar: AppBar(
        title: const Text('Lecturer Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (value) => value!.isEmpty ? 'Please enter your phone number' : null,
              ),
              TextFormField(
                controller: _workplaceController,
                decoration: const InputDecoration(labelText: 'Workplace'),
                validator: (value) => value!.isEmpty ? 'Please enter your workplace' : null,
              ),
              TextFormField(
                controller: _qualificationsController,
                decoration: const InputDecoration(labelText: 'Qualifications'),
                validator: (value) => value!.isEmpty ? 'Please enter your qualifications' : null,
              ),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: 'Bio'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              const Text('Courses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _courses.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_courses[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _courses.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _newCourseController,
                      decoration: const InputDecoration(labelText: 'Add New Course'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addCourse,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
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