import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  List<Timestamp> medicineTimes = [];
  String? doseFrequency;
  bool isNotification = true;

  final List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  final List<String> doseOptions = ['Once', 'Twice', 'Thrice', 'More'];

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      _medicineNameController.text = widget.existingData!['medicineName'] ?? '';
      _startDateController.text = widget.existingData!['startDate'] != null
          ? DateFormat('dd-MM-yyyy')
              .format(widget.existingData!['startDate'].toDate())
          : '';
      _endDateController.text = widget.existingData!['endDate'] != null
          ? DateFormat('dd-MM-yyyy')
              .format(widget.existingData!['endDate'].toDate())
          : '';
      selectedDays =
          List<String>.from(widget.existingData!['selectedDays'] ?? []);
      doseFrequency = widget.existingData!['doseFrequency'];
      medicineTimes =
          List<Timestamp>.from(widget.existingData!['medicineTimes'] ?? []);
      isNotification = widget.existingData!['isActive'] ?? true;
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

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      controller.text = DateFormat('dd-MM-yyyy').format(pickedDate);
    }
  }

  void _addMedicineTime() async {
    final maxAllowedTimes = doseFrequency == 'More' ? 10 : _getDoseCount();

    if (medicineTimes.length >= maxAllowedTimes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You can only add up to $maxAllowedTimes timings for the selected dose frequency.',
          ),
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
      final now = DateTime.now();
      final dateTime = DateTime(
          now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
      setState(() {
        medicineTimes.add(Timestamp.fromDate(dateTime));
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (doseFrequency == null || doseFrequency!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a dose frequency'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final requiredDoseCount = _getDoseCount();
      if (medicineTimes.length < requiredDoseCount) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please add ${requiredDoseCount - medicineTimes.length} more timing(s) to match the selected dose frequency.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final medicineData = {
        'medicineName': _medicineNameController.text,
        'startDate': Timestamp.fromDate(
          DateFormat('dd-MM-yyyy').parse(_startDateController.text),
        ),
        'endDate': Timestamp.fromDate(
          DateFormat('dd-MM-yyyy').parse(_endDateController.text),
        ),
        'selectedDays': selectedDays,
        'doseFrequency': doseFrequency,
        'medicineTimes': medicineTimes,
        'isActive': isNotification,
      };

      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User is not authenticated.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        await docRef.set({
          'medicines': [medicineData]
        });
      } else {
        final medicines = List.from(docSnapshot.data()?['medicines'] ?? []);
        if (widget.existingData != null) {
          final index = medicines.indexWhere(
              (medicine) => medicine['id'] == widget.existingData!['id']);
          if (index != -1) medicines[index] = medicineData;
        } else {
          medicines.add(medicineData);
        }
        await docRef.update({'medicines': medicines});
      }

      Navigator.pop(context, medicineData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medicine Schedule'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                TextFormField(
                  controller: _medicineNameController,
                  decoration: const InputDecoration(
                    labelText: 'Medicine Name',
                    hintText: 'Enter the name of the medicine',
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter the medicine name'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _startDateController,
                  decoration: const InputDecoration(
                    labelText: 'Start Date',
                    hintText: 'Select a start date',
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context, _startDateController),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please select a start date'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _endDateController,
                  decoration: const InputDecoration(
                    labelText: 'End Date',
                    hintText: 'Select an end date',
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context, _endDateController),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please select an end date'
                      : null,
                ),
                const SizedBox(height: 20),
                const Text('Select Days',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8.0,
                  children: daysOfWeek.map((day) {
                    return ChoiceChip(
                      label: Text(day),
                      selected: selectedDays.contains(day),
                      onSelected: (isSelected) {
                        setState(() {
                          if (isSelected) {
                            selectedDays.add(day);
                          } else {
                            selectedDays.remove(day);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  value: doseFrequency,
                  onChanged: (newValue) {
                    setState(() {
                      doseFrequency = newValue;
                    });
                  },
                  items: doseOptions.map((option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Dose Frequency',
                    hintText: 'Select the frequency of the dose',
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please select a dose frequency'
                      : null,
                ),
                const SizedBox(height: 20),

                // Add Medicine Time Button
                IconButton(
                  onPressed: _addMedicineTime,
                  icon: const Icon(Icons.add, size: 30),
                  tooltip: 'Add Medicine Time',
                ),
                const SizedBox(height: 20),
                const Text('Times:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: medicineTimes.length,
                  itemBuilder: (context, index) {
                    final time = DateFormat('hh:mm a')
                        .format(medicineTimes[index].toDate());
                    return ListTile(
                      title: Text(time),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            medicineTimes.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Alarms',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Switch(
                      value: isNotification,
                      onChanged: (bool value) {
                        setState(() {
                          isNotification = value;
                        });
                      },
                    ),
                    const Text('Notifications',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 30.0),
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('Save Medicine Schedule',
                      style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
