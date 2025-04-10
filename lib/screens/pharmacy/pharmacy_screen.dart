import 'package:flutter/material.dart';
import 'package:home/screens/pharmacy/home_screen.dart';
import 'package:home/main.dart';
import 'package:home/theme/app_colors.dart';
import 'package:lottie/lottie.dart';

class PharmacyScreen extends StatefulWidget {
  const PharmacyScreen({super.key});

  @override
  _PharmacyScreenState createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> {
  bool _dataFetched = false;

  @override
  void initState() {
    super.initState();
    _waitForData();
  }

  Future<void> _waitForData() async {
    while (pharmacyData == null || mapController == null) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    await Future.delayed(const Duration(seconds: 1)); // Smooth transition delay
    setState(() {
      _dataFetched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_dataFetched) {
      return MaterialApp(
        title: 'Pharmacy Finder',
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: AppColors.background, // Theme-aware background
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lottie Animation
                Lottie.asset(
                  'assets/animations/loading.json', // Adjust path to your file
                  width: 200, // Adjust size as needed
                  height: 200,
                  fit: BoxFit.contain,
                  repeat: true, // Loop the animation
                ),
                const SizedBox(height: 20),
                // Optional loading text
                Text(
                  'Fetching Pharmacy Data...',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    fontFamily: 'Poppins', // Assuming AppFonts uses Poppins
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Pharmacy Finder',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: HomeScreen(
        pharmacies: pharmacyData!,
        mapController: mapController,
      ),
    );
  }
}
