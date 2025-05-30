import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:home/theme/app_colors.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class OCRScreen extends StatefulWidget {
  const OCRScreen({super.key});

  @override
  _OCRScreenState createState() => _OCRScreenState();
}

class _OCRScreenState extends State<OCRScreen> {
  File? _image;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  final String _apiKey = "AIzaSyCU0iHiaA561vAjGUBtQ4_FAhZcR7pf_UA";

  Map<String, String> medicineDetails = {
    "name": "N/A",
    "dosage": "N/A",
    "uses": "N/A",
    "side_effects": "N/A",
    "precautions": "N/A",
    "interactions": "N/A",
    "storage": "N/A",
  };

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isLoading = true;
      });
      await _processImageWithAI(_image!);
    }
  }

  Future<void> _processImageWithAI(File imageFile) async {
    try {
      final response = await _sendImageToGemini(imageFile);
      if (response != null) {
        final cleanedResponse = _cleanJson(response);
        final data = jsonDecode(cleanedResponse);
        setState(() {
          medicineDetails = {
            "name": data["name"] ?? "Unknown Medicine",
            "dosage":
                data["dosage"] ?? "Standard dosage information not specified",
            "uses": data["uses"] ?? "Common medicinal uses",
            "side_effects":
                data["side_effects"] ?? "Typical side effects may apply",
            "precautions":
                data["precautions"] ?? "Standard precautions recommended",
            "interactions": data["interactions"] ??
                "Possible interactions with other medications",
            "storage": data["storage"] ?? "Store in a cool, dry place",
          };
          _isLoading = false;
        });
      } else {
        setState(() {
          medicineDetails["name"] = "Failed to process image";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        medicineDetails["name"] = "Error processing image: $e";
        _isLoading = false;
      });
    }
  }

  Future<String?> _sendImageToGemini(File imageFile) async {
    final uri = Uri.parse(
        "https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash:generateContent?key=$_apiKey");
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final requestBody = jsonEncode({
      "contents": [
        {
          "parts": [
            {
              "text":
                  "Analyze this medicine image and extract the medicine name if visible. Then, provide comprehensive details including name, dosage, uses, side effects, precautions, interactions, and storage instructions. If any information is not directly available from the image, use your knowledge base to provide accurate, complete details based on the identified medicine or typical standards for similar medications. Never return 'no info' or empty fields. Return in JSON format: {\"name\": \"\", \"dosage\": \"\", \"uses\": \"\", \"side_effects\": \"\", \"precautions\": \"\", \"interactions\": \"\", \"storage\": \"\"}"
            },
            {
              "inlineData": {"mimeType": "image/jpeg", "data": base64Image}
            }
          ]
        }
      ]
    });

    try {
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: requestBody,
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse["candidates"]?[0]["content"]["parts"]?[0]["text"];
      } else {
        print("API Error: Status Code ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("API Exception: $e");
      return null;
    }
  }

  String _cleanJson(String response) {
    return response.replaceAll("```json", "").replaceAll("```", "").trim();
  }

  Future<void> _addMedicineToFirestore() async {
    if (medicineDetails["name"] == "N/A" ||
        medicineDetails["name"] == "Error processing image" ||
        medicineDetails["name"] == "Failed to process image") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No valid medicine data to add.",
              style: TextStyle(color: AppColors.buttonText)),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please sign in to add medicine.",
              style: TextStyle(color: AppColors.buttonText)),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('medicines')
          .add({
        ...medicineDetails,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Medicine added successfully!",
              style: TextStyle(color: AppColors.buttonText)),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error adding medicine: $e",
              style: TextStyle(color: AppColors.buttonText)),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Medicine Scanner',
            style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildImagePreview(),
                const SizedBox(height: 20),
                _buildButtonRow(),
                const SizedBox(height: 20),
                _buildResultCard(),
                const SizedBox(height: 20),
                _buildAddButton(),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: AppColors.darkBackground.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.buttonColor),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppColors.cardBackground,
              AppColors.buttonColor.withOpacity(0.1)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(_image!, fit: BoxFit.cover),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt,
                        size: 40, color: AppColors.buttonColor),
                    const SizedBox(height: 8),
                    Text(
                      'Capture or Upload an Image',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _customButton(
          icon: Icons.camera_alt,
          label: "Camera",
          onPressed: () => _pickImage(ImageSource.camera),
        ),
        _customButton(
          icon: Icons.photo_library,
          label: "Gallery",
          onPressed: () => _pickImage(ImageSource.gallery),
        ),
      ],
    );
  }

  Widget _buildResultCard() {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.cardBackground,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: medicineDetails.entries
                  .map((entry) => _buildInfoSection(
                        entry.key.replaceAll('_', ' ').toUpperCase(),
                        entry.value,
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.buttonColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Divider(color: AppColors.borderColor),
        ],
      ),
    );
  }

  Widget _customButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24, color: AppColors.buttonText),
      label: Text(label, style: TextStyle(color: AppColors.buttonText)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        backgroundColor: AppColors.buttonColor,
        foregroundColor: AppColors.buttonText,
      ),
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _addMedicineToFirestore,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppColors.buttonColor,
          foregroundColor: AppColors.buttonText,
          elevation: 4,
        ),
        child: Text(
          "Add Medicine",
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.buttonText),
        ),
      ),
    );
  }
}
