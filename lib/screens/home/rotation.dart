import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart' as cube;
import 'package:google_fonts/google_fonts.dart';
import 'package:home/screens/home/connection_screen.dart';
import 'package:home/screens/home/find_device.dart';
import 'package:home/screens/home/issue.dart';
import 'package:home/theme/app_colors.dart';

class AutoRotateCubeWithFuture extends StatefulWidget {
  const AutoRotateCubeWithFuture({Key? key}) : super(key: key);

  @override
  State<AutoRotateCubeWithFuture> createState() =>
      _AutoRotateCubeWithFutureState();
}

class _AutoRotateCubeWithFutureState extends State<AutoRotateCubeWithFuture>
    with SingleTickerProviderStateMixin {
  Object? _model;

  // Sample device details (Replace with real data)
  String deviceName = "Smart Pillbox";
  int batteryLevel = 80;
  String connectivityStatus = "Connected";

  late AnimationController _controller;
  late Animation<double> _headerAnimation;
  late Animation<Offset> _cubeSlideAnimation;
  late Animation<double> _cubeFadeAnimation;
  late Animation<Offset> _gridSlideAnimation;
  late Animation<double> _gridFadeAnimation;

  @override
  void initState() {
    super.initState();
    // Create the controller for all animations.
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Header Animation: Fades and scales in
    _headerAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );

    // Cube Card Animation: Slide from left & fade in
    _cubeSlideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );
    _cubeFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.6, curve: Curves.easeIn),
      ),
    );

    // Grid Animation: Slide from bottom & fade in
    _gridSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );
    _gridFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    // Start the animations
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-Screen Gradient Background
          Container(
            height: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.buttonColor,
                  Colors.grey.shade400,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Content with Overlapping White Background
          Column(
            children: [
              // Animated Header with Gradient (Fixed Height)
              FadeTransition(
                opacity: _headerAnimation,
                child: ScaleTransition(
                  scale: _headerAnimation,
                  child: Container(
                    height: 166,
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      'SmartDose'.tr(),
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              // Expanded Content Section
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Animated cube card
                        SlideTransition(
                          position: _cubeSlideAnimation,
                          child: FadeTransition(
                            opacity: _cubeFadeAnimation,
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              height: 120,
                              child: cube.Cube(
                                onSceneCreated: (cube.Scene scene) {
                                  final obj = cube.Object(
                                    fileName: 'assets/cube/jewelry-box-009.obj',
                                  );
                                  obj.scale.setValues(6.0, 6.0, 6.0);
                                  scene.world.add(obj);
                                  scene.camera.position.z = 1;
                                  _model = obj;
                                },
                              ),
                            ),
                          ),
                        ),
                        // Animated grid for device controls
                        SlideTransition(
                          position: _gridSlideAnimation,
                          child: FadeTransition(
                            opacity: _gridFadeAnimation,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: GridView.count(
                                shrinkWrap: true,
                                crossAxisCount: 2,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                                childAspectRatio: 0.85,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  _buildDeviceInfoCard(deviceName, batteryLevel,
                                      connectivityStatus),
                                  _buildCard("Connection".tr(), "Connect".tr(),
                                      Icons.wifi, () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                WiFiScannerScreen()));
                                  }),
                                  _buildCard("Find Device".tr(), "Find".tr(),
                                      Icons.search, () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                FindingDeviceScreen()));
                                  }),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SendIssueScreen()));
                                    },
                                    child: _buildIssueCard(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Switch to German
                            context.setLocale(Locale('de', 'DE'));
                          },
                          child: Text('Switch to German'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Switch to German
                            context.setLocale(Locale('en', 'US'));
                          },
                          child: Text('Switch to English'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Switch to German
                            context.setLocale(Locale('hi', 'IN'));
                          },
                          child: Text('Switch to Hindi'),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 🔹 Device Info Card
Widget _buildDeviceInfoCard(String deviceName, int battery, String status) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 6,
    color: Colors.white,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Icon(Icons.devices, size: 50, color: AppColors.buttonColor),
            const SizedBox(height: 10),
            Text(
              deviceName.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.battery_full,
                    color: battery > 20 ? Colors.green : Colors.red),
                const SizedBox(width: 5),
                Text("$battery%", style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(status == "Connected" ? Icons.wifi : Icons.wifi_off,
                    color: status == "Connected" ? Colors.blue : Colors.red),
                const SizedBox(width: 5),
                Text(status,
                    style: TextStyle(
                        fontSize: 14,
                        color:
                            status == "Connected" ? Colors.blue : Colors.red)),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

// 🔹 Reusable Card Widget
Widget _buildCard(
    String title, String buttonText, IconData icon, VoidCallback onPressed) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 6,
    color: Colors.white,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 50, color: AppColors.buttonColor),
            const SizedBox(height: 10),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                softWrap: true,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  elevation: 4,
                ),
                onPressed: onPressed,
                child: Text(buttonText, style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// 🔹 Issue Card
Widget _buildIssueCard() {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 6,
    color: Colors.white,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Colors.white, Colors.red.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.report_problem, size: 50, color: Colors.red),
            const SizedBox(height: 10),
            Expanded(
              child: Text(
                "Facing some issues with the box?".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
