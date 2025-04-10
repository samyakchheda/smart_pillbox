import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:home/services/medicine_service/medicine_service.dart';
import 'package:intl/intl.dart';
import 'package:home/theme/app_colors.dart';
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
    if (widget.existingData != null &&
        widget.existingData!.containsKey('enteredMedicines')) {
      enteredMedicines =
          List<String>.from(widget.existingData!['enteredMedicines']);
    }
    initializeFormData(
        widget.existingData, _startDateController, _endDateController, (data) {
      setState(() {
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
      backgroundColor: AppColors.background, // Theme-aware background
      body: Form(
        key: _formKey,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back,
                                color: AppColors.buttonColor),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Set Medicine'.tr(),
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        height: doseFrequency != null ? 625 : 625,
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: _buildStepContent(),
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
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(-0.3, 0),
          end: Offset.zero,
        ).animate(curvedAnimation);
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

  int pillCount = 1;

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
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                    icon: Icon(Icons.arrow_back, color: AppColors.buttonColor),
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
                  const SizedBox(width: 10),
                  Text(
                    'Pills name'.tr(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
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
              Text(
                'Amount'.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.borderColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, color: AppColors.buttonColor),
                      onPressed: _decreaseCount,
                    ),
                    Expanded(
                      child: Text(
                        '$pillCount pills',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, color: AppColors.buttonColor),
                      onPressed: _increaseCount,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 210),
              _buildNextButton('Next', () {
                if (enteredMedicines.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Please add a medicine name.".tr(),
                        style: TextStyle(color: AppColors.textOnPrimary),
                      ),
                      backgroundColor: Colors.red,
                    ),
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
                icon: Icon(Icons.arrow_back, color: AppColors.buttonColor),
                onPressed: () {
                  setState(() {
                    currentStep = FormStep.values[currentStep.index - 1];
                  });
                },
              ),
              const SizedBox(width: 10),
              Text(
                'Dose Frequency'.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
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
                if (newValue == '1 time, Daily') {
                  numberOfDoses = 1;
                } else if (newValue == '2 times, Daily') {
                  numberOfDoses = 2;
                } else if (newValue == '3 times, Daily') {
                  numberOfDoses = 3;
                } else if (newValue == 'Custom') {
                  numberOfDoses = numberOfDoses > 0 ? numberOfDoses : 1;
                  currentStep = FormStep.frequencyCount;
                  return;
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
                icon: Icon(Icons.arrow_back, color: AppColors.buttonColor),
                onPressed: () {
                  setState(() {
                    currentStep = FormStep.doseFrequency;
                  });
                },
              ),
              const SizedBox(width: 10),
              Text(
                'Dose Frequency'.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon:
                          Icon(Icons.arrow_back, color: AppColors.buttonColor),
                      onPressed: () {
                        setState(() {
                          currentStep = FormStep.values[currentStep.index - 1];
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Medicine Days'.tr(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
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
                  if (selectedDays.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please select at least one day.'.tr()),
                      ),
                    );
                    return;
                  }

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
                  icon: Icon(Icons.arrow_back, color: AppColors.buttonColor),
                  onPressed: () {
                    setState(() {
                      currentStep = FormStep.daysSelection;
                    });
                  },
                ),
                const SizedBox(width: 10),
                Text(
                  'Medicine Times'.tr(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            MedicineTimeSelector(
              medicineTimes: medicineTimes,
              numberOfDoses: numberOfDoses,
              onTimeSelected: (newTime, index) {
                setState(() {
                  if (index < medicineTimes.length) {
                    medicineTimes[index] = newTime;
                  } else if (medicineTimes.length < numberOfDoses) {
                    medicineTimes.add(newTime);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Maximum number of doses reached'.tr(),
                          style: TextStyle(color: AppColors.textOnPrimary),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                });
              },
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                DateInput(
                  controller: _startDateController,
                  label: 'Start Date',
                  onTap: () {
                    DateTime? endDate;
                    if (_endDateController.text.isNotEmpty) {
                      endDate = DateFormat('dd-MM-yyyy')
                          .parse(_endDateController.text);
                    }
                    selectDate(context, _startDateController, maxDate: endDate);
                  },
                ),
                const SizedBox(height: 24),
                DateInput(
                  controller: _endDateController,
                  label: 'End Date',
                  onTap: () {
                    // Ensure a start date is set before selecting an end date.
                    if (_startDateController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Please select a Start Date first'.tr())),
                      );
                      return;
                    }
                    final DateTime startDate = DateFormat('dd-MM-yyyy')
                        .parse(_startDateController.text);
                    selectDate(context, _endDateController, minDate: startDate);
                  },
                ),
              ],
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
        icon: Icon(Icons.arrow_forward, color: AppColors.buttonColor),
        label: Text(
          text,
          style: const TextStyle(color: AppColors.textOnPrimary),
        ),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonColor,
          foregroundColor: AppColors.buttonText,
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
          SnackBar(
            content: Text(
              'User is not authenticated.'.tr(),
              style: TextStyle(color: AppColors.textOnPrimary),
            ),
            backgroundColor: Colors.red,
          ),
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
