import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:image_picker/image_picker.dart';

import '../api_service/cloudinary_service.dart';

class DocumentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  Future<void> deleteDocument(
      String userId, String documentId, String cloudinaryUrl) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('scanned_documents')
          .doc(documentId)
          .delete();

      // Delete from Cloudinary
      await CloudinaryService.deleteFromCloudinary(cloudinaryUrl);
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

  // Fetch scanned documents for a user
  Future<List<Map<String, dynamic>>> fetchScannedDocuments(
      String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('scanned_documents')
          .orderBy('uploaded_at', descending: true)
          .get();
      return querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'cloudinary_url': doc['cloudinary_url'],
          'uploaded_at': doc['uploaded_at'],
        };
      }).toList();
    } catch (e) {
      print('Error fetching documents: $e');
      return [];
    }
  }

  // Start scanning or picking from gallery and upload to Cloudinary
  Future<void> startScanning(String userId, {required bool useCamera}) async {
    try {
      File? documentFile;

      if (useCamera) {
        // Use CunningDocumentScanner for camera
        final scannedDocuments = await CunningDocumentScanner.getPictures(
          noOfPages: 1,
          isGalleryImportAllowed: false,
        );

        if (scannedDocuments != null && scannedDocuments.isNotEmpty) {
          documentFile = File(scannedDocuments.first);
        }
      } else {
        // Use ImagePicker for gallery
        final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          documentFile = File(pickedFile.path);
        }
      }

      if (documentFile != null) {
        // Upload to Cloudinary
        final cloudinaryUrl = await CloudinaryService.uploadImage(documentFile);
        if (cloudinaryUrl != null) {
          // Store in Firestore
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('scanned_documents')
              .add({
            'cloudinary_url': cloudinaryUrl,
            'uploaded_at': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      print('Error scanning/uploading document: $e');
    }
  }
}
