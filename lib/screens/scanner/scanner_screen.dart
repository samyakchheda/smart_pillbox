import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:home/theme/app_colors.dart'; // Assuming this exists
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: isDarkMode ? AppColors.kWhiteColor : AppColors.kBlackColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardTheme(
          color: isDarkMode
              ? AppColors.cardBackground.withOpacity(0.8)
              : AppColors.cardBackground,
          elevation: 4,
          margin: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black87,
            fontSize: 16,
          ),
          titleLarge: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: _startScanning,
          backgroundColor: AppColors.buttonColor,
          foregroundColor: AppColors.buttonText,
          child: const Icon(Icons.add, size: 30),
        ),
        appBar: AppBar(
          title: Text('Prescription Scanner'.tr()),
        ),
        body: Column(
          children: [
            Expanded(
              child: _scannedDocuments.isEmpty
                  ? Center(
                      child: Text(
                        'No documents scanned yet.'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
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
                            color: AppColors.errorColor, // Replace Colors.red
                            child: const Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Icon(Icons.delete, color: Colors.white),
                              ),
                            ),
                          ),
                          child: Card(
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
                              title: Text(
                                'Document ${index + 1}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              trailing: Icon(
                                Icons.arrow_forward,
                                color: AppColors.buttonColor,
                              ),
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
      ),
    );
  }
}
