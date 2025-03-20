import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home/theme/app_colors.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'dart:convert';

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
  addCareTaker
}

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
  ProfileOption _selectedOption = ProfileOption.main;

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

  void _onOptionSelected(ProfileOption option) {
    setState(() {
      _selectedOption = option;
    });
  }

  void _showProfilePictureDialog() {
    showDialog(
      context: context,
      barrierDismissible: true, // Close on tap outside
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent, // Transparent background
          insetPadding: EdgeInsets.zero, // Full-screen modal
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Profile picture with blue ring
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.blue, // Blue ring
                    width: 8,
                  ),
                ),
                child: CircleAvatar(
                  radius: 120,
                  backgroundColor: AppColors.darkBackground,
                  backgroundImage: _profilePictureBase64 != null
                      ? MemoryImage(base64Decode(_profilePictureBase64!))
                      : const AssetImage('assets/icons/ic_default_avatar.jpg')
                          as ImageProvider,
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
          // Header Background Using Container
          Column(
            children: [
              // Gradient Background for Header
              Container(
                height: 250, // Fixed height for the header
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.buttonColor, // Replace with your desired colors
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

          // Overlapping White Background Container
          Positioned.fill(
            top: 165, // Adjust this value to control overlap
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              child: Container(
                width: double.infinity,
                color: const Color(0xFFE0E0E0), // White background color
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                      top: 10), // Adjust for profile picture
                  child: Column(
                    children: [
                      if (_selectedOption == ProfileOption.main)
                        _buildProfileCard(),
                      _buildContent(),
                      const SizedBox(
                        height: 90,
                      )
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
          // User Info Card
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
                  const SizedBox(height: 40), // Space for avatar overlap
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

          // Profile Picture Overlapping
          Positioned(
            top: -60,
            left: 0,
            right: 0,
            child: Center(
              child: InkWell(
                onTap: () => _showProfilePictureDialog(),
                borderRadius: BorderRadius.circular(120),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.buttonColor,
                      width: _isProfilePictureTapped ? 10 : 4,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.darkBackground,
                    backgroundImage: _profilePictureBase64 != null
                        ? MemoryImage(base64Decode(_profilePictureBase64!))
                        : const AssetImage('assets/icons/ic_default_avatar.jpg')
                            as ImageProvider,
                  ),
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
        return _buildEditProfile();
      case ProfileOption.changePassword:
        return _buildChangePassword();
      case ProfileOption.changeEmail:
        return _buildChangeEmail();
      case ProfileOption.savedAddresses:
        return _buildSavedAddresses();
      case ProfileOption.notifications:
        return _buildPage("Notification Settings");
      case ProfileOption.darkMode:
        return _buildPage("Dark Mode / Light Mode");
      case ProfileOption.about:
        return _aboutUs();
      case ProfileOption.feedback:
        return _buildPage("Send Feedback");
      case ProfileOption.support:
        return _buildPage("Customer Support");
      case ProfileOption.logout:
        return _buildPage("Logout of the account");
      case ProfileOption.deleteAcc:
        return _buildPage("Account deleted");
      case ProfileOption.addCareTaker:
        return _caretaker();
      default:
        return Column(
          children: [
            _buildGeneralSettings(),
            _buildPreferences(),
            _buildSmartPillboxSettings(),
            _buildMoreSettings(),
          ],
        );
    }
  }

  // General Settings Section
  Widget _buildGeneralSettings() {
    return _buildSettingsCard("General", [
      _buildListTile(Icons.person, "Edit Profile",
          onTap: () => _onOptionSelected(ProfileOption.editProfile)),
      _buildListTile(Icons.lock, "Change Password",
          onTap: () => _onOptionSelected(ProfileOption.changePassword)),
      _buildListTile(Icons.email, "Change Email",
          onTap: () => _onOptionSelected(ProfileOption.changeEmail)),
      _buildListTile(Icons.location_on, "Saved Addresses",
          onTap: () => _onOptionSelected(ProfileOption.savedAddresses)),
      _buildListTile(Icons.person_add, "Caretaker/Family Member",
          onTap: () => _onOptionSelected(ProfileOption.addCareTaker)),
    ]);
  }

  // Preferences Section
  Widget _buildPreferences() {
    return _buildSettingsCard("Preferences", [
      _buildListTile(Icons.notifications, "Notification Page",
          trailing: Switch(
            value: _notificationsEnabled,
            activeColor: AppColors.buttonColor,
            onChanged: (bool value) async {
              setState(() {
                _notificationsEnabled = value;
              });
              AppSettings.openAppSettings(type: AppSettingsType.notification);
            },
          )),
      _buildListTile(Icons.brightness_6, "Dark Mode / Light Mode",
          onTap: () {}),
    ]);
  }

  // More Section
  Widget _buildMoreSettings() {
    return _buildSettingsCard("More", [
      _buildListTile(Icons.info, "About",
          onTap: () => _onOptionSelected(ProfileOption.about)),
      _buildListTile(Icons.feedback, "Send Feedback",
          onTap: () => _onOptionSelected(ProfileOption.feedback)),
      _buildListTile(Icons.support_agent, "Customer Support",
          onTap: () => _onOptionSelected(ProfileOption.support)),
      _buildListTile(Icons.logout, "Log Out",
          onTap: () => _onOptionSelected(ProfileOption.logout)),
      _buildListTile(Icons.delete, "Delete Account",
          onTap: () => _onOptionSelected(ProfileOption.deleteAcc)),
    ]);
  }

  // Smart Pillbox Section
  Widget _buildSmartPillboxSettings() {
    return _buildSettingsCard("Smart Pillbox", [
      _buildListTile(Icons.restart_alt, "Reset", onTap: () {}),
      _buildListTile(Icons.volume_up, "Buzzer", onTap: () {}),
      _buildListTile(FontAwesomeIcons.personDotsFromLine, "Smart Diagnosis",
          onTap: () {}),
    ]);
  }

  // Settings Card Wrapper
  Widget _buildSettingsCard(String title, List<Widget> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Text(
                title,
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildPage(String title) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => setState(() => _selectedOption = ProfileOption.main),
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            title,
            style: GoogleFonts.poppins(fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  // ListTile for each setting item
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

  Widget _buildEditProfile() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () =>
                    setState(() => _selectedOption = ProfileOption.main),
              ),
              Text("Edit Profile",
                  style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 20),

          // Profile Picture
          Center(
            child: InkWell(
              onTap: _showProfilePictureDialog,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.darkBackground,
                backgroundImage: _profilePictureBase64 != null
                    ? MemoryImage(base64Decode(_profilePictureBase64!))
                    : AssetImage('assets/icons/ic_default_avatar.jpg')
                        as ImageProvider,
              ),
            ),
          ),
          SizedBox(height: 20),

          // Name Field
          TextField(
            decoration: InputDecoration(
                labelText: "Name", border: OutlineInputBorder()),
          ),
          SizedBox(height: 15),

          // Contact Number Field
          TextField(
            decoration: InputDecoration(
                labelText: "Contact Number", border: OutlineInputBorder()),
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 30),

          // Save Button
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor),
              onPressed: () =>
                  setState(() => _selectedOption = ProfileOption.main),
              child: Text("Save",
                  style:
                      GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangePassword() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () =>
                    setState(() => _selectedOption = ProfileOption.main),
              ),
              Text("Change Password",
                  style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 20),

          // Old Password
          TextField(
            decoration: InputDecoration(
                labelText: "Old Password", border: OutlineInputBorder()),
            obscureText: true,
          ),
          SizedBox(height: 15),

          // New Password
          TextField(
            decoration: InputDecoration(
                labelText: "New Password", border: OutlineInputBorder()),
            obscureText: true,
          ),
          SizedBox(height: 15),

          // Confirm New Password
          TextField(
            decoration: InputDecoration(
                labelText: "Confirm New Password",
                border: OutlineInputBorder()),
            obscureText: true,
          ),
          SizedBox(height: 30),

          // Save Button
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor),
              onPressed: () {},
              child: Text("Save",
                  style:
                      GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeEmail() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () =>
                    setState(() => _selectedOption = ProfileOption.main),
              ),
              Text("Change Email",
                  style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 20),

          // New Email Field
          TextField(
            decoration: InputDecoration(
                labelText: "New Email", border: OutlineInputBorder()),
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 30),

          // Save Button
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor),
              onPressed: () {},
              child: Text("Save",
                  style:
                      GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedAddresses() {
    List<Map<String, String>> savedAddresses = [
      {
        "building": "Apartment 302",
        "address1": "123 Main Street",
        "address2": "City, Country",
        "tag": "Home"
      },
      {
        "building": "Office 12A",
        "address1": "456 Office Road",
        "address2": "City, Country",
        "tag": "Work"
      },
    ];

    List<String> tags = ["Home", "Work", "Other"];
    TextEditingController buildingController = TextEditingController();
    TextEditingController address1Controller = TextEditingController();
    TextEditingController address2Controller = TextEditingController();
    TextEditingController newTagController = TextEditingController();
    String selectedTag = "Home";

    void _showEditAddressDialog({int? index}) {
      if (index != null) {
        buildingController.text = savedAddresses[index]["building"]!;
        address1Controller.text = savedAddresses[index]["address1"]!;
        address2Controller.text = savedAddresses[index]["address2"]!;
        selectedTag = savedAddresses[index]["tag"]!;
      } else {
        buildingController.clear();
        address1Controller.clear();
        address2Controller.clear();
        selectedTag = "Home";
      }

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(index == null ? "Add New Address" : "Edit Address",
                          style: GoogleFonts.poppins(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  SizedBox(height: 15),

                  // Building & Room Number
                  TextField(
                    controller: buildingController,
                    decoration: InputDecoration(
                      labelText: "Building Name & Room Number",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Address Line 1
                  TextField(
                    controller: address1Controller,
                    decoration: InputDecoration(
                      labelText: "Address Line 1",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Address Line 2
                  TextField(
                    controller: address2Controller,
                    decoration: InputDecoration(
                      labelText: "Address Line 2",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 15),

                  // Tag Selection
                  Wrap(
                    spacing: 10,
                    children: tags.map((tag) {
                      return ChoiceChip(
                        label:
                            Text(tag, style: GoogleFonts.poppins(fontSize: 14)),
                        selected: selectedTag == tag,
                        selectedColor: AppColors.buttonColor,
                        backgroundColor: Colors.grey[300],
                        onSelected: (bool selected) {
                          setState(() {
                            selectedTag = selected ? tag : selectedTag;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 15),

                  // Add New Tag Field
                  TextField(
                    controller: newTagController,
                    decoration: InputDecoration(
                      labelText: "New Tag (Optional)",
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.add, color: AppColors.buttonColor),
                        onPressed: () {
                          if (newTagController.text.isNotEmpty) {
                            setState(() {
                              tags.add(newTagController.text);
                              selectedTag = newTagController.text;
                            });
                            newTagController.clear();
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Save Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonColor,
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                    ),
                    onPressed: () {
                      if (buildingController.text.isNotEmpty &&
                          address1Controller.text.isNotEmpty) {
                        Map<String, String> newAddress = {
                          "building": buildingController.text,
                          "address1": address1Controller.text,
                          "address2": address2Controller.text,
                          "tag": selectedTag,
                        };

                        setState(() {
                          if (index == null) {
                            savedAddresses.add(newAddress); // Add new address
                          } else {
                            savedAddresses[index] =
                                newAddress; // Edit existing address
                          }
                        });

                        Navigator.pop(context); // Close the bottom sheet
                      }
                    },
                    child: Text(index == null ? "Add Address" : "Save Changes",
                        style: GoogleFonts.poppins(
                            fontSize: 16, color: Colors.white)),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Prevents infinite height issue
        children: [
          // Header Row with Back Button
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () =>
                    setState(() => _selectedOption = ProfileOption.main),
              ),
              Text("Saved Addresses",
                  style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),

          // List of saved addresses
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: savedAddresses.length,
              itemBuilder: (context, index) {
                final address = savedAddresses[index];
                return Card(
                  color: Colors.white,
                  child: ListTile(
                    title: Text("${address["building"]}"),
                    subtitle:
                        Text("${address["address1"]}, ${address["address2"]}"),
                    trailing: IconButton(
                      icon: Icon(Icons.edit, color: AppColors.buttonColor),
                      onPressed: () => _showEditAddressDialog(index: index),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 10),

          // Add New Address Button
          Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor),
              icon: Icon(Icons.add, color: Colors.white),
              onPressed: () =>
                  _showEditAddressDialog(), // Open form for a new address
              label: Text("Add Address",
                  style:
                      GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _aboutUs() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back Arrow & Title (UNCHANGED)
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () =>
                      setState(() => _selectedOption = ProfileOption.main),
                ),
                Expanded(
                  child: Text(
                    "About Us",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 48), // To balance the row
              ],
            ),
            const SizedBox(height: 20),

            // Image Banner
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  'assets/images/about_us.jpg', // Replace with an actual image
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Description Card
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "At Smart PillBox, we are dedicated to revolutionizing medication management through innovative technology. "
                  "Our mission is to enhance medication adherence and improve the quality of life for individuals, "
                  "especially the elderly and those managing chronic conditions.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Mission Statement Card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.blueAccent, size: 30),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Our vision is to create a world where medication non-adherence is no longer a health risk. "
                        "We strive to empower individuals and caregivers with an intelligent, user-friendly solution for managing daily medications.",
                        style: GoogleFonts.poppins(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Features Section Title
            Text(
              "Why Choose Smart PillBox?",
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Features List with Cards
            _featureCard(Icons.alarm, "Automated Reminders",
                "Never forget a dose with timely alerts."),
            _featureCard(Icons.touch_app, "User-Friendly Design",
                "Easy to set up and use for all age groups."),
            _featureCard(Icons.notifications, "Caregiver Notifications",
                "Keep loved ones informed about adherence."),
            _featureCard(Icons.security, "Secure & Portable",
                "Compact, reliable, and built for everyday use."),

            // Contact Info Card
          ],
        ),
      ),
    );
  }

// Reusable Feature Card Widget
  Widget _featureCard(IconData icon, String title, String description) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.green, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(description, style: GoogleFonts.poppins(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _caretaker() {
    final TextEditingController _emailController = TextEditingController();

    // Add caretaker email and update Firestore.
    Future<void> _addCaretakerEmail() async {
      String email = _emailController.text.trim().toLowerCase();
      if (email.isNotEmpty) {
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          // Prevent adding current user's email as caretaker.
          if (email == currentUser.email?.trim().toLowerCase()) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("You cannot add your own email as caretaker."),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          // Check if the caretaker email is already registered as a user.
          QuerySnapshot userQuery = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .get();
          if (userQuery.docs.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    "Cannot add caretaker: email is already registered as a user."),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          // Check for duplicate caretaker email in current user's document.
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get();
          Map<String, dynamic> data =
              userDoc.data() as Map<String, dynamic>? ?? {};
          List<dynamic> caretakerEmails = data['caretakers'] ?? [];
          if (caretakerEmails.contains(email)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Caretaker email already added."),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          // Update current user's "caretakers" array.
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .update({
            'caretakers': FieldValue.arrayUnion([email])
          });

          // In the "caretakers" collection, auto-generate a document ID.
          // Store caretaker email and link it with the patient's (current user's) email.
          await FirebaseFirestore.instance.collection('caretakers').add({
            'email': email,
            'patient': currentUser.email?.trim().toLowerCase() ?? '',
            'deviceToken': "",
          });

          _emailController.clear();
        }
      }
    }

    // Remove caretaker email and update Firestore.
    Future<void> _removeCaretakerEmail(String email) async {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
          'caretakers': FieldValue.arrayRemove([email.toLowerCase()])
        });
        // Query and delete matching caretaker document(s) from the "caretakers" collection.
        QuerySnapshot query = await FirebaseFirestore.instance
            .collection('caretakers')
            .where('email', isEqualTo: email.toLowerCase())
            .where('patient',
                isEqualTo: currentUser.email?.trim().toLowerCase() ?? '')
            .get();
        for (var doc in query.docs) {
          await doc.reference.delete();
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with back button and title.
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => setState(() {
                  _selectedOption = ProfileOption.main;
                }),
              ),
              Text(
                "Caretakers",
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // New Caretaker Email Field.
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: "Add Caretaker Email",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          // Add Button.
          Center(
            child: ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              onPressed: () async {
                await _addCaretakerEmail();
                setState(() {}); // Refresh UI after addition.
              },
              child: Text(
                "Add Caretaker",
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 30),
          // Title for the list.
          Text(
            "Caretaker Emails:",
            style:
                GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // Fetch and display caretaker emails from current user's document.
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data?.data() == null) {
                return Center(
                  child: Text(
                    "No caretakers added",
                    style:
                        GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                  ),
                );
              }
              Map<String, dynamic> data =
                  snapshot.data!.data() as Map<String, dynamic>;
              List<dynamic> caretakerEmails = data['caretakers'] ?? [];
              if (caretakerEmails.isEmpty) {
                return Center(
                  child: Text(
                    "No caretakers added",
                    style:
                        GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                  ),
                );
              }
              return Column(
                children: caretakerEmails.map((email) {
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: const Icon(Icons.email, color: Colors.blue),
                      title: Text(email.toString(),
                          style: GoogleFonts.poppins(fontSize: 16)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _removeCaretakerEmail(email.toString());
                          setState(() {}); // Refresh UI after deletion.
                        },
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
