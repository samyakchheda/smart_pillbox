import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'services/medicine_service.dart';

class AddMedicineScreen extends StatefulWidget {
  @override
  _AddMedicineScreenState createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  PageController _pageController = PageController();
  String medicineName = '';
  List<bool> isChecked = [false, false, false]; // Morning, Afternoon, Evening
  int currentPage = 0;
  Map<int, TimeOfDay?> selectedTimes = {}; // Selected times for each frequency

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Add padding above the progress bar
          SizedBox(height: 50),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16), // Reduce bar width
            child: LinearProgressIndicator(
              value: (currentPage + 1) / 3, // 3 pages total
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              minHeight: 2, // Thinner like a line
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _buildFirstScreen(context),
                _buildSecondScreen(),
                _buildThirdScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirstScreen(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Medicine',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextField(
                  controller: TextEditingController(
                    text: medicineName, // Populate with current value
                  )..selection = TextSelection.collapsed(
                      offset: medicineName.length, // Keep cursor at the end
                    ),
                  onChanged: (value) {
                    setState(() {
                      medicineName = value; // Update state on change
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Medicine Name',
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color.fromARGB(255, 58, 55, 223),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: medicineName.isNotEmpty
                  ? () {
                      FocusScope.of(context).unfocus();
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: medicineName.isNotEmpty
                    ? const Color.fromARGB(255, 58, 55, 223)
                    : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.all(16),
              ),
              child: Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool get isForwardEnabled =>
      isChecked.contains(true); // Check if any checkbox is selected

  Widget _buildSecondScreen() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Frequency',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the modal
                },
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildCheckbox('Morning', 0),
          _buildCheckbox('Afternoon', 1),
          _buildCheckbox('Evening', 2),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 58, 55, 223),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              ElevatedButton(
                onPressed: isForwardEnabled
                    ? () {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null, // Disable if no checkbox is selected
                style: ElevatedButton.styleFrom(
                  backgroundColor: isForwardEnabled
                      ? const Color.fromARGB(255, 58, 55, 223) // Enabled state
                      : Colors.grey, // Disabled state
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                ),
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(String label, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isChecked[index] = !isChecked[index];
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isChecked[index]
                ? const Color.fromARGB(255, 58, 55, 223)
                : Colors.grey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
          color: isChecked[index]
              ? const Color.fromARGB(50, 58, 55, 223)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Checkbox(
              value: isChecked[index],
              onChanged: (value) {
                setState(() {
                  isChecked[index] = value!;
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThirdScreen() {
    List<int> selectedIndices = isChecked
        .asMap()
        .entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Set Time',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: selectedIndices.length,
              itemBuilder: (context, index) {
                int frequencyIndex = selectedIndices[index];
                String label = [
                  'Morning 🌅',
                  'Afternoon 🌞',
                  'Evening 🌙'
                ][frequencyIndex];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 150, // Reduced height for rectangular box
                      decoration: BoxDecoration(
                        color: Color.fromARGB(
                            255, 242, 242, 242), // Light grey background
                        border: Border.all(
                          color: Colors.grey, // Light grey border color
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildTimePicker(
                            1, // Start from 1 for hours
                            12, // End at 12 for hours
                            selectedTimes[frequencyIndex]?.hour ??
                                0, // Set initial value to current hour or 0 if none
                            (value) {
                              setState(() {
                                selectedTimes[frequencyIndex] = TimeOfDay(
                                  hour: value,
                                  minute:
                                      selectedTimes[frequencyIndex]?.minute ??
                                          0,
                                );
                              });
                            },
                          ),
                          Text(
                            ':',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.black, // Black colon
                            ),
                          ),
                          _buildTimePicker(
                            0, // Start from 0 for minutes
                            59, // End at 59 for minutes
                            selectedTimes[frequencyIndex]?.minute ??
                                0, // Set initial value to current minute or 0 if none
                            (value) {
                              setState(() {
                                selectedTimes[frequencyIndex] = TimeOfDay(
                                  hour: selectedTimes[frequencyIndex]?.hour ??
                                      0, // Keep current hour
                                  minute: value, // Update the selected minute
                                );
                              });
                            },
                          ),
                          Text(
                            ':',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.black, // Black colon
                            ),
                          ),
                          _buildTimePicker(
                            0, // Start from 0 (AM)
                            1, // End at 1 (PM)
                            selectedTimes[frequencyIndex]?.hour == null
                                ? 0 // Set to 0 (AM) if time is null
                                : selectedTimes[frequencyIndex]!.hour >= 12
                                    ? 1 // PM
                                    : 0, // AM
                            (value) {
                              setState(() {
                                int currentHour =
                                    selectedTimes[frequencyIndex]?.hour ?? 0;
                                int currentMinute =
                                    selectedTimes[frequencyIndex]?.minute ?? 0;

                                if (value == 1) {
                                  // PM selected
                                  if (currentHour >= 1 && currentHour <= 11) {
                                    currentHour +=
                                        12; // Convert hour to PM (1-11 -> 13-23)
                                  } else if (currentHour == 12) {
                                    // Keep 12 PM as it is
                                    currentHour = 12;
                                  }
                                } else {
                                  // AM selected
                                  if (currentHour >= 12) {
                                    currentHour -=
                                        12; // Convert hour to AM (12 PM -> 0, 1 PM -> 1)
                                  }
                                }

                                // Update the selected time with the adjusted hour
                                selectedTimes[frequencyIndex] = TimeOfDay(
                                  hour: currentHour,
                                  minute: currentMinute,
                                );
                              });
                            },
                            labels: ['AM', 'PM'],
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _saveDataToFirestore(medicineName, isChecked, context);
              print("Selected Times: $selectedTimes");
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 58, 55, 223),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: EdgeInsets.all(16),
            ),
            child: Text(
              'Finish',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker(
      int min, int max, int initialValue, Function(int) onChange,
      {List<String>? labels}) {
    return Expanded(
      child: Stack(
        children: [
          // Horizontal line positioned above the selected number (closer to the number)
          Positioned(
            top: 40, // Reduced gap between the line and the selected number
            left: 20, // Added space from the left
            right: 20, // Added space from the right
            child: Row(
              children: [
                Expanded(
                  child: Divider(color: Colors.grey, thickness: 1.5),
                ),
                Expanded(child: Divider(color: Colors.grey, thickness: 1.5)),
              ],
            ),
          ),
          // Horizontal line positioned below the selected number (closer to the number)
          Positioned(
            bottom: 40, // Reduced gap between the line and the selected number
            left: 20, // Added space from the left
            right: 20, // Added space from the right
            child: Row(
              children: [
                Expanded(
                  child: Divider(color: Colors.grey, thickness: 1.5),
                ),
                Expanded(child: Divider(color: Colors.grey, thickness: 1.5)),
              ],
            ),
          ),
          // The list wheel scroll view for selecting values
          ListWheelScrollView.useDelegate(
            itemExtent: 40, // Adjusted size for smaller rectangular boxes
            physics: FixedExtentScrollPhysics(),
            onSelectedItemChanged: onChange,
            perspective: 0.003, // Adds more 3D perspective
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                final isSelected = (index == initialValue);

                // Calculate opacity based on the distance from the center
                final opacity = isSelected
                    ? 1.0
                    : (index == initialValue + 1 || index == initialValue - 1)
                        ? 0.5 // More faded for numbers just above and below
                        : 0.2; // Even more faded for numbers further away

                final textStyle = TextStyle(
                  fontSize: isSelected ? 18 : 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: Colors.black.withOpacity(opacity),
                );

                if (labels != null) {
                  return Center(
                    child: Text(
                      labels[index],
                      style: textStyle,
                    ),
                  );
                }
                return Center(
                  child: Text(
                    index.toString().padLeft(2, '0'),
                    style: textStyle,
                  ),
                );
              },
              childCount: labels != null ? labels.length : max - min + 1,
            ),
          ),
        ],
      ),
    );
  }

  // Firestore data saving logic
  void _saveDataToFirestore(
      String medicineName, List<bool> isChecked, BuildContext context) {
    // Prepare data: Convert times to DateTime format
    List<Timestamp> times = [];
    selectedTimes.forEach((key, value) {
      if (value != null) {
        // Combine TimeOfDay with today's date to create DateTime
        DateTime now = DateTime.now();
        DateTime dateTime =
            DateTime(now.year, now.month, now.day, value.hour, value.minute);

        // Convert DateTime to Firestore Timestamp
        times.add(Timestamp.fromDate(dateTime));
      }
    });

    // Add medicine function
    void addMedicine(String medicineName, List<bool> isChecked,
        List<Timestamp> times, BuildContext context) async {
      try {
        // Get the current user ID
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No user is logged in')),
            );
          }
          return;
        }

        String userId = currentUser.uid;

        // Add medicine to Firestore
        await FirebaseFirestore.instance
            .collection('users') // Target the users collection
            .doc(userId) // Use the logged-in user's ID
            .set({
          'medicines': FieldValue.arrayUnion([
            {
              'name': medicineName,
              'frequency': isChecked
                  .asMap()
                  .entries
                  .where((e) => e.value)
                  .map((e) => ['Morning', 'Afternoon', 'Evening'][e.key])
                  .toList(),
              'times': times, // Save DateTime as Firestore Timestamps
            }
          ])
        }, SetOptions(merge: true));

        // Show success message
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Medicine added')),
          );
        }

        Navigator.of(context).pop();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }

    // Call addMedicine with the prepared data
    addMedicine(medicineName, isChecked, times, context);
    // Fetch the user ID dynamically
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      checkMedicineTimes(user.uid); // Pass the userId to the function
    } else {
      print("User not logged in.");
    }
  }
}
