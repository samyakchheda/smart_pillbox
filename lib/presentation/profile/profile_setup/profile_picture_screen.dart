import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:home/services/api/cloudinary_service.dart';
import 'package:home/theme/app_colors.dart';
import 'package:home/theme/app_fonts.dart';
import 'package:home/widgets/my_snack_bar.dart';

class ProfilePictureScreen extends StatefulWidget {
  const ProfilePictureScreen({super.key});

  @override
  _ProfilePictureScreenState createState() => _ProfilePictureScreenState();
}

class _ProfilePictureScreenState extends State<ProfilePictureScreen> {
  File? _image;
  String? _photoUrl;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchProfilePicture();
  }

  void _fetchProfilePicture() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (user.photoURL != null) {
        setState(() => _photoUrl = user.photoURL);
      } else {
        var userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists && userDoc.data()?['profile_picture'] != null) {
          setState(() => _photoUrl = userDoc['profile_picture']);
        }
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _isUploading = true);
      File? compressedImage = await _compressImage(File(pickedFile.path));
      if (compressedImage != null) {
        String? imageUrl = await CloudinaryService.uploadImage(compressedImage);
        if (imageUrl != null) {
          _saveProfilePicture(imageUrl);
        } else {
          mySnackBar(context, "Image upload failed!", isError: true);
        }
      }
      setState(() => _isUploading = false);
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

  void _saveProfilePicture(String imageUrl) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'profile_picture': imageUrl});
    setState(() => _photoUrl = imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text("Set Profile Picture", style: AppFonts.headline),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/profileCompletion'),
            child: const Text("Skip",
                style: TextStyle(color: AppColors.kBlackColor)),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 85,
                  backgroundColor: AppColors.lightBackground,
                  backgroundImage: _photoUrl != null
                      ? NetworkImage(_photoUrl!) as ImageProvider
                      : (_image != null ? FileImage(_image!) : null),
                  child: (_photoUrl == null && _image == null)
                      ? const Icon(Icons.person,
                          size: 80, color: AppColors.darkBackground)
                      : null,
                ),
                if (_isUploading)
                  const Positioned(
                    bottom: 5,
                    right: 5,
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                heroTag: "gallery",
                backgroundColor: Colors.blue,
                onPressed: () => _pickImage(ImageSource.gallery),
                child: const Icon(Icons.photo_library, color: Colors.white),
              ),
              const SizedBox(width: 20),
              FloatingActionButton(
                heroTag: "camera",
                backgroundColor: Colors.blue,
                onPressed: () => _pickImage(ImageSource.camera),
                child: const Icon(Icons.camera_alt, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
