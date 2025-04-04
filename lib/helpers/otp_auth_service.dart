import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter/material.dart';

class OtpAuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Gmail SMTP configuration (Replace with your credentials)
  static const String gmailEmail =
      'smartdose.care@gmail.com'; // Replace with your Gmail
  static const String gmailPassword =
      'ozqh lfvf wmfz gbua'; // Replace with your App Password

  bool _showOtpScreen = false;
  bool get showOtpScreen => _showOtpScreen;

  Future<bool> checkOtpEnabled(String userId) async {
    DocumentSnapshot doc =
        await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) {
      print('User document does not exist for UID: $userId');
      return false;
    }
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
    bool isEnabled = data != null && data.containsKey('is_otp_enabled')
        ? data['is_otp_enabled'] as bool
        : false;
    print('OTP Enabled for $userId: $isEnabled');
    return isEnabled;
  }

  Future<void> enableOtp(String userId) async {
    await _firestore.collection('users').doc(userId).set(
      {'is_otp_enabled': true},
      SetOptions(merge: true),
    );
    print('OTP enabled for UID: $userId');
    notifyListeners();
  }

  Future<void> generateAndSendOtp(String email, String userId) async {
    String otp = _generateOtp();
    print('Generated OTP for $userId: $otp');
    await _firestore.collection('otps').doc(userId).set({
      'otp': otp,
      'expires_at': DateTime.now()
          .add(const Duration(seconds: 60))
          .millisecondsSinceEpoch,
    });
    await _sendOtpEmail(email, otp);
    _showOtpScreen = true;
    print('Show OTP Screen set to: $_showOtpScreen');
    notifyListeners();
  }

  Future<bool> verifyOtp(String otp, String userId) async {
    DocumentSnapshot doc =
        await _firestore.collection('otps').doc(userId).get();
    if (doc.exists) {
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      if (data == null ||
          !data.containsKey('otp') ||
          !data.containsKey('expires_at')) {
        throw Exception('Invalid OTP data');
      }
      String storedOtp = data['otp'];
      int expiresAt = data['expires_at'];
      if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
        throw Exception('OTP expired');
      }
      if (storedOtp == otp) {
        await _firestore.collection('otps').doc(userId).delete();
        _showOtpScreen = false;
        print('OTP verified, screen reset');
        notifyListeners();
        return true;
      }
      throw Exception('Invalid OTP');
    }
    throw Exception('No OTP found');
  }

  Future<void> resendOtp(String email, String userId) async {
    await generateAndSendOtp(email, userId);
    print('OTP resent for $userId');
  }

  String _generateOtp() {
    return (100000 + Random().nextInt(900000)).toString(); // 6-digit OTP
  }

  Future<void> _sendOtpEmail(String email, String otp) async {
    final smtpServer = gmail(gmailEmail, gmailPassword);

    final message = Message()
      ..from = const Address(gmailEmail, 'SmartDose')
      ..recipients.add(email)
      ..subject = 'OTP Verification Code'
      ..text = 'Your SmartDose OTP is: $otp\nValid for 60 seconds'
      ..html = '''
        <h3>SmartDose OTP Verification</h3>
        <p>Your one-time verification code is: <strong>$otp</strong></p>
        <p>Valid for 60 seconds</p>
      ''';

    try {
      await send(message, smtpServer);
      print('OTP Email sent successfully to $email');
    } catch (e) {
      print('Failed to send OTP email: $e');
      throw Exception('Failed to send OTP email: $e');
    }
  }

  void resetOtpScreen() {
    _showOtpScreen = false;
    notifyListeners();
  }
}

// OTP Text Field Widget
class OtpTextField extends StatefulWidget {
  final Function(String) onCompleted;

  const OtpTextField({super.key, required this.onCompleted});

  @override
  _OtpTextFieldState createState() => _OtpTextFieldState();
}

class _OtpTextFieldState extends State<OtpTextField> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    String otp = _controllers.map((c) => c.text).join();
    if (otp.length == 6) {
      widget.onCompleted(otp);
    }
  }

  String getOtp() {
    return _controllers.map((c) => c.text).join();
  }

  void clear() {
    for (var controller in _controllers) {
      controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 50,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            decoration: const InputDecoration(
              counterText: '',
              border: OutlineInputBorder(),
              fillColor: Colors.grey, // Adjust based on your AppColors
              filled: true,
            ),
            onChanged: (value) => _onChanged(value, index),
          ),
        );
      }),
    );
  }
}
