import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class FirebaseServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signUpUser({
    required String email,
    required String password,
  }) async {
    String res = 'Some error occurred';
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        UserCredential credential =
            await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (credential.user != null) {
          await _firestore.collection('users').doc(credential.user!.uid).set({
            'email': email,
            'uid': credential.user!.uid,
          });

          res = await storeOtherDetails(
            email: email,
            name: '',
            birthDate: '',
            gender: '',
            phoneNumber: '',
          );

          res = "success";
        } else {
          res = "Failed to create user.";
        }
      } else {
        res = "Please fill all the fields";
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> storeOtherDetails({
    required String email,
    required String name,
    required String birthDate,
    required String gender,
    required String phoneNumber,
    String? profilePicture,
  }) async {
    String res = "Some error occurred";
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();

      if (userDoc.exists) {
        await FirebaseFirestore.instance.collection("users").doc(uid).update({
          "name": name,
          "gender": gender,
          "birthdate": birthDate,
          "phoneNumber": phoneNumber,
          if (profilePicture != null) "profilePicture": profilePicture,
        });
        res = "User details updated successfully!";
        print("User Details Updated!!!");
      } else {
        await FirebaseFirestore.instance.collection("users").doc(uid).set({
          "email": email,
          "name": name,
          "gender": gender,
          "birthdate": birthDate,
          "phoneNumber": phoneNumber,
          if (profilePicture != null) "profilePicture": profilePicture,
        });
        res = "User details stored successfully!";
        print("User Details Stored!!!");
      }
    } catch (e) {
      print("Error: $e");
      res = e.toString();
    }
    return res;
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = 'Some error occurred';
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        UserCredential credential =
            await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (credential.user != null) {
          res = "success";
        } else {
          res = "Failed to sign in.";
        }
      } else {
        res = "Please fill all the fields";
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<void> updateUserProfile({
    required String name,
    required String gender,
    required String birthdate,
    required String phoneNumber,
  }) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'name': name,
          'gender': gender,
          'birthdate': birthdate,
          'phoneNumber': phoneNumber,
        });
      }
    } catch (e) {
      throw Exception('Error updating user profile: $e');
    }
  }

  Future<String> sendPasswordResetEmail({required String email}) async {
    String res = 'Some error occurred';
    try {
      if (email.isNotEmpty) {
        await _firebaseAuth.sendPasswordResetEmail(email: email);
        res = "success";
      } else {
        res = "Please provide an email address";
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  static Future<String?> changePassword(
      {required String currentPassword,
      required String newPassword,
      required BuildContext context}) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);
        return null;
      }
      return "User not found";
    } catch (e) {
      return "Error : $e";
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> addMedicineToUser(Map<String, dynamic> medicineData) async {
    try {
      String uid = _firebaseAuth.currentUser!.uid;
      DocumentReference userDocRef = _firestore.collection('users').doc(uid);

      // Ensure the dates are in the correct format before converting
      if (medicineData['startDate'] != null &&
          medicineData['endDate'] != null) {
        try {
          medicineData['startDate'] = Timestamp.fromDate(
            DateFormat('dd-MM-yyyy').parse(medicineData['startDate']!),
          );
          medicineData['endDate'] = Timestamp.fromDate(
            DateFormat('dd-MM-yyyy').parse(medicineData['endDate']!),
          );
        } catch (e) {
          print('Date format error: $e');
          return;
        }
      } else {
        print('Start Date or End Date is missing');
        return;
      }

      // Generate a unique UUID for the medicine
      var uuid = const Uuid();
      String medicineId = uuid.v4();
      medicineData['medicineId'] = medicineId; // Add unique ID

      // Fetch the current user document
      DocumentSnapshot userDoc = await userDocRef.get();

      if (userDoc.exists) {
        // Add the medicine to the 'medicines' field in the user's document
        await userDocRef.update({
          'medicines': FieldValue.arrayUnion([medicineData]),
        });
        print('Medicine added to user document');
      } else {
        // Create the user document with medicines field
        await userDocRef.set({
          'medicines': [medicineData],
        });
        print('User document created and medicine added');
      }
    } catch (e) {
      print('Error adding medicine: $e');
    }
  }

  Future<void> deleteMedicineFromUser(String medicineId) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentReference userDocRef = _firestore.collection('users').doc(uid);
      DocumentSnapshot userDoc = await userDocRef.get();

      if (userDoc.exists) {
        List<dynamic> medicines = userDoc['medicines'] ?? [];

        print('Medicines before deletion: $medicines');

        medicines
            .removeWhere((medicine) => medicine['medicineId'] == medicineId);

        print('Medicines after deletion: $medicines');

        await userDocRef.update({
          'medicines': medicines,
        });

        print('Medicine deleted from user document');
      } else {
        print('User document not found');
      }
    } catch (e) {
      print('Error deleting medicine: $e');
      rethrow;
    }
  }

  Future<void> updateMedicineForUser(
      String medicineId, Map<String, dynamic> updatedMedicineData) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentReference userDocRef = _firestore.collection('users').doc(uid);
      DocumentSnapshot userDoc = await userDocRef.get();

      if (updatedMedicineData['startDate'] != null &&
          updatedMedicineData['endDate'] != null) {
        try {
          updatedMedicineData['startDate'] = Timestamp.fromDate(
            DateFormat('dd-MM-yyyy').parse(updatedMedicineData['startDate']),
          );
          updatedMedicineData['endDate'] = Timestamp.fromDate(
            DateFormat('dd-MM-yyyy').parse(updatedMedicineData['endDate']),
          );
        } catch (e) {
          print('Date format error: $e');
          return;
        }
      } else {
        print('Start Date or End Date is missing');
        return;
      }

      if (userDoc.exists) {
        List<dynamic> medicines = userDoc['medicines'] ?? [];

        // Find the index of the medicine to update
        int medicineIndex = medicines
            .indexWhere((medicine) => medicine['medicineId'] == medicineId);

        if (medicineIndex != -1) {
          // Update the medicine data
          medicines[medicineIndex] = updatedMedicineData;

          // Update the user's document with the new medicines list
          await userDocRef.update({
            'medicines': medicines,
          });

          print('Medicine updated in user document');
        } else {
          print('Medicine not found');
        }
      } else {
        print('User document not found');
      }
    } catch (e) {
      print('Error updating medicine: $e');
    }
  }
}
