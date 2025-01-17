import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:home/core/widgets/basic_alert_dialog.dart';
import 'package:home/presentation/reminders/medicine_form_screen.dart';

class MedicineListScreen extends StatefulWidget {
  const MedicineListScreen({super.key});

  @override
  _MedicineListScreenState createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _fetchMedicines() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      throw Exception('User is not authenticated.');
    }

    final docSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!docSnapshot.exists) {
      return [];
    }

    return List<Map<String, dynamic>>.from(
        docSnapshot.data()?['medicines'] ?? []);
  }

  String _formatMedicineTimes(List<dynamic> times) {
    if (times.isEmpty) return 'No times added';

    return times.map((time) {
      if (time is Timestamp) {
        return DateFormat('hh:mm a').format(time.toDate());
      } else {
        return time.toString();
      }
    }).join(', ');
  }

  String _formatDate(Timestamp timestamp) {
    return DateFormat('dd-MM-yyyy').format(timestamp.toDate());
  }

  void _navigateToAddMedicine() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MedicineFormScreen(),
      ),
    );
    setState(() {});
  }

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

  Future<void> _confirmAndDeleteMedicine(
      BuildContext context, String medicineName) async {
    final isConfirmed = await showDeleteConfirmationDialog(
      context,
      'Confirm Deletion',
      'Are you sure you want to delete this medicine?',
    );

    if (isConfirmed) {
      await deleteMedicineFromUser(medicineName);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine List'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchMedicines(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            final medicines = snapshot.data ?? [];

            if (medicines.isEmpty) {
              return const Center(
                child: Text('No medicines found. Tap "+" to add one.'),
              );
            }

            return ListView.builder(
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                final medicine = medicines[index];
                final startDate = medicine['startDate'] != null
                    ? _formatDate(medicine['startDate'])
                    : 'N/A';
                final endDate = medicine['endDate'] != null
                    ? _formatDate(medicine['endDate'])
                    : 'N/A';

                return Dismissible(
                  key: Key(medicine['medicineName']),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) async {
                    await _confirmAndDeleteMedicine(
                        context, medicine['medicineName']);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      leading: const Icon(
                        Icons.medical_services_rounded,
                      ),
                      title: Text(
                        medicine['medicineName'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          'Start Date: $startDate\n'
                          'End Date: $endDate\n'
                          'Times: ${_formatMedicineTimes(medicine['medicineTimes'])}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MedicineFormScreen(
                                existingData: medicine,
                              ),
                            ),
                          ).then((value) {
                            if (value != null) {
                              setState(() {});
                            }
                          });
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MedicineFormScreen(),
            ),
          ).then((value) {
            if (value != null) {
              setState(() {});
            }
          });
        },
        tooltip: 'Add New Medicine',
        child: const Icon(Icons.add),
      ),
    );
  }
}
