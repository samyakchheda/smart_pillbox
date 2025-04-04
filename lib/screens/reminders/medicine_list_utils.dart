import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:home/screens/home/loading.dart';
import 'package:home/screens/scanner/ocr_screen.dart';
import 'package:home/screens/scanner/scanner_screen.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../../theme/app_colors.dart';
import 'medicine_form_screen.dart';

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

  if (selectedDateIndex == -1) return; // Prevent errors if date not found

  double screenWidth = MediaQuery.of(context).size.width;
  double itemWidth = 54.0; // 50 width + 2 margin on each side

  // Calculate target scroll offset while keeping the selected date centered
  double maxScrollExtent = scrollController.position.maxScrollExtent;
  double minScrollExtent = scrollController.position.minScrollExtent;

  double targetOffset =
      (selectedDateIndex * itemWidth) - (screenWidth / 3) + (itemWidth / 2);

  // Ensure offset is within valid scroll bounds
  double finalOffset = targetOffset.clamp(minScrollExtent, maxScrollExtent);

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
      return DateFormat.jm().format(dateTime); // Example: "10:30 AM"
    }
    return "Invalid Time";
  }).toList();

  return formattedTimes.join(", "); // Join times with a comma
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
    Key? key,
    required this.dateRange,
    required this.selectedDate,
    required this.today,
    required this.scrollController,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text above the calendar with dynamic date
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Text(
              DateFormat('E, d\'th\' MMM').format(selectedDate),
              style: const TextStyle(
                fontSize: 28,
                color: Colors.black,
              ),
            ),
          ),
          // const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: scrollController,
            child: Row(
              children: [
                // Calendar Button
                GestureDetector(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate:
                          dateRange.first, // Keep the earliest available date
                      lastDate: DateTime(2125), // Allow selecting future dates
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                          15), // Adjust the radius for roundness
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                ),
                // Generate Date Items
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
                        color: isSelected ? Colors.white : null,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Column(
                        children: [
                          Text(
                            DateFormat('E').format(date)[0],
                            style: TextStyle(
                              fontSize: 18,
                              color:
                                  isFutureDate ? Colors.black54 : Colors.black,
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
                              color:
                                  isFutureDate ? Colors.black54 : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                // Calendar Button
                GestureDetector(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate:
                          dateRange.first, // Keep the earliest available date
                      lastDate: DateTime(2125), // Allow selecting future dates
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                          15), // Adjust the radius for roundness
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      color: Colors.black,
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
  final Function(String) onDelete;
  final Function(Map<String, dynamic>) onEdit;

  const MedicineList({
    Key? key,
    required this.firestore,
    required this.userId,
    required this.selectedDate,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  // Helper function to get the next scheduled time on the selected date.
  DateTime getNextScheduledTime(
      List<Timestamp> times, DateTime selectedDate, DateTime now) {
    // Map each Timestamp to a DateTime on the selected day.
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

    // If the selected date is today, try to pick a time that is still in the future.
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
    // Otherwise (or if all times today have passed), return the earliest time of the day.
    scheduledTimes.sort((a, b) => a.compareTo(b));
    return scheduledTimes.first;
  }

  @override
  Widget build(BuildContext context) {
    // Fetch the current user's email from FirebaseAuth.
    final String currentUserEmail =
        FirebaseAuth.instance.currentUser?.email?.trim().toLowerCase() ?? '';

    // First, check if there's a caretaker document for the current user's email.
    return FutureBuilder<QuerySnapshot>(
      future: firestore
          .collection('caretakers')
          .where('email', isEqualTo: currentUserEmail)
          .get(),
      builder: (context, caretakerSnapshot) {
        if (caretakerSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: RotatingPillAnimation());
        }
        // If caretaker doc exists, treat this user as a caretaker.
        if (caretakerSnapshot.hasData &&
            caretakerSnapshot.data!.docs.isNotEmpty) {
          final caretakerDoc = caretakerSnapshot.data!.docs.first;
          final caretakerData = caretakerDoc.data() as Map<String, dynamic>;
          final String patientEmail = caretakerData['patient'] ?? '';
          if (patientEmail.isEmpty) {
            return const Center(
                child: Text('Patient email not found in caretaker data.'));
          }
          // Query the "users" collection for the patient document using patientEmail.
          return StreamBuilder<QuerySnapshot>(
            stream: firestore
                .collection('users')
                .where('email', isEqualTo: patientEmail.trim().toLowerCase())
                .snapshots(),
            builder: (context, patientSnapshot) {
              if (patientSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!patientSnapshot.hasData ||
                  patientSnapshot.data!.docs.isEmpty) {
                return const Center(
                    child: Text('No medicines found for patient.'));
              }
              final patientDoc = patientSnapshot.data!.docs.first;
              Map<String, dynamic> data =
                  patientDoc.data() as Map<String, dynamic>;
              List<dynamic> medicines = data['medicines'] ?? [];

              return buildMedicineList(context, medicines);
            },
          );
        } else {
          // No caretaker document found – use the normal user's document.
          return StreamBuilder<DocumentSnapshot>(
            stream: firestore.collection('users').doc(userId).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(
                    child: Text('No medicines found. Click "+" to add one.'));
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
      return const Center(
        child: Text('No medicines found. Click "+" to add one.'),
      );
    }

    // Ensure selectedDate uses the same timezone by converting to UTC.
    DateTime selectedDayUtc = DateTime.utc(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    String selectedWeekday = DateFormat('EEE').format(selectedDate);

    // Format the selected date to match how it's stored in Firestore
    // e.g., "02-04-2025"
    // ------------------------------------------ // ADDED
    String selectedDateString = DateFormat('dd-MM-yyyy').format(selectedDate);
    // ------------------------------------------

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
      return const Center(child: Text('No medicines scheduled for this day.'));
    }

    // Sorting based on next scheduled medicine time for the selected day.
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

        // Safely extract daily status for this selectedDateString
        // ------------------------------------------ // ADDED
        String dailyStatus = 'not taken'; // default
        if (medicine['status'] != null && medicine['status'] is Map) {
          // Example: medicine['status']['02-04-2025'] -> "taken" or "not taken"
          dailyStatus = medicine['status'][selectedDateString] ?? 'not taken';
        }
        // ------------------------------------------

        String startDate = formatDate(medicine['startDate']);
        String endDate = formatDate(medicine['endDate']);
        DateTime nextScheduledTime = getNextScheduledTime(
          List<Timestamp>.from(medicine['medicineTimes']),
          selectedDate,
          now,
        );

        // Format the scheduled time
        String time = DateFormat('hh:mm a').format(nextScheduledTime);

        return Dismissible(
          key: Key(medicine['id']),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) async {
            await onDelete(medicine['id']);
          },
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Confirm Deletion'),
                content: Text(
                  'Are you sure you want to delete ${medicine['medicineNames'].first}?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
          },
          background: Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
              size: 40,
            ),
          ),
          child: TimelineTile(
            alignment: TimelineAlign.manual,
            lineXY: 0.1,
            isFirst: index == 0,
            isLast: index == filteredMedicines.length - 1,
            indicatorStyle: IndicatorStyle(
              width: 30,
              padding: const EdgeInsets.symmetric(vertical: 16),
              // Use the dailyStatus to decide the icon color
              indicator: dailyStatus == 'taken'
                  ? const Icon(Icons.check_circle,
                      color: Colors.green, size: 30)
                  : const Icon(Icons.remove_circle_outline,
                      color: Colors.red, size: 30),
            ),
            beforeLineStyle: const LineStyle(
              color: Colors.grey,
              thickness: 2,
            ),
            afterLineStyle: const LineStyle(
              color: Colors.grey,
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
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.redAccent,
                            size: 30,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Delete Item?',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      content: const Text(
                        'Do you want to delete this medicine entry? This action cannot be undone.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
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
                            'Cancel',
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
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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
                  onDelete(medicine['id']);
                }
              },
              child: AnimatedMedicineCard(
                medicine: medicine,
                startDate: startDate,
                endDate: endDate,
                onEdit: () => onEdit(medicine),
                onDelete: () => onDelete(medicine['id']),
              ),
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
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AnimatedMedicineCard({
    Key? key,
    required this.medicine,
    required this.startDate,
    required this.endDate,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

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
    // Get screen size using MediaQuery
    final size = MediaQuery.of(context).size;
    final double screenWidth = size.width;
    final double screenHeight = size.height;

    // Responsive scaling factors
    final double scaleFactor =
        screenWidth / 375.0; // Based on standard mobile width
    final double verticalMargin = screenHeight * 0.015; // 1.5% of screen height
    final double horizontalMargin = screenWidth * 0.04; // 4% of screen width
    final double paddingScale =
        scaleFactor.clamp(0.8, 1.5); // Limit scaling range

    // Format the times in 12-hour format with AM/PM
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
            vertical: verticalMargin, // Responsive vertical margin
            horizontal: horizontalMargin, // Responsive horizontal margin
          ),
          elevation: 8 * scaleFactor, // Scale elevation
          shadowColor: Colors.black26,
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
                // Medicine image with responsive size
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
                    color: Colors.black87,
                    size: 36 * scaleFactor,
                  ),
                ),
                SizedBox(width: 20 * scaleFactor),
                // Medicine details
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
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 6 * scaleFactor),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 18 * scaleFactor,
                            color: Colors.black87,
                          ),
                          SizedBox(width: 6 * scaleFactor),
                          Text(
                            '$time $amPm',
                            style: TextStyle(
                              fontSize: 16 * scaleFactor,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
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
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // PopupMenuButton
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.black87,
                    size: 30 * scaleFactor,
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      widget.onEdit();
                    } else if (value == 'delete') {
                      widget.onDelete();
                    }
                  },
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
                            'Edit',
                            style: TextStyle(
                              fontSize: 18 * scaleFactor,
                              color: Colors.black87,
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
                            color: Colors.redAccent,
                            size: 30 * scaleFactor,
                          ),
                          SizedBox(width: 12 * scaleFactor),
                          Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 18 * scaleFactor,
                              color: Colors.black87,
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
    foregroundColor: Colors.white,
    buttonSize: const Size(60, 60),
    openCloseDial: isOpen, // Bind the ValueNotifier
    renderOverlay: false, // Disable default overlay
    closeDialOnPop: true, // Ensure SpeedDial closes on navigation
    children: [
      SpeedDialChild(
        child: const Icon(Icons.medical_services),
        backgroundColor: const Color(0xFF4276FD),
        foregroundColor: Colors.white,
        label: 'Add Medicine',
        labelBackgroundColor: const Color(0xFF4276FD),
        labelStyle: const TextStyle(color: Colors.white, fontSize: 20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MedicineFormScreen(),
            ),
          );
        },
      ),
      SpeedDialChild(
        child: const Icon(Icons.qr_code_scanner, color: Colors.white),
        backgroundColor: const Color(0xFF4276FD),
        foregroundColor: Colors.white,
        label: 'Scanner',
        labelBackgroundColor: const Color(0xFF4276FD),
        labelStyle: const TextStyle(color: Colors.white, fontSize: 20),
        onTap: () {
          // Show a modal bottom sheet with two additional scanner options
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.white,
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
                      leading: const Icon(Icons.medical_services,
                          color: Color(0xFF4276FD)),
                      title: const Text(
                        'Scan Medicine',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context); // Dismiss bottom sheet
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OCRScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.receipt_long,
                          color: Color(0xFF4276FD)),
                      title: const Text(
                        'Scan Prescription',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context); // Dismiss bottom sheet
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScannerScreen(userId: userId),
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
