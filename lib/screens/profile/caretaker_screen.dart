import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home/theme/app_colors.dart';
import 'package:home/widgets/common/my_elevated_button.dart';
import 'package:home/widgets/common/my_text_field.dart';

class CaretakerScreen extends StatefulWidget {
  final VoidCallback onBack;

  const CaretakerScreen({required this.onBack, super.key});

  @override
  State<CaretakerScreen> createState() => _CaretakerScreenState();
}

class _CaretakerScreenState extends State<CaretakerScreen> {
  final TextEditingController _emailController = TextEditingController();

  Future<void> _addCaretakerEmail() async {
    String email = _emailController.text.trim();
    if (email.isNotEmpty) {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        if (email.toLowerCase() == currentUser.email?.trim().toLowerCase()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("You cannot add your own email as caretaker."),
                backgroundColor: Colors.red),
          );
          return;
        }
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        Map<String, dynamic> data =
            userDoc.data() as Map<String, dynamic>? ?? {};
        List<dynamic> caretakerEmails = data['caretakers'] ?? [];
        if (caretakerEmails.contains(email.toLowerCase())) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Caretaker email already added."),
                backgroundColor: Colors.red),
          );
          return;
        }
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
          'caretakers': FieldValue.arrayUnion([email.toLowerCase()])
        });
        await FirebaseFirestore.instance.collection('caretakers').add({
          'email': email.toLowerCase(),
          'patient': currentUser.email?.trim().toLowerCase() ?? '',
        });
        _emailController.clear();
      }
    }
  }

  Future<void> _removeCaretakerEmail(String email) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'caretakers': FieldValue.arrayRemove([email.toLowerCase()])
      });
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('caretakers')
          .where('email', isEqualTo: email.toLowerCase())
          .where('patient',
              isEqualTo: currentUser.email?.trim().toLowerCase() ?? '')
          .get();
      for (var doc in query.docs) {
        await doc.reference.delete();
      }
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
                icon: Icon(Icons.arrow_back, color: AppColors.buttonColor),
                onPressed: widget.onBack,
              ),
              Text(
                "Caretakers",
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          MyTextField(
            icon: Icons.email,
            controller: _emailController,
            hintText: "Add Caretaker Email",
            borderRadius: 50,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 35),
          Center(
            child: MyElevatedButton(
              text: "Add Caretaker",
              onPressed: () async {
                await _addCaretakerEmail();
                setState(() {});
              },
              borderRadius: 50,
              backgroundColor: AppColors.buttonColor,
              textColor: AppColors.kWhiteColor,
              textStyle: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
            ),
            // child: ElevatedButton(
            //   style:
            //       ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            //   onPressed: () async {
            //     await _addCaretakerEmail();
            //     setState(() {});
            //   },
            //   child: Text(
            //     "Add Caretaker",
            //     style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
            //   ),
            // ),
          ),
          const SizedBox(height: 30),
          Text(
            "Caretaker Emails:",
            style:
                GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data?.data() == null) {
                return Center(
                  child: Text(
                    "No caretakers added",
                    style:
                        GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                  ),
                );
              }
              Map<String, dynamic> data =
                  snapshot.data!.data() as Map<String, dynamic>;
              List<dynamic> caretakerEmails = data['caretakers'] ?? [];
              if (caretakerEmails.isEmpty) {
                return Center(
                  child: Text(
                    "No caretakers added",
                    style:
                        GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                  ),
                );
              }
              return Column(
                children: caretakerEmails.map((email) {
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: const Icon(Icons.email, color: Colors.blue),
                      title: Text(email.toString(),
                          style: GoogleFonts.poppins(fontSize: 16)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _removeCaretakerEmail(email.toString());
                          setState(() {});
                        },
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
