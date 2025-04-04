import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_emoji_feedback/flutter_emoji_feedback.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home/screens/profile/about_us_screen.dart';
import 'package:home/screens/profile/contact_us_screen.dart';
import 'package:home/screens/profile/settings_section.dart';
import 'package:home/theme/app_colors.dart';
import 'package:permission_handler/permission_handler.dart';

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
  bool _notificationsEnabled = false;
  ProfileOption _selectedOption = ProfileOption.main;
  int? _selectedRating;
  String? _caretakerName;
  String? _caretakerEmail;

  @override
  void initState() {
    super.initState();
    _fetchCaretakerInfo();
    _checkNotificationPermission();
  }

  Future<void> _checkNotificationPermission() async {
    final status = await Permission.notification.status;
    setState(() {
      _notificationsEnabled = status.isGranted;
    });
  }

  void _fetchCaretakerInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final String userEmail = user.email ?? '';

        if (userEmail.isNotEmpty) {
          // Query caretakers where patient matches the current user's email
          final caretakerQuery =
              await FirebaseFirestore.instance.collection('caretakers').get();

          if (caretakerQuery.docs.isNotEmpty) {
            final caretakerData = caretakerQuery.docs.first.data();
            final caretakerName = caretakerData['name'] ?? 'Unknown Caretaker';
            final caretakerEmail = caretakerData['email'] ?? 'No Email';

            print("Caretaker Name: $caretakerName");
            print("Caretaker Email: $caretakerEmail");

            setState(() {
              _caretakerName = caretakerName;
              _caretakerEmail = caretakerEmail;
            });
          } else {
            print("No caretaker found for this user.");
          }
        }
      }
    } catch (e) {
      print("Error fetching caretaker info: $e");
    }
  }

  void _onOptionSelected(ProfileOption option) {
    setState(() {
      _selectedOption = option;
    });
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
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              child: Container(
                color: const Color(0xFFE0E0E0),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'CareTaker',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      if (_selectedOption == ProfileOption.main)
                        _buildProfileCard(),
                      _buildContent(),
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
      padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
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
                  Text(
                    _caretakerName ?? "Unknown",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _caretakerEmail ?? "example.com",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppColors.textPlaceholder,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedOption) {
      case ProfileOption.about:
        return AboutUsScreen(
            onBack: () => _onOptionSelected(ProfileOption.main));
      case ProfileOption.contactUs:
        return ContactUsScreen(
            onBack: () => _onOptionSelected(ProfileOption.main));

      case ProfileOption.feedback:
        return _feedback(
          onSubmit: (rating, feedback) async {
            print("User Rating: $rating");
            print("User Feedback: $feedback");
          },
        );

      default:
        return Column(
          children: [
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
