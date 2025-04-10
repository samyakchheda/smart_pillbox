import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart' as cube;
import 'package:home/screens/home/connection_screen.dart';
import 'package:home/screens/home/find_device.dart';
import 'package:home/screens/home/issue.dart';
import 'package:home/theme/app_colors.dart';
import 'package:home/theme/app_fonts.dart';

class AutoRotateCubeWithFuture extends StatefulWidget {
  const AutoRotateCubeWithFuture({super.key});

  @override
  State<AutoRotateCubeWithFuture> createState() =>
      _AutoRotateCubeWithFutureState();
}

class _AutoRotateCubeWithFutureState extends State<AutoRotateCubeWithFuture>
    with SingleTickerProviderStateMixin {
  Object? _model;

  String deviceName = "Smart Pillbox";
  int batteryLevel = 80;
  String connectivityStatus = "Connected";

  late AnimationController _controller;
  late Animation<double> _headerAnimation;
  late Animation<Offset> _cubeSlideAnimation;
  late Animation<double> _cubeFadeAnimation;
  late Animation<Offset> _gridSlideAnimation;
  late Animation<double> _gridFadeAnimation;

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

    _cubeSlideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );
    _cubeFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.6, curve: Curves.easeIn),
      ),
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(
            height: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [
                        AppColors.buttonColor.withOpacity(0.8),
                        AppColors.darkBackground.withOpacity(0.9),
                      ]
                    : [
                        AppColors.buttonColor,
                        AppColors.lightBackground.withOpacity(0.7),
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
                      style: AppFonts.headline.copyWith(
                        fontSize: 24,
                        color: AppColors.textOnPrimary,
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
                        SlideTransition(
                          position: _cubeSlideAnimation,
                          child: FadeTransition(
                            opacity: _cubeFadeAnimation,
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              height: 120,
                              child: cube.Cube(
                                onSceneCreated: (cube.Scene scene) {
                                  final obj = cube.Object(
                                    fileName: 'assets/cube/jewelry-box-009.obj',
                                  );
                                  obj.scale.setValues(6.0, 6.0, 6.0);
                                  scene.world.add(obj);
                                  scene.camera.position.z = 1;
                                  _model = obj;
                                },
                              ),
                            ),
                          ),
                        ),
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
                                  _buildCard("Connection".tr(), "Connect".tr(),
                                      Icons.wifi, () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                WiFiScannerScreen()));
                                  }),
                                  _buildCard("Find Device".tr(), "Find".tr(),
                                      Icons.search, () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const FindingDeviceScreen()));
                                  }),
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
                        ElevatedButton(
                          onPressed: () {
                            context.setLocale(const Locale('gu', 'IN'));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonColor,
                            foregroundColor: AppColors.buttonText,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            'Switch to Gujarati',
                            style: AppFonts.buttonText
                                .copyWith(color: AppColors.buttonText),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            context.setLocale(const Locale('en', 'US'));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonColor,
                            foregroundColor: AppColors.buttonText,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            'Switch to English',
                            style: AppFonts.buttonText
                                .copyWith(color: AppColors.buttonText),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            context.setLocale(const Locale('hi', 'IN'));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonColor,
                            foregroundColor: AppColors.buttonText,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            'Switch to Hindi',
                            style: AppFonts.buttonText
                                .copyWith(color: AppColors.buttonText),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            context.setLocale(const Locale('mr', 'IN'));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonColor,
                            foregroundColor: AppColors.buttonText,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            'Switch to Marathi',
                            style: AppFonts.buttonText
                                .copyWith(color: AppColors.buttonText),
                          ),
                        ),
                        const SizedBox(height: 20),
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

  Widget _buildDeviceInfoCard(String deviceName, int battery, String status) {
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
              AppColors.cardBackground.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.textSecondary.withOpacity(0.2),
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
                style: AppFonts.subHeadline.copyWith(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.battery_full,
                      color: battery > 20 ? AppColors.buttonColor : Colors.red),
                  const SizedBox(width: 5),
                  Text(
                    "$battery%",
                    style: AppFonts.bodyText.copyWith(
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
                          : Colors.red),
                  const SizedBox(width: 5),
                  Text(
                    status,
                    style: AppFonts.bodyText.copyWith(
                      fontSize: 14,
                      color: status == "Connected"
                          ? AppColors.textPrimary
                          : Colors.red,
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
              AppColors.cardBackground.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.textSecondary.withOpacity(0.2),
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
                  style: AppFonts.subHeadline.copyWith(
                    fontSize: 16,
                    color: AppColors.textPrimary,
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
                    style: AppFonts.buttonText.copyWith(
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
              Colors.red.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.2),
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
              const Icon(Icons.report_problem, size: 50, color: Colors.red),
              const SizedBox(height: 10),
              Expanded(
                child: Text(
                  "Facing some issues with the box?".tr(),
                  textAlign: TextAlign.center,
                  style: AppFonts.subHeadline.copyWith(
                    fontSize: 16,
                    color: AppColors.textPrimary,
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
}
