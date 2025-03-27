// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:flutter_dotenv/flutter_dotenv.dart';
// // import 'package:crypto/crypto.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:flutter_image_compress/flutter_image_compress.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';

// // class CloudinaryService {
// //   static final String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
// //   static final String uploadPreset =
// //       dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';
// //   static final String apiKey = dotenv.env['CLOUDINARY_API_KEY'] ?? '';
// //   static final String apiSecret = dotenv.env['CLOUDINARY_API_SECRET'] ?? '';

// //   static Future<File> _compressImage(File imageFile) async {
// //     try {
// //       final filePath = imageFile.absolute.path;
// //       final lastIndex = filePath.lastIndexOf('.');
// //       final outPath = "${filePath.substring(0, lastIndex)}_compressed.jpg";

// //       var result = await FlutterImageCompress.compressAndGetFile(
// //         filePath,
// //         outPath,
// //         quality: 80,
// //       );

// //       return result != null ? File(result.path) : imageFile;
// //     } catch (e) {
// //       print("Error compressing image: $e");
// //       return imageFile;
// //     }
// //   }

// //   static Future<String?> uploadProfilePicture(
// //       File imageFile, String userId) async {
// //     try {
// //       const String folder = "user_profile_pictures";
// //       String fileName = userId;

// //       File compressedImage = await _compressImage(imageFile);

// //       String? oldProfilePicUrl = await getCurrentProfilePicUrl(userId);
// //       if (oldProfilePicUrl != null) {
// //         await deleteFromCloudinary(oldProfilePicUrl);
// //       }

// //       String? newProfilePicUrl =
// //           await uploadImage(compressedImage, folder, fileName);

// //       if (newProfilePicUrl != null) {
// //         await FirebaseFirestore.instance
// //             .collection('users')
// //             .doc(userId)
// //             .update({
// //           'profilePicUrl': newProfilePicUrl,
// //         });
// //       }

// //       return newProfilePicUrl;
// //     } catch (e) {
// //       print("Error uploading profile picture: $e");
// //       return null;
// //     }
// //   }

// //   static Future<String?> uploadScannedDocument(
// //       File docFile, String userId, String fileName) async {
// //     try {
// //       const String folder = "user_scanned_docs";
// //       File compressedFile = await _compressImage(docFile);

// //       return await uploadImage(compressedFile, folder, "$userId/$fileName");
// //     } catch (e) {
// //       print("Error uploading scanned document: $e");
// //       return null;
// //     }
// //   }

// //   static Future<String?> uploadImage(
// //       File imageFile, String folder, String fileName) async {
// //     try {
// //       final uri =
// //           Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
// //       final request = http.MultipartRequest("POST", uri)
// //         ..fields['upload_preset'] = uploadPreset
// //         ..fields['folder'] = folder
// //         ..fields['public_id'] = fileName
// //         ..files.add(await http.MultipartFile.fromPath("file", imageFile.path));

// //       final response = await request.send();
// //       if (response.statusCode == 200) {
// //         final responseData = json.decode(await response.stream.bytesToString());
// //         return responseData['secure_url'];
// //       } else {
// //         print("Cloudinary upload failed: ${response.reasonPhrase}");
// //       }
// //     } catch (e) {
// //       print("Error uploading to Cloudinary: $e");
// //     }
// //     return null;
// //   }

// //   static Future<void> deleteFromCloudinary(String cloudinaryUrl) async {
// //     try {
// //       final uriSegments = Uri.parse(cloudinaryUrl).pathSegments;
// //       if (uriSegments.isEmpty) {
// //         print("Invalid Cloudinary URL: $cloudinaryUrl");
// //         return;
// //       }

// //       final publicId = uriSegments.sublist(1).join('/').split('.').first;
// //       final timestamp =
// //           (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
// //       final stringToSign = 'public_id=$publicId&timestamp=$timestamp$apiSecret';
// //       final signature = sha1.convert(utf8.encode(stringToSign)).toString();

// //       final response = await http.post(
// //         Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/destroy"),
// //         body: {
// //           "public_id": publicId,
// //           "api_key": apiKey,
// //           "timestamp": timestamp,
// //           "signature": signature,
// //         },
// //       );

// //       final responseData = json.decode(response.body);
// //       if (responseData["result"] != "ok") {
// //         print(
// //             "Cloudinary deletion failed: ${responseData["error"]["message"]}");
// //       } else {
// //         print("File deleted successfully from Cloudinary.");
// //       }
// //     } catch (e) {
// //       print("Error deleting file from Cloudinary: $e");
// //     }
// //   }

// //   static Future<void> deleteScannedDocument(
// //       String userId, String fileName, String docUrl) async {
// //     try {
// //       await deleteFromCloudinary(docUrl);
// //       await FirebaseFirestore.instance.collection('users').doc(userId).update({
// //         "scannedDocs": FieldValue.arrayRemove([docUrl])
// //       });
// //     } catch (e) {
// //       print("Error deleting scanned document: $e");
// //     }
// //   }

// //   static Future<String?> getCurrentProfilePicUrl(String userId) async {
// //     try {
// //       final userDoc = await FirebaseFirestore.instance
// //           .collection('users')
// //           .doc(userId)
// //           .get();
// //       if (userDoc.exists) {
// //         final data = userDoc.data();
// //         return data != null && data.containsKey('profilePicUrl')
// //             ? data['profilePicUrl']
// //             : null;
// //       }
// //       return null;
// //     } catch (e) {
// //       print("Error fetching profile pic URL: $e");
// //       return null;
// //     }
// //   }
// // }

// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:crypto/crypto.dart';
// import 'package:http/http.dart' as http;
// import 'package:cloud_firestore/cloud_firestore.dart';

// class CloudinaryService {
//   static final String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
//   static final String uploadPreset =
//       dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';
//   static final String apiKey = dotenv.env['CLOUDINARY_API_KEY'] ?? '';
//   static final String apiSecret = dotenv.env['CLOUDINARY_API_SECRET'] ?? '';

//   static Future<String?> uploadProfilePicture(
//       File imageFile, String userId) async {
//     try {
//       const String folder = "user_profile_pictures";
//       String fileName = userId;

//       String? oldProfilePicUrl = await getCurrentProfilePicUrl(userId);
//       if (oldProfilePicUrl != null) {
//         await deleteFromCloudinary(oldProfilePicUrl);
//       }

//       String? newProfilePicUrl = await uploadImage(imageFile, folder, fileName);

//       if (newProfilePicUrl != null) {
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(userId)
//             .update({
//           'profilePicUrl': newProfilePicUrl,
//         });
//       }

//       return newProfilePicUrl;
//     } catch (e) {
//       print("Error uploading profile picture: $e");
//       return null;
//     }
//   }

//   static Future<String?> uploadScannedDocument(
//       File docFile, String userId, String fileName) async {
//     try {
//       const String folder = "user_scanned_docs";

//       return await uploadImage(docFile, folder, "$userId/$fileName");
//     } catch (e) {
//       print("Error uploading scanned document: $e");
//       return null;
//     }
//   }

//   static Future<String?> uploadImage(
//       File imageFile, String folder, String fileName) async {
//     try {
//       final uri =
//           Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
//       final request = http.MultipartRequest("POST", uri)
//         ..fields['upload_preset'] = uploadPreset
//         ..fields['folder'] = folder
//         ..fields['public_id'] = fileName
//         ..files.add(await http.MultipartFile.fromPath("file", imageFile.path));

//       final response = await request.send();
//       if (response.statusCode == 200) {
//         final responseData = json.decode(await response.stream.bytesToString());
//         return responseData['secure_url'];
//       } else {
//         print("Cloudinary upload failed: ${response.reasonPhrase}");
//       }
//     } catch (e) {
//       print("Error uploading to Cloudinary: $e");
//     }
//     return null;
//   }

//   static Future<void> deleteFromCloudinary(String cloudinaryUrl) async {
//     try {
//       final uriSegments = Uri.parse(cloudinaryUrl).pathSegments;
//       if (uriSegments.isEmpty) {
//         print("Invalid Cloudinary URL: $cloudinaryUrl");
//         return;
//       }

//       final publicId = uriSegments.sublist(1).join('/').split('.').first;
//       final timestamp =
//           (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
//       final stringToSign = 'public_id=$publicId&timestamp=$timestamp$apiSecret';
//       final signature = sha1.convert(utf8.encode(stringToSign)).toString();

//       final response = await http.post(
//         Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/destroy"),
//         body: {
//           "public_id": publicId,
//           "api_key": apiKey,
//           "timestamp": timestamp,
//           "signature": signature,
//         },
//       );

//       final responseData = json.decode(response.body);
//       if (responseData["result"] != "ok") {
//         print(
//             "Cloudinary deletion failed: ${responseData["error"]["message"]}");
//       } else {
//         print("File deleted successfully from Cloudinary.");
//       }
//     } catch (e) {
//       print("Error deleting file from Cloudinary: $e");
//     }
//   }

//   static Future<void> deleteScannedDocument(
//       String userId, String fileName, String docUrl) async {
//     try {
//       await deleteFromCloudinary(docUrl);
//       await FirebaseFirestore.instance.collection('users').doc(userId).update({
//         "scannedDocs": FieldValue.arrayRemove([docUrl])
//       });
//     } catch (e) {
//       print("Error deleting scanned document: $e");
//     }
//   }

//   static Future<String?> getCurrentProfilePicUrl(String userId) async {
//     try {
//       final userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(userId)
//           .get();
//       if (userDoc.exists) {
//         final data = userDoc.data();
//         return data != null && data.containsKey('profilePicUrl')
//             ? data['profilePicUrl']
//             : null;
//       }
//       return null;
//     } catch (e) {
//       print("Error fetching profile pic URL: $e");
//       return null;
//     }
//   }
// }

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
