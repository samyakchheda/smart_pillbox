import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:another_telephony/telephony.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home/pharmacy/screens/helper.dart';
import 'package:home/theme/app_colors.dart';
import '../models/pharmacy_model.dart';
import 'package:share_plus/share_plus.dart';

class MessageScreen extends StatefulWidget {
  final Pharmacy pharmacy;
  final String messageType;

  const MessageScreen({
    Key? key,
    required this.pharmacy,
    required this.messageType,
  }) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final Telephony telephony = Telephony.instance;

  // Hold the id of the selected document; null means no selection.
  String? _selectedDocumentId;

  // Store the document list locally.
  List<QueryDocumentSnapshot> _documentList = [];

  @override
  Widget build(BuildContext context) {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

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
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Message header
                Text(
                  'Compose your message:',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Multiline TextField for message input.
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100, // Light grey background
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: _messageController,
                    maxLines: 5,
                    style: const TextStyle(
                        color: Colors.black), // Changed to black
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(12),
                      border: InputBorder.none,
                      hintText: "Type your message here...",
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header for scanned documents.
                Text(
                  'Scanned Documents:',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // StreamBuilder to show list of scanned documents with radio buttons.
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
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

                    _documentList =
                        snapshot.data!.docs.cast<QueryDocumentSnapshot>();

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
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    doc['cloudinary_url'],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    },
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image,
                                                size: 50),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Document ${index + 1}',
                                  style: GoogleFonts.poppins(),
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
                // Send button sends the message along with the selected document.
                ElevatedButton(
                  onPressed: _sendMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor,
                    foregroundColor: Colors.white,
                    textStyle: GoogleFonts.poppins(
                      fontSize: 20,
                    ),
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

  Future<void> _sendMessage() async {
    final String message = _messageController.text;
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a message')),
      );
      return;
    }

    // Get the URL of the selected document if any.
    String? selectedUrl;
    if (_selectedDocumentId != null) {
      QueryDocumentSnapshot? selectedDoc;
      for (var doc in _documentList) {
        if (doc.id == _selectedDocumentId) {
          selectedDoc = doc;
          break;
        }
      }
      if (selectedDoc != null) {
        selectedUrl = selectedDoc['cloudinary_url'] as String?;
      }
    }

    if (widget.messageType == 'Share') {
      try {
        // If a document is selected, download and share it with the text.
        if (selectedUrl != null) {
          final localPath =
              await downloadFile(selectedUrl, 'selected_document.jpg');
          if (localPath != null) {
            final XFile fileToShare = XFile(localPath);
            await Share.shareXFiles(
              [fileToShare],
              text: message,
            );
          } else {
            // Fallback: share text only if file download fails.
            await Share.share(message);
          }
        } else {
          // If no document is selected, share text only.
          await Share.share(message);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not share: $e')),
        );
      }
    }

    Navigator.pop(context);
  }
}
