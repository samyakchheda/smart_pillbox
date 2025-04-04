import 'package:flutter/material.dart';
import 'package:home/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui'; // For Glassmorphism effect

class SendIssueScreen extends StatefulWidget {
  const SendIssueScreen({Key? key}) : super(key: key);

  @override
  _SendIssueScreenState createState() => _SendIssueScreenState();
}

class _SendIssueScreenState extends State<SendIssueScreen> {
  final TextEditingController _issueController = TextEditingController();

  void _sendEmail() async {
    final String email = "smartdose.care@gmail.com";
    final String subject =
        Uri.encodeComponent("User Issue Report - SmartPillbox");
    final String body = Uri.encodeComponent(_issueController.text);

    final Uri emailUri = Uri.parse("mailto:$email?subject=$subject&body=$body");

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open email app')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Extends background behind AppBar
      appBar: AppBar(
        title: const Text("Report an Issue"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(color: const Color(0xFFE0E0E0)),
          ),

          // Glassmorphism Card
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white, // Changed to solid white
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: Colors.grey.shade300), // Subtle border
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1), // Light shadow
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Describe Your Issue",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black, // Changed to black
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Input Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100, // Light grey background
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: _issueController,
                        maxLines: 5,
                        style: const TextStyle(
                            color: Colors.black), // Changed to black
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(12),
                          border: InputBorder.none,
                          hintText: "Enter your issue here...",
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Send Button
                    Center(
                      child: ElevatedButton(
                        onPressed: _sendEmail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.buttonColor, // Primary color
                          foregroundColor: Colors.white, // Text color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                        ),
                        child: const Text(
                          "Send Issue",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
