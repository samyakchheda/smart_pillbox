import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:another_telephony/telephony.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsapp_share/whatsapp_share.dart';
import '../models/pharmacy_model.dart';

class MessageScreen extends StatefulWidget {
  final Pharmacy pharmacy;
  final String messageType;

  const MessageScreen(
      {Key? key, required this.pharmacy, required this.messageType})
      : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final Telephony telephony = Telephony.instance;

  @override
  Widget build(BuildContext context) {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Message ${widget.pharmacy.name}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Compose your message:',
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Type your message here...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sendMessage,
              child: Text('Send ${widget.messageType}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                textStyle: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.bold),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Scanned Documents:',
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId) // Replace with dynamic user ID if needed
                    .collection('scanned_documents')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No scanned documents.'));
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            'Document ${index + 1}',
                            style: GoogleFonts.poppins(),
                          ),
                          leading: Image.file(
                            File(doc['thumbnail_path']),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() async {
    String message = _messageController.text;
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a message')),
      );
      return;
    }

    if (widget.messageType == 'SMS') {
      telephony.sendSms(
          to: "9137876370", message: "May the force be with you!");
      print('Sending SMS to ${widget.pharmacy.phoneNumber}: $message');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('SMS sent (simulated)')),
      );
    } else if (widget.messageType == 'WhatsApp') {
      try {
        await WhatsappShare.share(
          text: message,
          phone: "919137876370",
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    }

    Navigator.pop(context);
  }
}
