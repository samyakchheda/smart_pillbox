import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home/theme/app_colors.dart';

class SmartDiagnosisInfoScreen extends StatelessWidget {
  final VoidCallback onBack;

  const SmartDiagnosisInfoScreen({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: onBack,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Expanded(
          child: Text(
            "Smart Diagnosis",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.buttonColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.medical_services_outlined,
            size: 100,
            color: AppColors.buttonColor,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "What is Smart Diagnosis?",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Smart Diagnosis is an advanced feature that allows you to check the health and performance of your smart pillbox device.",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 24),
        ..._buildFeatureItems(),
        const SizedBox(height: 20),
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
        'description': "Identifies potential issues before they affect performance"
      },
      {
        'icon': Icons.tips_and_updates,
        'title': "Maintenance Tips",
        'description': "Provides recommendations to keep your device running optimally"
      },
    ];

    return features.map((feature) => _buildFeatureItem(
      icon: feature['icon'] as IconData,
      title: feature['title'] as String,
      description: feature['description'] as String,
    )).toList();
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.buttonColor,
            size: 24,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBox() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.amber, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.amber[800],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Please ensure your device is powered on and connected to your account before starting the diagnosis.",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.amber[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _navigateToDiagnosisScreen(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 3,
          ),
          child: Text(
            "Start Diagnosis",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToDiagnosisScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: DiagnosisInProgressScreen(
            onBack: () => Navigator.pop(context),
            onComplete: () {
              // You can navigate to a separate result screen if needed
            },
          ),
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
  State<DiagnosisInProgressScreen> createState() => _DiagnosisInProgressScreenState();
}

class _DiagnosisInProgressScreenState extends State<DiagnosisInProgressScreen>
    with SingleTickerProviderStateMixin {
  double _progress = 0.0;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isCompleted = false;

  // List of diagnostic items
  final List<String> _diagnosticItems = [
    "Temperature Sensor",
    "Evaporator Defrost",
    "Fan Motor",
    "Pill Dispenser",
    "Battery Health",
    "Connection Status"
  ];

  // Mock diagnosis results
  final Map<String, Map<String, dynamic>> _diagnosisResults = {
    "Temperature Sensor": {"status": "Good", "icon": Icons.check_circle, "color": Colors.green},
    "Evaporator Defrost": {"status": "Good", "icon": Icons.check_circle, "color": Colors.green},
    "Fan Motor": {"status": "Attention Needed", "icon": Icons.warning, "color": Colors.orange},
    "Pill Dispenser": {"status": "Good", "icon": Icons.check_circle, "color": Colors.green},
    "Battery Health": {"status": "Good", "icon": Icons.check_circle, "color": Colors.green},
    "Connection Status": {"status": "Good", "icon": Icons.check_circle, "color": Colors.green},
  };

  // Recommendations based on diagnosis
  final List<Map<String, dynamic>> _recommendations = [
    {
      "title": "Fan Motor Maintenance",
      "description": "Clean the fan motor area to improve performance.",
      "icon": Icons.cleaning_services,
    },
    {
      "title": "Regular Cleaning",
      "description": "Clean the device exterior weekly with a soft, dry cloth.",
      "icon": Icons.cleaning_services,
    },
    {
      "title": "Software Update",
      "description": "Keep your app updated for the latest features and fixes.",
      "icon": Icons.system_update,
    },
    {
      "title": "Battery Care",
      "description": "Charge the device when the battery level falls below 20%.",
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
      duration: const Duration(seconds: 5), // Simulate 5-second diagnosis
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

    // Start the diagnosis animation automatically
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
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
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
            _isCompleted ? "Diagnosis Results" : "Smart Diagnosis",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
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
              SizedBox(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(
                  value: _progress,
                  strokeWidth: 10,
                  backgroundColor: Colors.grey.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.buttonColor),
                ),
              ),
              Text(
                "${(_progress * 100).toInt()}%",
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.buttonColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Text(
          "Product check is in progress...",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 30),
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
          const SizedBox(height: 24),
          _buildDetailedResults(),
          const SizedBox(height: 32),
          _buildRecommendationsSection(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildResultSummary() {
    final hasIssue = _diagnosisResults.values.any((result) => result["status"] != "Good");

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: hasIssue ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasIssue ? Colors.orange : Colors.green,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            hasIssue ? Icons.warning_amber_rounded : Icons.check_circle,
            size: 48,
            color: hasIssue ? Colors.orange : Colors.green,
          ),
          const SizedBox(height: 12),
          Text(
            hasIssue ? "Minor Issues Detected" : "All Systems Operational",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasIssue
                ? "Your device is functioning but needs some attention."
                : "Your device is functioning properly with no issues detected.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Detailed Results",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            result["icon"] as IconData,
            color: result["color"] as Color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  result["status"] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: (result["color"] as Color).withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recommendations",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.buttonColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.buttonColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            recommendation["icon"] as IconData,
            color: AppColors.buttonColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation["title"] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recommendation["description"] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: widget.onBack,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 3,
          ),
          child: Text(
            "Complete Diagnosis",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosticItems() {
    return Column(
      children: [
        for (int i = 0; i < _diagnosticItems.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                Expanded(child: _buildCheckItem(_diagnosticItems[i])),
                const SizedBox(width: 16),
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
        Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.buttonColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarningText() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "PLEASE STAY ON THIS SCREEN UNTIL THE DIAGNOSIS IS COMPLETE.\nOtherwise, the diagnosis will end.",
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Cancel Diagnosis?",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "The diagnosis is still in progress. Are you sure you want to exit?",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Continue",
              style: GoogleFonts.poppins(
                color: Colors.grey[700],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onBack();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonColor,
            ),
            child: Text(
              "Exit",
              style: GoogleFonts.poppins(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}