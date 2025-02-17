import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'firebase_service.dart';

class MedicineService {
  // Singleton pattern to avoid multiple instances
  static final MedicineService _instance = MedicineService._internal();
  factory MedicineService() => _instance;
  MedicineService._internal();

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseService.instance.firestore;
  final FirebaseAuth _firebaseAuth = FirebaseService.instance.firebaseAuth;

  /// **Add Medicine to User**
  Future<void> addMedicineToUser(Map<String, dynamic> medicineData) async {
    try {
      String? uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) {
        print("User not authenticated");
        return;
      }
      DocumentReference userDocRef = _firestore.collection('users').doc(uid);

      // Ensure dates are properly formatted
      if (medicineData['startDate'] != null &&
          medicineData['endDate'] != null) {
        try {
          medicineData['startDate'] = Timestamp.fromDate(
            DateFormat('dd-MM-yyyy').parse(medicineData['startDate']),
          );
          medicineData['endDate'] = Timestamp.fromDate(
            DateFormat('dd-MM-yyyy').parse(medicineData['endDate']),
          );
        } catch (e) {
          print('Date format error: $e');
          return;
        }
      } else {
        print('Start Date or End Date is missing');
        return;
      }

      // Generate unique ID
      String medicineId = const Uuid().v4();
      medicineData['medicineId'] = medicineId;

      // Fetch user document
      DocumentSnapshot userDoc = await userDocRef.get();

      if (userDoc.exists) {
        await userDocRef.update({
          'medicines': FieldValue.arrayUnion([medicineData]),
        });
        print('Medicine added');
      } else {
        await userDocRef.set({
          'medicines': [medicineData],
        });
        print('User document created and medicine added');
      }
    } catch (e) {
      print('Error adding medicine: $e');
    }
  }

  /// **Delete Medicine from User**
  Future<void> deleteMedicineFromUser(String medicineId) async {
    try {
      String? uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) {
        print("User not authenticated");
        return;
      }
      DocumentReference userDocRef = _firestore.collection('users').doc(uid);
      DocumentSnapshot userDoc = await userDocRef.get();

      if (userDoc.exists) {
        List<dynamic> medicines = List.from(userDoc['medicines'] ?? []);

        medicines
            .removeWhere((medicine) => medicine['medicineId'] == medicineId);

        await userDocRef.update({
          'medicines': medicines,
        });

        print('Medicine deleted');
      } else {
        print('User document not found');
      }
    } catch (e) {
      print('Error deleting medicine: $e');
    }
  }

  /// **Update Medicine in User's List**
  Future<void> updateMedicineForUser(
      String medicineId, Map<String, dynamic> updatedMedicineData) async {
    try {
      String? uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) {
        print("User not authenticated");
        return;
      }
      DocumentReference userDocRef = _firestore.collection('users').doc(uid);
      DocumentSnapshot userDoc = await userDocRef.get();

      // Validate and convert dates
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
        List<dynamic> medicines = List.from(userDoc['medicines'] ?? []);

        // Find the index of the medicine
        int medicineIndex = medicines
            .indexWhere((medicine) => medicine['medicineId'] == medicineId);

        if (medicineIndex != -1) {
          // Update medicine details
          medicines[medicineIndex] = updatedMedicineData;

          // Save updated list
          await userDocRef.update({
            'medicines': medicines,
          });

          print('Medicine updated');
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
