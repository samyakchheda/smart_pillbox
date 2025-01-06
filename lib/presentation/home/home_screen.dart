import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:home/presentation/profile/user_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = [
    const Center(
      child: Text(
        'Hello user',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    ),
    const UserProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.deepPurple,
        color: Colors.deepPurple.shade200,
        items: const [
          Icon(Icons.home, color: Colors.deepPurple, size: 30),
          Icon(Icons.person, color: Colors.deepPurple, size: 30),
        ],
        animationDuration: const Duration(milliseconds: 300),
        index: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
