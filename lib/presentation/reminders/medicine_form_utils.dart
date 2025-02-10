import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class MedicineNameInput extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Medicine Name',
            hintText: 'Enter the name of the medicine',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: onAdd,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: enteredMedicines.map((medicineName) {
            return Chip(
              label: Text(medicineName),
              deleteIcon: const Icon(Icons.close),
              onDeleted: () => onRemove(medicineName),
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
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Select a $label',
        suffixIcon: const Icon(Icons.date_range),
      ),
      readOnly: true,
      onTap: onTap,
      validator: (value) =>
          value == null || value.isEmpty ? 'Please select a $label' : null,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: _toggleDaily,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDaily ? Colors.blue : Colors.grey[300],
            foregroundColor: isDaily ? Colors.white : Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: Text(isDaily ? 'Daily' : 'Select Daily'),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          childAspectRatio: 2.5,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          physics: const NeverScrollableScrollPhysics(),
          children: daysOfWeek.map((day) {
            final isSelected = widget.selectedDays.contains(day);
            return InkWell(
              onTap: () {
                widget.onSelectionChanged(day, !isSelected);
                setState(() {
                  isDaily = widget.selectedDays.length == 7;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
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
                backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
                foregroundColor: isSelected ? Colors.white : Colors.black87,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: isSelected ? 4 : 2,
              ),
              child: Text(option),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Times per day',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListWheelScrollView.useDelegate(
            itemExtent: 40,
            physics: const FixedExtentScrollPhysics(),
            perspective: 0.005,
            diameterRatio: 1.2,
            onSelectedItemChanged: (index) {
              final selectedFrequency = (index + 1).toString();
              onChanged(selectedFrequency);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                String frequency = (index + 1).toString();
                bool isSelected = value == frequency;

                return Center(
                  child: Text(
                    frequency,
                    style: TextStyle(
                      fontSize: isSelected ? 26 : 22,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.blue : Colors.grey[700],
                    ),
                  ),
                );
              },
              childCount: 10,
            ),
          ),
        ),
      ],
    );
  }
}

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
    return AlertDialog(
      title: const Text('Select Time'),
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
                    selectedHour = (index + 1);
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
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.black : Colors.grey,
                        ),
                      ),
                    );
                  },
                  childCount: 12,
                ),
              ),
            ),

            const Text(":", style: TextStyle(fontSize: 24)),

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
                        '${index.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.black : Colors.grey,
                        ),
                      ),
                    );
                  },
                  childCount: 60,
                ),
              ),
            ),

            const Text(":", style: TextStyle(fontSize: 24)),

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
                    final isSelected = (index == 0 && selectedPeriod == 'AM') ||
                        (index == 1 && selectedPeriod == 'PM');
                    return Center(
                      child: Text(
                        index == 0 ? 'AM' : 'PM',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
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
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            final now = DateTime.now();
            int hour = selectedHour;
            if (selectedPeriod == 'PM' && hour != 12) {
              hour += 12;
            } else if (selectedPeriod == 'AM' && hour == 12) {
              hour = 0;
            }
            final dateTime =
                DateTime(now.year, now.month, now.day, hour, selectedMinute);
            widget.onTimeSelected(Timestamp.fromDate(dateTime));
            Navigator.pop(context);
          },
          child: const Text("OK"),
        ),
      ],
    );
  }
}

class MedicineTimeSelector extends StatelessWidget {
  final List<Timestamp> medicineTimes;
  final int numberOfDoses;
  final Function(Timestamp) onAddTime;
  final Function(int) onRemoveTime;

  const MedicineTimeSelector({
    Key? key,
    required this.medicineTimes,
    required this.numberOfDoses,
    required this.onAddTime,
    required this.onRemoveTime,
  }) : super(key: key);

  void _pickTime(BuildContext context) {
    if (medicineTimes.length < numberOfDoses) {
      showDialog(
        context: context,
        builder: (context) {
          return CustomTimePicker(
            onTimeSelected: (timestamp) {
              onAddTime(timestamp);
            },
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum number of doses reached')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: () => _pickTime(context),
          child: Text(
              "Add Medicine Time (${medicineTimes.length}/$numberOfDoses)"),
        ),
        const SizedBox(height: 10),
        ...medicineTimes.asMap().entries.map((entry) {
          final int index = entry.key;
          final Timestamp timestamp = entry.value;
          final String formattedTime =
              DateFormat('hh:mm a').format(timestamp.toDate());

          return ListTile(
            title: Text(formattedTime),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => onRemoveTime(index),
            ),
          );
        }).toList(),
      ],
    );
  }
}

class NotificationToggle extends StatelessWidget {
  final bool isNotification;
  final ValueChanged<bool> onChanged;

  const NotificationToggle({
    Key? key,
    required this.isNotification,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Alarms', style: TextStyle(fontWeight: FontWeight.bold)),
        Switch(
          value: isNotification,
          onChanged: onChanged,
        ),
        const Text('Notifications',
            style: TextStyle(fontWeight: FontWeight.bold)),
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
    lastDate:
        DateTime(2099, 12, 31), // Explicit last date to ensure correctness
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
