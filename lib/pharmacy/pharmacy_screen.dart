import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'screens/home_screen.dart';
import 'services/location_service.dart';

class PharmacyScreen extends StatelessWidget {
  const PharmacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pharmacy Finder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<Position>(
        future: LocationService.getCurrentLocation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          } else if (snapshot.hasData) {
            return HomeScreen(userLocation: snapshot.data!);
          } else {
            return const Scaffold(
              body: Center(child: Text('Unknown error occurred')),
            );
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
