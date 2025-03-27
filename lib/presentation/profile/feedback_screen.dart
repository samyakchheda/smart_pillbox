import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home/theme/app_colors.dart'; // Assuming this exists in your project
import 'package:flutter_emoji_feedback/flutter_emoji_feedback.dart';

class FeedbackScreen extends StatefulWidget {
  final VoidCallback onBack;

  const FeedbackScreen({required this.onBack, super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController feedbackController = TextEditingController();
  int? selectedRating; // Rating from 1 to 5
  bool isSubmitting = false;

  void _submitFeedback() {
    if (selectedRating != null && feedbackController.text.isNotEmpty) {
      setState(() {
        isSubmitting = true;
      });

      // Simulate feedback submission without storing
      print('Rating: $selectedRating, Feedback: ${feedbackController.text}');

      // You could add additional logic here (e.g., send to an API, log locally, etc.)

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your feedback!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear form after submission
      feedbackController.clear();
      setState(() {
        selectedRating = null;
        isSubmitting = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating and provide feedback'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  void dispose() {
    feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back Button & Title
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: widget.onBack,
                ),
                Expanded(
                  child: Text(
                    "Feedback",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 48), // To balance the Row layout
              ],
            ),
            const SizedBox(height: 10),

            // Feedback Question
            Center(
              child: Text(
                "How was your experience?",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Emoji Feedback Widget from the package
            Center(
              child: EmojiFeedback(
                enableFeedback: true,
                onChangeWaitForAnimation: true,
                animDuration: const Duration(milliseconds: 300),
                emojiPreset: notoAnimatedEmojis, // Using animated emojis
                labelTextStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[700],
                ),
                curve: Curves.easeInOut,
                onChanged: (value) {
                  setState(() {
                    selectedRating = value; // Value ranges from 1 to 5
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            // Text Field for Additional Feedback
            TextField(
              controller: feedbackController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Tell us more about your experience...",
                hintStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button
            Center(
              child: ElevatedButton.icon(
                onPressed: isSubmitting ? null : _submitFeedback,
                icon: const Icon(Icons.send, color: Colors.white),
                label: Text(
                  isSubmitting ? "Submitting..." : "Submit Feedback",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
