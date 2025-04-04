import 'package:flutter/material.dart';
import 'package:home/screens/home/loading.dart';
import 'package:home/screens/pharmacy/home_screen.dart';
import 'package:home/main.dart'; // Import to access userLocation and pharmacyData

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
    // Wait until the location and pharmacyData are available.
    // You can adjust the condition as needed based on your actual logic.
    while (pharmacyData == null || mapController == null) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    // Optionally add a slight delay for smooth transition:
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _dataFetched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_dataFetched) {
      // Show the custom RotatingPillAnimation until the data is fetched.
      return MaterialApp(
        title: 'Pharmacy Finder',
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color(0xFFE0E0E0),
          body: Center(
            child: RotatingPillAnimation(),
          ),
        ),
      );
    }

    // Once data is available, load HomeScreen
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
