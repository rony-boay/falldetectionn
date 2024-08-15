import 'package:falldetectionn1/main.dart';
import 'package:falldetectionn1/screens/AuthenticationScreen.dart';
import 'package:falldetectionn1/screens/ButtonScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();

    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 5)); // Wait for animation

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is signed in, navigate to ButtonScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ButtonScreen()),
      );
    } else {
      // User is not signed in, navigate to AuthenticationScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthenticationScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 209, 208, 208),
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Text(
            'Fall Detection System',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 8, 8, 8),
            ),
          ),
        ),
      ),
    );
  }
}
