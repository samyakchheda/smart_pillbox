import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';

import '../api/cloudinary_service.dart';

class DocumentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  // Start scanning and upload to Cloudinary
  Future<void> startScanning(String userId) async {
    try {
      final scannedDocuments = await CunningDocumentScanner.getPictures(
        noOfPages: 1,
        isGalleryImportAllowed: false,
      );

      if (scannedDocuments != null) {
        for (String documentPath in scannedDocuments) {
          File documentFile = File(documentPath);

          // Upload to Cloudinary
          final cloudinaryUrl =
              await CloudinaryService.uploadImage(documentFile);
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
      }
    } catch (e) {
      print('Error scanning/uploading document: $e');
    }
  }
}
