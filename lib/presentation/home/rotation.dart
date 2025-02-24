import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:home/presentation/home/connection_screen.dart';
import 'package:lucide_icons/lucide_icons.dart'; // For icons

class AutoRotateCubeWithFuture extends StatefulWidget {
  const AutoRotateCubeWithFuture({Key? key}) : super(key: key);

  @override
  State<AutoRotateCubeWithFuture> createState() =>
      _AutoRotateCubeWithFutureState();
}

class _AutoRotateCubeWithFutureState extends State<AutoRotateCubeWithFuture> {
  Object? _model;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    _isAnimating = true;
    _animate();
  }

  void _animate() async {
    if (!_isAnimating) return;
    await Future.delayed(const Duration(milliseconds: 16));
    if (_model != null) {
      _model!.rotation.y += 1;
      if (_model!.rotation.y > 360) _model!.rotation.y -= 360;
      if (mounted) {
        setState(() {});
      }
    }
    _animate();
  }

  @override
  void dispose() {
    _isAnimating = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 200, // Adjust height as needed
            child: Center(
              child: Cube(
                onSceneCreated: (Scene scene) {
                  final obj =
                      Object(fileName: 'assets/cube/jewelry-box-009.obj');
                  scene.world.add(obj);
                  scene.camera.position.z = 1;
                  _model = obj;
                },
              ),
            ),
          ),
          // Device Information immediately below the 3D model
          const Column(
            children: [
              const Text(
                "Device no. YYY_4860",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.circle, size: 12, color: Colors.blue),
                  const SizedBox(width: 5),
                  const Text(
                    "Connected",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Icon(LucideIcons.batteryFull,
                      size: 18, color: Colors.green),
                  const SizedBox(width: 5),
                  const Text(
                    "95%",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Card with Connection Status and Button
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    "Status: Connected",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WiFiScannerScreen()),
                      );
                    },
                    child: const Text("Connect"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
