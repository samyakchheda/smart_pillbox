import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home/presentation/authentication/password/change_password_screen.dart';
import 'package:home/presentation/profile/feedback_screen.dart';
import 'package:home/presentation/profile/report_screen.dart';
import 'package:home/theme/app_colors.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'edit_profile_screen.dart';
import 'saved_addresses_screen.dart';
import 'about_us_screen.dart';
import 'caretaker_screen.dart';
import 'settings_screen.dart';

enum ProfileOption {
  main,
  editProfile,
  changePassword,
  changeEmail,
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
  deleteAcc,
  addCareTaker,
  reports,
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
  bool _profileImageError = false;

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

          // Validate URL format
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
      case ProfileOption.changeEmail:
      // return ChangeEmailScreen(
      //     onBack: () => _onOptionSelected(ProfileOption.main));
      case ProfileOption.savedAddresses:
        return SavedAddressesScreen(
            onBack: () => _onOptionSelected(ProfileOption.main));
      case ProfileOption.about:
        return AboutUsScreen(
            onBack: () => _onOptionSelected(ProfileOption.main));
      case ProfileOption.addCareTaker:
        return CaretakerScreen(
            onBack: () => _onOptionSelected(ProfileOption.main));
      case ProfileOption.feedback:
        return FeedbackScreen(
            onBack: () => _onOptionSelected(ProfileOption.main));
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
                _buildListTile(Icons.email, "Change Email",
                    onTap: () => _onOptionSelected(ProfileOption.changeEmail)),
                _buildListTile(Icons.location_on, "Saved Addresses",
                    onTap: () =>
                        _onOptionSelected(ProfileOption.savedAddresses)),
                _buildListTile(Icons.person_add, "Caretaker/Family Member",
                    onTap: () => _onOptionSelected(ProfileOption.addCareTaker)),
                _buildListTile(Icons.receipt_long_outlined, "Reports",
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
                _buildListTile(Icons.volume_up, "Buzzer", onTap: () {}),
                _buildListTile(Icons.person, "Smart Diagnosis", onTap: () {}),
              ],
            ),
            SettingsSection(
              title: "More",
              items: [
                _buildListTile(Icons.info, "About",
                    onTap: () => _onOptionSelected(ProfileOption.about)),
                _buildListTile(Icons.feedback, "Send Feedback",
                    onTap: () => _onOptionSelected(ProfileOption.feedback)),
                _buildListTile(Icons.support_agent, "Customer Support",
                    onTap: () {}),
                _buildListTile(Icons.logout, "Log Out", onTap: _handleLogout),
                _buildListTile(Icons.delete, "Delete Account",
                    onTap: _handleDeleteAccount),
              ],
            ),
          ],
        );
    }
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

  Future<void> _handleDeleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
              'Are you sure you want to permanently delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('DELETE', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // Show re-authentication dialog immediately
      final credentials = await _showReauthenticateDialog();
      if (credentials == null) return; // User canceled re-authentication

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Reauthenticate the user
          await user.reauthenticateWithCredential(credentials);

          // Delete user data from Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .delete();

          // Delete user account from Firebase Auth
          await user.delete();

          Navigator.of(context)
              .pushNamedAndRemoveUntil('/login', (route) => false);
        }
      } catch (e) {
        print("Error deleting account: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete account: ${e.toString()}')),
        );
      }
    }
  }

  Future<AuthCredential?> _showReauthenticateDialog() async {
    final TextEditingController passwordController = TextEditingController();

    final result = await showDialog<AuthCredential?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Re-authenticate'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Please enter your password to confirm account deletion.'),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                autofillHints: const [AutofillHints.password],
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null && user.email != null) {
                  final credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: passwordController.text,
                  );
                  Navigator.of(context).pop(credential);
                }
              },
              child: const Text('CONFIRM'),
            ),
          ],
        );
      },
    );

    return result;
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
