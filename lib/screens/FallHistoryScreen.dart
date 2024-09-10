import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'dart:async';

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
    _fallHistorySubscription = _databaseReference
        .child('fall_history')
        .onValue
        .listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        print('Fetched Data: $data'); // Log the data to see its structure

        List<Map<String, dynamic>> fallHistory = [];

        data.forEach((userId, fallEvents) {
          if (fallEvents is Map) {
            fallEvents.forEach((fallEventId, fallEventData) {
              print('Fetched Event Data: $fallEventData'); // Log each fall event data

              final timeString = fallEventData['timestamp'] as String?;
              final fallType = fallEventData['fallType'] as String? ?? 'Unknown';

              if (timeString != null) {
                try {
                  final dateTime = DateFormat('dd-MM-yyyy HH:mm:ss').parse(timeString);
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
          }
        });

        // Reverse the list to have the latest fall on top
        fallHistory = fallHistory.reversed.toList();

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
                    margin: const EdgeInsets.only(bottom: 16.0), // Gap between cards
                    elevation: 4.0, // Shadow
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0), // Rounded corners
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0), // Padding inside the card
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
