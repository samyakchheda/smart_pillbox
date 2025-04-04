import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutUsScreen extends StatelessWidget {
  final VoidCallback onBack;

  const AboutUsScreen({required this.onBack, super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: onBack,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    padding: const EdgeInsets.all(10),
                  ),
                ),
                Expanded(
                  child: Text(
                    "About Us",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.4),
                          offset: const Offset(2, 2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 30),
            Card(
              color: Colors.white.withOpacity(0.95),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 12,
              shadowColor: Colors.black.withOpacity(0.5),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      "At Smart PillBox",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A237E),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "We are dedicated to revolutionizing medication management through cutting-edge technology. "
                      "Our mission is to enhance medication adherence and elevate the quality of life for individuals, "
                      "especially the elderly and those managing chronic conditions.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1A237E),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 12,
              shadowColor: Colors.black.withOpacity(0.5),
              color: Colors.white.withOpacity(0.95),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(Icons.lightbulb,
                          color: Colors.white, size: 34),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        "Our vision is to create a world where medication non-adherence is a thing of the past. "
                        "We empower individuals and caregivers with an intelligent, sleek solution for managing daily medications.",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1A237E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "Why Choose Smart PillBox?",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.4),
                    offset: const Offset(2, 2),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            _featureCard(
                Icons.alarm,
                "Automated Reminders",
                "Never miss a dose with stylish, timely alerts.",
                Colors.redAccent),
            _featureCard(
                Icons.touch_app,
                "User-Friendly Design",
                "Sleek, intuitive, and perfect for all ages.",
                Colors.blueAccent),
            _featureCard(Icons.notifications, "Caregiver Notifications",
                "Stay connected with elegant updates.", Colors.purpleAccent),
            _featureCard(Icons.security, "Secure & Portable",
                "Compact luxury built for your lifestyle.", Colors.greenAccent),
          ],
        ),
      ),
    );
  }

  Widget _featureCard(
      IconData icon, String title, String description, Color accentColor) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 8,
      shadowColor: accentColor.withOpacity(0.6),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [accentColor, accentColor.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A237E),
                    ),
                  ),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
