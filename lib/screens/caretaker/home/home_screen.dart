import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:home/screens/caretaker/home/rotation.dart';
import 'package:home/screens/caretaker/home/user_profile_screen.dart';
import 'package:home/screens/caretaker/medicine/medicine_list_screen.dart';
import 'package:home/screens/pharmacy/pharmacy_screen.dart';
import 'package:home/theme/app_colors.dart'; // Import AppColors
import 'package:responsive_navigation_bar/responsive_navigation_bar.dart';

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
    const UserProfileScreen(),
    const PharmacyScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background, // Theme-aware background
      body: Stack(
        children: [
          _pages[_currentIndex],

          // Floating Navigation Bar with themed styling
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: ResponsiveNavigationBar(
                  backgroundColor: AppColors.cardBackground
                      .withOpacity(0.8), // Semi-transparent themed background
                  backgroundBlur: 0.0,
                  selectedIndex: _currentIndex,
                  onTabChange: (index) => setState(() => _currentIndex = index),
                  activeIconColor:
                      AppColors.buttonText, // Theme-aware active icon color
                  inactiveIconColor: AppColors.buttonText
                      .withOpacity(0.6), // Theme-aware inactive icon color
                  animationDuration:
                      const Duration(milliseconds: 300), // Smooth animation
                  navigationBarButtons: [
                    NavigationBarButton(
                      textColor: AppColors.buttonText, // Theme-aware text color
                      icon: FontAwesomeIcons.house,
                      text: "Home".tr(),
                    ),
                    NavigationBarButton(
                      textColor: AppColors.buttonText,
                      icon: FontAwesomeIcons.pills,
                      text: "Reminders".tr(),
                    ),
                    NavigationBarButton(
                      textColor: AppColors.buttonText,
                      icon: FontAwesomeIcons.user,
                      text: "Profile".tr(),
                    ),
                    NavigationBarButton(
                      textColor: AppColors.buttonText,
                      icon: FontAwesomeIcons.shop,
                      text: "Shop".tr(),
                    ),
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
