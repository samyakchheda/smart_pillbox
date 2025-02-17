import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save or Update User Details in Firestore
  Future<void> saveUserDetails(UserModel user) async {
    try {
      await _firestore.collection("users").doc(user.uid).set(
            user.toJson(),
            SetOptions(merge: true), // ✅ Merges instead of overwriting
          );
      print("✅ User details stored/updated successfully!");
    } catch (e) {
      print("❌ Error in saveUserDetails: $e");
      throw Exception("Failed to save user details");
    }
  }

  /// Fetch User Details
  Future<UserModel?> getUserDetails(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection("users").doc(uid).get();

      if (userDoc.exists) {
        return UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("❌ Error fetching user details: $e");
      throw Exception("Failed to fetch user details");
    }
  }
}
