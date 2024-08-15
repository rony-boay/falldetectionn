
import 'package:falldetectionn1/main.dart';
import 'package:falldetectionn1/screens/ButtonScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';



class AuthenticationScreen extends StatefulWidget {
  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          _isLogin ? 'Login' : 'Register',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          child: _isLogin
              ? LoginForm(onToggle: _toggle)
              : RegistrationForm(onToggle: _toggle),
        ),
      ),
    );
  }

  void _toggle() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }
}

class LoginForm extends StatefulWidget {
  final VoidCallback onToggle;

  LoginForm({required this.onToggle});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(color: Colors.white),
              prefixIcon: Icon(Icons.email, color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
                borderSide: BorderSide(color: Colors.white),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
                borderSide: BorderSide(color: Colors.white),
              ),
              filled: true,
              fillColor: Colors.black,
            ),
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 16.0),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(color: Colors.white),
              prefixIcon: Icon(Icons.lock, color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
                borderSide: BorderSide(color: Colors.white),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
                borderSide: BorderSide(color: Colors.white),
              ),
              filled: true,
              fillColor: Colors.black,
            ),
            obscureText: true,
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: _login,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Colors.black, // Set the background color to black
              foregroundColor: Colors.white, // Set the text color to white
              side: BorderSide(color: Colors.white), // Add a white border
            ),
            child: Text(
              'Login',
              style: TextStyle(color: Colors.white),
            ),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            ),
          SizedBox(
            height: 10,
          ),
          Container(
            child: Text(
              'Don\'t have an account?',
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: widget.onToggle,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Colors.black, // Set the background color to black
              foregroundColor: Colors.white, // Set the text color to white
              side: BorderSide(color: Colors.white), // Add a white border
            ),
            child: Text(
              'Register here',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ButtonScreen()),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }
}

class RegistrationForm extends StatefulWidget {
  final VoidCallback onToggle;

  RegistrationForm({required this.onToggle});

  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              labelStyle: TextStyle(color: Colors.white),
              prefixIcon: Icon(Icons.person, color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
                borderSide: BorderSide(color: Colors.white),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
                borderSide: BorderSide(color: Colors.white),
              ),
              filled: true,
              fillColor: Colors.black,
            ),
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 16.0),
          TextField(
            controller: _contactController,
            decoration: InputDecoration(
              labelText: 'Contact Number',
              labelStyle: TextStyle(color: Colors.white),
              prefixIcon: Icon(Icons.phone, color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
                borderSide: BorderSide(color: Colors.white),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
                borderSide: BorderSide(color: Colors.white),
              ),
              filled: true,
              fillColor: Colors.black,
            ),
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 16.0),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(color: Colors.white),
              prefixIcon: Icon(Icons.email, color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
                borderSide: BorderSide(color: Colors.white),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
                borderSide: BorderSide(color: Colors.white),
              ),
              filled: true,
              fillColor: Colors.black,
            ),
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 16.0),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(color: Colors.white),
              prefixIcon: Icon(Icons.lock, color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
                borderSide: BorderSide(color: Colors.white),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
                borderSide: BorderSide(color: Colors.white),
              ),
              filled: true,
              fillColor: Colors.black,
            ),
            obscureText: true,
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 16.0),
          // ElevatedButton(
          //   onPressed: _register,
          //   child: Text('Register'),
          // ),
          ElevatedButton(
            onPressed: _register,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Colors.black, // Set the background color to black
              foregroundColor: Colors.white, // Set the text color to white
              side: BorderSide(color: Colors.white), // Add a white border
            ),
            child: Text(
              'Register',
              style: TextStyle(color: Colors.white),
            ),
          ),

          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            ),
          SizedBox(
            height: 10,
          ),
          Container(
            child: Text(
              'Already have an account?',
              style: TextStyle(color: Colors.white),
            ),
          ),

          SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: widget.onToggle,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Colors.black, // Set the background color to black
              foregroundColor: Colors.white, // Set the text color to white
              side: BorderSide(color: Colors.white), // Add a white border
            ),
            child: Text(
              'Login here',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _register() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      User? user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(_nameController.text.trim());
        DatabaseReference userRef =
            FirebaseDatabase.instance.ref().child('users').child(user.uid);
        userRef.set({
          'name': _nameController.text.trim(),
          'contact': _contactController.text.trim(),
          'email': _emailController.text.trim(),
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ButtonScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }
}