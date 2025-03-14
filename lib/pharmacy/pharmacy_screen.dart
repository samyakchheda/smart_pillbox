import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'screens/home_screen.dart';
import 'package:home/main.dart'; // Import to access userLocation and pharmacyData

class PharmacyScreen extends StatelessWidget {
  const PharmacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pharmacy Finder',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(
        pharmacies: pharmacyData!,
        mapController: mapController,
      ), // Pass data
      debugShowCheckedModeBanner: false,
    );
  }
}
