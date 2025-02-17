import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class ImageDetailScreen extends StatelessWidget {
  final String imagePath;
  final String thumbnailPath;
  final Timestamp uploadedAt;

  const ImageDetailScreen({
    super.key,
    required this.imagePath,
    required this.thumbnailPath,
    required this.uploadedAt,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd-MM-yyyy').format(uploadedAt.toDate());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Displaying full image
            Image.file(
              File(imagePath),
              fit: BoxFit.cover,
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.6,
            ),
            const SizedBox(height: 16),
            // Displaying the upload date
            Text(
              'Uploaded on: $formattedDate',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
