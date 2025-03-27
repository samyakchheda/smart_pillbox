import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class CaretakerScreen extends StatefulWidget {
  final VoidCallback onBack;

  const CaretakerScreen({required this.onBack, super.key});

  @override
  State<CaretakerScreen> createState() => _CaretakerScreenState();
}

class _CaretakerScreenState extends State<CaretakerScreen> {
  final TextEditingController _emailController = TextEditingController();

  // Add caretaker email and update Firestore.
  Future<void> _addCaretakerEmail() async {
    String email = _emailController.text.trim().toLowerCase();
    if (email.isNotEmpty) {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Prevent adding the current user's email as a caretaker.
        if (email == currentUser.email?.trim().toLowerCase()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("You cannot add your own email as caretaker."),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Check if the caretaker email is already registered as a user.
        QuerySnapshot userQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();
        if (userQuery.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "Cannot add caretaker: email is already registered as a user."),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Check for duplicate caretaker email in the current user's document.
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        Map<String, dynamic> data =
            userDoc.data() as Map<String, dynamic>? ?? {};
        List<dynamic> caretakerEmails = data['caretakers'] ?? [];
        if (caretakerEmails.contains(email)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Caretaker email already added."),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Check if this email is already assigned as a caretaker for any patient.
        QuerySnapshot caretakerQuery = await FirebaseFirestore.instance
            .collection('caretakers')
            .where('email', isEqualTo: email)
            .get();
        if (caretakerQuery.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("This email is already assigned as a caretaker."),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Update the current user's "caretakers" array.
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
          'caretakers': FieldValue.arrayUnion([email])
        });

        // Add an entry in the "caretakers" collection to link the caretaker with the patient.
        await FirebaseFirestore.instance.collection('caretakers').add({
          'email': email,
          'patient': currentUser.email?.trim().toLowerCase() ?? '',
          'deviceToken': "",
        });

        _emailController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Caretaker added successfully."),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  // Remove caretaker email and update Firestore.
  Future<void> _removeCaretakerEmail(String email) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'caretakers': FieldValue.arrayRemove([email.toLowerCase()])
      });
      // Query and delete matching caretaker document(s) from the "caretakers" collection.
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
                icon: const Icon(Icons.arrow_back, color: Colors.black),
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
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
                labelText: "Add Caretaker Email", border: OutlineInputBorder()),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              onPressed: () async {
                await _addCaretakerEmail();
                setState(() {});
              },
              child: Text(
                "Add Caretaker",
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
              ),
            ),
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
