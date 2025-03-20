import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:responsive_navigation_bar/responsive_navigation_bar.dart';
import 'package:home/pharmacy/pharmacy_screen.dart';
import 'package:home/presentation/home/rotation.dart';
import 'package:home/presentation/reminders/medicine_list_screen.dart';

class CareTakerHomeScreen extends StatefulWidget {
  const CareTakerHomeScreen({super.key});

  @override
  State<CareTakerHomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<CareTakerHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const Center(child: AutoRotateCubeWithFuture()),
    const MedicineListScreen(),
    const PharmacyScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          _pages[_currentIndex],

          // Floating Navigation Bar without extra blur
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0), // Adjust as needed
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100), // Match bar shape
                child: ResponsiveNavigationBar(
                  backgroundColor: Colors.transparent,
                  backgroundBlur: 0.0, // Semi-transparent
                  selectedIndex: _currentIndex,
                  onTabChange: (index) => setState(() => _currentIndex = index),
                  activeIconColor: Colors.white,
                  inactiveIconColor: Colors.white,
                  animationDuration: Duration(minutes: 0),
                  navigationBarButtons: const [
                    NavigationBarButton(
                        textColor: Colors.white,
                        icon: FontAwesomeIcons.house,
                        text: "Home"),
                    NavigationBarButton(
                        textColor: Colors.white,
                        icon: FontAwesomeIcons.pills,
                        text: "Reminders"),
                    NavigationBarButton(
                        textColor: Colors.white,
                        icon: FontAwesomeIcons.shop,
                        text: "Shop"),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
