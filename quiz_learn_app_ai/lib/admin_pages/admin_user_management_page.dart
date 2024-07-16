import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class AdminUserManagementPage extends StatefulWidget {
  const AdminUserManagementPage({super.key});

  @override
  AdminUserManagementPageState createState() => AdminUserManagementPageState();
}

class AdminUserManagementPageState extends State<AdminUserManagementPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<UserData> _users = [];
  bool _isLoading = true;
  final FirebaseService _firebaseService = FirebaseService();
  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

 Future<void> _loadUsers() async {
  setState(() {
    _isLoading = true;
  });

  try {
    _users = await _firebaseService.loadUsers();
  } catch (e) {
    if (kDebugMode) {
      print('Error loading users: $e');
    }
    // You might want to show a snackbar or some other error indication to the user here
  } finally {
    setState(() {
      _isLoading = false;
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
            colors: [Colors.indigo[900]!, Colors.indigo[600]!],
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
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildUserList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateUserDialog,
        backgroundColor: Colors.indigo[600],
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Text(
            'User Management',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadUsers,
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            leading: CircleAvatar(
              backgroundColor: Colors.indigo[100],
              child: Text(
                user.email[0].toUpperCase(),
                style: TextStyle(color: Colors.indigo[800], fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              user.email,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'User Type: ${user.userType.capitalize()}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.indigo[400]),
                  onPressed: () => _showEditUserDialog(user),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red[400]),
                  onPressed: () => _showDeleteConfirmation(user),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCreateUserDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final List<String> validUserTypes = ['student', 'lecturer', 'admin'];
    String selectedUserType = 'student';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedUserType,
                  onChanged: (String? newValue) {
                    selectedUserType = newValue!;
                  },
                  items: validUserTypes
                    .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value.capitalize()),
                      );
                    }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'User Type',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              onPressed: () async {
                // Implement user creation logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[600],
              ),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _showEditUserDialog(UserData user) {
  final emailController = TextEditingController(text: user.email);
  
  // Define the list of valid user types
  final List<String> validUserTypes = ['student', 'lecturer', 'admin'];
  
  // Ensure the user's type is one of the valid types, defaulting to 'student' if not
  String selectedUserType = validUserTypes.contains(user.userType.toLowerCase()) 
      ? user.userType.toLowerCase() 
      : 'student';

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Edit User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                enabled: false, // Email can't be changed easily in Firebase Auth
              ),
              DropdownButtonFormField<String>(
                value: selectedUserType,
                onChanged: (String? newValue) {
                  selectedUserType = newValue!;
                },
                items: validUserTypes
                  .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value.capitalize()),
                    );
                  }).toList(),
                decoration: const InputDecoration(labelText: 'User Type'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Save'),
            onPressed: () async {
              try {
                await _database.child('users').child(user.id).update({
                  'userType': selectedUserType,
                });
                if(context.mounted) {
                  Navigator.of(context).pop();
                }
            
                _loadUsers();
              } catch (e) {
                if (kDebugMode) {
                  print('Error updating user: $e');
                }
                if(context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating user: $e')),
                  );
                }
              }
            },
          ),
        ],
      );
    },
  );
}


void _showDeleteConfirmation(UserData user) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.email}?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () async {
              try {
                // Delete from Realtime Database
                await _database.child('users').child(user.id).remove();
                
                // Delete from Firebase Authentication
                // Note: This requires the user to have recently signed in
                User? currentUser = _auth.currentUser;
                if (currentUser != null && currentUser.uid == user.id) {
                  await currentUser.delete();
                } else {
                  // If we're not deleting the current user, we can't delete from Auth
                  // You would typically handle this through a server-side function
                  if (kDebugMode) {
                    print('Cannot delete user from Auth: not the current user');
                  }
                }
                
                if(context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User deleted successfully')),
                  );
                }
               
                _loadUsers();
              } catch (e) {
                if (kDebugMode) {
                  print('Error deleting user: $e');
                }
                if(context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting user: $e')),
                  );
                }
              }
            },
          ),
        ],
      );
    },
  );
}

}

class UserData {
  final String id;
  final String email;
  final String userType;

  UserData({required this.id, required this.email, required this.userType});
}
