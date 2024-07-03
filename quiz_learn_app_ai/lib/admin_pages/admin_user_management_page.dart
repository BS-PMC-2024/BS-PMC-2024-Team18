import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

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
      // Get user types from Realtime Database
      DataSnapshot snapshot = await _database.child('users').get();
      Map<dynamic, dynamic>? userTypes = snapshot.value as Map<dynamic, dynamic>?;

      if (userTypes != null) {
        _users = userTypes.entries.map((entry) {
          return UserData(
            id: entry.key,
            email: entry.value['email'] ?? 'No email',
            userType: entry.value['userType'] ?? 'Unknown',
          );
        }).toList();
      } else {
        _users = [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading users: $e');
      }
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
            colors: [Colors.blue[800]!, Colors.blue[400]!],
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
          child: ListTile(
            title: Text(user.email),
            subtitle: Text('User Type: ${user.userType}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditUserDialog(user),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
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
  String selectedUserType = 'student'; // Default value

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
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
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
            child: const Text('Create'),
            onPressed: () async {
              try {
                UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
                  email: emailController.text,
                  password: passwordController.text,
                );

                await _database.child('users').child(userCredential.user!.uid).set({
                  'email': emailController.text,
                  'userType': selectedUserType,
                });

                if(context.mounted) {
                  Navigator.of(context).pop();
                }
            
                _loadUsers();
              } catch (e) {
                if (kDebugMode) {
                  print('Error creating user: $e');
                }
                if(context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error creating user: $e')),
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
