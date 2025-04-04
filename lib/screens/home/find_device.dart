import 'package:flutter/material.dart';
import 'package:home/theme/app_colors.dart';

class FindingDeviceScreen extends StatefulWidget {
  @override
  _FindingDeviceScreenState createState() => _FindingDeviceScreenState();
}

class _FindingDeviceScreenState extends State<FindingDeviceScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(); // Loops the animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      appBar: AppBar(
        title: const Text("Finding Device"),
        centerTitle: true,
        backgroundColor: const Color(0xFFE0E0E0),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: RadarPainter(_controller.value),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "Searching for device...",
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  // Action when device is found
                  Navigator.pop(context, true);
                },
                child: const Text("Yes, Found"),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  // Action when device is not found
                },
                child: const Text("No, Still not found"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RadarPainter extends CustomPainter {
  final double progress;

  RadarPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * progress, paint);
  }

  @override
  bool shouldRepaint(RadarPainter oldDelegate) => true;
}
