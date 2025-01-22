import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../../services/firebase_services.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  String? email;
  String? name;
  String? gender;
  String? dob;
  String? contact;
  String? _profilePictureBase64;

  bool _isLoading = false;
  bool _isNameLoading = true;

  final FirebaseServices _authService = FirebaseServices();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          email = user.email;
        });

        DocumentSnapshot<Map<String, dynamic>> userData =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (userData.exists) {
          final data = userData.data();
          if (data != null) {
            setState(() {
              name = data['name'] ?? 'Unknown';
              gender = data['gender'] ?? 'Unknown';
              dob = data['birthdate'] ?? 'Unknown';
              contact = data['phoneNumber'] ?? 'Unknown';
              _profilePictureBase64 = data['profilePicture'];

              _nameController.text = name!;
              _genderController.text = gender!;
              _dobController.text = dob!;
              _contactController.text = contact!;
              _isNameLoading = false;
            });
          } else {
            print("No data found in the user's Firestore document.");
          }
        } else {
          print("User document does not exist in Firestore.");
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _isNameLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      String base64Image = base64Encode(bytes);
      await _updateProfilePicture(base64Image);
    }
  }

  Future<void> _updateProfilePicture(String base64Image) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'profilePicture': base64Image});

      setState(() {
        _profilePictureBase64 = base64Image;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated successfully!')),
      );
    } catch (e) {
      print('Error updating profile picture: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _authService.updateUserProfile(
        name: _nameController.text,
        gender: _genderController.text,
        birthdate: _dobController.text,
        phoneNumber: _contactController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: _profilePictureBase64 != null
                          ? MemoryImage(base64Decode(_profilePictureBase64!))
                          : const AssetImage(
                                  'assets/icons/ic_default_avatar.jpg')
                              as ImageProvider,
                      child: _profilePictureBase64 == null
                          ? const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.edit,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _isNameLoading
                  ? const CircularProgressIndicator()
                  : TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
              const SizedBox(height: 20),
              TextField(
                controller: _genderController,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _dobController,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _contactController,
                decoration: const InputDecoration(
                  labelText: 'Contact Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: email ?? 'Fetching email...',
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Future<void> _fetchUserData() async {
//   try {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       setState(() {
//         email = user.email;
//       });
//       DocumentSnapshot userData = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .get();
//
//       setState(() {
//         name = userData['name'] ?? 'Unknown';
//         gender = userData['gender'] ?? 'Unknown';
//         dob = userData['birthdate'] ?? 'Unknown';
//         contact = userData['phoneNumber'] ?? 'Unknown';
//         _profilePictureBase64 = userData['profilePicture'] ?? null;
//
//         _nameController.text = name!;
//         _genderController.text = gender!;
//         _dobController.text = dob!;
//         _contactController.text = contact!;
//         _isNameLoading = false;
//       });
//     }
//   } catch (e) {
//     print('Error fetching user data: $e');
//     setState(() {
//       _isNameLoading = false;
//     });
//   }
// }