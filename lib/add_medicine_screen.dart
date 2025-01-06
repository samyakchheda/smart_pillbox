import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:home/services/medicine_service.dart';
import 'medicine_setup/screen1.dart';
import 'medicine_setup/screen2.dart';
import 'medicine_setup/screen3.dart';

class AddMedicineScreen extends StatefulWidget {
  @override
  _AddMedicineScreenState createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final PageController _pageController = PageController();
  String medicineName = '';
  List<bool> isChecked = [false, false, false]; // Morning, Afternoon, Evening
  int currentPage = 0;
  Map<int, TimeOfDay?> selectedTimes = {}; // Selected times for each frequency

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LinearProgressIndicator(
              value: (currentPage + 1) / 3,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
              minHeight: 2,
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildFirstScreen(context),
                _buildSecondScreen(),
                _buildThirdScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _saveDataToFirestore(
      String medicineName, List<bool> isChecked, BuildContext context) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        // Only show SnackBar if widget is mounted
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No user is logged in')),
          );
        }
        return;
      }

      String userId = currentUser.uid;

      List<String> frequency = isChecked
          .asMap()
          .entries
          .where((entry) => entry.value)
          .map((entry) => ['Morning', 'Afternoon', 'Evening'][entry.key])
          .toList();
      List<Timestamp> times = selectedTimes.entries
          .where((entry) => entry.value != null)
          .map((entry) {
        TimeOfDay time = entry.value!;
        DateTime now = DateTime.now();
        return Timestamp.fromDate(
          DateTime(now.year, now.month, now.day, time.hour, time.minute),
        );
      }).toList();

      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'medicines': FieldValue.arrayUnion([
          {
            'name': medicineName,
            'frequency': frequency,
            'times': times,
          }
        ]),
      }, SetOptions(merge: true));

      // Show success message if widget is still mounted
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Handle error, show SnackBar if widget is still mounted
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildFirstScreen(BuildContext context) {
    return Screen1(
      pageController: _pageController,
      onNameChange: (value) {
        setState(() {
          medicineName = value;
        });
      },
      medicineName: medicineName,
    );
  }

  Widget _buildSecondScreen() {
    return Screen2(
      isChecked: isChecked,
      onCheckboxChange: (index) {
        setState(() {
          isChecked[index] = !isChecked[index];
        });
      },
      pageController: _pageController,
    );
  }

  Widget _buildThirdScreen() {
    return Screen3(
      isChecked: isChecked,
      selectedTimes: selectedTimes,
      onTimeChange: (index, time) {
        setState(() {
          selectedTimes[index] = time;
        });
      },
      saveData: () {
        _saveDataToFirestore(medicineName, isChecked, context);
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          checkMedicineTimes(user.uid); // Pass the userId to the function
        } else {
          print("User not logged in.");
        }
      },
    );
  }
}
