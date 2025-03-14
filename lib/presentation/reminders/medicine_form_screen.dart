import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:home/services/medicine_service/medicine_service.dart';
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
  final GlobalKey<FormState> _pillDetailsFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _doseFrequencyFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _frequencyCountFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _daysSelectionFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _medicineTimeFormKey = GlobalKey<FormState>();

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
    // If existingData contains medicine names, load them immediately.
    if (widget.existingData != null &&
        widget.existingData!.containsKey('enteredMedicines')) {
      enteredMedicines =
          List<String>.from(widget.existingData!['enteredMedicines']);
    }
    // Then initialize other form data (if any)
    initializeFormData(
        widget.existingData, _startDateController, _endDateController, (data) {
      setState(() {
        // Use the already-set enteredMedicines if available; otherwise, update it from the callback.
        enteredMedicines = (data['enteredMedicines'] != null &&
                (data['enteredMedicines'] as List).isNotEmpty)
            ? List<String>.from(data['enteredMedicines'])
            : enteredMedicines;
        selectedDays = data['selectedDays'] ?? [];
        doseFrequency = data['doseFrequency'];
        medicineTimes = data['medicineTimes'] ?? [];
        isNotification = data['isNotification'] ?? true;
      });
    });
  }

  FormStep currentStep = FormStep.pillDetails;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Form(
        key: _formKey,
        child: Stack(
          children: [
            // Fixed Background Color
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFE0E0E0), // Replace with your desired color
                ),
              ),
            ),

            // Foreground Content
            SafeArea(
              child: SingleChildScrollView(
                // Move here
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.black),
                            onPressed: () {
                              Navigator.pop(context);
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
                    // Content
                    Padding(
                      padding: const EdgeInsets.only(bottom: 0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        child: Container(
                          height: doseFrequency != null ? 625 : 625,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.all(24),
                          child: _buildStepContent(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (Widget child, Animation<double> animation) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        );

        // Slide from left to right (gentle movement)
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(-0.3, 0),
          end: Offset.zero,
        ).animate(curvedAnimation);

        // Scale slightly up from 95% to full size
        final scaleAnimation = Tween<double>(
          begin: 0.95,
          end: 1.0,
        ).animate(curvedAnimation);

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: offsetAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: child,
            ),
          ),
        );
      },
      child: Builder(
        key: ValueKey(currentStep),
        builder: (context) {
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
        },
      ),
    );
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
          key: _pillDetailsFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      if (currentStep == FormStep.pillDetails) {
                        Navigator.pop(context);
                      } else {
                        setState(() {
                          currentStep = FormStep.values[currentStep.index - 1];
                        });
                      }
                    },
                  ),
                  const SizedBox(
                      width: 10), // Add spacing between icon and text
                  const Text(
                    'Pills name',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
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
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Light grey background
                  borderRadius: BorderRadius.circular(20), // Rounded borders
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
              const SizedBox(height: 210),

              _buildNextButton('Next', () {
                if (enteredMedicines.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Please add a medicine name.")),
                  );
                } else {
                  setState(() {
                    currentStep = FormStep.doseFrequency;
                  });
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoseFrequencyStep() {
    return Form(
      key: _doseFrequencyFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  setState(() {
                    currentStep = FormStep.values[currentStep.index - 1];
                  });
                },
              ),
              const SizedBox(width: 10), // Add spacing between icon and text
              const Text(
                'Dose Frequency',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
        ],
      ),
    );
  }

  Widget _buildFrequencyCounter() {
    return Form(
      key: _frequencyCountFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  setState(() {
                    currentStep = FormStep.doseFrequency;
                  });
                },
              ),
              const SizedBox(width: 10), // Add spacing between icon and text
              const Text(
                'Dose Frequency',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
          const SizedBox(height: 50),
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
    return Container(
      child: Form(
        key: _daysSelectionFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // Space out the top and bottom sections evenly.
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Top section: header and day selector.
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        setState(() {
                          currentStep = FormStep.values[currentStep.index - 1];
                        });
                      },
                    ),
                    const SizedBox(width: 10), // Spacing between icon and text.
                    const Text(
                      'Medicine Days',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
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
              ],
            ),
            const SizedBox(height: 40),
            // Bottom section: notification toggle and next button.
            Column(
              children: [
                AlarmNotificationToggle(
                  isNotification: isNotification,
                  onChanged: (value) {
                    setState(() {
                      isNotification = value;
                    });
                  },
                ),
                const SizedBox(height: 40),
                _buildNextButton('Next', () {
                  setState(() {
                    currentStep = FormStep.medicineTime;
                  });
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineTimeStep() {
    return SingleChildScrollView(
      child: Form(
        key: _medicineTimeFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    setState(() {
                      currentStep = FormStep.daysSelection;
                    });
                  },
                ),
                const SizedBox(width: 10),
                const Text(
                  'Medicine Times',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            MedicineTimeSelector(
              medicineTimes: medicineTimes,
              numberOfDoses: numberOfDoses,
              onTimeSelected: (newTime) {
                setState(() {
                  if (medicineTimes.length < numberOfDoses) {
                    medicineTimes.add(newTime);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Maximum number of doses reached')),
                    );
                  }
                });
              },
            ),
            const SizedBox(height: 24),
            DateInput(
              controller: _startDateController,
              label: 'Start Date',
              onTap: () => selectDate(context, _startDateController),
            ),
            const SizedBox(height: 24),
            DateInput(
              controller: _endDateController,
              label: 'End Date',
              onTap: () => selectDate(context, _endDateController),
            ),
            const SizedBox(height: 75),
            _buildNextButton('Save', handleSubmit),
          ],
        ),
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
          backgroundColor: const Color(0xFF4276FD),
          foregroundColor: Colors.white,
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
      await checkMedicineTimes(userId, isNotification);
    }
  }
}
