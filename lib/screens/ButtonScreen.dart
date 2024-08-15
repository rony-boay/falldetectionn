import 'dart:async';

import 'package:falldetectionn1/main.dart';
import 'package:falldetectionn1/screens/FallHistoryScreen.dart';
import 'package:falldetectionn1/screens/HomeScreen.dart';
import 'package:falldetectionn1/screens/ProfileScreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';



class ButtonScreen extends StatefulWidget {
  @override
  _ButtonScreenState createState() => _ButtonScreenState();
}

class _ButtonScreenState extends State<ButtonScreen> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  String? _userName;
  String? _userContact;
  String? _userEmail;

  StreamSubscription? _userDetailsSubscription;
  StreamSubscription? _fallHistorySubscription;
  List<Map<String, dynamic>> _fallHistory = [];

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _fetchFallHistory();
    _fetchFCMToken(); // Fetch FCM token
  }

  void _fetchUserDetails() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userDetailsSubscription = _databaseReference
          .child('users')
          .child(user.uid)
          .onValue
          .listen((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;

        setState(() {
          _userName = data?['name'] as String?;
          _userContact = data?['contact'] as String?;
          _userEmail = data?['email'] as String?;
        });
      });
    }
  }

  void _fetchFallHistory() {
    _fallHistorySubscription =
        _databaseReference.child('fall_history').onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        List<Map<String, dynamic>> fallHistory = [];

        data.forEach((key, value) {
          final timeString = value['timestamp'] as String?;
          final fallType = value['fallType'] as String? ?? 'Unknown';

          if (timeString != null) {
            try {
              final dateTime =
                  DateFormat('dd-MM-yyyy HH:mm:ss').parse(timeString);
              fallHistory.add({
                'date': DateFormat.yMMMd().format(dateTime),
                'time': DateFormat.jm().format(dateTime),
                'fall_type': fallType,
              });
            } catch (e) {
              print('Error parsing date: $e');
            }
          }
        });

        setState(() {
          _fallHistory = fallHistory;
        });
      }
    });
  }

  void _fetchFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      print("FCM Token: $token");
    }
  }

  @override
  void dispose() {
    _userDetailsSubscription?.cancel();
    _fallHistorySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 185, 182, 182),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_userName != null &&
                  _userContact != null &&
                  _userEmail != null)
                Container(
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Name: $_userName',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Contact: $_userContact',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Email: $_userEmail',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              SizedBox(
                width: 200, // Set a fixed width for all buttons
                height: 50, // Set a fixed height for all buttons
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color.fromARGB(255, 32, 106, 243),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, // Remove rounded corners
                    ),
                  ),
                  child: Text('Profile'),
                ),
              ),
              SizedBox(height: 16.0),
              SizedBox(
                width: 200, // Set a fixed width for all buttons
                height: 50, // Set a fixed height for all buttons
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color.fromARGB(255, 32, 106, 243),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, // Remove rounded corners
                    ),
                  ),
                  child: Text('Insight'),
                ),
              ),
              SizedBox(height: 16.0),
              SizedBox(
                width: 200, // Set a fixed width for all buttons
                height: 50, // Set a fixed height for all buttons
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FallHistoryScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color.fromARGB(255, 32, 106, 243),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, // Remove rounded corners
                    ),
                  ),
                  child: Text('Fall History'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}