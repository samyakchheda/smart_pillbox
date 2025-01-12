import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MedicineFormScreen extends StatefulWidget {
  final Map<String, dynamic>? existingData;

  const MedicineFormScreen({super.key, this.existingData});

  @override
  _MedicineFormScreenState createState() => _MedicineFormScreenState();
}

class _MedicineFormScreenState extends State<MedicineFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medicineNameController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  List<String> selectedDays = [];
  List<String> medicineTimes = [];
  String? doseFrequency;
  bool isNotification = true;

  final List<String> daysOfWeek = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];
  final List<String> doseOptions = ['Once', 'Twice', 'Thrice', 'More'];

  String? previousDoseFrequency;

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      _medicineNameController.text = widget.existingData!['medicineName'] ?? '';
      _startDateController.text = widget.existingData!['startDate'] ?? '';
      _endDateController.text = widget.existingData!['endDate'] ?? '';
      selectedDays = List<String>.from(widget.existingData!['selectedDays'] ?? []);
      doseFrequency = widget.existingData!['doseFrequency'];
      medicineTimes = List<String>.from(widget.existingData!['medicineTimes'] ?? []);
      isNotification = widget.existingData!['isActive'] ?? true;
      previousDoseFrequency = widget.existingData!['doseFrequency'];
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }

  void _addMedicineTime() async {
    if (medicineTimes.length >= _getDoseCount()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have already added the maximum number of times.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        medicineTimes.add(pickedTime.format(context));
      });
    }
  }

  int _getDoseCount() {
    switch (doseFrequency) {
      case 'Once':
        return 1;
      case 'Twice':
        return 2;
      case 'Thrice':
        return 3;
      case 'More':
        return 4;
      default:
        return 0;
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (medicineTimes.length < _getDoseCount()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add all required medicine times.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (previousDoseFrequency != null && _doseFrequencyIsDecreased()) {
        bool shouldProceed = await _showDoseChangeAlert();
        if (!shouldProceed) {
          return;
        }
      }

      final medicineData = {
        'medicineName': _medicineNameController.text,
        'startDate': _startDateController.text,
        'endDate': _endDateController.text,
        'selectedDays': selectedDays,
        'doseFrequency': doseFrequency,
        'medicineTimes': medicineTimes,
        'isActive': isNotification,
      };

      if (widget.existingData != null) {
        // Update existing record
        final docId = widget.existingData!['id'];
        await FirebaseFirestore.instance
            .collection('medicines')
            .doc(docId)
            .update(medicineData);
        Navigator.pop(context, {...medicineData, 'id': docId});
      } else {
        // Create new record
        final docRef = await FirebaseFirestore.instance
            .collection('medicines')
            .add(medicineData);
        Navigator.pop(context, {...medicineData, 'id': docRef.id});
      }
    }
  }

  bool _doseFrequencyIsDecreased() {
    if (previousDoseFrequency == null || doseFrequency == null) {
      return false;
    }
    final previousCount = _getDoseCountForFrequency(previousDoseFrequency!);
    final newCount = _getDoseCountForFrequency(doseFrequency!);
    return newCount < previousCount;
  }

  int _getDoseCountForFrequency(String frequency) {
    switch (frequency) {
      case 'Once':
        return 1;
      case 'Twice':
        return 2;
      case 'Thrice':
        return 3;
      case 'More':
        return 4;
      default:
        return 0;
    }
  }

  Future<bool> _showDoseChangeAlert() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Warning'),
        content: const Text('Are you sure you want to decrease the dose frequency?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medicine Schedule'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Medicine Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _medicineNameController,
                  decoration: const InputDecoration(
                    labelText: 'Medicine Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter the medicine name'
                      : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _startDateController,
                        decoration: const InputDecoration(
                          labelText: 'Start Date',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(context, _startDateController),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please select a start date'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _endDateController,
                        decoration: const InputDecoration(
                          labelText: 'End Date',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(context, _endDateController),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please select an end date'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Dose Frequency',
                  style: TextStyle(fontSize: 16),
                ),
                DropdownButtonFormField<String>(
                  value: doseFrequency,
                  items: doseOptions.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      doseFrequency = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Select Dose Frequency',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please select a dose frequency'
                      : null,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Medicine Times',
                  style: TextStyle(fontSize: 16),
                ),
                for (int i = 0; i < medicineTimes.length; i++)
                  ListTile(
                    title: Text('Medicine Time ${i + 1}'),
                    subtitle: Text(medicineTimes[i]),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          medicineTimes.removeAt(i);
                        });
                      },
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addMedicineTime,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Days of the Week',
                  style: TextStyle(fontSize: 16),
                ),
                Wrap(
                  spacing: 8.0,
                  children: daysOfWeek.map((day) {
                    return ChoiceChip(
                      label: Text(day),
                      selected: selectedDays.contains(day),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedDays.add(day);
                          } else {
                            selectedDays.remove(day);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Enable Notification'),
                  value: isNotification,
                  onChanged: (bool value) {
                    setState(() {
                      isNotification = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(widget.existingData != null ? 'Update Medicine' : 'Add Medicine'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
