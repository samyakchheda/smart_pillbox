import 'package:flutter/material.dart';

class AlarmScreen extends StatelessWidget {
  final String medicineName;

  const AlarmScreen({Key? key, required this.medicineName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Medicine Reminder',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'It\'s time to take your medicine: $medicineName',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Handle snooze logic
                Navigator.pop(context);
              },
              child: Text('Snooze'),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle stop logic
                Navigator.pop(context);
              },
              child: Text('Stop'),
            ),
          ],
        ),
      ),
    );
  }
}
