import 'package:falldetectionn1/NotificationService.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

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
