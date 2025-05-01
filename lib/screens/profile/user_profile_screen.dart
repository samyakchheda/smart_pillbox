import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_emoji_feedback/flutter_emoji_feedback.dart';
import 'package:home/screens/profile/buzzer_screen.dart';
import 'package:home/screens/profile/contact_us_screen.dart';
import 'package:home/screens/profile/language_screen.dart';
import 'package:home/screens/profile/report_screen.dart';
import 'package:home/screens/profile/smart_diagnosis_screen.dart';
import 'package:home/screens/profile/two_factor_auth_screen.dart';
import 'package:home/theme/app_colors.dart';
import 'package:home/theme/app_fonts.dart';
import 'package:home/theme/theme_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:home/widgets/common/my_elevated_button.dart';
import 'package:home/widgets/common/my_text_field.dart';
import 'package:home/widgets/common/my_snack_bar.dart';
import '../authentication/password/change_password_screen.dart';
import 'edit_profile_screen.dart';
import 'saved_addresses_screen.dart';
import 'about_us_screen.dart';
import 'caretaker_screen.dart';
import 'settings_section.dart';
import 'package:http/http.dart' as http;

enum ProfileOption {
  main,
  editProfile,
  changePassword,
  twoFactorAuth,
  savedAddresses,
  notifications,
  darkMode,
  about,
  feedback,
  support,
  reset,
  buzzer,
  smartDiagnosis,
  connection,
  logout,
  addCareTaker,
  contactUs,
  reports,
  language
}

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String? _profilePictureUrl;
  String? _userName;
  String? _userEmail;
  bool _notificationsEnabled = false;
  ProfileOption _selectedOption = ProfileOption.main;
  bool _isProfileImageLoading = true;
  int? _selectedRating;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _checkNotificationPermission();
    ThemeProvider.themeNotifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    ThemeProvider.themeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _checkNotificationPermission() async {
    final status = await Permission.notification.status;
    setState(() {
      _notificationsEnabled = status.isGranted;
    });
  }

  Future<void> _fetchUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (docSnapshot.exists) {
          final profileUrl = docSnapshot.data()?['profile_picture'];
          print("Profile URL from Firestore: $profileUrl");

          String? validatedUrl;
          if (profileUrl != null && profileUrl.isNotEmpty) {
            try {
              final uri = Uri.parse(profileUrl);
              if (uri.isAbsolute) {
                validatedUrl = profileUrl;
              } else {
                print("Invalid URL format: $profileUrl");
              }
            } catch (e) {
              print("URL parsing error: $e");
            }
          }

          setState(() {
            _profilePictureUrl = validatedUrl;
            _userName = docSnapshot.data()?['name'] ?? 'User Name';
            _userEmail = user.email ?? 'email@example.com';
            _isProfileImageLoading = false;
          });
        } else {
          setState(() {
            _isProfileImageLoading = false;
          });
        }
      } else {
        setState(() {
          _isProfileImageLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching user profile: $e");
      setState(() {
        _isProfileImageLoading = false;
      });
    }
  }

  void _onOptionSelected(ProfileOption option) {
    setState(() {
      _selectedOption = option;
    });
  }

  void _showProfilePictureDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.buttonColor, width: 8),
                ),
                child: _profilePictureUrl != null
                    ? CachedNetworkImage(
                        imageUrl: _profilePictureUrl!,
                        imageBuilder: (context, imageProvider) => CircleAvatar(
                          radius: 120,
                          backgroundImage: imageProvider,
                        ),
                        placeholder: (context, url) => CircleAvatar(
                          radius: 120,
                          backgroundColor: AppColors.cardBackground,
                          child: CircularProgressIndicator(
                            color: AppColors.buttonColor,
                          ),
                        ),
                        errorWidget: (context, url, error) => CircleAvatar(
                          radius: 120,
                          backgroundColor: AppColors.cardBackground,
                          child: Icon(Icons.error,
                              size: 60, color: AppColors.buttonColor),
                        ),
                      )
                    : CircleAvatar(
                        radius: 120,
                        backgroundColor: AppColors.cardBackground,
                        child: Icon(Icons.person,
                            size: 120, color: AppColors.buttonColor),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAppearanceBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppColors.cardBackground,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Appearance'.tr(),
                style: AppFonts.headline.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.light_mode, color: AppColors.buttonColor),
                title: Text('Light Theme'.tr(),
                    style: AppFonts.bodyText
                        .copyWith(color: AppColors.textPrimary)),
                trailing: ThemeProvider.themeNotifier.value == ThemeMode.light
                    ? Icon(Icons.check, color: AppColors.buttonColor)
                    : null,
                onTap: () {
                  print("Switching to Light Theme");
                  ThemeProvider.setTheme(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.dark_mode, color: AppColors.buttonColor),
                title: Text('Dark Theme'.tr(),
                    style: AppFonts.bodyText
                        .copyWith(color: AppColors.textPrimary)),
                trailing: ThemeProvider.themeNotifier.value == ThemeMode.dark
                    ? Icon(Icons.check, color: AppColors.buttonColor)
                    : null,
                onTap: () {
                  print("Switching to Dark Theme");
                  ThemeProvider.setTheme(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.settings_system_daydream,
                    color: AppColors.buttonColor),
                title: Text('System Default'.tr(),
                    style: AppFonts.bodyText
                        .copyWith(color: AppColors.textPrimary)),
                trailing: ThemeProvider.themeNotifier.value == ThemeMode.system
                    ? Icon(Icons.check, color: AppColors.buttonColor)
                    : null,
                onTap: () {
                  print("Switching to System Default");
                  ThemeProvider.setTheme(ThemeMode.system);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleReset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: Text(
            'Reset Smart Pillbox'.tr(),
            style: AppFonts.headline.copyWith(color: AppColors.textPrimary),
          ),
          content: Text(
            'Are you sure you want to reset the Smart Pillbox? This action will clear all current settings and data on the device.'
                .tr(),
            style: AppFonts.bodyText.copyWith(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
              child: Text(
                'NO'.tr(),
                style: AppFonts.buttonText.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.buttonColor.withOpacity(0.1),
                foregroundColor: AppColors.buttonColor,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
              child: Text(
                'YES'.tr(),
                style: AppFonts.buttonText.copyWith(
                  color: AppColors.buttonColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        // Fetch the user's ESP32 IP from Firestore
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          mySnackBar(context, 'User not logged in'.tr(), isError: true);
          return;
        }

        final docSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (!docSnapshot.exists) {
          mySnackBar(context, 'User data not found'.tr(), isError: true);
          return;
        }

        final esp32Ip = "192.168.1.106";
        if (esp32Ip == null || esp32Ip.isEmpty) {
          mySnackBar(context, 'ESP32 IP not configured'.tr(), isError: true);
          return;
        }

        // Make the API call to reset the device
        final response = await http.post(
          Uri.parse('https://6617-183-87-183-2.ngrok-free.app/command/reset'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'esp32_ip': esp32Ip,
            'user': user.uid,
          }),
        );

        // Parse the API response
        final responseData = jsonDecode(response.body);
        if (response.statusCode == 200) {
          // Show success message from API
          mySnackBar(
              context,
              responseData['message']?.toString() ??
                  'Smart Pillbox reset successfully'.tr());
        } else {
          // Show error message from API
          mySnackBar(
            context,
            responseData['error']?.toString() ??
                'Failed to reset Smart Pillbox'.tr(),
            isError: true,
          );
        }
      } catch (e) {
        print("Error resetting Smart Pillbox: $e");
        mySnackBar(context, 'Error resetting Smart Pillbox: $e'.tr(),
            isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ThemeProvider.themeNotifier.value == ThemeMode.dark ||
        (ThemeProvider.themeNotifier.value == ThemeMode.system &&
            WidgetsBinding.instance.window.platformBrightness ==
                Brightness.dark);

    return WillPopScope(
      onWillPop: () async {
        if (_selectedOption != ProfileOption.main) {
          setState(() {
            _selectedOption = ProfileOption.main;
          });
          return false; // Don't pop the screen
        } else {
          return true; // Allow the app to close or go back
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Column(
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
                              Colors.grey.shade400,
                            ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Profile Settings'.tr(),
                        style: AppFonts.headline.copyWith(
                          color: isDarkMode ? Colors.white : Colors.black87,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned.fill(
              top: 165,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                child: Container(
                  color: AppColors.background,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      children: [
                        if (_selectedOption == ProfileOption.main)
                          _buildProfileCard(),
                        _buildContent(),
                        const SizedBox(height: 90),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Padding(
      padding: const EdgeInsets.only(top: 80, left: 16, right: 16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Card(
            color: AppColors.cardBackground,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    _userName ?? "Unknown",
                    style: AppFonts.headline
                        .copyWith(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userEmail ?? "example.com",
                    style: AppFonts.caption
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -60,
            left: 0,
            right: 0,
            child: Center(
              child: InkWell(
                onTap: _showProfilePictureDialog,
                borderRadius: BorderRadius.circular(120),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.buttonColor, width: 4),
                  ),
                  child: _isProfileImageLoading
                      ? CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.cardBackground,
                          child: CircularProgressIndicator(
                            color: AppColors.buttonColor,
                          ),
                        )
                      : (_profilePictureUrl != null
                          ? CachedNetworkImage(
                              imageUrl: _profilePictureUrl!,
                              imageBuilder: (context, imageProvider) =>
                                  CircleAvatar(
                                radius: 50,
                                backgroundImage: imageProvider,
                              ),
                              placeholder: (context, url) => CircleAvatar(
                                radius: 50,
                                backgroundColor: AppColors.cardBackground,
                                child: CircularProgressIndicator(
                                  color: AppColors.buttonColor,
                                ),
                              ),
                              errorWidget: (context, url, error) {
                                print("Error loading image: $error");
                                return CircleAvatar(
                                  radius: 50,
                                  backgroundColor: AppColors.cardBackground,
                                  child: Icon(Icons.person,
                                      size: 50, color: AppColors.buttonColor),
                                );
                              },
                            )
                          : CircleAvatar(
                              radius: 50,
                              backgroundColor: AppColors.cardBackground,
                              child: Icon(Icons.person,
                                  size: 50, color: AppColors.buttonColor),
                            )),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedOption) {
      case ProfileOption.editProfile:
        return EditProfileScreen(
            onBack: () => _onOptionSelected(ProfileOption.main));
      case ProfileOption.changePassword:
        return ChangePasswordScreen(
            onBack: () => _onOptionSelected(ProfileOption.main));
      case ProfileOption.twoFactorAuth:
        return TwoFactorAuthScreen(
            onBack: () => _onOptionSelected(ProfileOption.main));
      case ProfileOption.savedAddresses:
        return SavedAddressesScreen(
            onBack: () => _onOptionSelected(ProfileOption.main));
      case ProfileOption.about:
        return AboutUsScreen(
            onBack: () => _onOptionSelected(ProfileOption.main));
      case ProfileOption.contactUs:
        return ContactUsScreen(
            onBack: () => _onOptionSelected(ProfileOption.main));
      case ProfileOption.buzzer:
        return BuzzerScreen(
          onBack: () => _onOptionSelected(ProfileOption.main),
        );
      case ProfileOption.smartDiagnosis:
        Future.microtask(() {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                body: SmartDiagnosisInfoScreen(
                  onBack: () => Navigator.pop(context),
                ),
              ),
            ),
          ).then((_) => _onOptionSelected(ProfileOption.main));
        });
        return Center(
            child: CircularProgressIndicator(color: AppColors.buttonColor));
      case ProfileOption.addCareTaker:
        return CaretakerScreen(
            onBack: () => _onOptionSelected(ProfileOption.main));
      case ProfileOption.feedback:
        return _feedback(
          onSubmit: (rating, feedback) async {
            print("User Rating: $rating");
            print("User Feedback: $feedback");
          },
        );
      case ProfileOption.reports:
        return ReportScreen(
            onBack: () => _onOptionSelected(ProfileOption.main));
      case ProfileOption.language:
        return LanguageScreen(
            onBack: () => _onOptionSelected(ProfileOption.main));
      default:
        return Column(
          children: [
            SettingsSection(
              title: "General".tr(),
              items: [
                _buildListTile(Icons.person, "Edit Profile".tr(),
                    onTap: () => _onOptionSelected(ProfileOption.editProfile)),
                _buildListTile(Icons.lock, "Change Password".tr(),
                    onTap: () =>
                        _onOptionSelected(ProfileOption.changePassword)),
                _buildListTile(Icons.security, "2-Factor Authentication".tr(),
                    onTap: () =>
                        _onOptionSelected(ProfileOption.twoFactorAuth)),
                _buildListTile(Icons.location_on, "Saved Addresses".tr(),
                    onTap: () =>
                        _onOptionSelected(ProfileOption.savedAddresses)),
                _buildListTile(Icons.person_add, "Caretaker/Family Member".tr(),
                    onTap: () => _onOptionSelected(ProfileOption.addCareTaker)),
                _buildListTile(Icons.receipt_long_sharp, "Reports".tr(),
                    onTap: () => _onOptionSelected(ProfileOption.reports)),
              ],
              sectionBackground: AppColors.sectionHeaderBackground,
              sectionText: AppColors.sectionHeaderText,
              itemBackground: AppColors.listItemBackground,
              itemText: AppColors.listItemText,
              itemIcon: AppColors.buttonColor,
            ),
            SettingsSection(
              title: "Preferences".tr(),
              items: [
                _buildListTile(Icons.notifications, "Notification Page".tr(),
                    trailing: Switch(
                      value: _notificationsEnabled,
                      activeColor: AppColors.buttonColor,
                      inactiveTrackColor: AppColors.buttonColor,
                      onChanged: (bool value) async {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                        await AppSettings.openAppSettings(
                            type: AppSettingsType.notification);
                      },
                    )),
                _buildListTile(Icons.brightness_6, "Appearance".tr(),
                    onTap: _showAppearanceBottomSheet),
                _buildListTile(Icons.language, "Language".tr(),
                    onTap: () => _onOptionSelected(ProfileOption.language)),
              ],
              sectionBackground: AppColors.sectionHeaderBackground,
              sectionText: AppColors.sectionHeaderText,
              itemBackground: AppColors.listItemBackground,
              itemText: AppColors.listItemText,
              itemIcon: AppColors.buttonColor,
            ),
            SettingsSection(
              title: "Smart Pillbox".tr(),
              items: [
                _buildListTile(Icons.restart_alt, "Reset".tr(),
                    onTap: _handleReset),
                _buildListTile(Icons.volume_up, "Buzzer".tr(),
                    onTap: () => _onOptionSelected(ProfileOption.buzzer)),
                _buildListTile(Icons.person, "Smart Diagnosis".tr(),
                    onTap: () =>
                        _onOptionSelected(ProfileOption.smartDiagnosis)),
              ],
              sectionBackground: AppColors.sectionHeaderBackground,
              sectionText: AppColors.sectionHeaderText,
              itemBackground: AppColors.listItemBackground,
              itemText: AppColors.listItemText,
              itemIcon: AppColors.buttonColor,
            ),
            SettingsSection(
              title: "More".tr(),
              items: [
                _buildListTile(Icons.info, "About".tr(),
                    onTap: () => _onOptionSelected(ProfileOption.about)),
                _buildListTile(Icons.feedback, "Send Feedback".tr(),
                    onTap: () => _onOptionSelected(ProfileOption.feedback)),
                _buildListTile(Icons.support_agent, "Contact Us".tr(),
                    onTap: () => _onOptionSelected(ProfileOption.contactUs)),
                _buildListTile(Icons.logout, "Log Out".tr(),
                    onTap: _handleLogout, trailing: null),
              ],
              sectionBackground: AppColors.sectionHeaderBackground,
              sectionText: AppColors.sectionHeaderText,
              itemBackground: AppColors.listItemBackground,
              itemText: AppColors.listItemText,
              itemIcon: AppColors.buttonColor,
            ),
          ],
        );
    }
  }

  Widget _buildListTile(IconData icon, String title,
      {VoidCallback? onTap, Widget? trailing}) {
    return Container(
      color: AppColors.listItemBackground,
      child: ListTile(
        leading: Icon(icon, color: AppColors.buttonColor),
        title: Text(
          title,
          style: AppFonts.bodyText.copyWith(color: AppColors.listItemText),
        ),
        trailing: trailing ??
            Icon(Icons.arrow_forward_ios,
                size: 16, color: AppColors.buttonColor),
        onTap: onTap,
      ),
    );
  }

  Widget _feedback({required Function(int rating, String feedback) onSubmit}) {
    final TextEditingController feedbackController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new,
                    color: AppColors.buttonColor),
                onPressed: () =>
                    setState(() => _selectedOption = ProfileOption.main),
              ),
              Expanded(
                child: Text(
                  "Feedback".tr(),
                  textAlign: TextAlign.center,
                  style:
                      AppFonts.headline.copyWith(color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              "How was your experience?".tr(),
              style:
                  AppFonts.subHeadline.copyWith(color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: EmojiFeedback(
              animDuration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              inactiveElementScale: .7,
              elementSize: 50,
              onChanged: (value) {
                setState(() {
                  _selectedRating = value != null ? value + 1 : null;
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          MyTextField(
            controller: feedbackController,
            hintText: "Tell us more about your experience...".tr(),
            maxLines: 3,
            borderRadius: 12,
            fillColor: AppColors.cardBackground,
            hintStyle: AppFonts.bodyText
                .copyWith(color: AppColors.textSecondary.withOpacity(0.6)),
            textStyle: AppFonts.bodyText.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 20),
          Center(
            child: MyElevatedButton(
              text: "Submit Feedback".tr(),
              onPressed: () {
                if (_selectedRating != null) {
                  onSubmit(_selectedRating!, feedbackController.text);
                  mySnackBar(context, 'Feedback submitted successfully');
                  _onOptionSelected(ProfileOption.main);
                } else {
                  mySnackBar(context, 'Please select a rating'.tr(),
                      isError: true);
                }
              },
              icon: Icon(Icons.send, color: AppColors.buttonColor),
              backgroundColor: AppColors.buttonColor,
              textColor: AppColors.buttonText,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
              borderRadius: 50,
              height: 60,
              textStyle: AppFonts.buttonText.copyWith(fontSize: 16),
              iconSpacing: 12.0,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: Text('Log Out'.tr(),
              style: AppFonts.headline.copyWith(color: AppColors.textPrimary)),
          content: Text('Are you sure you want to log out?'.tr(),
              style:
                  AppFonts.bodyText.copyWith(color: AppColors.textSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
              child: Text(
                'CANCEL'.tr(),
                style: AppFonts.buttonText.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.buttonColor.withOpacity(0.1),
                foregroundColor: AppColors.buttonColor,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
              child: Text(
                'LOG OUT'.tr(),
                style: AppFonts.buttonText.copyWith(
                  color: AppColors.buttonColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }
}
