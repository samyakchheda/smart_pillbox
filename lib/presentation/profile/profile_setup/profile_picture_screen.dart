import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../helpers/image_helper.dart';
import '../../../helpers/functions/save_user_info.dart';
import '../../../widgets/my_elevated_button.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_fonts.dart';
import '../../../routes/routes.dart';

class ProfilePictureScreen extends StatefulWidget {
  const ProfilePictureScreen({super.key});

  @override
  _ProfilePictureScreenState createState() => _ProfilePictureScreenState();
}

class _ProfilePictureScreenState extends State<ProfilePictureScreen> {
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  /// Load the saved profile picture from local storage
  Future<void> _loadProfileImage() async {
    final image = await ImageHelper.loadProfileImage();
    if (image != null && mounted) {
      setState(() => _imageFile = image);
    }
  }

  /// Pick an image from camera/gallery and save it
  Future<void> _pickImage(ImageSource source) async {
    final image = await ImageHelper.pickImage(source);
    if (image != null && mounted) {
      setState(() => _imageFile = image);
      await _saveUserInfo();
      _navigateToProfileCompletion();
    }
  }

  /// Save user details to Firestore
  Future<void> _saveUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name') ?? "";
    final birthDate = prefs.getString('birthDate') ?? "";
    final gender = prefs.getString('gender') ?? "";
    final phoneNumber = prefs.getString('phoneNumber') ?? "";

    if (name.isEmpty ||
        birthDate.isEmpty ||
        gender.isEmpty ||
        phoneNumber.isEmpty) {
      print("❌ Missing user details in SharedPreferences");
      return;
    }

    try {
      await saveUserInfo(
        name: name,
        birthDate: birthDate,
        gender: gender,
        phoneNumber: phoneNumber,
      );
    } catch (e) {
      print("❌ Error saving user info: $e");
    }
  }

  /// Navigate to Profile Completion Screen
  void _navigateToProfileCompletion() {
    if (mounted) {
      Navigator.pushReplacementNamed(context, Routes.profileCompletion);
    }
  }

  /// Skip profile picture step
  Future<void> _skipProfilePicture() async {
    await _saveUserInfo();
    _navigateToProfileCompletion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Set Your Profile Picture", style: AppFonts.headline),
            const SizedBox(height: 10),
            const Text(
              "Personalize your SmartDose experience! You can update this later.",
              textAlign: TextAlign.center,
              style: AppFonts.bodyText,
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () => _pickImage(ImageSource.gallery),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.cardBackground,
                backgroundImage:
                    _imageFile != null ? FileImage(_imageFile!) : null,
                child: _imageFile == null
                    ? const Icon(Icons.add_a_photo,
                        size: 40, color: AppColors.iconDisabled)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            MyElevatedButton(
              text: "Take a Photo",
              icon: const Icon(Icons.camera_alt, color: AppColors.buttonText),
              backgroundColor: AppColors.buttonColor,
              borderRadius: 30,
              onPressed: () => _pickImage(ImageSource.camera),
            ),
            const SizedBox(height: 10),
            MyElevatedButton(
              text: "Choose from Gallery",
              icon:
                  const Icon(Icons.photo_library, color: AppColors.buttonText),
              backgroundColor: AppColors.iconPrimary,
              borderRadius: 30,
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _skipProfilePicture,
              child: const Text("Skip for now", style: AppFonts.caption),
            ),
          ],
        ),
      ),
    );
  }
}
