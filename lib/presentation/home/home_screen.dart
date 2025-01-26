import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../profile/user_profile_screen.dart';
import '../reminders/medicine_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NotchBottomBarController _controller =
      NotchBottomBarController(index: 0);

  final List<Widget> _pages = [
    const Center(
      child: Text(
        'Hello user',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    ),
    const MedicineListScreen(),
    const UserProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_controller.index],
      bottomNavigationBar: AnimatedNotchBottomBar(
        notchBottomBarController: _controller,
        color: Colors.white,
        showLabel: true,
        shadowElevation: 5,
        kBottomRadius: 28.0,
        notchColor: Colors.black87,
        durationInMilliSeconds: 300,
        itemLabelStyle: const TextStyle(fontSize: 10),
        elevation: 1,
        bottomBarItems: const [
          BottomBarItem(
            inActiveItem: FaIcon(FontAwesomeIcons.house, color: Colors.black),
            activeItem: FaIcon(FontAwesomeIcons.house, color: Colors.white),
            itemLabel: 'Home',
          ),
          BottomBarItem(
            inActiveItem: Icon(FontAwesomeIcons.pills, color: Colors.black),
            activeItem: Icon(FontAwesomeIcons.pills, color: Colors.white),
            itemLabel: 'Reminders',
          ),
          BottomBarItem(
            inActiveItem: Icon(FontAwesomeIcons.user, color: Colors.black),
            activeItem: Icon(FontAwesomeIcons.user, color: Colors.white),
            itemLabel: 'Profile',
          ),
        ],
        onTap: (index) {
          setState(() {
            _controller.jumpTo(index);
          });
        },
        kIconSize: 24.0,
      ),
    );
  }
}
