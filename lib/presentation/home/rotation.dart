import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart' as cube;
import 'package:home/presentation/home/connection_screen.dart';
import 'package:home/presentation/home/find_device.dart';
import 'package:home/presentation/home/issue.dart';
import 'package:home/theme/app_colors.dart';

class AutoRotateCubeWithFuture extends StatefulWidget {
  const AutoRotateCubeWithFuture({Key? key}) : super(key: key);

  @override
  State<AutoRotateCubeWithFuture> createState() =>
      _AutoRotateCubeWithFutureState();
}

class _AutoRotateCubeWithFutureState extends State<AutoRotateCubeWithFuture> {
  Object? _model;

  // Sample device details (Replace with real data)
  String deviceName = "Smart Pillbox";
  int batteryLevel = 80;
  String connectivityStatus = "Connected";

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
              // Header with Gradient (Fixed Height)
              Container(
                height: 150,
                alignment: Alignment.center,
                child: Text(
                  'SmartDose',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              // Expanded Content Section
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Small rectangle card for the 3D model
                        Container(
                          margin: const EdgeInsets.only(
                              top: 16, left: 16, right: 16),
                          height: 150,
                          // decoration: BoxDecoration(
                          //   color: Colors.white,
                          //   borderRadius: BorderRadius.circular(16),
                          //   boxShadow: [
                          //     BoxShadow(
                          //       color: Colors.black.withOpacity(0.1),
                          //       blurRadius: 8,
                          //       offset: const Offset(0, 2),
                          //     ),
                          //   ],
                          // ),
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
                        // Device controls grid
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            childAspectRatio: 0.85,
                            children: [
                              _buildDeviceInfoCard(
                                  deviceName, batteryLevel, connectivityStatus),
                              _buildCard("Connection", "Connect", Icons.wifi,
                                  () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            WiFiScannerScreen()));
                              }),
                              _buildCard("Find Device", "Find", Icons.search,
                                  () {
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
              deviceName,
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
              child: const Text(
                "Facing some issues?",
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
