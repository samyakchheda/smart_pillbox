import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';

class DocumentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to delete a scanned document for a specific user
  Future<void> deleteDocument(String userId, String documentId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('scanned_documents')
          .doc(documentId)
          .delete();
    } catch (e) {
      print('Error deleting document from Firestore: $e');
    }
  }

  // Fetch saved file paths from Firestore for a specific user
  Future<List<Map<String, dynamic>>> fetchScannedDocuments(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('scanned_documents')
          .orderBy('uploaded_at', descending: true)
          .get();
      final documents = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'local_path': doc['local_path'],
          'thumbnail_path': doc['thumbnail_path'],
        };
      }).toList();
      return documents;
    } catch (e) {
      print('Error fetching documents: $e');
      return [];
    }
  }

  // Compress the image and return the thumbnail path
  Future<String> createThumbnail(String originalPath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final thumbnailPath =
        '${appDir.path}/thumbnail_${originalPath.split('/').last}';
    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      originalPath,
      thumbnailPath,
      quality: 50,
    );
    return compressedFile?.path ?? originalPath;
  }

  // Start scanning documents and associate them with the user
  Future<void> startScanning(String userId) async {
    try {
      final scannedDocuments = await CunningDocumentScanner.getPictures(
        noOfPages: 1,
        isGalleryImportAllowed: false,
      );

      if (scannedDocuments != null) {
        final appDir = await getApplicationDocumentsDirectory();

        for (String documentPath in scannedDocuments) {
          final fileName = documentPath.split('/').last;
          final newFilePath = '${appDir.path}/$fileName';

          // Copy the file to the app's storage directory
          await File(documentPath).copy(newFilePath);

          // Create a thumbnail
          final thumbnailPath = await createThumbnail(newFilePath);

          // Store the file path in the user's subcollection in Firestore
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('scanned_documents')
              .add({
            'local_path': newFilePath,
            'thumbnail_path': thumbnailPath,
            'uploaded_at': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      print('Error scanning documents: $e');
    }
  }
}
