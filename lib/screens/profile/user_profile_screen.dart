import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_emoji_feedback/flutter_emoji_feedback.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home/screens/profile/buzzer_screen.dart';
import 'package:home/screens/profile/contact_us_screen.dart';
import 'package:home/screens/profile/report_screen.dart';
import 'package:home/screens/profile/smart_diagnosis_screen.dart';
import 'package:home/screens/profile/two_factor_auth_screen.dart';
import 'package:home/theme/app_colors.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../authentication/password/change_password_screen.dart';
import 'edit_profile_screen.dart';
import 'saved_addresses_screen.dart';
import 'about_us_screen.dart';
import 'caretaker_screen.dart';
import 'settings_section.dart';

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
  reports
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
  }

  Future<void> _checkNotificationPermission() async {
    final status = await Permission.notification.status;
    setState(() {
      _notificationsEnabled = status.isGranted;
    });
  }

  void _fetchUserProfile() async {
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
                  border: Border.all(color: Colors.blue, width: 8),
                ),
                child: _profilePictureUrl != null
                    ? CachedNetworkImage(
                        imageUrl: _profilePictureUrl!,
                        imageBuilder: (context, imageProvider) => CircleAvatar(
                          radius: 120,
                          backgroundImage: imageProvider,
                        ),
                        placeholder: (context, url) => const CircleAvatar(
                          radius: 120,
                          backgroundColor: AppColors.darkBackground,
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) =>
                            const CircleAvatar(
                          radius: 120,
                          backgroundColor: AppColors.darkBackground,
                          child:
                              Icon(Icons.error, size: 60, color: Colors.white),
                        ),
                      )
                    : const CircleAvatar(
                        radius: 120,
                        backgroundColor: AppColors.darkBackground,
                        child:
                            Icon(Icons.person, size: 120, color: Colors.white),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 250,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.buttonColor, Colors.grey.shade400],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Profile Settings',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
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
                color: const Color(0xFFE0E0E0),
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
    );
  }

  Widget _buildProfileCard() {
    return Padding(
      padding: const EdgeInsets.only(top: 80, left: 16, right: 16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Card(
            color: Colors.white,
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
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userEmail ?? "example.com",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppColors.textPlaceholder,
                    ),
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
                      ? const CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.darkBackground,
                          child: CircularProgressIndicator(),
                        )
                      : (_profilePictureUrl != null
                          ? CachedNetworkImage(
                              imageUrl: _profilePictureUrl!,
                              imageBuilder: (context, imageProvider) =>
                                  CircleAvatar(
                                radius: 50,
                                backgroundImage: imageProvider,
                              ),
                              placeholder: (context, url) => const CircleAvatar(
                                radius: 50,
                                backgroundColor: AppColors.darkBackground,
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) {
                                print("Error loading image: $error");
                                return const CircleAvatar(
                                  radius: 50,
                                  backgroundColor: AppColors.darkBackground,
                                  child: Icon(Icons.person,
                                      size: 50, color: Colors.white),
                                );
                              },
                            )
                          : const CircleAvatar(
                              radius: 50,
                              backgroundColor: AppColors.darkBackground,
                              child: Icon(Icons.person,
                                  size: 50, color: Colors.white),
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
        // Navigate to a standalone SmartDiagnosis screen instead of embedding it
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
        // Return a placeholder while navigation happens
        return const Center(child: CircularProgressIndicator());
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
      default:
        return Column(
          children: [
            SettingsSection(
              title: "General",
              items: [
                _buildListTile(Icons.person, "Edit Profile",
                    onTap: () => _onOptionSelected(ProfileOption.editProfile)),
                _buildListTile(Icons.lock, "Change Password",
                    onTap: () =>
                        _onOptionSelected(ProfileOption.changePassword)),
                _buildListTile(Icons.security,
                    "2-Factor Authentication", // Add this new ListTile
                    onTap: () =>
                        _onOptionSelected(ProfileOption.twoFactorAuth)),
                _buildListTile(Icons.location_on, "Saved Addresses",
                    onTap: () =>
                        _onOptionSelected(ProfileOption.savedAddresses)),
                _buildListTile(Icons.person_add, "Caretaker/Family Member",
                    onTap: () => _onOptionSelected(ProfileOption.addCareTaker)),
                _buildListTile(Icons.receipt_long_sharp, "Reports",
                    onTap: () => _onOptionSelected(ProfileOption.reports)),
              ],
            ),
            SettingsSection(
              title: "Preferences",
              items: [
                _buildListTile(Icons.notifications, "Notification Page",
                    trailing: Switch(
                      value: _notificationsEnabled,
                      activeColor: AppColors.buttonColor,
                      onChanged: (bool value) async {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                        AppSettings.openAppSettings(
                            type: AppSettingsType.notification);
                      },
                    )),
                _buildListTile(Icons.brightness_6, "Dark Mode / Light Mode",
                    onTap: () {}),
              ],
            ),
            SettingsSection(
              title: "Smart Pillbox",
              items: [
                _buildListTile(Icons.restart_alt, "Reset", onTap: () {}),
                _buildListTile(Icons.volume_up, "Buzzer",
                    onTap: () => _onOptionSelected(ProfileOption.buzzer)),
                _buildListTile(Icons.person, "Smart Diagnosis",
                    onTap: () =>
                        _onOptionSelected(ProfileOption.smartDiagnosis)),
              ],
            ),
            SettingsSection(
              title: "More",
              items: [
                _buildListTile(Icons.info, "About",
                    onTap: () => _onOptionSelected(ProfileOption.about)),
                _buildListTile(Icons.feedback, "Send Feedback",
                    onTap: () => _onOptionSelected(ProfileOption.feedback)),
                _buildListTile(Icons.support_agent, "Contact Us",
                    onTap: () => _onOptionSelected(ProfileOption.contactUs)),
                _buildListTile(Icons.logout, "Log Out",
                    onTap: _handleLogout, trailing: null),
              ],
            ),
          ],
        );
    }
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
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () =>
                    setState(() => _selectedOption = ProfileOption.main),
              ),
              Expanded(
                child: Text(
                  "Feedback",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              "How was your experience?",
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold),
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
          TextField(
            controller: feedbackController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Tell us more about your experience...",
              hintStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade200,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                if (_selectedRating != null) {
                  // Submit the feedback
                  onSubmit(_selectedRating!, feedbackController.text);
                  // Show confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Feedback submitted successfully'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  // Navigate back to main profile screen
                  _onOptionSelected(ProfileOption.main);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a rating')),
                  );
                }
              },
              icon: const Icon(Icons.send, color: Colors.white),
              label: Text(
                "Submit Feedback",
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
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
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('LOG OUT'),
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

  Widget _buildListTile(IconData icon, String title,
      {VoidCallback? onTap, Widget? trailing}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.buttonColor),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14)),
      trailing: trailing ??
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}
