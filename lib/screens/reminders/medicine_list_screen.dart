import 'package:easy_localization/easy_localization.dart';
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                colors: isDarkMode
                    ? [
                        AppColors.buttonColor.withOpacity(0.8), // Darkened blue
                        AppColors.darkBackground.withOpacity(0.9), // Dark gray
                      ]
                    : [
                        AppColors.buttonColor, // Light mode blue
                        Colors.grey.shade400, // Light mode gray
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
                  decoration: BoxDecoration(
                    color: AppColors.background,
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
                        SnackBar(content: Text('Medicine deleted.'.tr())),
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
