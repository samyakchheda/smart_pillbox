import 'package:flutter/material.dart';
import 'package:home/full_image_screen.dart';
import 'package:home/services/scanner_service.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScannerScreen extends StatefulWidget {
  final String userId; // Pass the userId as a parameter

  const ScannerScreen({super.key, required this.userId});

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final DocumentService _documentService = DocumentService();
  List<Map<String, dynamic>> _scannedDocuments = [];

  @override
  void initState() {
    super.initState();
    _fetchScannedDocuments();
  }

  void _fetchScannedDocuments() async {
    final documents =
        await _documentService.fetchScannedDocuments(widget.userId);
    setState(() {
      _scannedDocuments = documents;
    });
  }

  void _startScanning() async {
    await _documentService.startScanning(widget.userId);
    _fetchScannedDocuments();
  }

  void _deleteDocument(
      String documentId, String localPath, String thumbnailPath) async {
    await File(localPath).delete();
    await File(thumbnailPath).delete();
    await _documentService.deleteDocument(widget.userId, documentId);
    _fetchScannedDocuments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _startScanning,
        child: const Text("+", style: TextStyle(fontSize: 25)),
      ),
      appBar: AppBar(
        title: const Text('Document Scanner'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _scannedDocuments.isEmpty
                ? const Center(child: Text('No documents scanned yet.'))
                : ListView.builder(
                    itemCount: _scannedDocuments.length,
                    itemBuilder: (context, index) {
                      final document = _scannedDocuments[index];
                      return Dismissible(
                        key: Key(document['id']),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          _deleteDocument(
                            document['id'],
                            document['local_path'],
                            document['thumbnail_path'],
                          );
                        },
                        background: Container(
                          color: Colors.red,
                          child: const Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                          ),
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.all(8),
                          child: Card(
                            elevation: 4,
                            child: ListTile(
                              leading: document['thumbnail_path'] != null
                                  ? Image.file(
                                      File(document['thumbnail_path']),
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.error,
                                                  color: Colors.red),
                                    )
                                  : const Icon(Icons.image, size: 50),
                              title: Text('Document ${index + 1}'),
                              trailing: const Icon(Icons.arrow_forward),
                              onTap: () {
                                // Check if uploaded_at is null and provide a default value
                                final uploadedAt =
                                    document['uploaded_at'] ?? Timestamp.now();
                                // Navigate to full image screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FullImageScreen(
                                      imagePath: document['local_path'],
                                      thumbnailPath: document['thumbnail_path'],
                                      uploadedAt: uploadedAt,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
