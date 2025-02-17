class UserModel {
  final String uid;
  final String email;
  final String name;
  final String birthDate;
  final String gender;
  final String phoneNumber;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.birthDate,
    required this.gender,
    required this.phoneNumber,
  });

  /// Convert Firestore document to `UserModel`
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      birthDate: json['birthDate'] ?? '',
      gender: json['gender'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
    );
  }

  /// Convert `UserModel` to Firestore-compatible JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'birthDate': birthDate,
      'gender': gender,
      'phoneNumber': phoneNumber,
    };
  }
}
