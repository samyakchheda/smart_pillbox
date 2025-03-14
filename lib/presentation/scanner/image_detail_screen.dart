import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:home/ai/services/image_service.dart';
import 'package:home/presentation/reminders/medicine_form_screen.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class ImageDetailScreen extends StatefulWidget {
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
  State<ImageDetailScreen> createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends State<ImageDetailScreen> {
  List<String> _medicineNames = [];
  bool _isLoading = true;
  final Set<String> _addedMedicines = {};

  @override
  void initState() {
    super.initState();
    _loadMedicineNames();
  }

  Future<void> _loadMedicineNames() async {
    final imageFile = File(widget.imagePath);
    final imageService = ImageService();
    const description =
        "Extract the medicine names from this prescription image and only list them. Do not include any medicine names that have been cancelled or scratched out with a pen. Only list the active medicines.";
    String? result =
        await imageService.processImageWithGemini(imageFile, description);
    String rawData = result ?? "No medicine names found.";
    // Parse the medicine names (assuming comma or newline separation)
    final names = rawData
        .split(RegExp(r'[\n,]+'))
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toList();
    setState(() {
      _medicineNames = names;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('dd-MM-yyyy').format(widget.uploadedAt.toDate());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Display full image
              Image.file(
                File(widget.imagePath),
                fit: BoxFit.cover,
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.6,
              ),
              const SizedBox(height: 16),
              Text(
                'Uploaded on: $formattedDate',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text("Fetching medicines..."),
                      ],
                    )
                  : _medicineNames.isEmpty
                      ? const Text(
                          "No medicine names found.",
                          style: TextStyle(fontSize: 16),
                        )
                      : DataTable(
                          columns: const [
                            DataColumn(label: Text('Medicine')),
                            DataColumn(label: Text('Action')),
                          ],
                          rows: _medicineNames.map((medicine) {
                            return DataRow(
                              cells: [
                                DataCell(Text(medicine)),
                                DataCell(
                                  _addedMedicines.contains(medicine)
                                      ? const Icon(Icons.check,
                                          color: Colors.green)
                                      : ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              _addedMedicines.add(medicine);
                                            });
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    MedicineFormScreen(
                                                  existingData: {
                                                    'enteredMedicines': [
                                                      medicine
                                                    ]
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                          child: const Text('Add Medicine'),
                                        ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
