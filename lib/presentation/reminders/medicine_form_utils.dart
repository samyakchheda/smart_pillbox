import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:home/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MedicineNameInput extends StatefulWidget {
  final TextEditingController controller;
  final List<String> enteredMedicines;
  final VoidCallback onAdd;
  final Function(String) onRemove;

  const MedicineNameInput({
    Key? key,
    required this.controller,
    required this.enteredMedicines,
    required this.onAdd,
    required this.onRemove,
  }) : super(key: key);

  @override
  _MedicineNameInputState createState() => _MedicineNameInputState();
}

class _MedicineNameInputState extends State<MedicineNameInput> {
  List<String> suggestions = [];
  bool isLoading = false;

  // Fetch suggestions from the API based on user input.
  Future<void> _fetchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        suggestions = [];
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url =
        'https://samyak000-medicine-names.hf.space/api/autocomplete?query=${Uri.encodeComponent(query)}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> result = json.decode(response.body);
        if (result.containsKey("suggestions")) {
          // Extract product_name from each suggestion.
          setState(() {
            suggestions = List<String>.from(result["suggestions"]
                .map((suggestion) => suggestion["product_name"]));
          });
        } else {
          print("Unexpected API response format");
        }
      } else {
        print("Error fetching suggestions: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching suggestions: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onChanged(String value) {
    _fetchSuggestions(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          cursorColor: Colors.black,
          decoration: InputDecoration(
            labelText: 'Medicine Name',
            floatingLabelBehavior: FloatingLabelBehavior.never,
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                widget.onAdd();
                setState(() {
                  suggestions = [];
                });
              },
            ),
          ),
          onChanged: _onChanged,
        ),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: LinearProgressIndicator(),
          ),
        if (suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = suggestions[index];
                return ListTile(
                  title: Text(suggestion),
                  onTap: () {
                    widget.controller.text = suggestion;
                    setState(() {
                      suggestions = [];
                    });
                  },
                );
              },
            ),
          ),
        const SizedBox(height: 5),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: widget.enteredMedicines.map((medicineName) {
            return Chip(
              label: Text(
                medicineName,
                style: const TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.grey[200],
              deleteIcon: const Icon(Icons.close),
              onDeleted: () => widget.onRemove(medicineName),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class DateInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final VoidCallback onTap;

  const DateInput({
    Key? key,
    required this.controller,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200], // Light grey background
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.date_range),
          border: InputBorder.none, // Removes the default border
          contentPadding: const EdgeInsets.symmetric(
              vertical: 15, horizontal: 20), // Padding for text
        ),
        readOnly: true,
        onTap: onTap,
        validator: (value) =>
            value == null || value.isEmpty ? 'Please select a $label' : null,
      ),
    );
  }
}

class DaySelector extends StatefulWidget {
  final List<String> selectedDays;
  final Function(String, bool) onSelectionChanged;

  const DaySelector({
    Key? key,
    required this.selectedDays,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  _DaySelectorState createState() => _DaySelectorState();
}

class _DaySelectorState extends State<DaySelector> {
  bool isDaily = false;

  @override
  void initState() {
    super.initState();
    isDaily = widget.selectedDays.length == 7;
  }

  void _toggleDaily() {
    setState(() {
      isDaily = !isDaily;
      final List<String> allDays = [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun'
      ];
      // Toggle all days based on the new isDaily value
      for (var day in allDays) {
        widget.onSelectionChanged(day, isDaily);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> daysOfWeek = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Daily button added above the day list
        ElevatedButton(
          onPressed: _toggleDaily,
          child: Text(isDaily ? 'Clear All' : 'Select All'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: AppColors.buttonColor,
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.transparent,
                  Colors.white,
                  Colors.white,
                  Colors.transparent,
                ],
                stops: [0.0, 0.1, 0.9, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: daysOfWeek.map((day) {
                  final isSelected = widget.selectedDays.contains(day);
                  return GestureDetector(
                    onTap: () {
                      widget.onSelectionChanged(day, !isSelected);
                      setState(() {
                        isDaily = widget.selectedDays.length == 7;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: AppColors.buttonColor, width: 2)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            day,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.buttonColor
                                  : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? AppColors.buttonColor
                                  : Colors.white,
                              border: isSelected
                                  ? null
                                  : Border.all(color: Colors.grey, width: 2),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 16)
                                : const Icon(Icons.check,
                                    color: Colors.grey, size: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DoseFrequencyButtonForm extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const DoseFrequencyButtonForm({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> doseOptions = [
      '1 time, Daily',
      '2 times, Daily',
      '3 times, Daily',
      'Custom'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: doseOptions.map((option) {
            final isSelected = value == option;
            return ElevatedButton(
              onPressed: () => onChanged(option),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isSelected ? AppColors.buttonColor : Colors.grey[300],
                foregroundColor: isSelected ? Colors.white : Colors.black87,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14), // Maintain padding
                minimumSize: const Size(
                    300, 40), // Increased width (kept height the same)
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: isSelected ? 4 : 2,
              ),
              child: Text(
                option,
                style: const TextStyle(
                  fontSize: 16, // Text size remains the same
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
        if (value == null || value!.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Please select a dose frequency',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }
}

class DoseFrequencySelector extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const DoseFrequencySelector({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      // Ensures everything is centered on the screen
      child: Column(
        mainAxisSize: MainAxisSize.min, // Keeps the column size minimal
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 140, // Maintain scrolling height
                width: 60, // Constrain width to focus on digits
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 44,
                  physics: const FixedExtentScrollPhysics(),
                  perspective: 0.005,
                  diameterRatio: 1.3,
                  onSelectedItemChanged: (index) {
                    final selectedFrequency = (index + 1).toString();
                    onChanged(selectedFrequency);
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      String frequency = (index + 1).toString();
                      bool isSelected = value == frequency;

                      return Center(
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 200),
                          tween: Tween<double>(
                              begin: 0.9, end: isSelected ? 1.2 : 1.0),
                          builder: (context, scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: Text(
                                frequency,
                                style: TextStyle(
                                  fontSize: isSelected ? 28 : 22,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? AppColors.buttonColor
                                      : Colors.grey[600],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    childCount: 5,
                  ),
                ),
              ),
              const SizedBox(width: 10), // Space between number & text
              const Text(
                "per day",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.buttonColor, // Fixed text color
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Uncomment this if you are not using an existing Timestamp type (e.g. from firebase)
// class Timestamp {
//   final DateTime dateTime;
//   Timestamp(this.dateTime);
//   factory Timestamp.fromDate(DateTime dateTime) => Timestamp(dateTime);
//   DateTime toDate() => dateTime;
// }

/// Custom time picker widget using ListWheelScrollView for hour, minute, and AM/PM selection.
class CustomTimePicker extends StatefulWidget {
  final Function(Timestamp) onTimeSelected;

  const CustomTimePicker({Key? key, required this.onTimeSelected})
      : super(key: key);

  @override
  _CustomTimePickerState createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  int selectedHour = 12;
  int selectedMinute = 30;
  String selectedPeriod = 'AM';

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light().copyWith(
        dialogBackgroundColor: Colors.white, // Background color set to white
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Colors.black), // Title color
          bodyLarge: TextStyle(color: Colors.black), // General text color
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.black, // Button text color
          ),
        ),
      ),
      child: AlertDialog(
        title: const Text(
          'Select Time',
          style: TextStyle(color: Colors.black), // Title text color
        ),
        content: SizedBox(
          height: 180,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hours Wheel
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 40,
                  perspective: 0.01,
                  diameterRatio: 1.2,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      selectedHour = index + 1;
                    });
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      final isSelected = (index + 1) == selectedHour;
                      return Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? Colors.black : Colors.grey,
                          ),
                        ),
                      );
                    },
                    childCount: 12,
                  ),
                ),
              ),
              const Text(":",
                  style: TextStyle(fontSize: 24, color: Colors.black)),
              // Minutes Wheel
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 40,
                  perspective: 0.01,
                  diameterRatio: 1.2,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      selectedMinute = index;
                    });
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      final isSelected = index == selectedMinute;
                      return Center(
                        child: Text(
                          index.toString().padLeft(2, '0'),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? Colors.black : Colors.grey,
                          ),
                        ),
                      );
                    },
                    childCount: 60,
                  ),
                ),
              ),
              // AM/PM Wheel
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 40,
                  perspective: 0.01,
                  diameterRatio: 1.2,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      selectedPeriod = index == 0 ? 'AM' : 'PM';
                    });
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      final isSelected =
                          (index == 0 && selectedPeriod == 'AM') ||
                              (index == 1 && selectedPeriod == 'PM');
                      return Center(
                        child: Text(
                          index == 0 ? 'AM' : 'PM',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? Colors.black : Colors.grey,
                          ),
                        ),
                      );
                    },
                    childCount: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              int hour = selectedHour;
              if (selectedPeriod == 'PM' && hour != 12) {
                hour += 12;
              } else if (selectedPeriod == 'AM' && hour == 12) {
                hour = 0;
              }
              // Use a fixed date so that only the time-of-day matters.
              final fixedDateTime = DateTime(1970, 1, 1, hour, selectedMinute);
              widget.onTimeSelected(Timestamp.fromDate(fixedDateTime));
              Navigator.pop(context);
            },
            child: const Text("OK", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}

/// Widget that shows a table of intakes (rows) with a label and a time-selection button.
class MedicineTimeSelector extends StatelessWidget {
  /// A list where each index represents an intake’s selected time.
  /// If a time hasn’t been set for an intake, its value is null.
  final List<Timestamp?> medicineTimes;
  final int numberOfDoses;
  final Function(Timestamp) onTimeSelected;

  const MedicineTimeSelector({
    Key? key,
    required this.medicineTimes,
    required this.numberOfDoses,
    required this.onTimeSelected,
  }) : super(key: key);

  void _pickTime(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return CustomTimePicker(
          onTimeSelected: (timestamp) {
            onTimeSelected(timestamp);
          },
        );
      },
    );
  }

  /// Format the timestamp to a readable string (e.g., "5:08 PM").
  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return DateFormat.jm().format(dateTime);
  }

  /// Returns a label for the intake row (e.g., "1st Intake", "2nd Intake", etc.).
  String _getIntakeLabel(int index) {
    if (index == 0) return "1st Intake";
    if (index == 1) return "2nd Intake";
    if (index == 2) return "3rd Intake";
    return "${index + 1}th Intake";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Set background color
        borderRadius: BorderRadius.circular(12), // Curved borders
        border:
            Border.all(color: Colors.grey.shade300, width: 2), // Outer border
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
            12), // Ensures the table follows the rounded shape
        child: Table(
          border: TableBorder(
            horizontalInside: BorderSide(
                color: Colors.grey.shade300, width: 1), // Only horizontal lines
          ),
          columnWidths: const {
            0: FixedColumnWidth(120),
            1: FlexColumnWidth(),
          },
          children: List.generate(numberOfDoses, (index) {
            final Timestamp? time =
                index < medicineTimes.length ? medicineTimes[index] : null;
            final buttonText =
                time != null ? _formatTimestamp(time) : "Select time";

            return TableRow(
              children: [
                // Intake Label Cell
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      _getIntakeLabel(index),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                // Button Cell
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () => _pickTime(context, index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class AlarmNotificationToggle extends StatelessWidget {
  final bool isNotification;
  final ValueChanged<bool> onChanged;

  const AlarmNotificationToggle({
    Key? key,
    required this.isNotification,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Alarms',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: () => onChanged(!isNotification),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 60,
            height: 30,
            decoration: BoxDecoration(
              color: isNotification ? Colors.grey[300] : AppColors.buttonColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                // Moving Circle with Icon Inside
                AnimatedAlign(
                  duration: const Duration(milliseconds: 300),
                  alignment: isNotification
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 26,
                    height: 26,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: Icon(
                          isNotification ? Icons.notifications : Icons.alarm,
                          key: ValueKey<bool>(isNotification),
                          color: AppColors.buttonColor,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// Functions

void initializeFormData(
  Map<String, dynamic>? existingData,
  TextEditingController startDateController,
  TextEditingController endDateController,
  Function(Map<String, dynamic>) updateState,
) {
  if (existingData != null) {
    final enteredMedicines =
        List<String>.from(existingData['medicineNames'] ?? []);
    final selectedDays = List<String>.from(existingData['selectedDays'] ?? []);
    final doseFrequency = existingData['doseFrequency'];
    final medicineTimes =
        List<Timestamp>.from(existingData['medicineTimes'] ?? []);
    final isNotification = existingData['isActive'] ?? true;

    startDateController.text = existingData['startDate'] != null
        ? DateFormat('dd-MM-yyyy').format(existingData['startDate'].toDate())
        : '';
    endDateController.text = existingData['endDate'] != null
        ? DateFormat('dd-MM-yyyy').format(existingData['endDate'].toDate())
        : '';

    updateState({
      'enteredMedicines': enteredMedicines,
      'selectedDays': selectedDays,
      'doseFrequency': doseFrequency,
      'medicineTimes': medicineTimes,
      'isNotification': isNotification,
    });
  }
}

Future<void> selectDate(
    BuildContext context, TextEditingController controller) async {
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2099, 12, 31),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.light().copyWith(
          dialogBackgroundColor: Colors.white, // Background color set to white
          primaryColor: AppColors.buttonColor, // Adjust primary color
          colorScheme: const ColorScheme.light(
            primary: AppColors.buttonColor, // Highlight color
            onPrimary: Colors.white, // Button text color
            onSurface: Colors.black, // Default text color
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.buttonColor, // Button text color
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            labelStyle:
                const TextStyle(color: Colors.black), // Default label color
            floatingLabelStyle:
                const TextStyle(color: Colors.black), // Floating label color
            focusedBorder: OutlineInputBorder(
              // Ensures no purple border
              borderSide: BorderSide(color: Colors.black),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Colors.grey), // Default border color
            ),
          ),
        ),
        child: child!,
      );
    },
  );

  if (pickedDate != null) {
    controller.text = DateFormat('dd-MM-yyyy').format(pickedDate);
  }
}

int getDoseCount(String? doseFrequency, {int? customDoseCount}) {
  switch (doseFrequency) {
    case '1 time, Daily':
      return 1;
    case '2 times, Daily':
      return 2;
    case '3 times, Daily':
      return 3;
    case 'Custom':
      // Use customDoseCount to return the dynamic value
      return customDoseCount ?? 0; // Return 0 if customDoseCount is null
    default:
      return 0;
  }
}

Future<Timestamp?> addMedicineTime(BuildContext context, String? doseFrequency,
    List<Timestamp> medicineTimes, int? customDoseCount) async {
  int maxAllowedTimes;
  if (doseFrequency == 'Custom') {
    maxAllowedTimes =
        customDoseCount ?? 10; // Default to 10 if customDoseCount is null
  } else {
    maxAllowedTimes = getDoseCount(doseFrequency);
  }

  if (medicineTimes.length >= maxAllowedTimes) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'You can only add up to $maxAllowedTimes timings for the selected dose frequency.',
        ),
        backgroundColor: Colors.red,
      ),
    );
    return null;
  }

  final TimeOfDay? pickedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );
  if (pickedTime != null) {
    final now = DateTime.now();
    final dateTime = DateTime(
        now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
    return Timestamp.fromDate(dateTime);
  }
  return null;
}

bool validateForm(BuildContext context, List<String> enteredMedicines,
    String? doseFrequency, List<Timestamp> medicineTimes) {
  if (enteredMedicines.isEmpty) {
    showErrorSnackBar(context, 'Please enter at least one medicine');
    return false;
  }

  if (doseFrequency == null || doseFrequency.isEmpty) {
    showErrorSnackBar(context, 'Please select a dose frequency');
    return false;
  }

  final requiredDoseCount = getDoseCount(doseFrequency);
  if (medicineTimes.length < requiredDoseCount) {
    showErrorSnackBar(
      context,
      'Please add ${requiredDoseCount - medicineTimes.length} more timing(s) to match the selected dose frequency.',
    );
    return false;
  }

  return true;
}

void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ),
  );
}

Map<String, dynamic> createMedicineData(
  List<String> enteredMedicines,
  String startDate,
  String endDate,
  List<String> selectedDays,
  String doseFrequency,
  List<Timestamp> medicineTimes,
  bool isNotification,
) {
  const uuid = Uuid();
  String uniqueId = uuid.v4();

  return {
    'id': uniqueId,
    'medicineNames': enteredMedicines,
    'startDate': Timestamp.fromDate(
      DateFormat('dd-MM-yyyy').parse(startDate),
    ),
    'endDate': Timestamp.fromDate(
      DateFormat('dd-MM-yyyy').parse(endDate),
    ),
    'selectedDays': selectedDays,
    'doseFrequency': doseFrequency,
    'medicineTimes': medicineTimes,
    'isActive': isNotification,
  };
}

Future<void> saveMedicineData(String userId, Map<String, dynamic> medicineData,
    Map<String, dynamic>? existingData) async {
  final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
  final docSnapshot = await docRef.get();

  if (!docSnapshot.exists) {
    await docRef.set({
      'medicines': [medicineData]
    });
  } else {
    final medicines = List.from(docSnapshot.data()?['medicines'] ?? []);
    if (existingData != null) {
      final index = medicines
          .indexWhere((medicine) => medicine['id'] == existingData['id']);
      if (index != -1) medicines[index] = medicineData;
    } else {
      medicines.add(medicineData);
    }
    await docRef.update({'medicines': medicines});
  }
}
