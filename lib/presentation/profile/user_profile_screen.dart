// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'edit_profile_screen.dart';
// import 'password/change_password_screen.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:convert';
//
// class UserProfileScreen extends StatefulWidget {
//   const UserProfileScreen({super.key});
//
//   @override
//   State<UserProfileScreen> createState() => _UserProfileScreenState();
// }
//
// class _UserProfileScreenState extends State<UserProfileScreen> {
//   String? _profilePictureBase64;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchUserProfile();
//   }
//
//   void _fetchUserProfile() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       final docSnapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .get();
//
//       if (docSnapshot.exists) {
//         setState(() {
//           _profilePictureBase64 = docSnapshot.data()?['profilePicture'];
//         });
//       }
//     }
//   }
//
//   Future<void> _updateProfilePicture(String base64Image) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .update({'profilePicture': base64Image});
//       setState(() {
//         _profilePictureBase64 = base64Image;
//       });
//     }
//   }
//
//   Future<void> _pickImage() async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? image = await picker.pickImage(source: ImageSource.gallery);
//     if (image != null) {
//       final bytes = await image.readAsBytes();
//       String base64Image = base64Encode(bytes);
//       _updateProfilePicture(base64Image);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(top: 100),
//             child: Center(
//               child: GestureDetector(
//                 onTap: _pickImage,
//                 child: CircleAvatar(
//                   radius: 60,
//                   backgroundColor: Colors.grey.shade300,
//                   backgroundImage: _profilePictureBase64 != null
//                       ? MemoryImage(base64Decode(_profilePictureBase64!))
//                       : const AssetImage('assets/icons/ic_default_avatar.jpg')
//                           as ImageProvider,
//                   child: _profilePictureBase64 == null
//                       ? const Icon(
//                           Icons.person,
//                           size: 50,
//                           color: Colors.white,
//                         )
//                       : null,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 18),
//           const Divider(height: 40, thickness: 1),
//           ListTile(
//             leading: const CircleAvatar(
//               backgroundColor: Colors.white,
//               child: Icon(
//                 Icons.edit,
//                 color: Colors.black,
//               ),
//             ),
//             title: const Text('Edit Profile'),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => const EditProfileScreen()),
//               );
//             },
//             trailing: const Icon(Icons.arrow_forward_ios, size: 20),
//           ),
//           ListTile(
//             leading: const CircleAvatar(
//               backgroundColor: Colors.white,
//               child: Icon(
//                 Icons.lock,
//                 color: Colors.black,
//               ),
//             ),
//             title: const Text('Change Password'),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => const ChangePasswordScreen()),
//               );
//             },
//             trailing: const Icon(Icons.arrow_forward_ios, size: 20),
//           ),
//           ListTile(
//             leading: const CircleAvatar(
//               backgroundColor: Colors.white,
//               child: Icon(
//                 Icons.logout,
//                 color: Colors.black,
//               ),
//             ),
//             title: const Text('Logout'),
//             onTap: () async {
//               await FirebaseAuth.instance.signOut();
//               Navigator.of(context).pushReplacementNamed('/');
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_screen.dart';
import 'password/change_password_screen.dart';
import 'dart:convert';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String? _profilePictureBase64;
  String? _userName;
  String? _userEmail;
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  void _fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (docSnapshot.exists) {
        setState(() {
          _profilePictureBase64 = docSnapshot.data()?['profilePicture'];
          _userName = docSnapshot.data()?['name'] ?? 'User Name';
          _userEmail = user.email ?? 'email@example.com';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 40),
              child: Center(
                child: Text(
                  'Profile Settings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: _profilePictureBase64 != null
                        ? MemoryImage(base64Decode(_profilePictureBase64!))
                        : const AssetImage('assets/icons/ic_default_avatar.jpg')
                            as ImageProvider,
                    child: _profilePictureBase64 == null
                        ? const Icon(Icons.person,
                            size: 30, color: Colors.white)
                        : null,
                  ),
                  title: Text(
                    _userName ?? 'User Name',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    _userEmail ?? 'email@example.com',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                      child: Text(
                        'General',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.edit, color: Colors.black),
                      title: const Text('Edit Profile'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const EditProfileScreen()),
                        );
                      },
                      trailing: const Icon(Icons.arrow_forward_ios, size: 20),
                    ),
                    ListTile(
                      leading: const Icon(Icons.lock, color: Colors.black),
                      title: const Text('Change Password'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ChangePasswordScreen()),
                        );
                      },
                      trailing: const Icon(Icons.arrow_forward_ios, size: 20),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                      child: Text(
                        'Preferences',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                    ),
                    ListTile(
                      leading:
                          const Icon(Icons.notifications, color: Colors.black),
                      title: const Text('Notifications'),
                      trailing: Switch(
                        value: _notificationsEnabled,
                        onChanged: (bool value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.black),
                      title: const Text('Logout'),
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushReplacementNamed('/');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
