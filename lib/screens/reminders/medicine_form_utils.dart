import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:home/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MedicineNameInput extends StatefulWidget {
  final TextEditingController controller;
  final List<String> enteredMedicines;
  final VoidCallback onAdd;
  final Function(String) onRemove;

  const MedicineNameInput({
    super.key,
    required this.controller,
    required this.enteredMedicines,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  _MedicineNameInputState createState() => _MedicineNameInputState();
}

class _MedicineNameInputState extends State<MedicineNameInput> {
  List<String> suggestions = [];
  bool isLoading = false;

  Timer? _debounce;

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
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 1), () {
      _fetchSuggestions(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          cursorColor: AppColors.textPrimary,
          decoration: InputDecoration(
            labelText: 'Medicine Name',
            labelStyle: TextStyle(color: AppColors.textSecondary),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            filled: true,
            fillColor: AppColors.borderColor.withOpacity(0.2),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.add, color: AppColors.buttonColor),
              onPressed: () {
                widget.onAdd();
                setState(() {
                  suggestions = [];
                });
              },
            ),
          ),
          style: TextStyle(color: AppColors.textPrimary),
          onChanged: _onChanged,
        ),
        if (isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: LinearProgressIndicator(
              backgroundColor: AppColors.borderColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.buttonColor),
            ),
          ),
        if (suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = suggestions[index];
                return ListTile(
                  title: Text(
                    suggestion,
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
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
                style: TextStyle(color: AppColors.textPrimary),
              ),
              backgroundColor: AppColors.borderColor.withOpacity(0.2),
              deleteIcon: Icon(Icons.close, color: AppColors.buttonColor),
              onDeleted: () => widget.onRemove(medicineName),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

class DateInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final VoidCallback onTap;

  const DateInput({
    super.key,
    required this.controller,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.borderColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.textSecondary),
          floatingLabelStyle: TextStyle(color: AppColors.textPrimary),
          suffixIcon: Icon(Icons.date_range, color: AppColors.buttonColor),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
        style: TextStyle(color: AppColors.textPrimary),
        readOnly: true,
        onTap: onTap,
        validator: (value) =>
            value == null || value.isEmpty ? 'Please select a $label' : null,
      ),
    );
  }
}

Future<void> selectDate(
  BuildContext context,
  TextEditingController controller, {
  DateTime? minDate,
  DateTime? maxDate,
}) async {
  DateTime initialDate;
  if (controller.text.isNotEmpty) {
    initialDate = DateFormat('dd-MM-yyyy').parse(controller.text);
  } else {
    initialDate = DateTime.now();
  }
  if (minDate != null && initialDate.isBefore(minDate)) {
    initialDate = minDate;
  }
  if (maxDate != null && initialDate.isAfter(maxDate)) {
    initialDate = maxDate;
  }

  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: minDate ?? DateTime.now(),
    lastDate: maxDate ?? DateTime(2099, 12, 31),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: Theme.of(context).copyWith(
          dialogBackgroundColor: AppColors.cardBackground,
          primaryColor: AppColors.buttonColor,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: MaterialColor(
              AppColors.buttonColor.value,
              <int, Color>{
                50: AppColors.buttonColor.withOpacity(0.1),
                100: AppColors.buttonColor.withOpacity(0.2),
                200: AppColors.buttonColor.withOpacity(0.3),
                300: AppColors.buttonColor.withOpacity(0.4),
                400: AppColors.buttonColor.withOpacity(0.5),
                500: AppColors.buttonColor,
                600: AppColors.buttonColor.withOpacity(0.7),
                700: AppColors.buttonColor.withOpacity(0.8),
                800: AppColors.buttonColor.withOpacity(0.9),
                900: AppColors.buttonColor,
              },
            ),
            accentColor: AppColors.buttonColor,
            cardColor: AppColors.cardBackground,
            backgroundColor: AppColors.cardBackground,
            errorColor: AppColors.errorColor,
            brightness: Theme.of(context).brightness, // Use current brightness
          ).copyWith(
            // Apply additional properties
            onPrimary: AppColors.textOnPrimary,
            onSurface: AppColors.textPrimary,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.buttonColor,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(color: AppColors.textSecondary),
            floatingLabelStyle: TextStyle(color: AppColors.textPrimary),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.buttonColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.borderColor),
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

class DaySelector extends StatefulWidget {
  final List<String> selectedDays;
  final Function(String, bool) onSelectionChanged;

  const DaySelector({
    super.key,
    required this.selectedDays,
    required this.onSelectionChanged,
  });

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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _toggleDaily,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonColor,
            foregroundColor: AppColors.buttonText,
          ),
          child: Text(
            isDaily ? 'Clear All' : 'Select All',
            style: const TextStyle(color: AppColors.textOnPrimary),
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.transparent,
                  AppColors.background,
                  AppColors.background,
                  Colors.transparent,
                ],
                stops: const [0.0, 0.1, 0.9, 1.0],
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
                        color: isSelected
                            ? AppColors.cardBackground
                            : AppColors.borderColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: AppColors.buttonColor, width: 2)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.textSecondary.withOpacity(0.2),
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
                                  : AppColors.textPrimary,
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
                                  : AppColors.cardBackground,
                              border: isSelected
                                  ? null
                                  : Border.all(
                                      color: AppColors.borderColor, width: 2),
                            ),
                            child: Icon(
                              Icons.check,
                              color: isSelected
                                  ? AppColors.buttonColor
                                  : AppColors.buttonColor,
                              size: 16,
                            ),
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
    super.key,
    required this.value,
    required this.onChanged,
  });

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
                    isSelected ? AppColors.buttonColor : AppColors.borderColor,
                foregroundColor:
                    isSelected ? AppColors.buttonText : AppColors.textPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                minimumSize: const Size(300, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: isSelected ? 4 : 2,
              ),
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.textOnPrimary
                      : AppColors.textPrimary,
                ),
              ),
            );
          }).toList(),
        ),
        if (value == null || value!.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Please select a dose frequency'.tr(),
              style: TextStyle(
                color: AppColors.errorColor,
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
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 140,
                width: 60,
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
                                      : AppColors.textSecondary,
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
              const SizedBox(width: 10),
              Text(
                "per day".tr(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomTimePicker extends StatefulWidget {
  final Function(Timestamp) onTimeSelected;
  final Timestamp? initialTime;

  const CustomTimePicker({
    super.key,
    required this.onTimeSelected,
    this.initialTime,
  });

  @override
  _CustomTimePickerState createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  late int selectedHour;
  late int selectedMinute;
  late String selectedPeriod;

  late FixedExtentScrollController hourController;
  late FixedExtentScrollController minuteController;
  late FixedExtentScrollController periodController;

  @override
  void initState() {
    super.initState();

    if (widget.initialTime != null) {
      DateTime dateTime = widget.initialTime!.toDate();
      selectedHour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
      selectedMinute = dateTime.minute;
      selectedPeriod = dateTime.hour >= 12 ? 'PM' : 'AM';
    } else {
      selectedHour = 1;
      selectedMinute = 00;
      selectedPeriod = 'AM';
    }

    hourController = FixedExtentScrollController(initialItem: selectedHour - 1);
    minuteController = FixedExtentScrollController(initialItem: selectedMinute);
    periodController = FixedExtentScrollController(
        initialItem: selectedPeriod == 'AM' ? 0 : 1);
  }

  @override
  void dispose() {
    hourController.dispose();
    minuteController.dispose();
    periodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dialogBackgroundColor: AppColors.cardBackground,
        textTheme: TextTheme(
          titleLarge: TextStyle(color: AppColors.textPrimary),
          bodyLarge: TextStyle(color: AppColors.textPrimary),
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: MaterialColor(
            AppColors.buttonColor.value,
            <int, Color>{
              50: AppColors.buttonColor.withOpacity(0.1),
              100: AppColors.buttonColor.withOpacity(0.2),
              200: AppColors.buttonColor.withOpacity(0.3),
              300: AppColors.buttonColor.withOpacity(0.4),
              400: AppColors.buttonColor.withOpacity(0.5),
              500: AppColors.buttonColor,
              600: AppColors.buttonColor.withOpacity(0.7),
              700: AppColors.buttonColor.withOpacity(0.8),
              800: AppColors.buttonColor.withOpacity(0.9),
              900: AppColors.buttonColor,
            },
          ),
          accentColor: AppColors.buttonColor,
          cardColor: AppColors.cardBackground,
          backgroundColor: AppColors.cardBackground,
          errorColor: AppColors.errorColor,
          brightness: Theme.of(context).brightness, // Use current brightness
        ).copyWith(
          // Apply additional properties
          onPrimary: AppColors.textOnPrimary,
          onSurface: AppColors.textPrimary,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.buttonColor,
          ),
        ),
      ),
      child: AlertDialog(
        title: Text(
          'Select Time'.tr(),
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: SizedBox(
          height: 180,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  controller: hourController,
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
                            color: isSelected
                                ? AppColors.buttonColor
                                : AppColors.textSecondary,
                          ),
                        ),
                      );
                    },
                    childCount: 12,
                  ),
                ),
              ),
              Text(":",
                  style: TextStyle(fontSize: 24, color: AppColors.textPrimary)),
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  controller: minuteController,
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
                            color: isSelected
                                ? AppColors.buttonColor
                                : AppColors.textSecondary,
                          ),
                        ),
                      );
                    },
                    childCount: 60,
                  ),
                ),
              ),
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  controller: periodController,
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
                            color: isSelected
                                ? AppColors.buttonColor
                                : AppColors.textSecondary,
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
            child: Text("Cancel".tr(),
                style: TextStyle(color: AppColors.buttonColor)),
          ),
          TextButton(
            onPressed: () {
              int hour = selectedHour;
              if (selectedPeriod == 'PM' && hour != 12) {
                hour += 12;
              } else if (selectedPeriod == 'AM' && hour == 12) {
                hour = 0;
              }
              final fixedDateTime = DateTime(1970, 1, 1, hour, selectedMinute);
              widget.onTimeSelected(Timestamp.fromDate(fixedDateTime));
              Navigator.pop(context);
            },
            child:
                Text("OK".tr(), style: TextStyle(color: AppColors.buttonColor)),
          ),
        ],
      ),
    );
  }
}

class MedicineTimeSelector extends StatelessWidget {
  final List<Timestamp?> medicineTimes;
  final int numberOfDoses;
  final Function(Timestamp, int) onTimeSelected;

  const MedicineTimeSelector({
    super.key,
    required this.medicineTimes,
    required this.numberOfDoses,
    required this.onTimeSelected,
  });

  void _pickTime(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return CustomTimePicker(
          initialTime:
              index < medicineTimes.length ? medicineTimes[index] : null,
          onTimeSelected: (timestamp) {
            onTimeSelected(timestamp, index);
          },
        );
      },
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return DateFormat.jm().format(dateTime);
  }

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
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Table(
          border: TableBorder(
            horizontalInside:
                BorderSide(color: AppColors.borderColor, width: 1),
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      _getIntakeLabel(index),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () => _pickTime(context, index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonColor,
                      foregroundColor: AppColors.buttonText,
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textOnPrimary,
                      ),
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
    super.key,
    required this.isNotification,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Alarms'.tr(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        GestureDetector(
          onTap: () => onChanged(!isNotification),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 60,
            height: 30,
            decoration: BoxDecoration(
              color: isNotification
                  ? AppColors.borderColor
                  : AppColors.buttonColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 300),
                  alignment: isNotification
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 26,
                    height: 26,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.cardBackground,
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
        Text(
          'Notifications'.tr(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// Functions (mostly unchanged, themed where applicable)

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

int getDoseCount(String? doseFrequency, {int? customDoseCount}) {
  switch (doseFrequency) {
    case '1 time, Daily':
      return 1;
    case '2 times, Daily':
      return 2;
    case '3 times, Daily':
      return 3;
    case 'Custom':
      return customDoseCount ?? 0;
    default:
      return 0;
  }
}

Future<Timestamp?> addMedicineTime(BuildContext context, String? doseFrequency,
    List<Timestamp> medicineTimes, int? customDoseCount) async {
  int maxAllowedTimes;
  if (doseFrequency == 'Custom') {
    maxAllowedTimes = customDoseCount ?? 10;
  } else {
    maxAllowedTimes = getDoseCount(doseFrequency);
  }

  if (medicineTimes.length >= maxAllowedTimes) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'You can only add up to $maxAllowedTimes timings for the selected dose frequency.',
          style: const TextStyle(color: AppColors.textOnPrimary),
        ),
        backgroundColor: AppColors.errorColor,
      ),
    );
    return null;
  }

  final TimeOfDay? pickedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.light().copyWith(
          primaryColor: AppColors.buttonColor,
          colorScheme: ColorScheme.light(
            primary: AppColors.buttonColor,
            onPrimary: AppColors.textOnPrimary,
            onSurface: AppColors.textPrimary,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.buttonColor,
            ),
          ),
        ),
        child: child!,
      );
    },
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
      content: Text(
        message,
        style: const TextStyle(color: AppColors.textOnPrimary),
      ),
      backgroundColor: AppColors.errorColor,
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

  DateTime start = DateFormat('dd-MM-yyyy').parse(startDate);
  DateTime end = DateFormat('dd-MM-yyyy').parse(endDate);

  Map<String, String> statusMap = {};
  for (DateTime date = start;
      !date.isAfter(end);
      date = date.add(const Duration(days: 1))) {
    String formattedDate = DateFormat('dd-MM-yyyy').format(date);
    statusMap[formattedDate] = 'not taken';
  }

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
    'status': statusMap,
  };
}

Future<void> saveMedicineData(String userId, Map<String, dynamic> medicineData,
    Map<String, dynamic>? existingData) async {
  try {
    final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final docSnapshot = await docRef.get();

    print("📌 Medicine Data to Save: $medicineData");

    if (!docSnapshot.exists) {
      print("🆕 Document does not exist, creating new user entry...");
      await docRef.set({
        'medicines': [medicineData]
      });
      print("✅ New user document created with medicine data.");
    } else {
      print("📄 Document exists, updating medicine list...");
      final medicines = List.from(docSnapshot.data()?['medicines'] ?? []);

      if (existingData != null) {
        final index = medicines
            .indexWhere((medicine) => medicine['id'] == existingData['id']);
        if (index != -1) {
          print("🔄 Updating existing medicine entry...");
          medicines[index] = medicineData;
        } else {
          print("⚠ Existing medicine ID not found, adding as new entry...");
          medicines.add(medicineData);
        }
      } else {
        print("➕ Adding new medicine entry...");
        medicines.add(medicineData);
      }

      await docRef.update({'medicines': medicines});
      print("✅ Medicine data updated successfully in Firestore.");
    }
  } catch (e, stackTrace) {
    print("❌ Error saving medicine data: $e");
    print(stackTrace);
  }
}
