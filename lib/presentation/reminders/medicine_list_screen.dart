import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:home/services/notifications_service/alarm_scheduler.dart';
import 'package:home/theme/app_colors.dart';
import 'medicine_form_screen.dart';
import 'medicine_list_utils.dart';

class MedicineListScreen extends StatefulWidget {
  const MedicineListScreen({super.key});

  @override
  State<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final MedicineFormScreenState medicineFormScreenState =
      MedicineFormScreenState();

  late DateTime today;
  late DateTime selectedDate;
  late ScrollController _scrollController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    today = DateTime.now();
    selectedDate = today;
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToDate();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToDate() {
    scrollToDate(context, _scrollController, today, selectedDate);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> dateRange = generateDateRange(today);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not authenticated'),
        ),
      );
    }

    return Scaffold(
      key: scaffoldMessengerKey,
      body: Stack(
        children: [
          // Full-Screen Gradient Background
          Container(
            height: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.buttonColor, // Replace with your desired colors
                  Colors.grey.shade400,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Content with Overlapping White Background
          Column(
            children: [
              // Header with Gradient (Fixed Height)
              Container(
                // Fixed height for the header
                alignment: Alignment.center,
                child: DateSelector(
                  dateRange: dateRange,
                  selectedDate: selectedDate,
                  today: today,
                  scrollController: _scrollController,
                  onDateSelected: (date) {
                    setState(() {
                      selectedDate = date;
                    });
                  },
                ),
              ),

              // Expanded Content Section (Ensures Proper Layout)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        Colors.white.withOpacity(0.9), // Soft blending effect
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: MedicineList(
                    firestore: _firestore,
                    userId: userId,
                    selectedDate: selectedDate,
                    onDelete: (medicineId) async {
                      await deleteMedicine(_firestore, userId, medicineId);
                      scaffoldMessengerKey.currentState?.showSnackBar(
                        const SnackBar(content: Text('Medicine deleted.')),
                      );
                      await AlarmScheduler.cancelAlarm(medicineId);
                    },
                    onEdit: (medicine) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MedicineFormScreen(
                            existingData: medicine,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding:
            const EdgeInsets.only(bottom: 100, left: 250), // Adjust as needed
        child: buildSpeedDial(context, userId),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
