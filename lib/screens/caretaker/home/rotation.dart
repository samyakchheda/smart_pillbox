import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home/screens/caretaker/home/report_screen.dart';
import 'package:home/screens/home/issue.dart';
import 'package:home/theme/app_colors.dart';

class AutoRotateCubeWithFuture extends StatefulWidget {
  const AutoRotateCubeWithFuture({super.key});

  @override
  State<AutoRotateCubeWithFuture> createState() =>
      _AutoRotateCubeWithFutureState();
}

class _AutoRotateCubeWithFutureState extends State<AutoRotateCubeWithFuture>
    with SingleTickerProviderStateMixin {
  String deviceName = "Smart Pillbox";
  int batteryLevel = 80;
  String connectivityStatus = "Connected";

  late AnimationController _controller;
  late Animation<double> _headerAnimation;
  late Animation<Offset> _gridSlideAnimation;
  late Animation<double> _gridFadeAnimation, huntingAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );

    _gridSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );
    _gridFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> fetchPatientData() async {
    try {
      String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;
      if (currentUserEmail == null) return null;

      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('caretakers')
          .where('email', isEqualTo: currentUserEmail)
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) return null;

      String? patientEmail = userSnapshot.docs.first['patient'];
      if (patientEmail == null) return null;

      QuerySnapshot patientSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: patientEmail)
          .limit(1)
          .get();

      if (patientSnapshot.docs.isNotEmpty) {
        return patientSnapshot.docs.first.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Error fetching patient data: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Theme-aware background
      body: Stack(
        children: [
          Container(
            height: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.buttonColor,
                  AppColors.cardBackground.withOpacity(0.7),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Column(
            children: [
              FadeTransition(
                opacity: _headerAnimation,
                child: ScaleTransition(
                  scale: _headerAnimation,
                  child: Container(
                    height: 166,
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      'SmartDose'.tr(),
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          'Patient'.tr(),
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        FutureBuilder<Map<String, dynamic>?>(
                          future: fetchPatientData(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: CircularProgressIndicator(
                                  color: AppColors.buttonColor,
                                ),
                              );
                            }
                            if (!snapshot.hasData || snapshot.data == null) {
                              return Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  'Patient data not found'.tr(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              );
                            }

                            final patientData = snapshot.data!;
                            return PatientInfoCard(
                              name: patientData['name'] ?? 'Unknown',
                              email: patientData['email'] ?? 'No Email',
                              profileUrl: patientData['profile_picture'] ??
                                  'https://via.placeholder.com/150',
                            );
                          },
                        ),
                        const ReportScreen(),
                        SlideTransition(
                          position: _gridSlideAnimation,
                          child: FadeTransition(
                            opacity: _gridFadeAnimation,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: GridView.count(
                                shrinkWrap: true,
                                crossAxisCount: 2,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                                childAspectRatio: 0.85,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  _buildDeviceInfoCard(deviceName, batteryLevel,
                                      connectivityStatus),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const SendIssueScreen()));
                                    },
                                    child: _buildIssueCard(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _buildDeviceInfoCard(String deviceName, int battery, String status) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 6,
    color: AppColors.cardBackground,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.borderColor.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(Icons.devices, size: 50, color: AppColors.buttonColor),
            const SizedBox(height: 10),
            Text(
              deviceName.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.cardText,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.battery_full,
                    color: battery > 20 ? Colors.green : AppColors.errorColor),
                const SizedBox(width: 5),
                Text(
                  "$battery%",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(status == "Connected" ? Icons.wifi : Icons.wifi_off,
                    color: status == "Connected"
                        ? AppColors.buttonColor
                        : AppColors.errorColor),
                const SizedBox(width: 5),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 14,
                    color: status == "Connected"
                        ? AppColors.buttonColor
                        : AppColors.errorColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildCard(
    String title, String buttonText, IconData icon, VoidCallback onPressed) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 6,
    color: AppColors.cardBackground,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            AppColors.cardBackground,
            AppColors.borderColor.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.borderColor.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 50, color: AppColors.buttonColor),
            const SizedBox(height: 10),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cardText,
                ),
                softWrap: true,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  foregroundColor: AppColors.buttonText,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  elevation: 4,
                ),
                onPressed: onPressed,
                child: Text(
                  buttonText,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppColors.buttonText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildIssueCard() {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 6,
    color: AppColors.cardBackground,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            AppColors.cardBackground,
            AppColors.errorColor.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.errorColor.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.report_problem, size: 50, color: AppColors.errorColor),
            const SizedBox(height: 10),
            Expanded(
              child: Text(
                "Facing some issues with the box?".tr(),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cardText,
                ),
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class PatientInfoCard extends StatelessWidget {
  final String name;
  final String email;
  final String profileUrl;

  const PatientInfoCard({
    super.key,
    required this.name,
    required this.email,
    required this.profileUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(profileUrl),
          radius: 30,
        ),
        title: Text(
          name,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.cardText,
          ),
        ),
        subtitle: Text(
          email,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
