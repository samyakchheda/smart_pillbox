import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroScreen2 extends StatelessWidget {
  const IntroScreen2({super.key});

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
            child: Lottie.asset("assets/animations/Progress_Tracker.json"),
          ),
          const SizedBox(
            height: 25,
          ),
          Text(
            "Stay on Track",
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
              "Keep your health goals in check by managing your medication schedule. "
              "Stay organized and never miss a step in your wellness journey.",
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
