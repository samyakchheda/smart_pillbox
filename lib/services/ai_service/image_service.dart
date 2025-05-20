import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  Future<String> convertImageToBase64(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      return base64Encode(imageBytes);
    } catch (e) {
      print('Error converting image to base64: $e');
      return '';
    }
  }

  Future<String?> processImageWithGemini(File image, String description) async {
    String base64Image = await convertImageToBase64(image);

    final inlineData = InlineData(
      mimeType: 'image/jpeg',
      data: base64Image,
    );
    final dataPart = Part.inline(inlineData);

    // Step 1: Check if either the description or the image is health-related.
    final isHealthRelated = await Gemini.instance.prompt(parts: [
      Part.text(
          "Does the following input relate to health? Answer 'yes' or 'no'. Consider both the text and the image.\n\nText: $description\n\nImage: (attached)"),
      dataPart
    ]);

    if (isHealthRelated?.output?.trim().toLowerCase() == 'yes') {
      // Step 2: If health-related, proceed with processing.
      final response = await Gemini.instance.prompt(parts: [
        Part.text(description),
        dataPart,
      ]);
      return response?.output ?? 'No response from Gemini.';
    } else {
      return "I'm sorry, but I can only respond to health-related questions. Please ask a question about health or medical topics.";
    }
  }
}
