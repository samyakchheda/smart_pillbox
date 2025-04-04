import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const SettingsSection({required this.title, required this.items, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Text(
                title,
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ...items,
          ],
        ),
      ),
    );
  }
}
