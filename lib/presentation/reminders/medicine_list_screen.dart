import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'medicine_form_screen.dart';

class MedicineListScreen extends StatefulWidget {
  MedicineListScreen({super.key});

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

  Future<void> deleteMedicine(String medicineId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return;
    }

    final docRef = _firestore.collection('users').doc(userId);
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

  String formatDate(Timestamp timestamp) {
    return DateFormat('dd-MM-yyyy').format(timestamp.toDate());
  }

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

  // Scroll to the current date
  void _scrollToDate() {
    List<DateTime> dateRange = List.generate(
      21,
      (index) => today.subtract(Duration(days: 10 - index)),
    );

    int selectedDateIndex = dateRange.indexWhere((date) =>
        date.day == selectedDate.day &&
        date.month == selectedDate.month &&
        date.year == selectedDate.year);

    double screenWidth = MediaQuery.of(context).size.width;
    double itemWidth = 50.0;
    double offset =
        (selectedDateIndex * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        offset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  // Helper to get the weekday name
  String _getWeekdayName(DateTime date) {
    return DateFormat('EEEE').format(date); // Returns full weekday name
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> dateRange = List.generate(
      21,
      (index) => today.subtract(Duration(days: 10 - index)),
    );

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
      appBar: AppBar(
        title: const Text('My Medicines'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _scrollController,
              child: Row(
                children: List.generate(dateRange.length, (index) {
                  DateTime date = dateRange[index];
                  bool isSelected = date.day == selectedDate.day &&
                      date.month == selectedDate.month &&
                      date.year == selectedDate.year;
                  bool isFutureDate = date.isAfter(today);

                  return GestureDetector(
                    onTap: isFutureDate
                        ? null
                        : () {
                            setState(() {
                              selectedDate = date;
                            });
                          },
                    child: Container(
                      width: 50.0,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.grey.withOpacity(0.2) : null,
                        borderRadius: BorderRadius.circular(8),
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
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: _firestore.collection('users').doc(userId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(
                      child: Text('No medicines found. Click "+" to add one.'));
                }

                var userDoc = snapshot.data;
                List<dynamic> medicines = userDoc!['medicines'] ?? [];

                if (medicines.isEmpty) {
                  return const Center(
                      child: Text('No medicines found. Click "+" to add one.'));
                }

                String selectedWeekday = _getWeekdayName(selectedDate);

                // Filter medicines for the selected weekday and date range
                var filteredMedicines = medicines.where((medicine) {
                  var scheduledDays =
                      List<String>.from(medicine['selectedDays']);
                  DateTime startDate =
                      (medicine['startDate'] as Timestamp).toDate();
                  DateTime endDate =
                      (medicine['endDate'] as Timestamp).toDate();

                  bool isWithinDateRange = selectedDate.isAfter(
                          startDate.subtract(const Duration(days: 1))) &&
                      selectedDate
                          .isBefore(endDate.add(const Duration(days: 1)));

                  bool isScheduledOnDay =
                      scheduledDays.contains(selectedWeekday);

                  return isWithinDateRange && isScheduledOnDay;
                }).toList();

                if (filteredMedicines.isEmpty) {
                  return const Center(
                      child: Text('No medicines scheduled for this day.'));
                }

                return ListView.builder(
                  itemCount: medicines.length,
                  itemBuilder: (context, index) {
                    var medicine = medicines[index];
                    String startDate = formatDate(medicine['startDate']);
                    String endDate = formatDate(medicine['endDate']);

                    return Dismissible(
                      key: Key(medicine['id']),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) async {
                        await deleteMedicine(medicine['id']);
                        scaffoldMessengerKey.currentState?.showSnackBar(
                          SnackBar(
                              content: Text(
                                  '${medicine['medicineNames'].first} deleted.')),
                        );
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
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Wrap(
                            spacing: 8.0,
                            children: medicine['medicineNames']
                                    ?.map<Widget>((name) => Text(
                                          name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ))
                                    .toList() ??
                                [const Text('Unnamed')],
                          ),
                          subtitle: Text('Start: $startDate\nEnd: $endDate'),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
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
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MedicineFormScreen(),
            ),
          );
        },
        tooltip: 'Add Medicine',
        child: const Icon(Icons.add),
      ),
    );
  }
}
