import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

class ContactUsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const ContactUsScreen({super.key, required this.onBack});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Function to launch URLs
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not launch $url")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                    onPressed: widget.onBack,
                  ),
                  Expanded(
                    child: Text(
                      "Contact Us",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                "Get in Touch",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black.withOpacity(0.8),
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
              const SizedBox(height: 8),
              Text(
                "We’re here to help—reach out anytime.",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black.withOpacity(0.6),
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
              const SizedBox(height: 32),
              _buildContactOptions(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactOptions() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildContactCard(
              icon: Icons.email_outlined,
              title: "Email Us",
              subtitle: "smartdose.care@gmail.com",
              onTap: () {
                _launchUrl(
                    'mailto:smartdose.care@gmail.com?subject=Contact%20Us');
              },
            ),
            _buildContactCard(
              icon: Icons.phone_outlined,
              title: "Call Us",
              subtitle: "+91 123 456 7890",
              onTap: () {
                _launchUrl('tel:+911234567890');
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildContactCard(
              icon: Icons.chat_bubble_outline,
              title: "Live Chat",
              subtitle: "Chat with us now",
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Chat feature coming soon!")),
                );
              },
            ),
            _buildContactCard(
              icon: Icons.location_on_outlined,
              title: "Visit Us",
              subtitle:
                  "SVKM's SBMPCOE, Irla, Suvarna Nagar, Vile Parle, Mumbai, Maharashtra 400056",
              onTap: () {
                _launchUrl(
                    'https://www.google.com/maps/search/?api=1&query=SVKM"s Shri Bhagubhai Mafatlal Polytechnic and College of Engineering');
              },
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 400.ms, duration: 600.ms);
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            border: Border.all(
              color: _isHovered
                  ? Colors.black.withOpacity(0.8)
                  : Colors.black.withOpacity(0.3),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: Colors.black),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.black.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
