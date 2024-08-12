import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/services.dart';
import 'knn.dart';

class NotificationService {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final KNN _knnModel = KNN();
  StreamSubscription? _sensorDataSubscription;
  Timer? _notificationDelayTimer;
  bool _isNotificationScheduled = false;

  static const platform = MethodChannel('com.example.falldetectionn1/notification');

  NotificationService() {
    _initializeNotifications();
    _trainKNNModel();
    _fetchSensorData();
  }

  static Future<void> init() async {
    await AndroidAlarmManager.initialize(); // Initialize the AlarmManager
    final NotificationService _notificationService = NotificationService();
  }

  void _initializeNotifications() {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    _notificationsPlugin.initialize(initializationSettings);
  }

  void _trainKNNModel() {
    List<List<double>> trainingFeatures = [
      [1.0, 2.0, 3.0, 4.0, 5.0],
      [5.0, 4.0, 3.0, 2.0, 1.0],
    ];
    List<String> trainingLabels = [
      'Natural Fall',
      'Accidental Fall',
    ];

    _knnModel.train(trainingFeatures, trainingLabels);
  }

  void _fetchSensorData() {
    _sensorDataSubscription =
        _databaseReference.child('max30100/data').onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> max30100Data =
            event.snapshot.value as Map<dynamic, dynamic>;
        int irValue = max30100Data['irValue'];
        int redValue = max30100Data['redValue'];

        _databaseReference.child('mpu6050/data').onValue.listen((mpuEvent) {
          if (mpuEvent.snapshot.value != null) {
            Map<dynamic, dynamic> mpuData =
                mpuEvent.snapshot.value as Map<dynamic, dynamic>;
            double ax = mpuData['ax'].toDouble();
            double ay = mpuData['ay'].toDouble();
            double az = mpuData['az'].toDouble();

            List<double> featureData = [
              irValue.toDouble(),
              redValue.toDouble(),
              ax,
              ay,
              az,
            ];

            String prediction = _knnModel.predict(featureData);
            _handleFallDetection(prediction, featureData);
          }
        });
      }
    });
  }

  void _handleFallDetection(String prediction, List<double> featureData) {
    if (prediction == 'Accidental Fall' || prediction == 'Natural Fall') {
      if (!_isNotificationScheduled) {
        _isNotificationScheduled = true;
        scheduleNotification(prediction);

        // Add fall data to KNN model for retraining
        _knnModel.addFallData(featureData, prediction);

        // Reset timer to allow notifications after 5 seconds
        _notificationDelayTimer?.cancel();
        _notificationDelayTimer = Timer(Duration(seconds: 5), () {
          _isNotificationScheduled = false;
        });
      }
    }
  }

  Future<void> scheduleNotification(String prediction) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;
      DateTime now = DateTime.now();
      String timestamp = DateFormat('dd-MM-yyyy HH:mm:ss').format(now);

      await _databaseReference.child('fall_history').child(uid).push().set({
        'fallType': prediction,
        'timestamp': timestamp,
      });

      // Schedule the alarm
      await AndroidAlarmManager.oneShot(
        Duration(seconds: 1), // Alarm delay
        0, // Alarm ID
        _showNotification,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
        params: <String, dynamic>{
          "prediction": prediction,
          "timestamp": timestamp,
        },
      );
    }
  }

  static Future<void> _showNotification(Map<String, dynamic> params) async {
    try {
      await platform.invokeMethod('showNotification', params);
    } on PlatformException catch (e) {
      print("Failed to trigger notification: '${e.message}'.");
    }
  }

  void dispose() {
    _sensorDataSubscription?.cancel();
    _notificationDelayTimer?.cancel();
  }
}
