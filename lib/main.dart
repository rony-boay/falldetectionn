import 'package:falldetectionn1/NotificationService.dart';
import 'package:falldetectionn1/SplashScreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:math';

import 'knn.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.init(); // Initialize NotificationService

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fall Detection App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}

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

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  List<BarChartGroupData> _chartData = [];
  List<Map<String, dynamic>> _fallHistory = [];
  Timer? _timer;
  StreamSubscription? _fallHistorySubscription;
  StreamSubscription? _userDetailsSubscription;
  StreamSubscription? _sensorSubscription;
  String? _userName;
  String? _userContact;
  String? _userEmail;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _fetchFallHistory();
    _fetchUserDetails();
    _startAutoRefresh();
  }

  void _fetchUserDetails() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userDetailsSubscription = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(user.uid)
          .onValue
          .listen((event) {
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic> data =
              event.snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            _userName = data['name'];
            _userContact = data['contact'];
            _userEmail = data['email'];
          });
        }
      });
    }
  }

  void _fetchFallHistory() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _fallHistorySubscription = FirebaseDatabase.instance
          .ref()
          .child('fall_history')
          .child(user.uid)
          .onValue
          .listen((event) {
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic> data =
              event.snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            _fallHistory = data.values.map((e) {
              return {
                'fallType': e['fallType'],
                'timestamp': e['timestamp'],
              };
            }).toList();
          });
        }
      });
    }
  }

  void _fetchSensorData() {
    _sensorSubscription = FirebaseDatabase.instance
        .ref()
        .child('max30100/data')
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> max30100Data =
            event.snapshot.value as Map<dynamic, dynamic>;
        int irValue = max30100Data['irValue'];
        int redValue = max30100Data['redValue'];

        FirebaseDatabase.instance
            .ref()
            .child('mpu6050/data')
            .onValue
            .listen((mpuEvent) {
          if (mpuEvent.snapshot.value != null) {
            Map<dynamic, dynamic> mpuData =
                mpuEvent.snapshot.value as Map<dynamic, dynamic>;
            double ax = mpuData['ax'].toDouble();
            double ay = mpuData['ay'].toDouble();
            double az = mpuData['az'].toDouble();
            setState(() {
              _chartData = [
                _buildBarChartGroupData(0, redValue.toDouble()),
                _buildBarChartGroupData(1, irValue.toDouble()),
                _buildBarChartGroupData(2, ax),
                _buildBarChartGroupData(3, ay),
              ];
            });
          }
        });
      }
    });
  }

  BarChartGroupData _buildBarChartGroupData(int x, double value) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          color: Colors.blue,
        ),
      ],
    );
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _fetchSensorData(); // Call the method to fetch new sensor data
    });
  }

  @override
  void dispose() {
    _fallHistorySubscription?.cancel();
    _userDetailsSubscription?.cancel();
    _sensorSubscription?.cancel(); // Cancel the sensor data subscription
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Light grey background
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: SingleChildScrollView(
        // Wraps the content to prevent overflow
        child: Column(
          children: [
            if (_userName != null && _userContact != null && _userEmail != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text('Name: $_userName'),
                    Text('Contact: $_userContact'),
                    Text('Email: $_userEmail'),
                  ],
                ),
              ),
            SizedBox(height: 10),
            SizedBox(
              height: 300, // Set a fixed height for the bar chart container
              child: BarChart(
                BarChartData(
                  barGroups: _chartData,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          switch (value.toInt()) {
                            case 0:
                              return Text('Red');
                            case 1:
                              return Text('IR');
                            case 2:
                              return Text('Acc');
                            case 3:
                              return Text('Gyro');
                            default:
                              return Text('');
                          }
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String label;
                        switch (group.x.toInt()) {
                          case 0:
                            label = 'Red';
                            break;
                          case 1:
                            label = 'IR';
                            break;
                          case 2:
                            label = 'Acc';
                            break;
                          case 3:
                            label = 'Gyro';
                            break;
                          default:
                            label = '';
                        }
                        return BarTooltipItem(
                          '$label: ${rod.toY}',
                          TextStyle(color: Colors.yellow),
                        );
                      },
                    ),
                  ),
                  alignment: BarChartAlignment.spaceEvenly, // Adjust as needed
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(
                  16.0), // Adding padding for better spacing
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align text to the left
                children: [
                  Text(
                    'IR Value (Infrared Value)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8), // Adding space between title and content
                  Text(
                    'Infrared (IR) Light: This is the measurement of light absorption or reflection in the infrared spectrum. In pulse oximetry, the IR value is typically used to detect the volume of blood in the tissue, which changes with each heartbeat. The IR value can help determine heart rate and is less affected by skin pigmentation compared to red light.',
                  ),
                  SizedBox(height: 16), // Adding space between sections
                  Text(
                    'Red Value',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Red Light: This measures the absorption of light in the red spectrum. The red value is crucial for calculating blood oxygen saturation (SpO2). Hemoglobin in the blood absorbs red light differently depending on whether it is oxygenated or deoxygenated. By comparing the red and IR values, the device can estimate the oxygen saturation in the blood.',
                  ),
                  SizedBox(height: 16), // Adding space between sections
                  Text(
                    'Gyro (Gyroscope)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8), // Adding space between title and content
                  Text(
                    'Gyroscope: This measures the rate of rotation around an axis.',
                  ),
                  SizedBox(height: 16), // Adding space between sections
                  Text(
                    'Acceleration (Acc)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Acceleration: This measures the rate of change of velocity of an object.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FallHistoryScreen extends StatefulWidget {
  @override
  _FallHistoryScreenState createState() => _FallHistoryScreenState();
}

class _FallHistoryScreenState extends State<FallHistoryScreen> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  StreamSubscription? _fallHistorySubscription;
  List<Map<String, dynamic>> _fallHistory = [];

  @override
  void initState() {
    super.initState();
    _fetchFallHistory();
  }

  @override
  void dispose() {
    _fallHistorySubscription?.cancel();
    super.dispose();
  }

  void _fetchFallHistory() {
    _fallHistorySubscription =
        _databaseReference.child('fall_history').onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        print('Fetched Data: $data'); // Log the data to see its structure

        List<Map<String, dynamic>> fallHistory = [];

        data.forEach((key, value) {
          print('Fetched Value: $value'); // Log each value

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
              // Handle parsing error
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Light grey background
      appBar: AppBar(
        title: Text('Fall History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _fallHistory.isEmpty
            ? Center(child: Text('No fall history available'))
            : ListView.builder(
                itemCount: _fallHistory.length,
                itemBuilder: (context, index) {
                  final fall = _fallHistory[index];
                  return Card(
                    margin: const EdgeInsets.only(
                        bottom: 16.0), // Gap between cards
                    elevation: 4.0, // Shadow
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12.0), // Rounded corners
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.all(16.0), // Padding inside the card
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date: ${fall['date']}',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Time: ${fall['time']}',
                            style: TextStyle(fontSize: 14.0),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Type: ${fall['fall_type']}',
                            style: TextStyle(fontSize: 14.0),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
