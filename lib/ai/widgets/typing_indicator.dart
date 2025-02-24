import 'package:flutter/material.dart';
import 'package:jumping_dot/jumping_dot.dart';

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          JumpingDots(
            numberOfDots: 3,
            color: Colors.grey,
            radius: 8.0,
            animationDuration: Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
