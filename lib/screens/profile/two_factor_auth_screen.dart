import 'package:easy_localization/easy_localization.dart';
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
      mySnackBar(context, 'Error fetching 2FA status'.tr(), isError: true);
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
          value
              ? '2FA Enabled Successfully'.tr()
              : '2FA Disabled Successfully'.tr(),
        );
      }
    } catch (e) {
      print('Error updating 2FA status: $e');
      mySnackBar(context, 'Error updating 2FA status. Please try again.'.tr(),
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new,
                    color: AppColors.buttonColor),
                onPressed: widget.onBack,
              ),
              Expanded(
                child: Text(
                  "2-Factor Authentication".tr(),
                  textAlign: TextAlign.center,
                  style: AppFonts.headline,
                ),
              ),
              const SizedBox(width: 48),
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
                    "About 2FA".tr(),
                    style: AppFonts.subHeadline,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.security,
                          color: AppColors.buttonColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Adds extra security with a second verification. "
                              .tr(),
                          style: AppFonts.bodyText.copyWith(
                            color: AppColors.textPlaceholder,
                          ),
                        ),
                      ),
                    ],
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppColors.buttonColor,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                "Enable 2-Factor \nAuthentication".tr(),
                                style: AppFonts.bodyText,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Switch(
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
                          ],
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "How it Works".tr(),
                    style: AppFonts.subHeadline,
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.login,
                              color: AppColors.buttonColor, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "1. Log in with your password".tr(),
                              style: AppFonts.bodyText.copyWith(
                                color: AppColors.textPlaceholder,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.sms,
                              color: AppColors.buttonColor, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "2. Enter code sent via SMS/email".tr(),
                              style: AppFonts.bodyText.copyWith(
                                color: AppColors.textPlaceholder,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle,
                              color: AppColors.buttonColor, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "3. Access your account".tr(),
                              style: AppFonts.bodyText.copyWith(
                                color: AppColors.textPlaceholder,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
