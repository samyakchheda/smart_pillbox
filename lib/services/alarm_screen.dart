import 'package:flutter/material.dart';

class AlarmScreen extends StatelessWidget {
  final String medicineName;

  const AlarmScreen({super.key, required this.medicineName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Medicine Reminder',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'It\'s time to take your medicine: $medicineName',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Handle snooze logic
                Navigator.pop(context);
              },
              child: const Text('Snooze'),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle stop logic
                Navigator.pop(context);
              },
              child: const Text('Stop'),
            ),
          ],
        ),
      ),
    );
  }
}
