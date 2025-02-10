import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../scanner_screen.dart';
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
            padding: const EdgeInsets.only(top: 30.0),
            child: Text(
              DateFormat('E, d\'th\' MMM').format(selectedDate),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 16),
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
                          vertical: 6, horizontal: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : null,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Text(
                            DateFormat('E').format(date)[0],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isFutureDate ? Colors.grey : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('d').format(date),
                            style: TextStyle(
                              fontSize: 14,
                              color: isFutureDate ? Colors.grey : Colors.black,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Make the background transparent
      body: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFE0E0E0), // White background for the whole screen
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(0), // Padding for the content inside
            child: StreamBuilder<DocumentSnapshot>(
              stream: firestore.collection('users').doc(userId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(
                      child: Text('No medicines found. Click "+" to add one.'));
                }

                var userDoc = snapshot.data;
                Map<String, dynamic> data =
                    userDoc?.data() as Map<String, dynamic>;
                List<dynamic> medicines = data['medicines'] ?? [];

                if (medicines.isEmpty) {
                  return const Center(
                      child: Text('No medicines found. Click "+" to add one.'));
                }

                // Ensure selectedDate uses the same timezone
                DateTime selectedDayUtc = DateTime.utc(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                );

                String selectedWeekday =
                    DateFormat('EEE').format(selectedDate); // "Sat" format

                var filteredMedicines = medicines.where((medicine) {
                  List<String> scheduledDays =
                      List<String>.from(medicine['selectedDays']);
                  // Convert Firestore timestamp to local DateTime and set to end of the day
                  DateTime startDate =
                      (medicine['startDate'] as Timestamp).toDate().toLocal();
                  DateTime endDate = (medicine['endDate'] as Timestamp)
                      .toDate()
                      .toLocal()
                      .add(const Duration(hours: 23, minutes: 59, seconds: 59));

                  // Ensure date comparison matches correct timezone
                  bool isWithinDateRange = (selectedDayUtc.isAfter(startDate) &&
                          selectedDayUtc.isBefore(endDate)) ||
                      selectedDayUtc.isAtSameMomentAs(startDate) ||
                      selectedDayUtc.isAtSameMomentAs(endDate);

                  bool isScheduledOnDay =
                      scheduledDays.contains(selectedWeekday);

                  return isWithinDateRange && isScheduledOnDay;
                }).toList();

                if (filteredMedicines.isEmpty) {
                  return const Center(
                      child: Text('No medicines scheduled for this day.'));
                }

                // Sorting based on next medicine time
                filteredMedicines.sort((a, b) {
                  List<Timestamp> timesA =
                      List<Timestamp>.from(a['medicineTimes']);
                  List<Timestamp> timesB =
                      List<Timestamp>.from(b['medicineTimes']);

                  DateTime now =
                      DateTime.now().toLocal(); // Ensure correct timezone

                  DateTime? nextTimeA = timesA
                      .map((timestamp) => timestamp.toDate().toLocal())
                      .firstWhere((time) => time.isAfter(now),
                          orElse: () => DateTime(9999));

                  DateTime? nextTimeB = timesB
                      .map((timestamp) => timestamp.toDate().toLocal())
                      .firstWhere((time) => time.isAfter(now),
                          orElse: () => DateTime(9999));

                  return nextTimeA.compareTo(nextTimeB);
                });

                return ListView.builder(
                  itemCount: filteredMedicines.length,
                  itemBuilder: (context, index) {
                    var medicine = filteredMedicines[index];
                    String startDate = formatDate(medicine['startDate']);
                    String endDate = formatDate(medicine['endDate']);

                    return Dismissible(
                      key: Key(medicine['id']),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) async {
                        await onDelete(
                            medicine['id']); // Ensure we pass the correct ID
                      },
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Deletion'),
                            content: Text(
                                'Are you sure you want to delete ${medicine['medicineNames'].first}?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: AnimatedMedicineCard(
                        medicine: medicine,
                        startDate: startDate,
                        endDate: endDate,
                        onEdit: () => onEdit(medicine),
                        onDelete: () => onDelete(
                            medicine['id']), // Ensure correct ID is passed
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
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
      begin: const Offset(0, 1), // Start from bottom
      end: const Offset(0, 0), // Move to its position
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward(); // Start the animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Format the times in 12-hour format with AM/PM
    String formattedTimes = DateFormat('hh:mm a').format(
      DateTime.parse(widget.medicine['medicineTimes'][0].toDate().toString()),
    );

    // Split the time and AM/PM parts
    List<String> timeParts = formattedTimes.split(' ');
    String time = timeParts[0]; // hh:mm
    String amPm = timeParts[1]; // AM/PM

    return SlideTransition(
      position: _animation,
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 8,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          title: Row(
            children: [
              Text(
                time, // Show the time (hh:mm)
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30, // Increased font size for time
                ),
              ),
              const SizedBox(width: 4), // Space between time and AM/PM
              Text(
                amPm, // Show AM/PM
                style: const TextStyle(
                  fontSize: 12, // Reduced font size for AM/PM
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(
                  color:
                      Colors.black26), // Horizontal line between time and name
              const SizedBox(
                  height: 8), // Space between line and medicine names
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.medicine['medicineNames']
                        ?.map<Widget>(
                          (name) => Row(
                            children: [
                              const Icon(FontAwesomeIcons.pills,
                                  color: Colors.black87,
                                  size: 24), // Medicine icon
                              const SizedBox(
                                width: 15,
                                height: 40,
                              ), // Spacing between icon and text
                              Text(
                                name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        )
                        ?.toList() ??
                    [const Text('Unnamed')], // Fallback if no medicines exist
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert), // Three dots icon
            onSelected: (value) {
              if (value == 'edit') {
                widget.onEdit();
              } else if (value == 'delete') {
                widget.onDelete();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(
                      Icons.edit,
                      color: Colors.black,
                      size: 30,
                    ),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete,
                      color: Colors.black,
                      size: 30,
                    ),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildSpeedDial(BuildContext context, String userId) {
  return SpeedDial(
    icon: Icons.add,
    activeIcon: Icons.close,
    backgroundColor: Color(0xFF4276FD), // Background color remains the same
    foregroundColor: Colors.white, // Makes the '+' icon white
    children: [
      SpeedDialChild(
        child: const Icon(Icons.medical_services), // Ensure white icon
        backgroundColor: Color(0xFF4276FD),
        foregroundColor: Colors.white,
        label: 'Add Medicine', labelBackgroundColor: Color(0xFF4276FD),
        labelStyle: const TextStyle(
            color: Colors.white, fontSize: 20), // Makes text white
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
        child:
            const Icon(Icons.scanner, color: Colors.white), // Ensure white icon
        backgroundColor: Color(0xFF4276FD),
        foregroundColor: Colors.white,
        label: 'Scan Document', labelBackgroundColor: Color(0xFF4276FD),
        labelStyle: const TextStyle(
            color: Colors.white, fontSize: 18), // Makes text white,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScannerScreen(userId: userId),
            ),
          );
        },
      ),
    ],
  );
}
