import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'screens/home_screen.dart';
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
      // Show a loading indicator until the data is fetched
      return MaterialApp(
        title: 'Pharmacy Finder',
        theme: ThemeData(primarySwatch: Colors.blue),
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(
                    height: 16), // Adds spacing between the loader and text
                Text(
                  'Fetching your location, please wait...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
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
