import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home/theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TwoFactorAuthScreen extends StatefulWidget {
  final VoidCallback onBack;

  const TwoFactorAuthScreen({super.key, required this.onBack});

  @override
  State<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  bool _is2FAEnabled = false;
  bool _isLoading = true; // Added to handle initial loading state

  @override
  void initState() {
    super.initState();
    _fetch2FAStatus();
  }

  // Fetch initial 2FA status from Firestore
  Future<void> _fetch2FAStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (docSnapshot.exists) {
          setState(() {
            _is2FAEnabled = docSnapshot.data()?['is_otp_enabled'] ?? false;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching 2FA status: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Update 2FA status in Firestore
  Future<void> _update2FAStatus(bool value) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          {'is_otp_enabled': value},
          SetOptions(merge: true), // Merge with existing data
        );
      }
    } catch (e) {
      print('Error updating 2FA status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error updating 2FA status. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: widget.onBack,
              ),
              Expanded(
                child: Text(
                  "2-Factor Authentication",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "About 2FA",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Two-Factor Authentication (2FA) adds an extra layer of security to your account. In addition to your password, you'll need to provide a second form of verification, such as a code sent to your phone or email.",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textPlaceholder,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListTile(
                    title: Text(
                      "Enable 2-Factor Authentication",
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                    trailing: Switch(
                      value: _is2FAEnabled,
                      activeColor: AppColors.buttonColor,
                      onChanged: (value) async {
                        setState(() {
                          _is2FAEnabled = value;
                        });
                        await _update2FAStatus(value);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              value
                                  ? '2FA Enabled Successfully'
                                  : '2FA Disabled Successfully',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "How it Works",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "1. Log in with your username and password\n"
                    "2. Receive a verification code via SMS or email\n"
                    "3. Enter the code to access your account",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textPlaceholder,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
