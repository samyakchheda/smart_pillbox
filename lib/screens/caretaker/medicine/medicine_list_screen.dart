import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:home/theme/app_colors.dart';
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

  late DateTime today;
  late DateTime selectedDate;
  late ScrollController _scrollController;
  int _selectedIndex = 0;

  // Add ValueNotifier to track SpeedDial open/close state
  late ValueNotifier<bool> _isSpeedDialOpen;

  @override
  void initState() {
    super.initState();
    today = DateTime.now();
    selectedDate = today;
    _scrollController = ScrollController();
    _isSpeedDialOpen = ValueNotifier<bool>(false); // Initialize ValueNotifier
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToDate();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _isSpeedDialOpen.dispose(); // Dispose of the ValueNotifier
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
      return Scaffold(
        body: Center(
          child: Text('User is not authenticated'.tr()),
        ),
      );
    }

    return Scaffold(
      key: scaffoldMessengerKey,
      body: Stack(
        children: [
          // Existing background and main UI
          Container(
            height: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.buttonColor,
                  Colors.grey.shade400,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          Column(
            children: [
              Container(
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
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: MedicineList(
                    firestore: _firestore,
                    userId: userId,
                    selectedDate: selectedDate,
                  ),
                ),
              ),
            ],
          ),
          // Custom gradient overlay for SpeedDial
          ValueListenableBuilder<bool>(
            valueListenable: _isSpeedDialOpen,
            builder: (context, value, child) {
              return AnimatedOpacity(
                opacity: value ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 150),
                child: value
                    ? Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment.bottomRight,
                              radius: 2.5,
                              colors: [
                                const Color(0xFF4276FD).withOpacity(0.4),
                                Colors.transparent,
                              ],
                              stops: const [0.1, 1.0],
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100, left: 250),
        child: buildSpeedDial(context, userId, _isSpeedDialOpen),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
