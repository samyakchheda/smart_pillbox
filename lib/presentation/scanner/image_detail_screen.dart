import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:home/ai/services/image_service.dart';
import 'package:home/presentation/reminders/medicine_form_screen.dart';
import 'package:home/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

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
  bool _isLoadingMedicines = true;
  List<String> _medicineNames = [];
  final Set<String> _addedMedicines = {};

  // Cache medicine names per document using documentId as key.
  static final Map<String, List<String>> _cachedMedicineNames = {};

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
        // Once the image URL is fetched, load the medicine names.
        if (imageUrl != null) {
          _loadMedicineNames();
        }
      }
    } catch (e) {
      print('Error fetching document details: $e');
    }
  }

  /// Downloads the image from the network and saves it to a temporary file.
  Future<File> _downloadImage(String url) async {
    final response = await http.get(Uri.parse(url));
    final documentDirectory = await getTemporaryDirectory();
    final filePath =
        '${documentDirectory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  Future<void> _loadMedicineNames() async {
    // Check if the medicine names are already cached for this document.
    if (_cachedMedicineNames.containsKey(widget.documentId)) {
      setState(() {
        _medicineNames = _cachedMedicineNames[widget.documentId]!;
        _isLoadingMedicines = false;
      });
      return;
    }
    try {
      // Download the network image.
      final imageFile = await _downloadImage(imageUrl!);
      final imageService = ImageService();
      const description =
          "Extract the medicine names from this prescription image and only list them. Do not include any medicine names that have been cancelled or scratched out with a pen. Only list the active medicines.";
      String? result =
          await imageService.processImageWithGemini(imageFile, description);
      String rawData = result ?? "No medicine names found.";
      // Parse the medicine names (assuming they are separated by commas or newlines)
      final names = rawData
          .split(RegExp(r'[\n,]+'))
          .map((name) => name.trim())
          .where((name) => name.isNotEmpty)
          .toList();

      setState(() {
        _medicineNames = names;
        _isLoadingMedicines = false;
      });
      // Cache the loaded medicine names for this document.
      _cachedMedicineNames[widget.documentId] = names;
    } catch (e) {
      print('Error loading medicine names: $e');
      setState(() {
        _isLoadingMedicines = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = uploadedAt != null
        ? DateFormat('dd-MM-yyyy').format(uploadedAt!.toDate())
        : 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription Details'),
        backgroundColor: Color(0xFFE0E0E0), // Use your theme's primary color
        elevation: 0,
      ),
      body: imageUrl == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Display the image with rounded corners.
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Scaffold(
                              backgroundColor: Colors.white,
                              appBar: AppBar(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                iconTheme:
                                    const IconThemeData(color: Colors.black),
                              ),
                              body: Center(
                                child: InteractiveViewer(
                                  child: Image.network(
                                    imageUrl!,
                                    fit: BoxFit.contain,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    },
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                      Icons.error,
                                      color: Colors.red,
                                      size: 50,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.4,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                                child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.error,
                            color: Colors.red,
                            size: 50,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    // Display upload date.
                    Text(
                      "Uploaded on: ${formattedDate}",
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Wrap the medicine list in a Card for a cleaner look.
                    Card(
                      color: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _isLoadingMedicines
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 8),
                                  Text("Fetching medicines..."),
                                ],
                              )
                            : _medicineNames.isEmpty
                                ? const Center(
                                    child: Text(
                                      "No medicine names found.",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Detected Medicines",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: _medicineNames.length,
                                        separatorBuilder: (context, index) =>
                                            const Divider(),
                                        itemBuilder: (context, index) {
                                          final medicine =
                                              _medicineNames[index];
                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  medicine,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              _addedMedicines.contains(medicine)
                                                  ? const Icon(
                                                      Icons.check_circle,
                                                      color: Colors.green)
                                                  : ElevatedButton.icon(
                                                      onPressed: () {
                                                        setState(() {
                                                          _addedMedicines
                                                              .add(medicine);
                                                        });
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                MedicineFormScreen(
                                                              existingData: {
                                                                'enteredMedicines':
                                                                    [medicine],
                                                              },
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      icon:
                                                          const Icon(Icons.add),
                                                      label: const Text('Add'),
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            AppColors
                                                                .buttonColor,
                                                        foregroundColor:
                                                            Colors.white,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                    ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
