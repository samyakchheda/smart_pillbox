import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:home/models/pharmacy_model.dart';
import 'package:home/screens/pharmacy/helper.dart';
import 'package:sms_mms/sms_mms.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home/theme/app_colors.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number is empty')),
      );
      return;
    }

    final String messageText = _messageController.text;
    if (messageText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a message')),
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message sent successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not send message: $e')),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.pharmacy.name,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
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
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: _messageController,
                    maxLines: 5,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(12),
                      border: InputBorder.none,
                      hintText: "Type your message here...",
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Scanned Documents:',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: Text(
                            'No scanned documents.',
                            style: GoogleFonts.poppins(),
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
                          color: const Color(0xFFE0E0E0),
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
                                Text('Document ${index + 1}'),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _sendMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor,
                    foregroundColor: Colors.white,
                    textStyle: GoogleFonts.poppins(fontSize: 20),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(double.infinity, 60),
                  ),
                  child: Text('${widget.messageType}'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
