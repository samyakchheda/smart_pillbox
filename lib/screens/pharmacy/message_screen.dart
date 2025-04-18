import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:home/models/pharmacy_model.dart';
import 'package:home/screens/pharmacy/helper.dart';
import 'package:sms_mms/sms_mms.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home/theme/app_colors.dart';
import '../../widgets/common/my_elevated_button.dart';
import '../../widgets/common/my_snack_bar.dart';

class MessageScreen extends StatefulWidget {
  final Pharmacy pharmacy;
  final String messageType; // "SMS" or "MMS"

  const MessageScreen({
    super.key,
    required this.pharmacy,
    required this.messageType,
  });

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  String? _selectedDocumentId;
  List<QueryDocumentSnapshot> _documentList = [];
  String? userId;
  String? targetUserId;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User not authenticated');
      return;
    }

    userId = user.uid;

    // Check if user is a caretaker
    final caretakerQuery = await FirebaseFirestore.instance
        .collection('caretakers')
        .where('email', isEqualTo: user.email)
        .get();

    if (caretakerQuery.docs.isNotEmpty) {
      // Caretaker found, get assigned patient's ID
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

    // If user is not a caretaker, use their own ID
    targetUserId ??= userId;

    setState(() {});
  }

  Future<void> _sendMessage() async {
    if (widget.pharmacy.phoneNumber.trim().isEmpty) {
      mySnackBar(
        context,
        'Phone number is empty',
        isError: true,
      );
      return;
    }

    final String messageText = _messageController.text;
    if (messageText.isEmpty) {
      mySnackBar(
        context,
        'Please enter a message',
        isError: true,
      );
      return;
    }

    // Retrieve selected document URL
    String? selectedUrl;
    if (_selectedDocumentId != null) {
      for (var doc in _documentList) {
        if (doc.id == _selectedDocumentId) {
          selectedUrl = doc['cloudinary_url'] as String?;
          break;
        }
      }
    }

    try {
      String? localPath;
      if (selectedUrl != null) {
        localPath = await downloadFile(selectedUrl, 'selected_document.jpg');
      }

      await SmsMms.send(
        recipients: [widget.pharmacy.phoneNumber],
        filePath: localPath,
        message: messageText,
      );

      mySnackBar(
        context,
        'Message sent successfully',
        isError: false,
      );
    } catch (e) {
      mySnackBar(
        context,
        'Could not send message: $e',
        isError: true,
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.pharmacy.name,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.borderColor.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Compose your message:',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: TextField(
                    controller: _messageController,
                    maxLines: 5,
                    style: TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(12),
                      border: InputBorder.none,
                      hintText: "Type your message here...",
                      hintStyle: TextStyle(color: AppColors.textPlaceholder),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Scanned Documents:',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(targetUserId)
                      .collection('scanned_documents')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.buttonColor),
                          ),
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: Text(
                            'No scanned documents.',
                            style: GoogleFonts.poppins(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }

                    _documentList = snapshot.data!.docs;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _documentList.length,
                      itemBuilder: (context, index) {
                        var doc = _documentList[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          color: AppColors.listItemBackground,
                          child: ListTile(
                            leading: Radio<String>(
                              value: doc.id,
                              groupValue: _selectedDocumentId,
                              activeColor: AppColors.buttonColor,
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedDocumentId = value;
                                });
                              },
                            ),
                            title: Row(
                              children: [
                                Image.network(
                                  doc['cloudinary_url'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Document ${index + 1}',
                                  style:
                                      TextStyle(color: AppColors.listItemText),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                MyElevatedButton(
                  text: widget.messageType,
                  onPressedAsync: _sendMessage,
                  height: 60,
                  width: double.infinity,
                  backgroundColor: AppColors.buttonColor,
                  textColor: AppColors.textOnPrimary,
                  borderRadius: 12,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  ),
                  textShift: 0, // Center the text
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
