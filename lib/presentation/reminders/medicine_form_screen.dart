import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:home/core/constants/app_color.dart';
import 'package:home/services/medicine_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'medicine_form_utils.dart';

enum FormStep {
  pillDetails,
  doseFrequency,
  daysSelection,
  frequencyCount,
  medicineTime
}

class MedicineFormScreen extends StatefulWidget {
  final Map<String, dynamic>? existingData;

  const MedicineFormScreen({super.key, this.existingData});

  @override
  MedicineFormScreenState createState() => MedicineFormScreenState();
}

class MedicineFormScreenState extends State<MedicineFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medicineNameController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  List<String> selectedDays = [];
  List<Timestamp> medicineTimes = [];
  String? doseFrequency;
  bool isNotification = true;
  int? customDoseCount;

  List<String> enteredMedicines = [];

  int numberOfDoses = 1;

  @override
  void initState() {
    super.initState();
    initializeFormData(
        widget.existingData, _startDateController, _endDateController, (data) {
      setState(() {
        enteredMedicines = data['enteredMedicines'];
        selectedDays = data['selectedDays'];
        doseFrequency = data['doseFrequency'];
        medicineTimes = data['medicineTimes'];
        isNotification = data['isNotification'];
      });
    });
  }

  FormStep currentStep = FormStep.pillDetails;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Fixed Background Image
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/doc.jpg'), // Your image path
                  fit: BoxFit.cover, // Ensures full coverage
                  alignment: Alignment.topCenter, // Keeps image fixed at top
                ),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.lightBlueAccent, // Bottom color
                    Colors.transparent, // Fades into transparency
                  ],
                ),
              ),
            ),
          ),

          // Foreground Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          if (currentStep == FormStep.pillDetails) {
                            Navigator.pop(context);
                          } else {
                            setState(() {
                              currentStep =
                                  FormStep.values[currentStep.index - 1];
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Set Medicine',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                Padding(
                  padding: const EdgeInsets.only(
                      bottom: 40), // Adds space above the bottom
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: _buildStepContent(),
                      ),
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

  Widget _buildStepContent() {
    switch (currentStep) {
      case FormStep.pillDetails:
        return _buildPillDetailsStep();
      case FormStep.doseFrequency:
        return _buildDoseFrequencyStep();
      case FormStep.frequencyCount:
        return _buildFrequencyCounter();
      case FormStep.daysSelection:
        return _buildDaysSelection();
      case FormStep.medicineTime:
        return _buildMedicineTimeStep();
    }
  }

  int pillCount = 1; // Initial value

  void _increaseCount() {
    setState(() {
      pillCount++;
    });
  }

  void _decreaseCount() {
    if (pillCount > 1) {
      setState(() {
        pillCount--;
      });
    }
  }

  Widget _buildPillDetailsStep() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard on tap
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior
            .onDrag, // Dismiss keyboard on scroll
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pills name',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              MedicineNameInput(
                controller: _medicineNameController,
                enteredMedicines: enteredMedicines,
                onAdd: _addMedicineName,
                onRemove: _removeMedicine,
              ),

              const SizedBox(height: 24),
              const Text(
                'Amount',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Amount controls
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: _decreaseCount,
                    ),
                    Expanded(
                      child: Text(
                        '$pillCount pills',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _increaseCount,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              _buildNextButton('Next', () {
                setState(() {
                  currentStep = FormStep.doseFrequency;
                });
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoseFrequencyStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Dose Frequency',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          DoseFrequencyButtonForm(
            value: doseFrequency,
            onChanged: (newValue) {
              setState(() {
                doseFrequency = newValue;
                // Set the number of doses based on the selected frequency
                if (newValue == '1 time, Daily') {
                  numberOfDoses = 1;
                } else if (newValue == '2 times, Daily') {
                  numberOfDoses = 2;
                } else if (newValue == '3 times, Daily') {
                  numberOfDoses = 3;
                } else if (newValue == 'Custom') {
                  // Keep the current value or set to 1 if it's 0
                  numberOfDoses = numberOfDoses > 0 ? numberOfDoses : 1;
                  currentStep = FormStep.frequencyCount;
                  return; // Exit early to prevent moving to daysSelection
                }
                currentStep = FormStep.daysSelection;
              });
            },
          ),
          const SizedBox(height: 24),
          _buildNextButton('Next', () {
            if (doseFrequency != null && doseFrequency!.isNotEmpty) {
              setState(() {
                currentStep = FormStep.daysSelection;
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select a dose frequency')),
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildFrequencyCounter() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Dose Frequency',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          DoseFrequencySelector(
            value: numberOfDoses.toString(),
            onChanged: (newValue) {
              setState(() {
                numberOfDoses = int.tryParse(newValue ?? '1') ?? 1;
                doseFrequency = 'Custom';
              });
            },
          ),
          const SizedBox(height: 24),
          _buildNextButton('Next', () {
            setState(() {
              currentStep = FormStep.daysSelection;
            });
          }),
        ],
      ),
    );
  }

  Widget _buildDaysSelection() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Medicine Days',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          DaySelector(
            selectedDays: selectedDays,
            onSelectionChanged: (day, isSelected) {
              setState(() {
                if (isSelected) {
                  selectedDays.add(day);
                } else {
                  selectedDays.remove(day);
                }
              });
            },
          ),
          const SizedBox(height: 16),
          NotificationToggle(
            isNotification: isNotification,
            onChanged: (value) {
              setState(() {
                isNotification = value;
              });
            },
          ),
          const SizedBox(height: 24),
          _buildNextButton('Next', () {
            setState(() {
              currentStep = FormStep.medicineTime;
            });
          }),
        ],
      ),
    );
  }

  Widget _buildMedicineTimeStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Medicine Times',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          MedicineTimeSelector(
            medicineTimes: medicineTimes,
            numberOfDoses: numberOfDoses,
            onAddTime: (newTime) {
              setState(() {
                if (medicineTimes.length < numberOfDoses) {
                  medicineTimes.add(newTime);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Maximum number of doses reached')),
                  );
                }
              });
            },
            onRemoveTime: (index) {
              setState(() {
                medicineTimes.removeAt(index);
              });
            },
          ),
          const SizedBox(height: 24),
          DateInput(
            controller: _startDateController,
            label: 'Start Date',
            onTap: () => selectDate(context, _startDateController),
          ),
          DateInput(
            controller: _endDateController,
            label: 'End Date',
            onTap: () => selectDate(context, _endDateController),
          ),
          const SizedBox(height: 24),
          _buildNextButton('Save', handleSubmit),
        ],
      ),
    );
  }

  Widget _buildNextButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.arrow_forward),
        label: Text(text),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sky,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _addMedicineName() {
    final medicineName = _medicineNameController.text.trim();
    if (medicineName.isNotEmpty && !enteredMedicines.contains(medicineName)) {
      setState(() {
        enteredMedicines.add(medicineName);
        _medicineNameController.clear();
      });
    }
  }

  void _removeMedicine(String medicineName) {
    setState(() {
      enteredMedicines.remove(medicineName);
    });
  }

  Future<void> _addMedicineTime() async {
    final newTime = await addMedicineTime(
        context, doseFrequency, medicineTimes, customDoseCount);
    if (newTime != null) {
      setState(() {
        medicineTimes.add(newTime);
      });
    }
  }

  Future<void> handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!validateForm(
          context, enteredMedicines, doseFrequency, medicineTimes)) {
        return;
      }

      final medicineData = createMedicineData(
        enteredMedicines,
        _startDateController.text,
        _endDateController.text,
        selectedDays,
        doseFrequency ?? '',
        medicineTimes,
        isNotification,
      );

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User is not authenticated.')),
        );
        return;
      }

      await saveMedicineData(userId, medicineData, widget.existingData);

      if (mounted) {
        Navigator.pop(context, medicineData);
      }

      await Future.delayed(const Duration(seconds: 3));
      await checkMedicineTimes(
          userId, flutterLocalNotificationsPlugin, isNotification);
    }
  }
}
