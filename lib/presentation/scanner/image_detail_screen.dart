import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ImageDetailScreen extends StatefulWidget {
  final String documentId;
  final String userId;

  const ImageDetailScreen({
    super.key,
    required this.documentId,
    required this.userId,
  });

  @override
  _ImageDetailScreenState createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends State<ImageDetailScreen> {
  String? imageUrl;
  Timestamp? uploadedAt;

  @override
  void initState() {
    super.initState();
    _fetchDocumentDetails();
  }

  Future<void> _fetchDocumentDetails() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('scanned_documents')
          .doc(widget.documentId)
          .get();

      if (docSnapshot.exists) {
        setState(() {
          imageUrl = docSnapshot['cloudinary_url'];
          uploadedAt = docSnapshot['uploaded_at'];
        });
      }
    } catch (e) {
      print('Error fetching document details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Document Details')),
      body: imageUrl == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.6,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error, color: Colors.red, size: 50),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Uploaded on: ${uploadedAt != null ? DateFormat('dd-MM-yyyy').format(uploadedAt!.toDate()) : 'Unknown'}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
    );
  }
}
