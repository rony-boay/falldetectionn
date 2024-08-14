import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'knn.dart';

class NotificationService {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final KNN _knnModel = KNN();
  StreamSubscription? _sensorDataSubscription;
  Timer? _fallDetectionResetTimer;
  Timer? _notificationDelayTimer;
  bool _canSendNotification = true;

  NotificationService() {
    _initializeNotifications();
    _trainKNNModel();
    _fetchSensorData();
  }

  static Future<void> init() async {
    final NotificationService _notificationService = NotificationService();
  }

  void _initializeNotifications() {
    final AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings = InitializationSettings(
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
    _sensorDataSubscription = _databaseReference.child('max30100/data').onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> max30100Data = event.snapshot.value as Map<dynamic, dynamic>;
        int irValue = max30100Data['irValue'];
        int redValue = max30100Data['redValue'];

        _databaseReference.child('mpu6050/data').onValue.listen((mpuEvent) {
          if (mpuEvent.snapshot.value != null) {
            Map<dynamic, dynamic> mpuData = mpuEvent.snapshot.value as Map<dynamic, dynamic>;
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
    if ((prediction == 'Accidental Fall' || prediction == 'Natural Fall') && _canSendNotification) {
      scheduleNotification(prediction);
      _canSendNotification = false;
      _startNotificationDelayTimer();

      // Add fall data to KNN model for retraining
      _knnModel.addFallData(featureData, prediction);
    }
  }

  void _startNotificationDelayTimer() {
    _notificationDelayTimer = Timer(Duration(seconds: 5), () {
      _canSendNotification = true;
    });
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

      var androidDetails = AndroidNotificationDetails(
        'channelId',
        'channelName',
        importance: Importance.max,
      );
      var generalNotificationDetails = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch % 100000, // Ensures a unique notification ID
        'Fall Detected: $prediction',
        'Timestamp: $timestamp',
        generalNotificationDetails,
      );
    }
  }

  void dispose() {
    _sensorDataSubscription?.cancel();
    _fallDetectionResetTimer?.cancel();
    _notificationDelayTimer?.cancel();
  }
}
