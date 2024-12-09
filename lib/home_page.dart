import 'dart:async'; // Import Timer for periodic checks
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_medicine_screen.dart'; // Import the new screen
import 'services/notifications_service.dart'; // Import notification service

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String username =
      "Rishi"; // Replace with dynamic username logic if needed
  late DateTime today;
  late DateTime selectedDate;
  late ScrollController _scrollController; // Declare the controller
  Timer? _timer; // Timer to check periodically for notifications

  @override
  void initState() {
    super.initState();
    today = DateTime.now(); // Dynamically fetch today's date
    selectedDate = today; // Preselect today's date
    _scrollController = ScrollController(); // Initialize the scroll controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToDate(); // Scroll to the current date after the widget is built
    });
    _startPeriodicCheck(); // Start checking periodically for notifications
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    _scrollController.dispose();
    super.dispose();
  }

  // Start periodic check every 30 seconds
  void _startPeriodicCheck() {
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      _checkMedicineTimes();
    });
  }

  // Check if the current time matches any medicine time
  void _checkMedicineTimes() {
    DateTime now = DateTime.now();
    FirebaseFirestore.instance
        .collection('medicines')
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        var times = doc['times'] ?? [];
        if (times.isNotEmpty) {
          var timeStamp = times[0]; // Assuming the first time is the target
          if (timeStamp is Timestamp) {
            DateTime medicineTime = timeStamp.toDate();

            // Check if current time is within a 30-second window of the medicine time
            if (now.year == medicineTime.year &&
                now.month == medicineTime.month &&
                now.day == medicineTime.day &&
                (now.isAfter(medicineTime.subtract(Duration(seconds: 30))) &&
                    now.isBefore(medicineTime.add(Duration(seconds: 30))))) {
              // Trigger notification when time matches
              NotificationsService.showCustomNotification(
                "Medicine Reminder",
                "It's time to take your medicine: ${doc['name'] ?? 'Unnamed medicine'}",
              );
            }
          }
        }
      }
    });
  }

  // Scroll to the current date after the widget is built
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
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> dateRange = List.generate(
      21,
      (index) => today.subtract(Duration(days: 10 - index)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, $username!'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Handle settings navigation
            },
          ),
        ],
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
                      margin: EdgeInsets.symmetric(horizontal: 2),
                      padding:
                          EdgeInsets.symmetric(vertical: 6, horizontal: 12),
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
                          SizedBox(height: 4),
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
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('medicines') // 'medicines' collection
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                var medicines = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: medicines.length,
                  itemBuilder: (context, index) {
                    var medicine = medicines[index];
                    var medicineName = medicine['name'] ??
                        'Unnamed medicine'; // Default if 'name' is missing
                    var times = medicine['times'] ??
                        []; // A list of times for the medicine

                    // Display the first available time
                    String displayTime = 'No upcoming dose';

                    if (times.isNotEmpty) {
                      var timeStamp = times[0];
                      if (timeStamp is Timestamp) {
                        DateTime time = timeStamp.toDate();
                        displayTime = DateFormat("hh:mm a").format(time);
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  medicineName,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddMedicineScreen(),
                                        ),
                                      );
                                    } else if (value == 'delete') {
                                      FirebaseFirestore.instance
                                          .collection('medicines')
                                          .doc(medicine.id)
                                          .delete()
                                          .then((_) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text('Medicine deleted'),
                                        ));
                                      }).catchError((e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text('Error: $e'),
                                        ));
                                      });
                                    }
                                  },
                                  itemBuilder: (BuildContext context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit Reminder'),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete Reminder'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Divider(
                              color: Colors.grey,
                              thickness: 1,
                            ),
                            SizedBox(height: 8),
                            Text(
                              '$displayTime',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => AddMedicineScreen(),
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: const Color.fromARGB(255, 58, 55, 223),
        elevation: 5,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: 0,
        onTap: (index) {
          // Handle bottom navigation taps
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Box',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Me',
          ),
        ],
      ),
    );
  }
}
