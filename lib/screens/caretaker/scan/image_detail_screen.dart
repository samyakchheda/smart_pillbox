import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:home/services/ai_service/image_service.dart';
import 'package:home/screens/reminders/medicine_form_screen.dart';
import 'package:home/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final Set<String> _addedMedicines = {}; // Medicines confirmed in Firebase

  // Cache medicine names per document using documentId as key in memory.
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
        if (imageUrl != null) {
          await _loadMedicineNames();
          await _checkAddedMedicinesInFirebase(); // Check Firebase for added medicines
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

  /// Loads the medicine names by first checking SharedPreferences and the in-memory cache.
  Future<void> _loadMedicineNames() async {
    if (_cachedMedicineNames.containsKey(widget.documentId)) {
      setState(() {
        _medicineNames = _cachedMedicineNames[widget.documentId]!;
        _isLoadingMedicines = false;
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final storedNames = prefs.getString('medicine_names_${widget.documentId}');
    if (storedNames != null) {
      final names = List<String>.from(json.decode(storedNames));
      setState(() {
        _medicineNames = names;
        _isLoadingMedicines = false;
      });
      _cachedMedicineNames[widget.documentId] = names;
      return;
    }

    try {
      final imageFile = await _downloadImage(imageUrl!);
      final imageService = ImageService();
      const description =
          "Extract the medicine names from this prescription image and only list them. Do not include any medicine names that have been cancelled or scratched out with a pen. Only list the active medicines.";
      String? result =
          await imageService.processImageWithGemini(imageFile, description);
      String rawData = result ?? "No medicine names found.";

      final names = rawData
          .split(RegExp(r'[\n,]+'))
          .map((name) => name.trim())
          .where((name) => name.isNotEmpty)
          .toList();

      setState(() {
        _medicineNames = names;
        _isLoadingMedicines = false;
      });

      _cachedMedicineNames[widget.documentId] = names;
      await prefs.setString(
          'medicine_names_${widget.documentId}', json.encode(names));
    } catch (e) {
      print('Error loading medicine names: $e');
      setState(() {
        _isLoadingMedicines = false;
      });
    }
  }

  /// Check Firebase for medicines already added under the user's reminders collection.
  Future<void> _checkAddedMedicinesInFirebase() async {
    try {
      final userDocSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      final data = userDocSnapshot.data();
      final existingMedicines = <String>{};

      if (data != null) {
        // Assuming reminders is stored as an array in the user document.
        final medicines = data['medicines'] as List<dynamic>?;

        if (medicines != null) {
          for (final medicine in medicines) {
            // Each reminder is expected to be a Map.
            final reminderMap = medicine as Map<String, dynamic>;
            final medicineNames =
                reminderMap['medicineNames'] as List<dynamic>?;

            if (medicineNames != null) {
              // Convert each medicine name to String before adding to the set.
              existingMedicines.addAll(medicineNames.map((e) => e.toString()));
            }
          }
        }
      }

      print('All medicine names: $existingMedicines');

      setState(() {
        _addedMedicines.clear();
        _addedMedicines.addAll(_medicineNames
            .where((medicine) => existingMedicines.contains(medicine)));
      });
    } catch (e) {
      print('Error checking Firebase for added medicines: $e');
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
        backgroundColor: const Color(0xFFE0E0E0),
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
                    Text(
                      "Uploaded on: ${formattedDate}",
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
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
                                          final isAdded = _addedMedicines
                                              .contains(medicine);

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
