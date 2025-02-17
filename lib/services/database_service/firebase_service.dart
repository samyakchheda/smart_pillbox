import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  // Private constructor to enforce singleton pattern
  FirebaseService._();

  // Singleton instance
  static final FirebaseService instance = FirebaseService._();

  // Firebase Instances
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
}
