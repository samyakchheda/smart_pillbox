import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:home/services/notifications_service.dart';

Future<void> checkMedicineTimes(String userId) async {
  try {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!documentSnapshot.exists) return;

    Map<String, dynamic>? userData =
        documentSnapshot.data() as Map<String, dynamic>?;

    if (userData == null) return;

    List<dynamic> medicines = userData['medicines'] ?? [];
    String? fcmToken =
        userData['deviceToken'] ?? await FirebaseMessaging.instance.getToken();

    if (fcmToken == null) return;

    for (var medicine in medicines) {
      String medicineName = medicine['name'] ?? 'Unnamed medicine';
      List<dynamic> times = medicine['times'] ?? [];

      for (var timeStamp in times) {
        if (timeStamp is Timestamp) {
          DateTime medicineTime = timeStamp.toDate();

          String notificationId =
              '$medicineName-${medicineTime.toIso8601String()}';

          await NotificationHelper.scheduleMedicineReminder(
            medicineTime,
            "Medicine Reminder",
            "It's time to take your medicine: $medicineName",
            notificationId: notificationId,
          );

          await NotificationHelper().sendNotificationToBackend(
            fcmToken,
            "Medicine Reminder",
            "It's time to take your medicine: $medicineName",
          );
        }
      }
    }
  } catch (error) {
    print("[ERROR] Error checking medicine times: $error");
  }
}
