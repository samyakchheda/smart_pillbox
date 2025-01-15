import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

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
      String uid = FirebaseAuth.instance.currentUser!.uid;

      DocumentReference userDocRef = _firestore.collection('users').doc(uid);

      // Fetch the current user document
      DocumentSnapshot userDoc = await userDocRef.get();

      // Convert startDate and endDate to Timestamp
      medicineData['startDate'] = Timestamp.fromDate(
        DateFormat('dd-MM-yyyy').parse(medicineData['startDate']),
      );
      medicineData['endDate'] = Timestamp.fromDate(
        DateFormat('dd-MM-yyyy').parse(medicineData['endDate']),
      );

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

  Future<List<Map<String, dynamic>>> fetchMedicines() async {
    final userId = _firebaseAuth.currentUser?.uid;

    if (userId == null) {
      throw Exception('User is not authenticated.');
    }

    final docSnapshot = await _firestore.collection('users').doc(userId).get();

    if (!docSnapshot.exists) {
      return [];
    }

    final data = docSnapshot.data();
    return List<Map<String, dynamic>>.from(data?['medicines'] ?? []);
  }

  Future<void> saveMedicine(Map<String, dynamic> medicineData) async {
    final userId = _firebaseAuth.currentUser?.uid;

    if (userId == null) {
      throw Exception('User is not authenticated.');
    }

    final docRef = _firestore.collection('users').doc(userId);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      await docRef.set({
        'medicines': [medicineData]
      });
    } else {
      final medicines = List.from(docSnapshot.data()?['medicines'] ?? []);
      final index = medicines
          .indexWhere((medicine) => medicine['id'] == medicineData['id']);
      if (index != -1) {
        medicines[index] = medicineData;
      } else {
        medicines.add(medicineData);
      }
      await docRef.update({'medicines': medicines});
    }
  }

  /// Deletes a specific medicine from the user's document in Firestore
  Future<void> deleteMedicineFromUser(String medicineName) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentReference userDocRef = _firestore.collection('users').doc(uid);
      DocumentSnapshot userDoc = await userDocRef.get();

      if (userDoc.exists) {
        List<dynamic> medicines = userDoc['medicines'] ?? [];

        medicines.removeWhere(
            (medicine) => medicine['medicineName'] == medicineName);

        await userDocRef.update({
          'medicines': medicines,
        });

        print('Medicine deleted from user document');
      } else {
        print('User document not found');
      }
    } catch (e) {
      print('Error deleting medicine: $e');
    }
  }

  /// Updates a specific medicine in the user's document in Firestore
  Future<void> updateMedicineForUser(
      String medicineName, Map<String, dynamic> updatedMedicineData) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentReference userDocRef = _firestore.collection('users').doc(uid);
      DocumentSnapshot userDoc = await userDocRef.get();

      // Convert startDate and endDate to Timestamp
      updatedMedicineData['startDate'] = Timestamp.fromDate(
        DateFormat('dd-MM-yyyy').parse(updatedMedicineData['startDate']),
      );
      updatedMedicineData['endDate'] = Timestamp.fromDate(
        DateFormat('dd-MM-yyyy').parse(updatedMedicineData['endDate']),
      );

      if (userDoc.exists) {
        List<dynamic> medicines = userDoc['medicines'] ?? [];

        // Find the index of the medicine to update
        int medicineIndex = medicines
            .indexWhere((medicine) => medicine['medicineName'] == medicineName);

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

// Future<void> addMedicineToUser(Map<String, dynamic> medicineData) async {
//   try {
//     String uid = FirebaseAuth.instance.currentUser!.uid;
//
//     DocumentReference userDocRef = _firestore.collection('users').doc(uid);
//
//     // Fetch the current user document
//     DocumentSnapshot userDoc = await userDocRef.get();
//
//     // Check if the user document exists
//     if (userDoc.exists) {
//       // Add the medicine to the 'medicines' field in the user's document
//       await userDocRef.update({
//         'medicines': FieldValue.arrayUnion(
//             [medicineData]), // Append medicine data to the array
//       });
//
//       print('Medicine added to user document');
//     } else {
//       print('User document not found');
//     }
//   } catch (e) {
//     print('Error adding medicine: $e');
//   }
// }
//
// Future<List<Map<String, dynamic>>> fetchMedicinesForUser() async {
//   try {
//     String uid = FirebaseAuth.instance.currentUser!.uid;
//
//     // Get the user's document from the 'users' collection
//     DocumentSnapshot userDoc =
//     await _firestore.collection('users').doc(uid).get();
//
//     if (userDoc.exists) {
//       List<dynamic> medicines = userDoc['medicines'] ?? [];
//
//       return medicines.map((medicine) {
//         return {
//           'medicineName': medicine['medicineName'] ?? 'Unknown',
//           'startDate': medicine['startDate'] ?? '',
//           'endDate': medicine['endDate'] ?? '',
//           'doseFrequency': medicine['doseFrequency'] ?? 'Not specified',
//           'medicineTimes': medicine['medicineTimes'] ?? 'Not specified',
//           'selectedDays': medicine['selectedDays'] ?? [],
//         };
//       }).toList();
//     } else {
//       print('User document not found');
//       return [];
//     }
//   } catch (e) {
//     print('Error fetching medicines: $e');
//     return [];
//   }
// }
//
// Future<void> deleteMedicineFromUser(String medicineName) async {
//   try {
//     String uid = FirebaseAuth.instance.currentUser!.uid;
//     DocumentReference userDocRef = _firestore.collection('users').doc(uid);
//     DocumentSnapshot userDoc = await userDocRef.get();
//
//     if (userDoc.exists) {
//       List<dynamic> medicines = userDoc['medicines'] ?? [];
//       medicines.removeWhere(
//               (medicine) => medicine['medicineName'] == medicineName);
//       await userDocRef.update({
//         'medicines': medicines,
//       });
//       print('Medicine deleted from user document');
//     } else {
//       print('User document not found');
//     }
//   } catch (e) {
//     print('Error deleting medicine: $e');
//   }
// }
//
// Future<void> updateMedicineForUser(
//     String medicineName, Map<String, dynamic> updatedMedicineData) async {
//   try {
//     String uid = FirebaseAuth.instance.currentUser!.uid;
//     DocumentReference userDocRef = _firestore.collection('users').doc(uid);
//     DocumentSnapshot userDoc = await userDocRef.get();
//
//     if (userDoc.exists) {
//       List<dynamic> medicines = userDoc['medicines'] ?? [];
//
//       // Find the index of the medicine to update
//       int medicineIndex = medicines
//           .indexWhere((medicine) => medicine['medicineName'] == medicineName);
//
//       if (medicineIndex != -1) {
//         // Update the medicine data
//         medicines[medicineIndex] = updatedMedicineData;
//
//         // Update the user's document with the new medicines list
//         await userDocRef.update({
//           'medicines': medicines,
//         });
//         print('Medicine updated in user document');
//       } else {
//         print('Medicine not found');
//       }
//     } else {
//       print('User document not found');
//     }
//   } catch (e) {
//     print('Error updating medicine: $e');
//   }
// }
