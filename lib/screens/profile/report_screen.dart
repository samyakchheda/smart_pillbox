import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:home/theme/app_colors.dart';
import 'package:home/theme/app_fonts.dart';
import 'package:home/widgets/common/my_elevated_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class ReportScreen extends StatefulWidget {
  final VoidCallback onBack;

  const ReportScreen({required this.onBack, super.key});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool _showCards = false;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  String parseTimestampAsDate(dynamic value) {
    if (value is Timestamp) {
      return DateFormat('dd MMM yyyy').format(value.toDate());
    } else if (value != null) {
      return value.toString();
    }
    return 'N/A';
  }

  String parseTimestampAsTime(dynamic value) {
    if (value is Timestamp) {
      return DateFormat('hh:mm a').format(value.toDate());
    } else if (value != null) {
      return value.toString();
    }
    return 'N/A';
  }

  DateTime? parseCustomDateString(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is! String) return null;
    String cleaned =
        value.replaceAll(RegExp(r'UTC.*'), '').replaceAll('at', '').trim();
    try {
      return DateFormat("d MMMM yyyy HH:mm:ss").parse(cleaned);
    } catch (e) {
      return null;
    }
  }

  String formatTimeOnly(DateTime dt) => DateFormat('hh:mm a').format(dt);
  String formatDateOnly(DateTime dt) => DateFormat('dd MMM yyyy').format(dt);

  @override
  void initState() {
    super.initState();
    _fetchCalendarData();
  }

  Future<void> shareMedicationPdf(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user is currently signed in.')),
        );
        return;
      }
      final userId = user.uid;

      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!docSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User document not found.'.tr())),
        );
        return;
      }

      final data = docSnapshot.data() as Map<String, dynamic>? ?? {};
      final List<dynamic> medicinesArray = data['medicines'] ?? [];

      if (medicinesArray.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No medication data found.')),
        );
        return;
      }

      final pdf = pw.Document();
      final tableData = medicinesArray
          .where((item) => item is Map<String, dynamic>)
          .map((item) {
        final map = item as Map<String, dynamic>;
        final String doseFrequency = map['doseFrequency']?.toString() ?? 'N/A';
        final String startDate = parseTimestampAsDate(map['startDate']);
        final String endDate = parseTimestampAsDate(map['endDate']);
        final dynamic medNamesData = map['medicineNames'];
        String medicineName = medNamesData is List
            ? medNamesData.join(', ')
            : medNamesData?.toString() ?? 'Unknown';
        final dynamic timesList = map['medicineTimes'];
        String timesString = timesList is List
            ? timesList.map((e) => parseTimestampAsTime(e)).join(', ')
            : timesList?.toString() ?? 'N/A';

        return [medicineName, doseFrequency, startDate, endDate, timesString];
      }).toList();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            children: [
              pw.Text("Medication List", style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: [
                  "Medicine Name",
                  "Dose Frequency",
                  "Start Date",
                  "End Date",
                  "Medicine Times"
                ],
                data: tableData,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
                headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                cellHeight: 30,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.centerLeft,
                  3: pw.Alignment.centerLeft,
                  4: pw.Alignment.centerLeft,
                },
              ),
            ],
          ),
        ),
      );

      final pdfBytes = await pdf.save();
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/medications.pdf';
      final file = File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(pdfBytes);

      await Share.shareXFiles([XFile(file.path)], text: "Medication List PDF");
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> shareMedicationRecordsPdf(BuildContext context) async {
    final DateTimeRange? dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 7)),
        end: DateTime.now(),
      ),
    );
    if (dateRange == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user is currently signed in.')),
      );
      return;
    }
    final userId = user.uid;

    final docSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!docSnapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User document not found.')),
      );
      return;
    }
    final data = docSnapshot.data() as Map<String, dynamic>? ?? {};
    final List<dynamic> medicinesArray = data['medicines'] ?? [];

    if (medicinesArray.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No medication data found.')),
      );
      return;
    }

    final List<List<String>> tableData = [];
    DateTime currentDay = DateTime(
      dateRange.start.year,
      dateRange.start.month,
      dateRange.start.day,
    );
    final DateTime endDay = DateTime(
      dateRange.end.year,
      dateRange.end.month,
      dateRange.end.day,
    );

    while (!currentDay.isAfter(endDay)) {
      final String dayLabel = DateFormat('dd MMM yyyy').format(currentDay);
      final String dayKey = DateFormat('dd-MM-yyyy').format(currentDay);

      for (final item in medicinesArray) {
        if (item is! Map<String, dynamic>) continue;
        final map = item;
        final dynamic medNamesData = map['medicineNames'];
        String medicineName = medNamesData is List
            ? medNamesData.join(', ')
            : medNamesData?.toString() ?? 'Unknown';

        final DateTime? medStart = parseCustomDateString(map['startDate']);
        final DateTime? medEnd = parseCustomDateString(map['endDate']);
        if (medStart == null || medEnd == null) continue;

        final DateTime medStartDate =
            DateTime(medStart.year, medStart.month, medStart.day);
        final DateTime medEndDate =
            DateTime(medEnd.year, medEnd.month, medEnd.day);

        if (currentDay.isBefore(medStartDate) ||
            currentDay.isAfter(medEndDate)) {
          continue;
        }

        String dosageStatus = 'Not Taken';
        if (map.containsKey('status')) {
          final statusMap = map['status'];
          if (statusMap is Map<String, dynamic>) {
            final dayValue = statusMap[dayKey]?.toString().toLowerCase();
            if (dayValue == 'taken') dosageStatus = 'Taken';
          }
        }

        final dynamic timesList = map['medicineTimes'];
        if (timesList is List && timesList.isNotEmpty) {
          for (final t in timesList) {
            String timeStr =
                t is Timestamp ? parseTimestampAsTime(t) : t.toString();
            tableData.add([dayLabel, medicineName, timeStr, dosageStatus]);
          }
        } else {
          tableData.add([dayLabel, medicineName, '-', dosageStatus]);
        }
      }
      currentDay = currentDay.add(const Duration(days: 1));
    }

    if (tableData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No records found in this date range.'.tr())),
      );
      return;
    }

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Medication Records", style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 10),
            pw.Text(
              "From ${DateFormat('dd MMM yyyy').format(dateRange.start)} "
              "to ${DateFormat('dd MMM yyyy').format(dateRange.end)}",
              style: pw.TextStyle(fontSize: 14),
            ),
            pw.SizedBox(height: 20),
          ],
        ),
        build: (pw.Context context) => [
          pw.Table.fromTextArray(
            headers: ["Date", "Medicine Name", "Time", "Dosage Status"],
            data: tableData,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
            headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
            cellHeight: 30,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.centerLeft,
            },
          ),
        ],
      ),
    );

    final pdfBytes = await pdf.save();
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/medication_records.pdf';
    final file = File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(pdfBytes);

    await Share.shareXFiles([XFile(file.path)], text: "Medication Records PDF");
  }

  Map<DateTime, double> _dailyTakenRatio = {};

  Future<void> _fetchCalendarData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final userId = user.uid;

      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!docSnapshot.exists) return;

      final data = docSnapshot.data() as Map<String, dynamic>? ?? {};
      final List<dynamic> medicinesArray = data['medicines'] ?? [];

      final Map<DateTime, int> dailyScheduledCount = {};
      final Map<DateTime, int> dailyTakenCount = {};

      for (final item in medicinesArray) {
        if (item is Map<String, dynamic>) {
          final DateTime? startDate = parseCustomDateString(item['startDate']);
          final DateTime? endDate = parseCustomDateString(item['endDate']);
          final statusMap = item['status'];

          if (startDate == null || endDate == null) continue;

          DateTime currentDay =
              DateTime(startDate.year, startDate.month, startDate.day);
          final DateTime endDay =
              DateTime(endDate.year, endDate.month, endDate.day);

          while (!currentDay.isAfter(endDay)) {
            dailyScheduledCount[currentDay] =
                (dailyScheduledCount[currentDay] ?? 0) + 1;

            if (statusMap is Map<String, dynamic>) {
              final dayKey = DateFormat('dd-MM-yyyy').format(currentDay);
              final dayValue = statusMap[dayKey]?.toString().toLowerCase();
              if (dayValue == 'taken') {
                dailyTakenCount[currentDay] =
                    (dailyTakenCount[currentDay] ?? 0) + 1;
              }
            }
            currentDay = currentDay.add(const Duration(days: 1));
          }
        }
      }

      _dailyTakenRatio.clear();
      for (final day in dailyScheduledCount.keys) {
        final scheduled = dailyScheduledCount[day] ?? 0;
        final taken = dailyTakenCount[day] ?? 0;
        _dailyTakenRatio[day] = scheduled > 0 ? taken / scheduled : 0.0;
      }

      setState(() {});
    } catch (e) {
      debugPrint('Error in _fetchCalendarData: $e');
    }
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          final dateOnly = DateTime(day.year, day.month, day.day);
          if (!_dailyTakenRatio.containsKey(dateOnly)) {
            return Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  day.day.toString(),
                  style:
                      AppFonts.bodyText.copyWith(color: AppColors.textPrimary),
                ),
              ),
            );
          }

          final ratio = _dailyTakenRatio[dateOnly]!;
          Color boxColor;
          if (ratio == 0.0) {
            boxColor = AppColors.buttonColor.withOpacity(0.1);
          } else if (ratio < 0.25) {
            boxColor = AppColors.buttonColor.withOpacity(0.25);
          } else if (ratio < 0.50) {
            boxColor = AppColors.buttonColor.withOpacity(0.4);
          } else if (ratio < 0.75) {
            boxColor = AppColors.buttonColor.withOpacity(0.6);
          } else if (ratio < 1.0) {
            boxColor = AppColors.buttonColor.withOpacity(0.8);
          } else {
            boxColor = AppColors.buttonColor;
          }

          return Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: boxColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                day.day.toString(),
                style: AppFonts.bodyText.copyWith(color: AppColors.textPrimary),
              ),
            ),
          );
        },
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendTextStyle:
            AppFonts.bodyText.copyWith(color: AppColors.textPrimary),
        todayDecoration: BoxDecoration(
          color: AppColors.buttonColor.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: AppColors.buttonColor,
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle:
            AppFonts.subHeadline.copyWith(color: AppColors.textPrimary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new,
                          color: AppColors.buttonColor, size: 28),
                      onPressed: widget.onBack,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Expanded(
                      child: Text(
                        "Reports".tr(),
                        textAlign: TextAlign.center,
                        style: AppFonts.headline.copyWith(fontSize: 24),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 32),
                if (!_showCards) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLegendItem(
                          AppColors.buttonColor.withOpacity(0.1), "0%"),
                      _buildLegendItem(
                          AppColors.buttonColor.withOpacity(0.25), "25%"),
                      _buildLegendItem(
                          AppColors.buttonColor.withOpacity(0.4), "50%"),
                      _buildLegendItem(
                          AppColors.buttonColor.withOpacity(0.6), "75%"),
                      _buildLegendItem(AppColors.buttonColor, "100%"),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: AppColors.cardBackground,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildCalendar(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  MyElevatedButton(
                    text: "Share Med Logs\nwith your Doctor".tr(),
                    icon: const Icon(Icons.ios_share, size: 20),
                    onPressed: () => setState(() => _showCards = true),
                    backgroundColor: AppColors.buttonColor,
                    textColor: AppColors.buttonText,
                    borderRadius: 50,
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 24),
                    textStyle: AppFonts.buttonText.copyWith(fontSize: 16),
                    height: 60,
                    iconSpacing:
                        12.0, // Increased spacing between icon and text
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: GestureDetector(
                            onTap: () => shareMedicationPdf(context),
                            child: Card(
                              color: AppColors.cardBackground,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.medical_services,
                                      size: 36,
                                      color: AppColors.buttonColor,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "Medication List".tr(),
                                      textAlign: TextAlign.center,
                                      style: AppFonts.bodyText.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: GestureDetector(
                            onTap: () => shareMedicationRecordsPdf(context),
                            child: Card(
                              color: AppColors.cardBackground,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.receipt_long,
                                      size: 36,
                                      color: AppColors.buttonColor,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "Medication Records".tr(),
                                      textAlign: TextAlign.center,
                                      style: AppFonts.bodyText.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppFonts.bodyText.copyWith(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
