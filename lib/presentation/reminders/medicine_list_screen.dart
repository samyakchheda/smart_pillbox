import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'medicine_form_screen.dart';

class MedicineListScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
  GlobalKey<ScaffoldMessengerState>();
  MedicineListScreen({super.key});

  Future<void> deleteMedicine(String medicineId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return;
    }

    final docRef = _firestore.collection('users').doc(userId);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      return;
    }

    final medicines = List.from(docSnapshot.data()?['medicines'] ?? []);

    final medicineIndex =
    medicines.indexWhere((medicine) => medicine['id'] == medicineId);
    if (medicineIndex != -1) {
      medicines.removeAt(medicineIndex);
      await docRef.update({'medicines': medicines});
    }
  }

  String formatDate(Timestamp timestamp) {
    return DateFormat('dd-MM-yyyy').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not authenticated'),
        ),
      );
    }

    return Scaffold(
      key: scaffoldMessengerKey,
      appBar: AppBar(
        title: const Text('My Medicines'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('users').doc(userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
                child: Text('No medicines found. Click "+" to add one.'));
          }

          var userDoc = snapshot.data;
          List<dynamic> medicines = userDoc!['medicines'] ?? [];

          if (medicines.isEmpty) {
            return const Center(
                child: Text('No medicines found. Click "+" to add one.'));
          }

          return ListView.builder(
            itemCount: medicines.length,
            itemBuilder: (context, index) {
              var medicine = medicines[index];
              String startDate = formatDate(medicine['startDate']);
              String endDate = formatDate(medicine['endDate']);

              return Dismissible(
                key: Key(medicine['id']),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) async {
                  await deleteMedicine(medicine['id']);
                  scaffoldMessengerKey.currentState?.showSnackBar(
                    SnackBar(content: Text('${medicine['medicineNames'].first} deleted.')),
                  );
                },
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirm Deletion'),
                      content: Text(
                          'Are you sure you want to delete ${medicine['medicineNames'].first}?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  margin:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Wrap(
                      spacing: 8.0,
                      children: medicine['medicineNames']
                          ?.map<Widget>((name) => Text(
                        name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ))
                          .toList() ??
                          [const Text('Unnamed')],
                    ),
                    subtitle: Text('Start: $startDate\nEnd: $endDate'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MedicineFormScreen(
                              existingData: medicine,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MedicineFormScreen(),
            ),
          );
        },
        tooltip: 'Add Medicine',
        child: const Icon(Icons.add),
      ),
    );
  }
}
