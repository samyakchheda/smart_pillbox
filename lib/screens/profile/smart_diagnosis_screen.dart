import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:home/theme/app_colors.dart';
import 'package:home/theme/app_fonts.dart';
import 'package:home/widgets/common/my_elevated_button.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SmartDiagnosisInfoScreen extends StatelessWidget {
  final VoidCallback onBack;

  const SmartDiagnosisInfoScreen({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildContent(context),
                ),
              ),
              _buildStartButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: AppColors.buttonColor, size: 28),
          onPressed: onBack,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Expanded(
          child: Text(
            "Smart Diagnosis",
            textAlign: TextAlign.center,
            style: AppFonts.headline.copyWith(fontSize: 24),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.buttonColor.withOpacity(0.2),
                AppColors.buttonColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.buttonColor.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.medical_services_outlined,
            size: 120,
            color: AppColors.buttonColor,
          ),
        ),
        const SizedBox(height: 32),
        Card(
          color: AppColors.cardBackground,
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  "What is Smart Diagnosis?",
                  style: AppFonts.subHeadline.copyWith(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "Smart Diagnosis is an advanced feature that allows you to check the health and performance of your smart pillbox device.",
                  textAlign: TextAlign.center,
                  style: AppFonts.bodyText.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        ..._buildFeatureItems(),
        const SizedBox(height: 24),
        _buildWarningBox(),
      ],
    );
  }

  List<Widget> _buildFeatureItems() {
    final features = [
      {
        'icon': Icons.check_circle_outline,
        'title': "Quick Analysis",
        'description': "Complete device diagnosis in just a few seconds"
      },
      {
        'icon': Icons.sensors,
        'title': "Comprehensive Check",
        'description': "Tests temperature sensors, motor functions, and more"
      },
      {
        'icon': Icons.healing,
        'title': "Problem Detection",
        'description':
            "Identifies potential issues before they affect performance"
      },
      {
        'icon': Icons.tips_and_updates,
        'title': "Maintenance Tips",
        'description':
            "Provides recommendations to keep your device running optimally"
      },
    ];

    return features
        .map((feature) => _buildFeatureItem(
              icon: feature['icon'] as IconData,
              title: feature['title'] as String,
              description: feature['description'] as String,
            ))
        .toList();
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      color: AppColors.cardBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: AppColors.buttonColor,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFonts.bodyText.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: AppFonts.bodyText.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningBox() {
    return Card(
      color: AppColors.cardBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppColors.kGreyColor,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                "Please ensure your device is powered on and connected to your account before starting the diagnosis.",
                style: AppFonts.bodyText.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: MyElevatedButton(
        text: "Start Diagnosis",
        icon: const Icon(Icons.play_arrow, size: 20),
        onPressed: () => _navigateToDiagnosisScreen(context),
        backgroundColor: AppColors.buttonColor,
        borderRadius: 50,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        textStyle: AppFonts.buttonText.copyWith(fontSize: 16),
        height: 60,
        textShift: 0,
      ),
    );
  }

  void _navigateToDiagnosisScreen(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser; // Get current user

    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiagnosisInProgressScreen(
            esp32Ip: "192.168.1.106",
            userId: user.uid, // Pass the fetched user ID
            onBack: () => Navigator.pop(context),
            onComplete: () {},
          ),
        ),
      );
    } else {
      // Handle the case where the user is not signed in
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not signed in')),
      );
    }
  }
}

class DiagnosisInProgressScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;
  final String esp32Ip;
  final String userId;

  const DiagnosisInProgressScreen({
    super.key,
    required this.onComplete,
    required this.onBack,
    required this.esp32Ip,
    required this.userId,
  });

  @override
  State<DiagnosisInProgressScreen> createState() =>
      _DiagnosisInProgressScreenState();
}

class _DiagnosisInProgressScreenState extends State<DiagnosisInProgressScreen> {
  double _progress = 0.0;
  bool _isCompleted = false;

  // the 6 diagnostic steps
  final List<String> _steps = [
    "microcontroller",
    "reset",
    "camera",
    "lcd",
    "motor",
  ];

  // store the result of each step
  final Map<String, _StepResult> _diagnosisResults = {};

  // static recommendations data
  final List<Map<String, dynamic>> _recommendations = [
    {
      "title": "Motor Maintenance",
      "description": "Clean the motor area to improve performance.",
      "icon": Icons.cleaning_services,
    },
    {
      "title": "LCD Cleaning",
      "description": "Clean the LCD screen with a soft, dry cloth.",
      "icon": Icons.cleaning_services,
    },
    {
      "title": "Camera Check",
      "description": "Ensure the camera lens is clean and unobstructed.",
      "icon": Icons.camera_alt,
    },
    {
      "title": "Software Update",
      "description": "Keep your app updated for the latest features and fixes.",
      "icon": Icons.system_update,
    },
  ];

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    for (var i = 0; i < _steps.length; i++) {
      final step = _steps[i];
      bool success = false;
      String msg = "";

      try {
        final resp = await http.post(
          Uri.parse("https://6617-183-87-183-2.ngrok-free.app/command/$step"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "esp32_ip": widget.esp32Ip.replaceAll(RegExp(r'https?://'), ""),
            "user": widget.userId,
          }),
        );
        if (resp.statusCode == 200) {
          success = true;
          final data = jsonDecode(resp.body);
          msg = data["message"] ?? "OK";
          debugPrint("Response: $msg");
        } else {
          msg = "Error ${resp.statusCode}";
        }
      } catch (e) {
        msg = e.toString();
      }

      setState(() {
        final label = step[0].toUpperCase() + step.substring(1);
        _diagnosisResults[label] = _StepResult(
          name: label,
          success: success,
          message: msg,
        );
        _progress = (i + 1) / _steps.length;
      });

      // if the very first step fails with "not reachable", stop everything:
      if (step == "microcontroller" &&
          msg.toLowerCase().contains("not reachable")) {
        // tell the user to reconnect, then pop this screen
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Device Unreachable".tr()),
            content: Text(
                "Please power on and connect your microcontroller, then try again."
                    .tr()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // close dialog
                  widget.onBack(); // pop diagnosis screen
                },
                child: Text("OK".tr()),
              ),
            ],
          ),
        );
        return;
      }

      // small pause so each icon update is visible
      await Future.delayed(const Duration(milliseconds: 300));
    }

    setState(() => _isCompleted = true);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_isCompleted) {
          _showExitConfirmation(context);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                Expanded(
                  child: _isCompleted
                      ? _buildDiagnosisResults()
                      : _buildDiagnosisInProgress(),
                ),
                if (_isCompleted) _buildCompleteButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.buttonColor, size: 28),
          onPressed: () {
            if (!_isCompleted) {
              _showExitConfirmation(context);
            } else {
              widget.onBack();
            }
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Expanded(
          child: Text(
            _isCompleted ? "Diagnosis Results".tr() : "Smart Diagnosis".tr(),
            textAlign: TextAlign.center,
            style: AppFonts.headline.copyWith(fontSize: 24),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildDiagnosisInProgress() {
    final screenWidth = MediaQuery.of(context).size.width;

    double progressSize = screenWidth < 360 ? 140 : 180;
    double progressStroke = screenWidth < 360 ? 8 : 12;
    double percentageFontSize = screenWidth < 360 ? 28 : 36;
    double diagnosingTextFontSize = screenWidth < 360 ? 16 : 18;
    double topSpacing = screenWidth < 360 ? 30 : 40;
    double bottomSpacing = screenWidth < 360 ? 24 : 32;

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: topSpacing),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: progressSize,
                    height: progressSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.buttonColor.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: CircularProgressIndicator(
                      value: _progress,
                      strokeWidth: progressStroke,
                      backgroundColor:
                          AppColors.textPlaceholder.withOpacity(0.2),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.buttonColor),
                    ),
                  ),
                  Text(
                    "${(_progress * 100).toInt()}%",
                    style: AppFonts.headline.copyWith(
                      color: AppColors.buttonColor,
                      fontSize: percentageFontSize,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: topSpacing),
            Text(
              "Diagnosing your device...".tr(),
              style: AppFonts.subHeadline
                  .copyWith(fontSize: diagnosingTextFontSize),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: bottomSpacing),
            _buildDiagnosticItems(),
            SizedBox(height: 40), // Give some bottom space
            _buildWarningText(),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosticItems() {
    final screenWidth =
        MediaQuery.of(context).size.width; // Access context directly

    double fontSizeMain = screenWidth < 360 ? 15 : 17;
    double fontSizeSecondary = screenWidth < 360 ? 12 : 14;
    double iconSize = screenWidth < 360 ? 20 : 24;
    double spacing = screenWidth < 360 ? 8 : 12;

    return Column(
      children: _steps.map((step) {
        final label = step[0].toUpperCase() + step.substring(1);
        final result = _diagnosisResults[label];
        return Padding(
          padding: EdgeInsets.symmetric(vertical: spacing / 2),
          child: Row(
            children: [
              Icon(
                result == null
                    ? Icons.hourglass_empty
                    : (result.success ? Icons.check_circle : Icons.error),
                color: result == null
                    ? AppColors.textPlaceholder
                    : (result.success ? Colors.green : Colors.red),
                size: iconSize,
              ),
              SizedBox(width: spacing),
              Flexible(
                child: Text(
                  label,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.bodyText.copyWith(fontSize: fontSizeMain),
                ),
              ),
              SizedBox(width: spacing),
              Flexible(
                child: Text(
                  result?.message ?? "Pending".tr(),
                  style: AppFonts.bodyText.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: fontSizeSecondary,
                  ),
                  overflow:
                      TextOverflow.ellipsis, // Ensure the text doesn't overflow
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDiagnosisResults() {
    final micro = _diagnosisResults['Microcontroller'];
    final isMicroError = micro != null &&
        !micro.success &&
        micro.message.toLowerCase().contains('not reachable');

    if (isMicroError) {
      return SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Card(
              color: AppColors.cardBackground,
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Device Unreachable'.tr(),
                      style: AppFonts.subHeadline.copyWith(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Please power on and connect your microcontroller, then retry.'
                          .tr(),
                      textAlign: TextAlign.center,
                      style: AppFonts.bodyText.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildDetailedResults(),
            const SizedBox(height: 24),
          ],
        ),
      );
    }

    final hasIssue = _diagnosisResults.values.any((r) => r.success == false);
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          Card(
            color: AppColors.cardBackground,
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    hasIssue ? Icons.warning_amber_rounded : Icons.check_circle,
                    size: 60,
                    color: hasIssue ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    hasIssue
                        ? 'Minor Issues Detected'.tr()
                        : 'All Systems Operational'.tr(),
                    style: AppFonts.subHeadline.copyWith(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    hasIssue
                        ? 'Your device is functioning but needs some attention.'
                            .tr()
                        : 'Your device is functioning properly with no issues detected.'
                            .tr(),
                    textAlign: TextAlign.center,
                    style: AppFonts.bodyText.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildDetailedResults(),
          const SizedBox(height: 32),
          _buildRecommendationsSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDetailedResults() {
    final micro = _diagnosisResults['Microcontroller'];
    final isMicroError = micro != null &&
        !micro.success &&
        micro.message.toLowerCase().contains('not reachable');

    final children = <Widget>[
      Text(
        'Detailed Results'.tr(),
        style: AppFonts.subHeadline.copyWith(fontSize: 20),
      ),
      const SizedBox(height: 16),
    ];

    if (isMicroError) {
      children.add(_buildResultItem('Microcontroller', micro!));
    } else {
      for (final step in _steps) {
        final label = step[0].toUpperCase() + step.substring(1);
        final r = _diagnosisResults[label];
        if (r != null) {
          children.add(_buildResultItem(label, r));
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildResultItem(String item, _StepResult r) {
    return Card(
      color: AppColors.cardBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(
          r.success ? Icons.check_circle : Icons.error,
          color: r.success ? Colors.green : Colors.red,
          size: 28,
        ),
        title: Text(item, style: AppFonts.bodyText.copyWith(fontSize: 16)),
        subtitle: Text(
          r.message,
          style: AppFonts.bodyText.copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Recommendations".tr(),
            style: AppFonts.subHeadline.copyWith(fontSize: 20)),
        const SizedBox(height: 16),
        ..._recommendations.map((rec) {
          return Card(
            color: AppColors.cardBackground,
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    rec["icon"] as IconData,
                    color: AppColors.buttonColor,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rec["title"] as String,
                            style: AppFonts.bodyText.copyWith(
                                fontWeight: FontWeight.w600, fontSize: 16)),
                        const SizedBox(height: 6),
                        Text(rec["description"] as String,
                            style: AppFonts.bodyText.copyWith(
                                color: AppColors.textSecondary, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildWarningText() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 600;
    return Card(
      color: AppColors.cardBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isSmall ? 12 : 16),
        child: Text(
          "Please stay on this screen until the diagnosis is complete.\nLeaving now will cancel the process."
              .tr(),
          textAlign: TextAlign.center,
          style: AppFonts.bodyText.copyWith(
            color: AppColors.textSecondary,
            fontSize: isSmall ? 13 : 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCompleteButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: MyElevatedButton(
        text: "Finish".tr(),
        icon: const Icon(Icons.check, size: 20),
        onPressed: widget.onBack,
        backgroundColor: AppColors.buttonColor,
        borderRadius: 50,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        textStyle: AppFonts.buttonText.copyWith(fontSize: 16),
        height: 60,
        textShift: 0,
      ),
    );
  }

  void _showExitConfirmation(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Cancel Diagnosis?".tr(),
            style: AppFonts.subHeadline.copyWith(fontSize: 20),
            textAlign: TextAlign.center),
        content: Text(
          "The diagnosis is still in progress. Are you sure you want to exit?"
              .tr(),
          style: AppFonts.bodyText.copyWith(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Continue".tr(),
                style: AppFonts.buttonText
                    .copyWith(color: AppColors.textSecondary, fontSize: 16)),
          ),
          MyElevatedButton(
            text: "Exit".tr(),
            onPressed: () {
              Navigator.pop(ctx);
              widget.onBack();
            },
            backgroundColor: AppColors.buttonColor,
            borderRadius: 50,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            textStyle: AppFonts.buttonText.copyWith(fontSize: 16),
            height: 60,
            textShift: 0,
          ),
        ],
      ),
    );
  }
}

class _StepResult {
  final String name;
  final bool success;
  final String message;

  _StepResult({
    required this.name,
    required this.success,
    required this.message,
  });
}
