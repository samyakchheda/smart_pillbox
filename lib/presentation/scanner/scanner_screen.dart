import 'package:flutter/material.dart';
import 'package:home/theme/app_colors.dart';
import '../../services/scanner_service/scanner_service.dart';
import 'image_detail_screen.dart';

class ScannerScreen extends StatefulWidget {
  final String userId;

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

  void _deleteDocument(String documentId, String cloudinaryUrl) async {
    await _documentService.deleteDocument(
        widget.userId, documentId, cloudinaryUrl);
    _fetchScannedDocuments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _startScanning,
        child: const Icon(Icons.add, size: 30),
        backgroundColor: AppColors.buttonColor,
        foregroundColor: Colors.white,
      ),
      appBar: AppBar(
        title: const Text('Prescrtiption Scanner'),
        backgroundColor: Color(0xFFE0E0E0),
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
                              document['id'], document['cloudinary_url']);
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
                        child: Card(
                          color: Colors.white,
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
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.error,
                                                color: Colors.red),
                                  )
                                : const Icon(Icons.image, size: 50),
                            title: Text('Document ${index + 1}'),
                            trailing: const Icon(Icons.arrow_forward),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ImageDetailScreen(
                                    documentId: document['id'],
                                    userId: widget.userId,
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
