import 'package:flutter/material.dart';
import 'package:home/theme/app_colors.dart';
import 'package:home/theme/app_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home/widgets/common/my_snack_bar.dart';

class TwoFactorAuthScreen extends StatefulWidget {
  final VoidCallback onBack;

  const TwoFactorAuthScreen({super.key, required this.onBack});

  @override
  State<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  bool _is2FAEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetch2FAStatus();
  }

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
      mySnackBar(context, 'Error fetching 2FA status', isError: true);
    }
  }

  Future<void> _update2FAStatus(bool value) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          {'is_otp_enabled': value},
          SetOptions(merge: true),
        );
        mySnackBar(
          context,
          value ? '2FA Enabled Successfully' : '2FA Disabled Successfully',
        );
      }
    } catch (e) {
      print('Error updating 2FA status: $e');
      mySnackBar(context, 'Error updating 2FA status. Please try again.',
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background, // Theme-aware background
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.buttonColor),
                onPressed: widget.onBack,
              ),
              Expanded(
                child: Text(
                  "2-Factor Authentication",
                  textAlign: TextAlign.center,
                  style: AppFonts.headline,
                ),
              ),
              const SizedBox(width: 48), // Spacer for alignment
            ],
          ),
          const SizedBox(height: 20),
          Card(
            color: AppColors.cardBackground,
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
                    style: AppFonts.subHeadline,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Two-Factor Authentication (2FA) adds an extra layer of security to your account. In addition to your password, you'll need to provide a second form of verification, such as a code sent to your phone or email.",
                    style: AppFonts.bodyText.copyWith(
                      color: AppColors.textPlaceholder,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            color: AppColors.cardBackground,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.buttonColor,
                    ),
                  )
                : ListTile(
                    title: Text(
                      "Enable 2-Factor Authentication",
                      style: AppFonts.bodyText,
                    ),
                    trailing: Switch(
                      value: _is2FAEnabled,
                      activeColor: AppColors.buttonColor,
                      inactiveThumbColor: AppColors.textPlaceholder,
                      inactiveTrackColor:
                          AppColors.textPlaceholder.withOpacity(0.5),
                      onChanged: (value) async {
                        setState(() {
                          _is2FAEnabled = value;
                        });
                        await _update2FAStatus(value);
                      },
                    ),
                  ),
          ),
          const SizedBox(height: 20),
          Card(
            color: AppColors.cardBackground,
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
                    style: AppFonts.subHeadline,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "1. Log in with your username and password\n"
                    "2. Receive a verification code via SMS or email\n"
                    "3. Enter the code to access your account",
                    style: AppFonts.bodyText.copyWith(
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
