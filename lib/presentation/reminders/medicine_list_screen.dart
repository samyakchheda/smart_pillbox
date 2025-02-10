import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:home/services/alarm_scheduler.dart';
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
      backgroundColor: Colors.grey.shade400,
      body: Column(
        children: [
          DateSelector(
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
          Expanded(
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
        ],
      ),
      floatingActionButton: buildSpeedDial(context, userId),
    );
  }
}
