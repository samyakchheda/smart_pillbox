import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroScreen3 extends StatelessWidget {
  const IntroScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(context),
    );
  }

  Widget _buildUI(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          Center(
            child: Lottie.asset("assets/animations/Reminders.json"),
          ),
          const SizedBox(
            height: 25,
          ),
          Text(
            "Gentle Reminders",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white 
                  : Colors.indigo, 
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(40),
            child: Text(
              "Receive gentle reminders when it's time to take your medicine."
              "Let us help you stay consistent, ensuring you never forget a dose.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
