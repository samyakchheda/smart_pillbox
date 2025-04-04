import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static final String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static final String uploadPreset =
      dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';
  static final String apiKey = dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  static final String apiSecret = dotenv.env['CLOUDINARY_API_SECRET'] ?? '';

  static void _checkEnvVariables() {
    if (cloudName.isEmpty ||
        uploadPreset.isEmpty ||
        apiKey.isEmpty ||
        apiSecret.isEmpty) {
      throw Exception(
          'Missing Cloudinary environment variables. Check your .env file.');
    }
  }

  static Future<String?> uploadImage(File imageFile) async {
    _checkEnvVariables();

    final uri =
        Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
    final request = http.MultipartRequest("POST", uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath("file", imageFile.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = json.decode(await response.stream.bytesToString());
      return responseData['secure_url'];
    } else {
      print('Upload failed with status: ${response.statusCode}');
      return null;
    }
  }

  static String extractPublicId(String cloudinaryUrl) {
    Uri uri = Uri.parse(cloudinaryUrl);
    List<String> segments = uri.pathSegments;

    int uploadIndex = segments.indexOf('upload');
    if (uploadIndex != -1 && uploadIndex + 1 < segments.length) {
      String publicId = segments.sublist(uploadIndex + 1).join('/');
      publicId = publicId.split('.').first; // Remove file extension
      return publicId;
    }
    return '';
  }

  static Future<bool> deleteFromCloudinary(String cloudinaryUrl) async {
    try {
      _checkEnvVariables();

      final publicId = extractPublicId(cloudinaryUrl);
      if (publicId.isEmpty) {
        print("Failed to extract public ID from URL: $cloudinaryUrl");
        return false;
      }

      print("Extracted public_id: $publicId");

      final timestamp =
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
      final String stringToSign =
          'public_id=$publicId&timestamp=$timestamp$apiSecret'; // Fixed signature
      final signature = sha1.convert(utf8.encode(stringToSign)).toString();

      final url = "https://api.cloudinary.com/v1_1/$cloudName/image/destroy";

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "public_id": publicId,
          "api_key": apiKey,
          "timestamp": timestamp,
          "signature": signature,
        },
      );

      final responseBody = response.body;
      print("Cloudinary Response: $responseBody");

      final responseData = json.decode(responseBody);
      if (response.statusCode == 200 && responseData["result"] == "ok") {
        print("Image deleted successfully from Cloudinary: $publicId");
        return true;
      } else {
        print(
            "Cloudinary deletion failed: ${responseData["error"]?["message"] ?? 'Unknown error'}");
        return false;
      }
    } catch (e) {
      print("Error deleting file from Cloudinary: $e");
      return false;
    }
  }
}
