import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:home/screens/caretaker/scan/scanner_service.dart';
import 'package:home/theme/app_colors.dart';
import 'image_detail_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final DocumentService _documentService = DocumentService();
  List<Map<String, dynamic>> _scannedDocuments = [];
  String? userId;
  String? userEmail;
  String? targetUserId;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  void _fetchUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User not authenticated');
      return;
    }

    userId = user.uid;
    userEmail = user.email ?? '';

    final caretakerQuery = await FirebaseFirestore.instance
        .collection('caretakers')
        .where('email', isEqualTo: userEmail)
        .get();

    if (caretakerQuery.docs.isNotEmpty) {
      final caretakerData = caretakerQuery.docs.first.data();
      final String patientEmail = caretakerData['patient'] ?? '';

      if (patientEmail.isNotEmpty) {
        final patientQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: patientEmail.trim().toLowerCase())
            .get();

        if (patientQuery.docs.isNotEmpty) {
          targetUserId = patientQuery.docs.first.id;
        }
      }
    }

    targetUserId ??= userId;

    _fetchScannedDocuments();
  }

  void _fetchScannedDocuments() async {
    if (targetUserId == null) return;
    final documents =
        await _documentService.fetchScannedDocuments(targetUserId!);
    setState(() {
      _scannedDocuments = documents;
    });
  }

  void _startScanning() async {
    if (targetUserId == null) return;
    await _documentService.startScanning(targetUserId!);
    _fetchScannedDocuments();
  }

  void _deleteDocument(String documentId, String cloudinaryUrl) async {
    if (targetUserId == null) return;
    await _documentService.deleteDocument(
        targetUserId!, documentId, cloudinaryUrl);
    _fetchScannedDocuments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: _startScanning,
        backgroundColor: AppColors.buttonColor,
        child: Icon(Icons.add, size: 30, color: AppColors.buttonText),
      ),
      appBar: AppBar(
        title: Text('Prescription Scanner',
            style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.cardBackground,
      ),
      body: Column(
        children: [
          Expanded(
            child: _scannedDocuments.isEmpty
                ? Center(
                    child: Text('No documents scanned yet.',
                        style: TextStyle(color: AppColors.textPrimary)))
                : ListView.builder(
                    itemCount: _scannedDocuments.length,
                    itemBuilder: (context, index) {
                      final document = _scannedDocuments[index];
                      return Dismissible(
                        key: Key(document['id']),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          _deleteDocument(
                              document['id'], document['cloudinary_url']);
                        },
                        background: Container(
                          color: AppColors.errorColor,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Icon(Icons.delete,
                                  color: AppColors.buttonText),
                            ),
                          ),
                        ),
                        child: Card(
                          color: AppColors.cardBackground,
                          margin: const EdgeInsets.all(8),
                          elevation: 4,
                          child: ListTile(
                            leading: document['cloudinary_url'] != null
                                ? Image.network(
                                    document['cloudinary_url'],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                            Icons.error,
                                            color: AppColors.errorColor),
                                  )
                                : Icon(Icons.image,
                                    size: 50, color: AppColors.textPrimary),
                            title: Text('Document ${index + 1}',
                                style: TextStyle(color: AppColors.textPrimary)),
                            trailing: Icon(Icons.arrow_forward,
                                color: AppColors.textPrimary),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ImageDetailScreen(
                                    documentId: document['id'],
                                    userId: targetUserId!,
                                  ),
                                ),
                              );
                            },
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
