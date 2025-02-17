import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';
import '../../services/database_service/user_service.dart';

Future<void> saveUserInfo({
  required String name,
  required String birthDate,
  required String gender,
  required String phoneNumber,
}) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print("❌ No authenticated user found!");
    return;
  }

  UserModel userModel = UserModel(
    uid: user.uid,
    email: user.email ?? '',
    name: name,
    birthDate: birthDate,
    gender: gender,
    phoneNumber: phoneNumber,
  );

  await UserService().saveUserDetails(userModel);
}
