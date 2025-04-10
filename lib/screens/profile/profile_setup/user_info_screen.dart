import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:home/services/api_service/cloudinary_service.dart';
import 'package:home/widgets/common/my_elevated_button.dart';
import 'package:home/widgets/common/my_snack_bar.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:home/routes/routes.dart';
import 'package:home/theme/app_colors.dart';
import 'package:home/theme/app_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../../widgets/common/my_text_field.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  String? selectedGender;
  String? phoneNumber;
  String? phoneCountryCode;

  // Profile picture variables
  File? _image;
  String? _photoUrl;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      nameController.text = user.displayName ?? "";

      // Fetch additional details from Firestore if already saved
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

        setState(() {
          dobController.text = data['birthDate'] ?? "";
          selectedGender = data['gender'];
          phoneNumber = data['phoneNumber'];
          phoneCountryCode = data['phoneCountryCode'];
          _photoUrl = data['profile_picture'];
        });
      }
    }
  }

  Future<void> _selectDOB() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        dobController.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile =
        await _picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<File?> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath =
        path.join(dir.path, "${DateTime.now().millisecondsSinceEpoch}.jpg");

    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 50,
      minWidth: 800,
      minHeight: 800,
    );

    return result != null ? File(result.path) : null;
  }

  Future<void> _saveUserData() async {
    if (nameController.text.isEmpty ||
        dobController.text.isEmpty ||
        selectedGender == null ||
        phoneNumber == null) {
      mySnackBar(context, "Please fill all required fields", isError: true);
      return;
    }

    setState(() => _isUploading = true);

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Upload image if a new one was selected
        String? profilePictureUrl = _photoUrl;
        if (_image != null) {
          File? compressedImage = await _compressImage(_image!);
          if (compressedImage != null) {
            profilePictureUrl =
                await CloudinaryService.uploadImage(compressedImage);
            if (profilePictureUrl == null) {
              setState(() => _isUploading = false);
              mySnackBar(context, "Image upload failed. Please try again.",
                  isError: true);
              return;
            }
          }
        }

        // Save user data to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': nameController.text,
          'birthDate': dobController.text,
          'gender': selectedGender,
          'phoneNumber': phoneNumber,
          'phoneCountryCode': phoneCountryCode,
          'profile_picture': profilePictureUrl,
          'email': user.email, // Store email for reference
        }, SetOptions(merge: true));

        setState(() => _isUploading = false);
        Navigator.pushReplacementNamed(context, Routes.profileCompletion);
      }
    } catch (e) {
      setState(() => _isUploading = false);
      mySnackBar(context, "Error saving data: $e", isError: true);
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Choose Photo Source", style: AppFonts.headline),
          backgroundColor: AppColors.cardBackground,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading:
                    Icon(Icons.photo_library, color: AppColors.textPrimary),
                title: Text("Gallery", style: AppFonts.bodyText),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppColors.textPrimary),
                title: Text("Camera", style: AppFonts.bodyText),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
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
      backgroundColor: AppColors.background, // Theme-aware background
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text.rich(
                TextSpan(
                  text: "Tell us about ",
                  style:
                      AppFonts.headline.copyWith(fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: "yourself",
                      style: AppFonts.headline.copyWith(
                        color: AppColors.buttonColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Profile Picture Section
            Center(
              child: Stack(
                children: [
                  InkWell(
                    onTap: _showImageSourceDialog,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.cardBackground,
                      backgroundImage: _image != null
                          ? FileImage(_image!) as ImageProvider
                          : (_photoUrl != null
                              ? NetworkImage(_photoUrl!) as ImageProvider
                              : null),
                      child: (_image == null && _photoUrl == null)
                          ? Icon(Icons.person,
                              size: 60, color: AppColors.textSecondary)
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.buttonColor,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 20),
                        onPressed: _showImageSourceDialog,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Full Name
            MyTextField(
              controller: nameController,
              hintText: "Enter your full name",
              keyboardType: TextInputType.name,
              fillColor: AppColors.cardBackground,
            ),
            const SizedBox(height: 15),
            // Date of Birth
            MyTextField(
              controller: dobController,
              hintText: "Select your DOB",
              // readOnly: true,
              fillColor: AppColors.cardBackground,
              icon: Icons.calendar_today,
              onTap: _selectDOB,
            ),

            // Gender Dropdown
            _buildDropdown(),

            // Contact Number
            _buildPhoneField(),

            const SizedBox(height: 30),

            // Continue Button
            Align(
              alignment: Alignment.center,
              child: _isUploading
                  ? CircularProgressIndicator(color: AppColors.buttonColor)
                  : MyElevatedButton(
                      text: 'Save & Continue',
                      onPressed: _saveUserData,
                      backgroundColor: AppColors.buttonColor,
                      height: 50,
                      borderRadius: 50,
                      textStyle: AppFonts.buttonText
                          .copyWith(color: AppColors.textOnPrimary),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField<String>(
        value: selectedGender,
        onChanged: (value) => setState(() => selectedGender = value),
        items: ["Male", "Female", "Prefer not to say"]
            .map((gender) => DropdownMenuItem(
                  value: gender,
                  child: Text(gender, style: AppFonts.bodyText),
                ))
            .toList(),
        decoration: InputDecoration(
          labelText: "Gender",
          filled: true,
          fillColor: AppColors.cardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(color: AppColors.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(color: AppColors.buttonColor),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          labelStyle: AppFonts.caption.copyWith(color: AppColors.textSecondary),
        ),
        dropdownColor: AppColors.cardBackground,
        style: AppFonts.bodyText.copyWith(color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: IntlPhoneField(
        decoration: InputDecoration(
          labelText: "Contact Number",
          filled: true,
          fillColor: AppColors.cardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(color: AppColors.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(color: AppColors.buttonColor),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          labelStyle: AppFonts.caption.copyWith(color: AppColors.textSecondary),
        ),
        initialCountryCode: 'IN',
        initialValue: phoneNumber ?? "",
        onChanged: (phone) {
          setState(() {
            phoneNumber = phone.number;
            phoneCountryCode = phone.countryCode;
          });
        },
        style: AppFonts.bodyText.copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}
