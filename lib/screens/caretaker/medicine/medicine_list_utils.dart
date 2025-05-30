import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:home/screens/caretaker/scan/ocr_screen.dart';
import 'package:home/screens/caretaker/scan/scanner_screen.dart';
import 'package:home/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';

// Utility Functions

List<DateTime> generateDateRange(DateTime today) {
  return List.generate(
    21,
    (index) => today.subtract(Duration(days: 10 - index)),
  );
}

void scrollToDate(BuildContext context, ScrollController scrollController,
    DateTime today, DateTime selectedDate) {
  List<DateTime> dateRange = generateDateRange(today);

  int selectedDateIndex = dateRange.indexWhere((date) =>
      date.day == selectedDate.day &&
      date.month == selectedDate.month &&
      date.year == selectedDate.year);

  if (selectedDateIndex == -1) return;

  double screenWidth = MediaQuery.of(context).size.width;
  double itemWidth = 54.0;

  double targetOffset =
      (selectedDateIndex * itemWidth) - (screenWidth / 3) + (itemWidth / 2);

  double finalOffset = targetOffset.clamp(
      scrollController.position.minScrollExtent,
      scrollController.position.maxScrollExtent);

  if (scrollController.hasClients) {
    scrollController.animateTo(
      finalOffset,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }
}

String getWeekdayName(DateTime date) {
  return DateFormat('EEEE').format(date);
}

String formatDate(Timestamp timestamp) {
  return DateFormat('dd-MM-yyyy').format(timestamp.toDate());
}

String formatMedicineTimes(List<dynamic> timestamps) {
  if (timestamps.isEmpty) return "No Time Set";

  List<String> formattedTimes = timestamps.map((timestamp) {
    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return DateFormat.jm().format(dateTime);
    }
    return "Invalid Time";
  }).toList();

  return formattedTimes.join(", ");
}

Future<void> deleteMedicine(
    FirebaseFirestore firestore, String userId, String medicineId) async {
  final docRef = firestore.collection('users').doc(userId);
  final docSnapshot = await docRef.get();

  if (!docSnapshot.exists) {
    return;
  }

  final medicines = List.from(docSnapshot.data()?['medicines'] ?? []);

  final medicineIndex =
      medicines.indexWhere((medicine) => medicine['id'] == medicineId);
  if (medicineIndex != -1) {
    medicines.removeAt(medicineIndex);
    await docRef.update({'medicines': medicines});
  }
}

// Widgets

class DateSelector extends StatelessWidget {
  final List<DateTime> dateRange;
  final DateTime selectedDate;
  final DateTime today;
  final ScrollController scrollController;
  final Function(DateTime) onDateSelected;

  const DateSelector({
    super.key,
    required this.dateRange,
    required this.selectedDate,
    required this.today,
    required this.scrollController,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Text(
              DateFormat('E, d\'th\' MMM').format(selectedDate),
              style: TextStyle(
                fontSize: 28,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: scrollController,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: dateRange.first,
                      lastDate: DateTime(2125),
                    );

                    if (pickedDate != null) {
                      onDateSelected(pickedDate);
                    }
                  },
                  child: Container(
                    width: 50.0,
                    height: 50.0,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      Icons.calendar_today,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                  ),
                ),
                ...List.generate(dateRange.length, (index) {
                  DateTime date = dateRange[index];
                  bool isSelected = date.day == selectedDate.day &&
                      date.month == selectedDate.month &&
                      date.year == selectedDate.year;
                  bool isFutureDate = date.isAfter(today);

                  return GestureDetector(
                    onTap: () => onDateSelected(date),
                    child: Container(
                      width: 50.0,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.cardBackground : null,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Column(
                        children: [
                          Text(
                            DateFormat('E').format(date)[0],
                            style: TextStyle(
                              fontSize: 18,
                              color: isFutureDate
                                  ? AppColors.textPlaceholder
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('d').format(date),
                            style: TextStyle(
                              fontWeight: isFutureDate
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              fontSize: 14,
                              color: isFutureDate
                                  ? AppColors.textPlaceholder
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                GestureDetector(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: dateRange.first,
                      lastDate: DateTime(2125),
                    );

                    if (pickedDate != null) {
                      onDateSelected(pickedDate);
                    }
                  },
                  child: Container(
                    width: 50.0,
                    height: 50.0,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      Icons.calendar_today,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MedicineList extends StatelessWidget {
  final FirebaseFirestore firestore;
  final String userId;
  final DateTime selectedDate;

  const MedicineList({
    super.key,
    required this.firestore,
    required this.userId,
    required this.selectedDate,
  });

  DateTime getNextScheduledTime(
      List<Timestamp> times, DateTime selectedDate, DateTime now) {
    List<DateTime> scheduledTimes = times.map((ts) {
      final DateTime dt = ts.toDate().toLocal();
      return DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        dt.hour,
        dt.minute,
        dt.second,
      );
    }).toList();

    if (selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day) {
      List<DateTime> upcoming =
          scheduledTimes.where((time) => time.isAfter(now)).toList();
      if (upcoming.isNotEmpty) {
        upcoming.sort((a, b) => a.compareTo(b));
        return upcoming.first;
      }
    }
    scheduledTimes.sort((a, b) => a.compareTo(b));
    return scheduledTimes.first;
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserEmail =
        FirebaseAuth.instance.currentUser?.email?.trim().toLowerCase() ?? '';

    return FutureBuilder<QuerySnapshot>(
      future: firestore
          .collection('caretakers')
          .where('email', isEqualTo: currentUserEmail)
          .get(),
      builder: (context, caretakerSnapshot) {
        if (caretakerSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.buttonColor,
            ),
          );
        }
        if (caretakerSnapshot.hasData &&
            caretakerSnapshot.data!.docs.isNotEmpty) {
          final caretakerDoc = caretakerSnapshot.data!.docs.first;
          final caretakerData = caretakerDoc.data() as Map<String, dynamic>;
          final String patientEmail = caretakerData['patient'] ?? '';
          if (patientEmail.isEmpty) {
            return Center(
                child: Text('Patient email not found in caretaker data.'.tr(),
                    style: TextStyle(color: AppColors.textPrimary)));
          }
          return StreamBuilder<QuerySnapshot>(
            stream: firestore
                .collection('users')
                .where('email', isEqualTo: patientEmail.trim().toLowerCase())
                .snapshots(),
            builder: (context, patientSnapshot) {
              if (patientSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.buttonColor,
                  ),
                );
              }
              if (!patientSnapshot.hasData ||
                  patientSnapshot.data!.docs.isEmpty) {
                return Center(
                    child: Text('No medicines found for patient.'.tr(),
                        style: TextStyle(color: AppColors.textPrimary)));
              }
              final patientDoc = patientSnapshot.data!.docs.first;
              Map<String, dynamic> data =
                  patientDoc.data() as Map<String, dynamic>;
              List<dynamic> medicines = data['medicines'] ?? [];

              return buildMedicineList(context, medicines);
            },
          );
        } else {
          return StreamBuilder<DocumentSnapshot>(
            stream: firestore.collection('users').doc(userId).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.buttonColor,
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return Center(
                    child: Text(
                        'No medicines found. Click "+" to add one.'.tr(),
                        style: TextStyle(color: AppColors.textPrimary)));
              }
              Map<String, dynamic> data =
                  snapshot.data!.data() as Map<String, dynamic>;
              List<dynamic> medicines = data['medicines'] ?? [];

              return buildMedicineList(context, medicines);
            },
          );
        }
      },
    );
  }

  Widget buildMedicineList(BuildContext context, List<dynamic> medicines) {
    if (medicines.isEmpty) {
      return Center(
        child: Text('No medicines found. Click "+" to add one.'.tr(),
            style: TextStyle(color: AppColors.textPrimary)),
      );
    }

    DateTime selectedDayUtc = DateTime.utc(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    String selectedWeekday = DateFormat('EEE').format(selectedDate);

    String selectedDateString = DateFormat('dd-MM-yyyy').format(selectedDate);

    var filteredMedicines = medicines.where((medicine) {
      List<String> scheduledDays = List<String>.from(medicine['selectedDays']);
      DateTime startDate =
          (medicine['startDate'] as Timestamp).toDate().toLocal();
      DateTime endDate = (medicine['endDate'] as Timestamp)
          .toDate()
          .toLocal()
          .add(const Duration(hours: 23, minutes: 59, seconds: 59));

      bool isWithinDateRange = (selectedDayUtc.isAfter(startDate) &&
              selectedDayUtc.isBefore(endDate)) ||
          selectedDayUtc.isAtSameMomentAs(startDate) ||
          selectedDayUtc.isAtSameMomentAs(endDate);
      bool isScheduledOnDay = scheduledDays.contains(selectedWeekday);
      return isWithinDateRange && isScheduledOnDay;
    }).toList();

    if (filteredMedicines.isEmpty) {
      return Center(
          child: Text('No medicines scheduled for this day.'.tr(),
              style: TextStyle(color: AppColors.textPrimary)));
    }

    DateTime now = DateTime.now().toLocal();
    filteredMedicines.sort((a, b) {
      List<Timestamp> timesA = List<Timestamp>.from(a['medicineTimes']);
      List<Timestamp> timesB = List<Timestamp>.from(b['medicineTimes']);

      DateTime nextTimeA = getNextScheduledTime(timesA, selectedDate, now);
      DateTime nextTimeB = getNextScheduledTime(timesB, selectedDate, now);

      return nextTimeA.compareTo(nextTimeB);
    });

    return ListView.builder(
      itemCount: filteredMedicines.length,
      itemBuilder: (context, index) {
        var medicine = filteredMedicines[index];

        String dailyStatus = 'not taken';
        if (medicine['status'] != null && medicine['status'] is Map) {
          dailyStatus = medicine['status'][selectedDateString] ?? 'not taken';
        }

        String startDate = formatDate(medicine['startDate']);
        String endDate = formatDate(medicine['endDate']);
        DateTime nextScheduledTime = getNextScheduledTime(
          List<Timestamp>.from(medicine['medicineTimes']),
          selectedDate,
          now,
        );

        String time = DateFormat('hh:mm a').format(nextScheduledTime);

        return TimelineTile(
          alignment: TimelineAlign.manual,
          lineXY: 0.1,
          isFirst: index == 0,
          isLast: index == filteredMedicines.length - 1,
          indicatorStyle: IndicatorStyle(
            width: 30,
            padding: const EdgeInsets.symmetric(vertical: 16),
            indicator: dailyStatus == 'taken'
                ? Icon(Icons.check_circle, color: Colors.green, size: 30)
                : Icon(Icons.remove_circle_outline,
                    color: AppColors.errorColor, size: 30),
          ),
          beforeLineStyle: LineStyle(
            color: AppColors.borderColor,
            thickness: 2,
          ),
          afterLineStyle: LineStyle(
            color: AppColors.borderColor,
            thickness: 2,
          ),
          endChild: GestureDetector(
            onLongPress: () async {
              HapticFeedback.vibrate();
              bool? confirmDelete = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: AppColors.buttonColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    backgroundColor: AppColors.cardBackground,
                    elevation: 10,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    title: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.errorColor,
                          size: 30,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Delete Item?'.tr(),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    content: Text(
                      'Do you want to delete this medicine entry? This action cannot be undone.'
                          .tr(),
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    actions: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppColors.buttonColor,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: Text(
                          'Cancel'.tr(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.buttonColor,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.errorColor,
                          foregroundColor: AppColors.buttonText,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          elevation: 2,
                        ),
                        child: Text(
                          'Delete'.tr(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.buttonText,
                          ),
                        ),
                      ),
                    ],
                    actionsPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    actionsAlignment: MainAxisAlignment.spaceBetween,
                  );
                },
              );
              if (confirmDelete == true) {
                await deleteMedicine(firestore, userId, medicine['id']);
              }
            },
            child: AnimatedMedicineCard(
              medicine: medicine,
              startDate: startDate,
              endDate: endDate,
            ),
          ),
        );
      },
    );
  }
}

class AnimatedMedicineCard extends StatefulWidget {
  final Map<String, dynamic> medicine;
  final String startDate;
  final String endDate;

  const AnimatedMedicineCard({
    super.key,
    required this.medicine,
    required this.startDate,
    required this.endDate,
  });

  @override
  _AnimatedMedicineCardState createState() => _AnimatedMedicineCardState();
}

class _AnimatedMedicineCardState extends State<AnimatedMedicineCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double screenWidth = size.width;
    final double screenHeight = size.height;

    final double scaleFactor = screenWidth / 375.0;
    final double verticalMargin = screenHeight * 0.015;
    final double horizontalMargin = screenWidth * 0.04;
    final double paddingScale = scaleFactor.clamp(0.8, 1.5);

    String formattedTimes = DateFormat('hh:mm a').format(
      DateTime.parse(widget.medicine['medicineTimes'][0].toDate().toString()),
    );
    List<String> timeParts = formattedTimes.split(' ');
    String time = timeParts[0];
    String amPm = timeParts[1];

    return SlideTransition(
      position: _animation,
      child: GestureDetector(
        child: Card(
          color: AppColors.cardBackground,
          margin: EdgeInsets.symmetric(
            vertical: verticalMargin,
            horizontal: horizontalMargin,
          ),
          elevation: 8 * scaleFactor,
          shadowColor: AppColors.borderColor.withOpacity(0.26),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(60 * scaleFactor),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 16 * paddingScale,
              horizontal: 20 * paddingScale,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 70 * scaleFactor,
                  height: 70 * scaleFactor,
                  decoration: BoxDecoration(
                    color: AppColors.darkBackground,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.buttonColor,
                      width: 4 * scaleFactor,
                    ),
                  ),
                  child: Icon(
                    FontAwesomeIcons.pills,
                    color: AppColors.textPrimary,
                    size: 36 * scaleFactor,
                  ),
                ),
                SizedBox(width: 20 * scaleFactor),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.medicine['medicineNames']?.isNotEmpty == true
                            ? widget.medicine['medicineNames'][0]
                            : 'Unnamed',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20 * scaleFactor,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 6 * scaleFactor),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 18 * scaleFactor,
                            color: AppColors.textPrimary,
                          ),
                          SizedBox(width: 6 * scaleFactor),
                          Text(
                            '$time $amPm',
                            style: TextStyle(
                              fontSize: 16 * scaleFactor,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6 * scaleFactor),
                      Text(
                        widget.medicine['doseFrequency']?.isNotEmpty == true
                            ? widget.medicine['doseFrequency']
                            : '',
                        style: TextStyle(
                          fontSize: 16 * scaleFactor,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: AppColors.textPrimary,
                    size: 30 * scaleFactor,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12 * scaleFactor),
                  ),
                  color: AppColors.cardBackground,
                  elevation: 4 * scaleFactor,
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit,
                            color: AppColors.buttonColor,
                            size: 30 * scaleFactor,
                          ),
                          SizedBox(width: 12 * scaleFactor),
                          Text(
                            'Edit'.tr(),
                            style: TextStyle(
                              fontSize: 18 * scaleFactor,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            color: AppColors.errorColor,
                            size: 30 * scaleFactor,
                          ),
                          SizedBox(width: 12 * scaleFactor),
                          Text(
                            'Delete'.tr(),
                            style: TextStyle(
                              fontSize: 18 * scaleFactor,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget buildSpeedDial(
    BuildContext context, String userId, ValueNotifier<bool> isOpen) {
  return SpeedDial(
    icon: Icons.add,
    activeIcon: Icons.close,
    backgroundColor: AppColors.buttonColor,
    foregroundColor: AppColors.buttonText,
    buttonSize: const Size(60, 60),
    openCloseDial: isOpen,
    renderOverlay: false,
    closeDialOnPop: true,
    children: [
      SpeedDialChild(
        child: const Icon(Icons.qr_code_scanner, color: Colors.white),
        backgroundColor: AppColors.buttonColor,
        foregroundColor: AppColors.buttonText,
        label: 'Scanner',
        labelBackgroundColor: AppColors.buttonColor,
        labelStyle: TextStyle(color: AppColors.buttonText, fontSize: 20),
        onTap: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: AppColors.cardBackground,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(Icons.medical_services,
                          color: AppColors.buttonColor),
                      title: Text(
                        'Scan Medicine'.tr(),
                        style: TextStyle(
                          fontSize: 20,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OCRScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: Icon(Icons.receipt_long,
                          color: AppColors.buttonColor),
                      title: Text(
                        'Scan Prescription'.tr(),
                        style: TextStyle(
                          fontSize: 20,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ScannerScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    ],
  );
}
