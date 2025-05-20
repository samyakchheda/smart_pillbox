import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home/theme/app_colors.dart';
import 'package:home/theme/app_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:home/services/api_service/cloudinary_service.dart';
import 'package:home/widgets/common/my_elevated_button.dart';
import 'package:home/widgets/common/my_text_field.dart';
import 'package:home/widgets/common/my_snack_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditProfileScreen extends StatefulWidget {
  final VoidCallback onBack;

  const EditProfileScreen({required this.onBack, super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String? selectedGender;
  String? phoneNumber;
  String? phoneCountryCode;
  File? _image;
  String? _photoUrl;
  bool _isUploading = false;
  bool _isLoadingImage = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

          print("User data from Firestore: $data");

          setState(() {
            nameController.text = data['name'] ?? user.displayName ?? "";
            dobController.text = data['birthDate'] ?? "";
            selectedGender = data['gender'];
            _photoUrl = data['profile_picture'];
            phoneCountryCode = data['phoneCountryCode'];
            phoneNumber = data['phoneNumber'];

            if (phoneCountryCode != null && phoneNumber != null) {
              phoneController.text = '$phoneCountryCode $phoneNumber';
            }

            _isLoadingImage = false;
            print("Photo URL fetched: $_photoUrl");
            print("Phone display set to: ${phoneController.text}");
          });
        } else {
          setState(() {
            _isLoadingImage = false;
          });
          print("User document does not exist");
        }
      } else {
        setState(() {
          _isLoadingImage = false;
        });
        print("No authenticated user found");
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        _isLoadingImage = false;
      });
      mySnackBar(context, "Error fetching data: $e".tr(), isError: true);
    }
  }

  Future<void> _selectDOB() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.buttonColor,
              onPrimary: AppColors.buttonText,
              onSurface: AppColors.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.buttonColor,
              ),
            ),
          ),
          child: child!,
        );
      },
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
        _isLoadingImage = false;
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
    if (nameController.text.trim().isEmpty ||
        dobController.text.trim().isEmpty ||
        selectedGender == null ||
        phoneController.text.trim().isEmpty) {
      mySnackBar(context, "Please fill all required fields".tr(),
          isError: true);
      return;
    }

    setState(() => _isUploading = true);

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String? profilePictureUrl = _photoUrl;

        if (_image != null) {
          File? compressedImage = await _compressImage(_image!);
          if (compressedImage != null) {
            if (_photoUrl != null && _photoUrl!.isNotEmpty) {
              bool deleted =
                  await CloudinaryService.deleteFromCloudinary(_photoUrl!);
              if (!deleted) {
                print("Failed to delete old image from Cloudinary");
              } else {
                print("Old image deleted successfully from Cloudinary");
              }
            }
            profilePictureUrl =
                await CloudinaryService.uploadImage(compressedImage);
            if (profilePictureUrl == null) {
              throw Exception("Image upload failed");
            }
          }
        }

        String phoneInput = phoneController.text.trim().replaceAll(' ', '');
        String countryCode =
            phoneInput.startsWith('+') ? phoneInput.substring(0, 3) : '+91';
        String number =
            phoneInput.startsWith('+') ? phoneInput.substring(3) : phoneInput;

        await _firestore.collection('users').doc(user.uid).set({
          'name': nameController.text.trim(),
          'birthDate': dobController.text.trim(),
          'gender': selectedGender,
          'phoneNumber': number,
          'phoneCountryCode': countryCode,
          'profile_picture': profilePictureUrl,
          'email': user.email,
        }, SetOptions(merge: true));

        if (user.displayName != nameController.text.trim()) {
          await user.updateDisplayName(nameController.text.trim());
        }

        setState(() {
          _isUploading = false;
          _photoUrl = profilePictureUrl;
          _image = null;
        });
        mySnackBar(context, "Profile updated successfully");
        widget.onBack();
      }
    } catch (e) {
      setState(() => _isUploading = false);
      mySnackBar(context, "Error updating data: $e".tr(), isError: true);
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: AppColors.cardBackground,
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: MaterialColor(
                AppColors.buttonColor.value,
                <int, Color>{
                  50: AppColors.buttonColor.withOpacity(0.1),
                  100: AppColors.buttonColor.withOpacity(0.2),
                  200: AppColors.buttonColor.withOpacity(0.3),
                  300: AppColors.buttonColor.withOpacity(0.4),
                  400: AppColors.buttonColor.withOpacity(0.5),
                  500: AppColors.buttonColor,
                  600: AppColors.buttonColor.withOpacity(0.7),
                  700: AppColors.buttonColor.withOpacity(0.8),
                  800: AppColors.buttonColor.withOpacity(0.9),
                  900: AppColors.buttonColor,
                },
              ),
              accentColor: AppColors.buttonColor,
              cardColor: AppColors.cardBackground,
              backgroundColor: AppColors.cardBackground,
              errorColor: AppColors.errorColor,
              brightness: Theme.of(context).brightness,
            ).copyWith(
              onPrimary: AppColors.buttonText,
              onSurface: AppColors.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.buttonColor,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                foregroundColor: AppColors.buttonText,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                elevation: 4,
              ),
            ),
          ),
          child: AlertDialog(
            backgroundColor: AppColors.cardBackground,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(
              "Choose Photo Source".tr(),
              style: AppFonts.headline.copyWith(color: AppColors.textPrimary),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MyElevatedButton(
                  text: "Gallery".tr(),
                  onPressed: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                  icon: const Icon(Icons.photo_library, size: 20),
                  backgroundColor: AppColors.buttonColor,
                  textColor: AppColors.buttonText,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  borderRadius: 50,
                  textStyle: AppFonts.buttonText.copyWith(fontSize: 16),
                  iconSpacing: 8.0,
                ),
                const SizedBox(height: 10),
                MyElevatedButton(
                  text: "Camera".tr(),
                  onPressed: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                  icon: const Icon(Icons.camera_alt, size: 20),
                  backgroundColor: AppColors.buttonColor,
                  textColor: AppColors.buttonText,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  borderRadius: 50,
                  textStyle: AppFonts.buttonText.copyWith(fontSize: 16),
                  iconSpacing: 8.0,
                ),
              ],
            ),
            actions: [
              MyElevatedButton(
                text: "Cancel".tr(),
                onPressed: () => Navigator.pop(context),
                backgroundColor: AppColors.cardBackground,
                textColor: AppColors.buttonText,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                borderRadius: 50,
                textStyle: AppFonts.buttonText.copyWith(fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new,
                      color: AppColors.buttonColor),
                  onPressed: widget.onBack,
                ),
                Text(
                  "Edit Profile".tr(),
                  style:
                      AppFonts.headline.copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Stack(
                children: [
                  InkWell(
                    onTap: _showImageSourceDialog,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.buttonColor, width: 2),
                      ),
                      child: ClipOval(
                        child: _isLoadingImage
                            ? CircleAvatar(
                                radius: 60,
                                backgroundColor: AppColors.cardBackground,
                                child: CircularProgressIndicator(
                                  color: AppColors.buttonColor,
                                ),
                              )
                            : _image != null
                                ? Image.file(
                                    _image!,
                                    fit: BoxFit.cover,
                                    width: 120,
                                    height: 120,
                                  )
                                : (_photoUrl != null && _photoUrl!.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: _photoUrl!,
                                        fit: BoxFit.cover,
                                        width: 120,
                                        height: 120,
                                        placeholder: (context, url) =>
                                            CircleAvatar(
                                          radius: 60,
                                          backgroundColor:
                                              AppColors.cardBackground,
                                          child: CircularProgressIndicator(
                                            color: AppColors.buttonColor,
                                          ),
                                        ),
                                        errorWidget: (context, url, error) {
                                          print("Image load error: $error");
                                          return CircleAvatar(
                                            radius: 60,
                                            backgroundColor:
                                                AppColors.cardBackground,
                                            child: Icon(Icons.error,
                                                size: 60,
                                                color: AppColors.buttonColor),
                                          );
                                        },
                                      )
                                    : CircleAvatar(
                                        radius: 60,
                                        backgroundColor:
                                            AppColors.cardBackground,
                                        child: Icon(Icons.person,
                                            size: 60,
                                            color: AppColors.textPrimary),
                                      )),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.kBlackColor,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.camera_alt,
                            color: AppColors.buttonColor, size: 20),
                        onPressed: _showImageSourceDialog,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildInputField(
              label: "Full Name".tr(),
              hint: "Enter your full name".tr(),
              controller: nameController,
              keyboardType: TextInputType.name,
            ),
            _buildInputField(
              label: "Date of Birth".tr(),
              hint: "Select your DOB".tr(),
              controller: dobController,
              readOnly: true,
              icon: Icons.calendar_today,
              onTap: _selectDOB,
            ),
            _buildDropdown(),
            _buildPhoneField(),
            const SizedBox(height: 30),
            Center(
              child: _isUploading
                  ? CircularProgressIndicator(color: AppColors.buttonColor)
                  : MyElevatedButton(
                      onPressed: _saveUserData,
                      text: 'Save'.tr(),
                      backgroundColor: AppColors.buttonColor,
                      textColor: AppColors.buttonText,
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 24),
                      borderRadius: 50,
                      textStyle: AppFonts.buttonText.copyWith(fontSize: 16),
                      height: 60,
                      icon: const Icon(Icons.save, size: 20),
                      iconSpacing: 12.0,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: MyTextField(
        controller: controller,
        hintText: hint,
        keyboardType: keyboardType ?? TextInputType.text,
        onTap: onTap,
        enabled: !readOnly,
        icon: icon,
        fillColor: AppColors.cardBackground,
        hintStyle: AppFonts.bodyText
            .copyWith(color: AppColors.textSecondary.withOpacity(0.6)),
        textStyle: AppFonts.bodyText.copyWith(color: AppColors.textPrimary),
        borderRadius: 50,
      ),
    );
  }

  Widget _buildDropdown() {
    const genderOptions = ['Male', 'Female', 'Prefer not to say'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField<String>(
        value: genderOptions.contains(selectedGender) ? selectedGender : null,
        onChanged: (value) => setState(() => selectedGender = value),
        items: genderOptions
            .map((gender) => DropdownMenuItem(
                  value: gender, // actual value saved in Firestore
                  child: Text(
                    gender.tr(), // only translate for display
                    style: GoogleFonts.poppins(color: AppColors.textPrimary),
                  ),
                ))
            .toList(),
        decoration: InputDecoration(
          labelText: "Gender".tr(),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
        style: GoogleFonts.poppins(),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: MyTextField(
        controller: phoneController,
        hintText: "Enter phone number".tr(),
        keyboardType: TextInputType.phone,
        icon: Icons.phone,
        fillColor: AppColors.cardBackground,
        hintStyle: AppFonts.bodyText
            .copyWith(color: AppColors.textSecondary.withOpacity(0.6)),
        textStyle: AppFonts.bodyText.copyWith(color: AppColors.textPrimary),
        borderRadius: 50,
      ),
    );
  }
}
