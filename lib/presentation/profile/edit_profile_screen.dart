// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:convert';

// class EditProfileScreen extends StatefulWidget {
//   const EditProfileScreen({super.key});

//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _genderController = TextEditingController();
//   final TextEditingController _dobController = TextEditingController();
//   final TextEditingController _contactController = TextEditingController();

//   String? email;
//   String? name;
//   String? gender;
//   String? dob;
//   String? contact;
//   String? _profilePictureBase64;

//   bool _isLoading = false;
//   bool _isNameLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserData();
//   }

//   Future<void> _fetchUserData() async {
//     try {
//       User? user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         setState(() {
//           email = user.email;
//         });

//         DocumentSnapshot<Map<String, dynamic>> userData =
//             await FirebaseFirestore.instance
//                 .collection('users')
//                 .doc(user.uid)
//                 .get();

//         if (userData.exists) {
//           final data = userData.data();
//           if (data != null) {
//             setState(() {
//               name = data['name'] ?? 'Unknown';
//               gender = data['gender'] ?? 'Unknown';
//               dob = data['birthdate'] ?? 'Unknown';
//               contact = data['phoneNumber'] ?? 'Unknown';
//               _profilePictureBase64 = data['profilePicture'];

//               _nameController.text = name!;
//               _genderController.text = gender!;
//               _dobController.text = dob!;
//               _contactController.text = contact!;
//               _isNameLoading = false;
//             });
//           } else {
//             print("No data found in the user's Firestore document.");
//           }
//         } else {
//           print("User document does not exist in Firestore.");
//         }
//       }
//     } catch (e) {
//       print('Error fetching user data: $e');
//       setState(() {
//         _isNameLoading = false;
//       });
//     }
//   }

//   Future<void> _pickImage() async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? image = await picker.pickImage(source: ImageSource.gallery);
//     if (image != null) {
//       final bytes = await image.readAsBytes();
//       String base64Image = base64Encode(bytes);
//       await _updateProfilePicture(base64Image);
//     }
//   }

//   Future<void> _updateProfilePicture(String base64Image) async {
//     try {
//       String userId = FirebaseAuth.instance.currentUser!.uid;
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(userId)
//           .update({'profilePicture': base64Image});

//       setState(() {
//         _profilePictureBase64 = base64Image;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Profile picture updated successfully!')),
//       );
//     } catch (e) {
//       print('Error updating profile picture: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   }

//   Future<void> _updateProfile() async {
//     setState(() {
//       _isLoading = true;
//     });
//     try {
//       await saveUserInfo(
//         name: _nameController.text,
//         gender: _genderController.text,
//         birthDate: _dobController.text,
//         phoneNumber: _contactController.text,
//       );
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Profile updated successfully!')),
//       );
//       Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error updating profile: $e')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Profile'),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               GestureDetector(
//                 onTap: _pickImage,
//                 child: Stack(
//                   children: [
//                     CircleAvatar(
//                       radius: 60,
//                       backgroundColor: Colors.grey.shade300,
//                       backgroundImage: _profilePictureBase64 != null
//                           ? MemoryImage(base64Decode(_profilePictureBase64!))
//                           : const AssetImage(
//                                   'assets/icons/ic_default_avatar.jpg')
//                               as ImageProvider,
//                       child: _profilePictureBase64 == null
//                           ? const Icon(
//                               Icons.person,
//                               size: 50,
//                               color: Colors.white,
//                             )
//                           : null,
//                     ),
//                     Positioned(
//                       bottom: 0,
//                       right: 4,
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: Colors.blue,
//                           shape: BoxShape.circle,
//                           border: Border.all(
//                             color: Colors.white,
//                             width: 2,
//                           ),
//                         ),
//                         child: const Padding(
//                           padding: EdgeInsets.all(4.0),
//                           child: Icon(
//                             Icons.edit,
//                             size: 18,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),
//               _isNameLoading
//                   ? const CircularProgressIndicator()
//                   : TextField(
//                       controller: _nameController,
//                       decoration: const InputDecoration(
//                         labelText: 'Name',
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//               const SizedBox(height: 20),
//               TextField(
//                 controller: _genderController,
//                 decoration: const InputDecoration(
//                   labelText: 'Gender',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               TextField(
//                 controller: _dobController,
//                 decoration: const InputDecoration(
//                   labelText: 'Date of Birth',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               TextField(
//                 controller: _contactController,
//                 decoration: const InputDecoration(
//                   labelText: 'Contact Number',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               TextFormField(
//                 initialValue: email ?? 'Fetching email...',
//                 readOnly: true,
//                 decoration: const InputDecoration(
//                   labelText: 'Email',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _isLoading ? null : _updateProfile,
//                 child: _isLoading
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text('Save Changes'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Future<void> _fetchUserData() async {
// //   try {
// //     User? user = FirebaseAuth.instance.currentUser;
// //     if (user != null) {
// //       setState(() {
// //         email = user.email;
// //       });
// //       DocumentSnapshot userData = await FirebaseFirestore.instance
// //           .collection('users')
// //           .doc(user.uid)
// //           .get();
// //
// //       setState(() {
// //         name = userData['name'] ?? 'Unknown';
// //         gender = userData['gender'] ?? 'Unknown';
// //         dob = userData['birthdate'] ?? 'Unknown';
// //         contact = userData['phoneNumber'] ?? 'Unknown';
// //         _profilePictureBase64 = userData['profilePicture'] ?? null;
// //
// //         _nameController.text = name!;
// //         _genderController.text = gender!;
// //         _dobController.text = dob!;
// //         _contactController.text = contact!;
// //         _isNameLoading = false;
// //       });
// //     }
// //   } catch (e) {
// //     print('Error fetching user data: $e');
// //     setState(() {
// //       _isNameLoading = false;
// //     });
// //   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:home/services/api/cloudinary_service.dart';
import 'package:home/widgets/my_elevated_button.dart';
import 'package:home/widgets/my_snack_bar.dart';

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

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUserData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (phoneNumber != null && phoneCountryCode != null) {
        setState(() {
          phoneController.text = '$phoneCountryCode $phoneNumber';
        });
      }
    });
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

            print("Phone display set to: ${phoneController.text}");
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
      mySnackBar(context, "Error fetching data: $e", isError: true);
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
    if (nameController.text.trim().isEmpty ||
        dobController.text.trim().isEmpty ||
        selectedGender == null ||
        phoneController.text.trim().isEmpty) {
      mySnackBar(context, "Please fill all required fields", isError: true);
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
// Delete old image from Cloudinary if it exists
            if (_photoUrl != null && _photoUrl!.isNotEmpty) {
              bool deleted =
                  await CloudinaryService.deleteFromCloudinary(_photoUrl!);
              if (!deleted) {
                print("Failed to delete old image from Cloudinary");
// Optionally, you can decide to proceed or throw an error
// throw Exception("Failed to delete old image from Cloudinary");
              } else {
                print("Old image deleted successfully from Cloudinary");
              }
            }

// Upload new image
            profilePictureUrl =
                await CloudinaryService.uploadImage(compressedImage);
            if (profilePictureUrl == null) {
              throw Exception("Image upload failed");
            }
          }
        }

// Remove space and split the phone number
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

        setState(() => _isUploading = false);
        mySnackBar(context, "Profile updated successfully");
        widget.onBack();
      }
    } catch (e) {
      setState(() => _isUploading = false);
      mySnackBar(context, "Error updating data: $e", isError: true);
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Choose Photo Source"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: widget.onBack,
                ),
                Text(
                  "Edit Profile",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Stack(
                children: [
                  InkWell(
                    onTap: _showImageSourceDialog,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.lightBackground,
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : (_photoUrl != null
                              ? NetworkImage(_photoUrl!)
                              : null),
                      child: (_image == null && _photoUrl == null)
                          ? const Icon(Icons.person,
                              size: 60, color: AppColors.darkBackground)
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
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
            const SizedBox(height: 20),
            _buildInputField(
              label: "Full Name",
              hint: "Enter your full name",
              controller: nameController,
              keyboardType: TextInputType.name,
            ),
            _buildInputField(
              label: "Date of Birth",
              hint: "Select your DOB",
              controller: dobController,
              readOnly: true,
              suffixIcon: const Icon(Icons.calendar_today,
                  color: AppColors.textSecondary),
              onTap: _selectDOB,
            ),
            _buildDropdown(),
            _buildPhoneField(),
            const SizedBox(height: 30),
            Center(
              child: _isUploading
                  ? const CircularProgressIndicator(
                      color: AppColors.buttonColor)
                  : MyElevatedButton(
                      onPressed: _saveUserData,
                      text: 'Save',
                      backgroundColor: AppColors.buttonColor,
                      textStyle: GoogleFonts.poppins(
                          fontSize: 16, color: Colors.white),
                      borderRadius: 50,
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
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixIcon: suffixIcon,
          labelStyle: GoogleFonts.poppins(color: AppColors.textSecondary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
        style: GoogleFonts.poppins(),
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
                  child: Text(
                    gender,
                    style: GoogleFonts.poppins(color: Colors.black),
                  ),
                ))
            .toList(),
        decoration: InputDecoration(
          labelText: "Gender",
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
      child: TextField(
        controller: phoneController,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          labelText: "Contact Number",
          hintText: "Enter phone number (e.g., +91 9876543210)",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          labelStyle: GoogleFonts.poppins(color: AppColors.textSecondary),
        ),
        style: GoogleFonts.poppins(),
      ),
    );
  }
}
