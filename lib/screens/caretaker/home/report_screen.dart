import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:home/theme/app_colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  // Toggle for showing the medication cards.
  bool _showCards = false;

  // Focused day for the calendar.
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Helper functions for Firestore Timestamps.
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

  String formatTimeOnly(DateTime dt) {
    return DateFormat('hh:mm a').format(dt);
  }

  String formatDateOnly(DateTime dt) {
    return DateFormat('dd MMM yyyy').format(dt);
  }

  @override
  void initState() {
    super.initState();
    _fetchCalendarData();
  }

  // -------------------------------------------------
  // 1) SHARE MEDICATION LIST PDF (unchanged)
  // -------------------------------------------------
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

      final pdf = pw.Document();

      final tableData = medicinesArray
          .where((item) => item is Map<String, dynamic>)
          .map((item) {
        final map = item as Map<String, dynamic>;

        final String doseFrequency = map['doseFrequency']?.toString() ?? 'N/A';
        final String startDate = parseTimestampAsDate(map['startDate']);
        final String endDate = parseTimestampAsDate(map['endDate']);

        final dynamic medNamesData = map['medicineNames'];
        String medicineName;
        if (medNamesData is List) {
          medicineName = medNamesData.join(', ');
        } else {
          medicineName = medNamesData?.toString() ?? 'Unknown';
        }

        final dynamic timesList = map['medicineTimes'];
        String timesString;
        if (timesList is List) {
          timesString =
              timesList.map((e) => parseTimestampAsTime(e)).join(', ');
        } else {
          timesString = timesList?.toString() ?? 'N/A';
        }

        return [
          medicineName,
          doseFrequency,
          startDate,
          endDate,
          timesString,
        ];
      }).toList();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Text(
                  "Medication List",
                  style: const pw.TextStyle(fontSize: 24),
                ),
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
                  headerDecoration:
                      const pw.BoxDecoration(color: PdfColors.grey300),
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
            );
          },
        ),
      );

      final pdfBytes = await pdf.save();
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/medications.pdf';
      final file = File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(pdfBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: "Medication List PDF",
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // -------------------------------------------------
  // 2) SHARE MEDICATION RECORDS PDF (WITH DATE RANGE, LOCAL FILTER)
  // -------------------------------------------------
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
      // The key to lookup in the `status` map (e.g. "25-03-2025")
      final String dayKey = DateFormat('dd-MM-yyyy').format(currentDay);

      for (final item in medicinesArray) {
        if (item is! Map<String, dynamic>) continue;
        final map = item;

        // --- Get the medicine name(s) ---
        final dynamic medNamesData = map['medicineNames'];
        String medicineName;
        if (medNamesData is List) {
          medicineName = medNamesData.join(', ');
        } else {
          medicineName = medNamesData?.toString() ?? 'Unknown';
        }

        // --- Check date range ---
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

        // --- Retrieve daily status from `status` map ---
        String dosageStatus = 'Not Taken'; // default
        if (map.containsKey('status')) {
          final statusMap = map['status'];
          if (statusMap is Map<String, dynamic>) {
            final dayValue = statusMap[dayKey]?.toString().toLowerCase();
            if (dayValue == 'taken') {
              dosageStatus = 'Taken';
            }
          }
        }

        // --- Retrieve times (if any) ---
        final dynamic timesList = map['medicineTimes'];
        if (timesList is List && timesList.isNotEmpty) {
          for (final t in timesList) {
            String timeStr;
            if (t is Timestamp) {
              timeStr = parseTimestampAsTime(t);
            } else {
              timeStr = t.toString();
            }
            tableData.add([
              dayLabel,
              medicineName,
              timeStr,
              dosageStatus,
            ]);
          }
        } else {
          tableData.add([
            dayLabel,
            medicineName,
            '-',
            dosageStatus,
          ]);
        }
      }

      // Move to next day
      currentDay = currentDay.add(const Duration(days: 1));
    }

    if (tableData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No records found in this date range.')),
      );
      return;
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        // Optionally add a header that repeats on every page:
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "Medication Records",
              style: const pw.TextStyle(fontSize: 24),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              "From ${DateFormat('dd MMM yyyy').format(dateRange.start)} "
              "to ${DateFormat('dd MMM yyyy').format(dateRange.end)}",
              style: const pw.TextStyle(fontSize: 14),
            ),
            pw.SizedBox(height: 20),
          ],
        ),
        build: (pw.Context context) {
          return [
            pw.Table.fromTextArray(
              headers: ["Date", "Medicine Name", "Time", "Dosage Status"],
              data: tableData,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey300),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.centerLeft,
              },
            ),
          ];
        },
      ),
    );

    final pdfBytes = await pdf.save();
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/medication_records.pdf';
    final file = File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(pdfBytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: "Medication Records PDF",
    );
  }

  Map<DateTime, double> _dailyTakenRatio = {};

  Future<void> _fetchCalendarData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // No user is signed in.
        return;
      }
      final userId = user.uid;

      // Retrieve the user document.
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!docSnapshot.exists) {
        // Document not found.
        return;
      }

      final data = docSnapshot.data() as Map<String, dynamic>? ?? {};
      final List<dynamic> medicinesArray = data['medicines'] ?? [];

      // Temporary maps to count scheduled vs. taken for each date.
      final Map<DateTime, int> dailyScheduledCount = {};
      final Map<DateTime, int> dailyTakenCount = {};

      for (final item in medicinesArray) {
        if (item is Map<String, dynamic>) {
          // Start and end date of this medicine
          final DateTime? startDate = parseCustomDateString(item['startDate']);
          final DateTime? endDate = parseCustomDateString(item['endDate']);
          final statusMap = item['status'];

          if (startDate == null || endDate == null) continue;

          // Go day by day from startDate to endDate
          DateTime currentDay =
              DateTime(startDate.year, startDate.month, startDate.day);
          final DateTime endDay =
              DateTime(endDate.year, endDate.month, endDate.day);

          while (!currentDay.isAfter(endDay)) {
            // For each day in the medicine's range, increment the scheduled count
            dailyScheduledCount[currentDay] =
                (dailyScheduledCount[currentDay] ?? 0) + 1;

            // Check if statusMap indicates "taken" for this day
            if (statusMap is Map<String, dynamic>) {
              final dayKey = DateFormat('dd-MM-yyyy').format(currentDay);
              final dayValue = statusMap[dayKey]?.toString().toLowerCase();
              if (dayValue == 'taken') {
                dailyTakenCount[currentDay] =
                    (dailyTakenCount[currentDay] ?? 0) + 1;
              }
            }

            // Move to next day
            currentDay = currentDay.add(const Duration(days: 1));
          }
        }
      }

      // Now compute the ratio of (taken / scheduled) for each date.
      // Clear the old map before filling new data:
      _dailyTakenRatio.clear();

      for (final day in dailyScheduledCount.keys) {
        final scheduled = dailyScheduledCount[day] ?? 0;
        final taken = dailyTakenCount[day] ?? 0;
        if (scheduled > 0) {
          _dailyTakenRatio[day] = taken / scheduled; // e.g. 0.5 => 50% taken
        } else {
          _dailyTakenRatio[day] = 0.0;
        }
      }

      setState(() {
        // Trigger UI rebuild after fetching data
      });
    } catch (e) {
      // Handle errors if needed
      debugPrint('Error in _fetchCalendarData: $e');
    }
  }

  // -------------------------------------------------
  // Build the Calendar using TableCalendar.
  // -------------------------------------------------
  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          final dateOnly = DateTime(day.year, day.month, day.day);

          // If no medicines are scheduled for this day, show a default color.
          if (!_dailyTakenRatio.containsKey(dateOnly)) {
            return Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(day.day.toString())),
            );
          }

          final ratio = _dailyTakenRatio[dateOnly]!;

          // Determine the box color based on the ratio.
          Color? boxColor;
          if (ratio == 0.0) {
            // Scheduled, but none taken (0%).
            boxColor = Colors.blue.shade50;
          } else if (ratio < 0.25) {
            boxColor = Colors.blue.shade100;
          } else if (ratio < 0.50) {
            boxColor = Colors.blue.shade200;
          } else if (ratio < 0.75) {
            boxColor = Colors.blue.shade300;
          } else if (ratio < 1.0) {
            boxColor = Colors.blue.shade400;
          } else {
            boxColor = Colors.blue.shade500;
          }

          return Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: boxColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(day.day.toString())),
          );
        },
      ),
    );
  }

  // -------------------------------------------------
  // Build Method: Includes Calendar, Share Button, and Cards.
  // -------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button and centered title.
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Reports",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 20),
            // Calendar at the top.
            // In your build method's Column, replace the calendar and button section with:

            if (!_showCards) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLegendItem(Colors.blue.shade50!, "0%"),
                  _buildLegendItem(Colors.blue.shade100!, "25%"),
                  _buildLegendItem(Colors.blue.shade200!, "50%"),
                  _buildLegendItem(Colors.blue.shade300!, "75%"),
                  _buildLegendItem(Colors.blue.shade400!, "100%"),
                ],
              ),
              const SizedBox(height: 8),
              _buildCalendar(),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.ios_share, color: Colors.black),
                  label: const Text("Share Med Logs with your Doctor"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    textStyle: GoogleFonts.poppins(
                      fontSize: 14,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _showCards = true;
                    });
                  },
                ),
              ),
            ] else ...[
              // Replace calendar and button with the two cards.
              Row(
                children: [
                  // Medication List card.
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: GestureDetector(
                        onTap: () => shareMedicationPdf(context),
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.medical_services, // Medicine icon
                                  size: 36,
                                  color: AppColors.buttonColor,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Medication List",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
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
                  // Medication Records card.
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: GestureDetector(
                        onTap: () => shareMedicationRecordsPdf(context),
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long, // Records/logs icon
                                  size: 36,
                                  color: AppColors.buttonColor,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Medication Records",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
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
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
