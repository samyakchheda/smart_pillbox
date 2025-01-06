import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'add_medicine_screen.dart'; // Import for adding medicines
import 'presentation/profile/user_profile_screen.dart'; // User profile screen

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String username =
      "Rishi"; // Replace with dynamic username logic if needed
  late DateTime today;
  late DateTime selectedDate;
  late ScrollController _scrollController;
  int _selectedIndex = 0;

  // Screens for navigation
  final List<Widget> _widgetOptions = [
    HomeContentScreen(),
    const UserProfileScreen(),
  ];

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.deepPurple,
        color: Colors.deepPurple.shade200,
        items: const [
          Icon(Icons.home, color: Colors.deepPurple, size: 30),
          Icon(Icons.person, color: Colors.deepPurple, size: 30),
        ],
        animationDuration: const Duration(milliseconds: 300),
        index: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeContentScreen extends StatefulWidget {
  @override
  _HomeContentScreenState createState() => _HomeContentScreenState();
}

class _HomeContentScreenState extends State<HomeContentScreen> {
  late DateTime today;
  late DateTime selectedDate;
  late ScrollController _scrollController;

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

  // Fetch the current user's UID
  String? getCurrentUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

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

  @override
  Widget build(BuildContext context) {
    List<DateTime> dateRange = List.generate(
      21,
      (index) => today.subtract(Duration(days: 10 - index)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
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
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data?.data() == null) {
                  return const Center(child: Text('No data available'));
                }

                var medicines = (snapshot.data!.data()
                        as Map<String, dynamic>)['medicines'] ??
                    [];

                if (medicines.isEmpty) {
                  return const Center(child: Text('No medicines found'));
                }

                return ListView.builder(
                  itemCount: medicines.length,
                  itemBuilder: (context, index) {
                    var medicine = medicines[index];
                    var medicineName = medicine['name'] ?? 'Unnamed medicine';
                    var times = medicine['times'] ?? [];

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
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
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
                                  style: const TextStyle(
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
                                      String? userId = getCurrentUserId();

                                      if (userId != null) {
                                        FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(userId)
                                            .update({
                                          'medicines':
                                              FieldValue.arrayRemove([medicine])
                                        });
                                      } else {
                                        print('User not logged in');
                                      }
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
                            const Divider(color: Colors.grey, thickness: 1),
                            const SizedBox(height: 8),
                            Text(
                              '$displayTime',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                            const Divider(color: Colors.grey, thickness: 1),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceEvenly, // Distribute buttons evenly
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // Handle Ring Daily action
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    minimumSize: const Size(60, 24),
                                  ),
                                  child: const Text(
                                    'Ring Daily',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // Handle Ring Once action
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                    minimumSize: const Size(60, 24),
                                  ),
                                  child: const Text(
                                    'Ring Once',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // Handle Custom action
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                    minimumSize: const Size(60, 24),
                                  ),
                                  child: const Text(
                                    'Custom',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => AddMedicineScreen(),
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: const Color.fromARGB(255, 58, 55, 223),
        elevation: 5,
      ),
    );
  }
}
