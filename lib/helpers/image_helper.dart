import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Pick an image from the given source (camera or gallery)
  static Future<File?> pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return null;

      return await saveImageLocally(File(pickedFile.path));
    } catch (e) {
      print("❌ Error picking image: $e");
      return null;
    }
  }

  /// Save image locally and update SharedPreferences
  static Future<File> saveImageLocally(File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final localPath = '${directory.path}/profile_pic.jpg';
      final savedImage = await imageFile.copy(localPath);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', savedImage.path);

      return savedImage;
    } catch (e) {
      print("❌ Error saving image locally: $e");
      return imageFile;
    }
  }

  /// Load the saved profile picture from local storage
  static Future<File?> loadProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final imagePath = prefs.getString('profile_image');
      if (imagePath != null) {
        return File(imagePath);
      }
    } catch (e) {
      print("❌ Error loading profile image: $e");
    }
    return null;
  }
}
