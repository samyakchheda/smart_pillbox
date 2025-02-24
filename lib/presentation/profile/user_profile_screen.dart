import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home/presentation/authentication/password/change_password_screen.dart';
import 'package:home/theme/app_colors.dart';
import 'package:permission_handler/permission_handler.dart';
import 'edit_profile_screen.dart';
import 'dart:convert';
import 'package:app_settings/app_settings.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String? _profilePictureBase64;
  String? _userName;
  String? _userEmail;
  bool _notificationsEnabled = false;
  bool _isProfilePictureTapped = false;

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
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (docSnapshot.exists) {
        setState(() {
          _profilePictureBase64 = docSnapshot.data()?['profilePicture'];
          _userName = docSnapshot.data()?['name'] ?? 'User Name';
          _userEmail = user.email ?? 'email@example.com';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section with Custom Paint
            SizedBox(
              height: MediaQuery.of(context)
                  .size
                  .height, // Define a fixed height for the header section
              child: Stack(
                children: [
                  // Custom Paint for the Header
                  CustomPaint(
                    size: Size(MediaQuery.of(context).size.width, 300),
                    painter: HeaderPainter(),
                  ),

                  // Title Text Positioned in the Header
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 80),
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

                  // White Background Container with Rounded Corners
                  Positioned(
                    top: 150, // Adjust this value to control overlap
                    left: 0,
                    right: 0,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32), // Rounded top corners
                        topRight: Radius.circular(32),
                      ),
                      child: Container(
                        color: Color(0xFFE0E0E0), // White background
                        child: Column(
                          children: [
                            // Profile Card
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0, right: 16.0, top: 80),
                              child: Center(
                                child: Stack(
                                  clipBehavior:
                                      Clip.none, // Allows avatar to overflow
                                  children: [
                                    // User Info Card
                                    Card(
                                      color: Colors.white,
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0, vertical: 12),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const SizedBox(
                                                height:
                                                    40), // Space for avatar overlap
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
                                                color:
                                                    AppColors.textPlaceholder,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Profile Picture Overlapping
                                    Positioned(
                                      top:
                                          -60, // Move half of the avatar out of the card
                                      left: 0,
                                      right: 0,
                                      child: Center(
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              _isProfilePictureTapped =
                                                  !_isProfilePictureTapped;
                                            });
                                          },
                                          borderRadius:
                                              BorderRadius.circular(120),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeInOut,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: AppColors.buttonColor,
                                                width: _isProfilePictureTapped
                                                    ? 10
                                                    : 4,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors.buttonColor
                                                      .withOpacity(0.3),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: CircleAvatar(
                                              radius: 50,
                                              backgroundColor:
                                                  AppColors.darkBackground,
                                              backgroundImage:
                                                  _profilePictureBase64 != null
                                                      ? MemoryImage(base64Decode(
                                                          _profilePictureBase64!))
                                                      : const AssetImage(
                                                              'assets/icons/ic_default_avatar.jpg')
                                                          as ImageProvider,
                                              child:
                                                  _profilePictureBase64 == null
                                                      ? const Icon(Icons.person,
                                                          size: 50,
                                                          color: AppColors
                                                              .cardBackground)
                                                      : null,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // General Section
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Card(
                                color: Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 12),
                                      child: Text(
                                        'General',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                    ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                      leading: const Icon(Icons.edit,
                                          color: AppColors.buttonColor),
                                      title: Text(
                                        'Edit Profile',
                                        style:
                                            GoogleFonts.poppins(fontSize: 14),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const EditProfileScreen(),
                                          ),
                                        );
                                      },
                                      trailing: const Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16),
                                    ),
                                    const Divider(
                                      height: 1,
                                      thickness: 0.5,
                                      color: AppColors.darkBackground,
                                    ),
                                    ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                      leading: const Icon(Icons.lock,
                                          color: AppColors.buttonColor),
                                      title: Text(
                                        'Change Password',
                                        style:
                                            GoogleFonts.poppins(fontSize: 14),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ChangePasswordScreen(),
                                          ),
                                        );
                                      },
                                      trailing: const Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Preferences Section
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Card(
                                color: Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 12),
                                      child: Text(
                                        'Preferences',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                    ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                      leading: const Icon(Icons.notifications,
                                          color: AppColors.buttonColor),
                                      title: Text(
                                        'Manage Notifications',
                                        style:
                                            GoogleFonts.poppins(fontSize: 14),
                                      ),
                                      trailing: Switch(
                                        value: _notificationsEnabled,
                                        activeColor: AppColors.buttonColor,
                                        onChanged: (bool value) async {
                                          setState(() {
                                            _notificationsEnabled = value;
                                          });

                                          // Open notification settings
                                          AppSettings.openAppSettings(
                                              type:
                                                  AppSettingsType.notification);
                                        },
                                      ),
                                    ),
                                    const Divider(
                                      height: 1,
                                      thickness: 0.5,
                                      color: AppColors.darkBackground,
                                    ),
                                    ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                      leading: const Icon(Icons.logout,
                                          color: Colors.red),
                                      title: Text(
                                        'Logout',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.red,
                                        ),
                                      ),
                                      onTap: () async {
                                        await FirebaseAuth.instance.signOut();
                                        Navigator.of(context)
                                            .pushReplacementNamed('/');
                                      },
                                    ),
                                  ],
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
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Painter for Header
class HeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.grey.shade400 // Background color of the header
      ..style = PaintingStyle.fill;

    // Define the rounded rectangle path
    final Rect rect =
        Rect.fromLTRB(0, 0, size.width, size.height * 0.7); // Adjust height
    const double borderRadius = 40; // Rounded corner radius

    final RRect roundedRect = RRect.fromRectAndCorners(
      rect,
    );

    // Draw the rounded rectangle
    canvas.drawRRect(roundedRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // No need to repaint unless data changes
  }
}
