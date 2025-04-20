import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:home/theme/app_colors.dart';
import 'package:home/theme/app_fonts.dart';
import 'package:home/widgets/common/my_elevated_button.dart';

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
            "Smart Diagnosis".tr(),
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
                  "What is Smart Diagnosis?".tr(),
                  style: AppFonts.subHeadline.copyWith(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "Smart Diagnosis is an advanced feature that allows you to check the health and performance of your smart pillbox device."
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
        'title': "Quick Analysis".tr(),
        'description': "Complete device diagnosis in just a few seconds".tr()
      },
      {
        'icon': Icons.sensors,
        'title': "Comprehensive Check".tr(),
        'description':
            "Tests temperature sensors, motor functions, and more".tr()
      },
      {
        'icon': Icons.healing,
        'title': "Problem Detection".tr(),
        'description':
            "Identifies potential issues before they affect performance".tr()
      },
      {
        'icon': Icons.tips_and_updates,
        'title': "Maintenance Tips".tr(),
        'description':
            "Provides recommendations to keep your device running optimally"
                .tr()
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
                "Please ensure your device is powered on and connected to your account before starting the diagnosis."
                    .tr(),
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
        text: "Start Diagnosis".tr(),
        icon: const Icon(Icons.play_arrow, size: 20),
        onPressed: () => _navigateToDiagnosisScreen(context),
        backgroundColor: AppColors.buttonColor,
        borderRadius: 50,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        textStyle: AppFonts.buttonText.copyWith(fontSize: 16),
        height: 60, // Increased height to prevent text cutoff
        textShift: 0, // Adjusted to center text when icon is present
      ),
    );
  }

  void _navigateToDiagnosisScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiagnosisInProgressScreen(
          onBack: () => Navigator.pop(context),
          onComplete: () {},
        ),
      ),
    );
  }
}

class DiagnosisInProgressScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const DiagnosisInProgressScreen({
    super.key,
    required this.onComplete,
    required this.onBack,
  });

  @override
  State<DiagnosisInProgressScreen> createState() =>
      _DiagnosisInProgressScreenState();
}

class _DiagnosisInProgressScreenState extends State<DiagnosisInProgressScreen>
    with SingleTickerProviderStateMixin {
  double _progress = 0.0;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isCompleted = false;

  final List<String> _diagnosticItems = [
    "Motor".tr(),
    "LCD".tr(),
    "Camera".tr(),
    "Microcontroller".tr(),
    "Battery".tr(),
  ];

  final Map<String, Map<String, dynamic>> _diagnosisResults = {
    "Motor": {
      "status": "Good",
      "icon": Icons.check_circle,
      "color": Colors.green
    },
    "LCD": {
      "status": "Good",
      "icon": Icons.check_circle,
      "color": Colors.green
    },
    "Camera": {
      "status": "Attention Needed",
      "icon": Icons.warning,
      "color": Colors.orange
    },
    "Microcontroller": {
      "status": "Good",
      "icon": Icons.check_circle,
      "color": Colors.green
    },
    "Battery": {
      "status": "Good",
      "icon": Icons.check_circle,
      "color": Colors.green
    },
  };

  final List<Map<String, dynamic>> _recommendations = [
    {
      "title": "Motor Maintenance".tr(),
      "description": "Clean the motor area to improve performance.".tr(),
      "icon": Icons.cleaning_services,
    },
    {
      "title": "LCD Cleaning".tr(),
      "description": "Clean the LCD screen with a soft, dry cloth.".tr(),
      "icon": Icons.cleaning_services,
    },
    {
      "title": "Camera Check".tr(),
      "description": "Ensure the camera lens is clean and unobstructed.".tr(),
      "icon": Icons.camera_alt,
    },
    {
      "title": "Software Update".tr(),
      "description":
          "Keep your app updated for the latest features and fixes.".tr(),
      "icon": Icons.system_update,
    },
    {
      "title": "Battery Care".tr(),
      "description":
          "Charge the device when the battery level falls below 20%.".tr(),
      "icon": Icons.battery_charging_full,
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    )..addListener(() {
        setState(() {
          _progress = _animation.value;
        });
        if (_animation.isCompleted && !_isCompleted) {
          setState(() {
            _isCompleted = true;
          });
        }
      });

    _animationController.forward(from: 0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
    return Column(
      children: [
        const SizedBox(height: 40),
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 180,
                height: 180,
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
                  strokeWidth: 12,
                  backgroundColor: AppColors.textPlaceholder.withOpacity(0.2),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.buttonColor),
                ),
              ),
              Text(
                "${(_progress * 100).toInt()}%",
                style: AppFonts.headline.copyWith(
                  color: AppColors.buttonColor,
                  fontSize: 36,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Text(
          "Diagnosing your device...".tr(),
          style: AppFonts.subHeadline.copyWith(fontSize: 18),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _buildDiagnosticItems(),
        const Spacer(),
        _buildWarningText(),
      ],
    );
  }

  Widget _buildDiagnosisResults() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildResultSummary(),
          const SizedBox(height: 32),
          _buildDetailedResults(),
          const SizedBox(height: 32),
          _buildRecommendationsSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildResultSummary() {
    final hasIssue =
        _diagnosisResults.values.any((result) => result["status"] != "Good");

    return Card(
      color: AppColors.cardBackground,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  ? "Minor Issues Detected".tr()
                  : "All Systems Operational".tr(),
              style: AppFonts.subHeadline.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              hasIssue
                  ? "Your device is functioning but needs some attention.".tr()
                  : "Your device is functioning properly with no issues detected."
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
    );
  }

  Widget _buildDetailedResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Detailed Results".tr(),
          style: AppFonts.subHeadline.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 16),
        ...List.generate(
          _diagnosticItems.length,
          (index) => _buildResultItem(_diagnosticItems[index]),
        ),
      ],
    );
  }

  Widget _buildResultItem(String item) {
    final result = _diagnosisResults[item]!;

    return Card(
      color: AppColors.cardBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              result["icon"] as IconData,
              color: result["color"] as Color,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item,
                    style: AppFonts.bodyText.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    result["status"] as String,
                    style: AppFonts.bodyText.copyWith(
                      color: (result["color"] as Color).withOpacity(0.8),
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

  Widget _buildRecommendationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recommendations".tr(),
          style: AppFonts.subHeadline.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 16),
        ...List.generate(
          _recommendations.length,
          (index) => _buildRecommendationItem(_recommendations[index]),
        ),
      ],
    );
  }

  Widget _buildRecommendationItem(Map<String, dynamic> recommendation) {
    return Card(
      color: AppColors.cardBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              recommendation["icon"] as IconData,
              color: AppColors.buttonColor,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recommendation["title"] as String,
                    style: AppFonts.bodyText.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    recommendation["description"] as String,
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

  Widget _buildDiagnosticItems() {
    return Column(
      children: [
        for (int i = 0; i < _diagnosticItems.length; i += 2)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(child: _buildCheckItem(_diagnosticItems[i])),
                const SizedBox(width: 20),
                if (i + 1 < _diagnosticItems.length)
                  Expanded(child: _buildCheckItem(_diagnosticItems[i + 1]))
                else
                  const Spacer(),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCheckItem(String label) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _progress > 0.2
                ? AppColors.buttonColor
                : AppColors.textPlaceholder,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppFonts.bodyText.copyWith(fontSize: 17),
          ),
        ),
      ],
    );
  }

  Widget _buildWarningText() {
    return Card(
      color: AppColors.cardBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          "Please stay on this screen until the diagnosis is complete.\nLeaving now will cancel the process."
              .tr(),
          textAlign: TextAlign.center,
          style: AppFonts.bodyText.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Cancel Diagnosis?".tr(),
          style: AppFonts.subHeadline.copyWith(fontSize: 20),
          textAlign: TextAlign.center,
        ),
        content: Text(
          "The diagnosis is still in progress. Are you sure you want to exit?"
              .tr(),
          style: AppFonts.bodyText.copyWith(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Continue".tr(),
              style: AppFonts.buttonText.copyWith(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ),
          MyElevatedButton(
            text: "Exit".tr(),
            onPressed: () {
              Navigator.pop(context);
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
