import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutUsScreen extends StatelessWidget {
  final VoidCallback onBack;

  const AboutUsScreen({required this.onBack, super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: onBack,
                ),
                Expanded(
                  child: Text(
                    "About Us",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  'assets/images/about_us.jpg',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "At Smart PillBox, we are dedicated to revolutionizing medication management through innovative technology. "
                  "Our mission is to enhance medication adherence and improve the quality of life for individuals, "
                  "especially the elderly and those managing chronic conditions.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb,
                        color: Colors.blueAccent, size: 30),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Our vision is to create a world where medication non-adherence is no longer a health risk. "
                        "We strive to empower individuals and caregivers with an intelligent, user-friendly solution for managing daily medications.",
                        style: GoogleFonts.poppins(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Why Choose Smart PillBox?",
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _featureCard(Icons.alarm, "Automated Reminders",
                "Never forget a dose with timely alerts."),
            _featureCard(Icons.touch_app, "User-Friendly Design",
                "Easy to set up and use for all age groups."),
            _featureCard(Icons.notifications, "Caregiver Notifications",
                "Keep loved ones informed about adherence."),
            _featureCard(Icons.security, "Secure & Portable",
                "Compact, reliable, and built for everyday use."),
          ],
        ),
      ),
    );
  }

  Widget _featureCard(IconData icon, String title, String description) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.green, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(description, style: GoogleFonts.poppins(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
