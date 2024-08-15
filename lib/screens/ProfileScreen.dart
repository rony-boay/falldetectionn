
import 'package:falldetectionn1/screens/AuthenticationScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _genderController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isEditing = false; // Track whether the user is in editing mode

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Color.fromARGB(255, 236, 235, 235), // Background color of the screen
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_isEditing)
                Column(
                  children: [
                    TextField(
                      controller: _firstNameController,
                      decoration: InputDecoration(labelText: 'First Name'),
                    ),
                    TextField(
                      controller: _lastNameController,
                      decoration: InputDecoration(labelText: 'Last Name'),
                    ),
                    TextField(
                      controller: _contactNumberController,
                      decoration: InputDecoration(labelText: 'Contact Number'),
                    ),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      controller: _genderController,
                      decoration: InputDecoration(labelText: 'Gender'),
                    ),
                    TextField(
                      controller: _addressController,
                      decoration: InputDecoration(labelText: 'Address'),
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      child: Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(
                            255, 32, 106, 243), // Sky blue button color
                      ),
                    ),
                  ],
                )
              else
                Card(
                  elevation: 5,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('First Name: ${_firstNameController.text}'),
                        Text('Last Name: ${_lastNameController.text}'),
                        Text(
                            'Contact Number: ${_contactNumberController.text}'),
                        Text('Email: ${_emailController.text}'),
                        Text('Gender: ${_genderController.text}'),
                        Text('Address: ${_addressController.text}'),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _toggleEditMode,
                child: Text(
                  _isEditing ? 'Cancel' : 'Edit Profile',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(
                      255, 24, 100, 241), // Sky blue button color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveProfile() {
    // Save the profile information to Firebase or perform any other action
    setState(
      () {
        _isEditing = false;
      },
    );
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut(); // Sign out from Firebase
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AuthenticationScreen(),
      ), // Navigate to the login screen
    );
  }
}
