import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:home/theme/app_colors.dart'; // Assuming this exists
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
  final String _apiKey =
      "AIzaSyCU0iHiaA561vAjGUBtQ4_FAhZcR7pf_UA"; // Replace with your Gemini API Key

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
        SnackBar(content: Text("No valid medicine data to add.".tr())),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please sign in to add medicine.".tr())),
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
          content: Text("Medicine added successfully!".tr()),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error adding medicine: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.buttonColor,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: AppColors.textOnPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardTheme(
          color: isDarkMode
              ? AppColors.cardBackground.withOpacity(0.8)
              : AppColors.cardBackground,
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black87,
            fontSize: 14,
          ),
          titleLarge: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            backgroundColor: AppColors.buttonColor,
            foregroundColor: AppColors.buttonText,
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: isDarkMode ? AppColors.errorColor : Colors.red,
          contentTextStyle: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Medicine Scanner'.tr()),
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
                color: Colors.black45,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.buttonColor),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Card(
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: Theme.of(context).brightness == Brightness.dark
                ? [
                    AppColors.buttonColor.withOpacity(0.2),
                    AppColors.cardBackground.withOpacity(0.5),
                  ]
                : [Colors.blue.shade50, Colors.white],
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
                      'Capture or Upload an Image'.tr(),
                      style: Theme.of(context).textTheme.titleLarge,
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
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).cardTheme.color,
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
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.buttonColor,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Divider(color: Colors.grey),
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
      icon: Icon(icon, size: 24),
      label: Text(label),
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _addMedicineToFirestore,
        child: Text(
          "Add Medicine".tr(),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
