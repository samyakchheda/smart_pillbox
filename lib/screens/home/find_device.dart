import 'package:flutter/material.dart';
import 'package:home/theme/app_colors.dart'; // Assuming this exists

class FindingDeviceScreen extends StatefulWidget {
  const FindingDeviceScreen({super.key});

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.buttonColor,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: AppColors.textOnPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          centerTitle: true,
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black87,
            fontSize: 18,
          ),
          titleLarge: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonColor,
            foregroundColor: AppColors.buttonText,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Finding Device"),
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
                      painter: RadarPainter(
                        _controller.value,
                        isDarkMode: isDarkMode,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "Searching for device...",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text("Yes, Found"),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    // Action when device is not found
                  },
                  child: const Text("No, Still not found"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RadarPainter extends CustomPainter {
  final double progress;
  final bool isDarkMode;

  RadarPainter(this.progress, {required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = AppColors.buttonColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * progress, paint);
  }

  @override
  bool shouldRepaint(RadarPainter oldDelegate) => true;
}
