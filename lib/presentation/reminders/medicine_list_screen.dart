import 'package:flutter/material.dart';
import 'package:smart_pillbox/services/firebase_services.dart';
import '../../core/widgets/basic_alert_dialog.dart';
import 'medicine_form_screen.dart';

class MedicineListScreen extends StatefulWidget {
  const MedicineListScreen({super.key});

  @override
  _MedicineListScreenState createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  late Future<List<Map<String, dynamic>>> medicines;

  @override
  void initState() {
    super.initState();
    medicines = FirebaseServices().fetchMedicinesForUser();
  }

  void _deleteMedicine(String id) async {
    bool isConfirmed = await showDeleteConfirmationDialog(context,
        'Confirm Deletion', 'Are you sure you want to delete this medicine?');
    if (isConfirmed) {
      await FirebaseServices().deleteMedicineFromUser(id);
      setState(() {
        medicines = FirebaseServices().fetchMedicinesForUser(); // Refresh the list
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine List'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        // FutureBuilder to load medicines
        future: medicines,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading medicines'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No medicines available'));
          } else {
            final medicinesList = snapshot.data!;

            return ListView.builder(
              itemCount: medicinesList.length,
              itemBuilder: (context, index) {
                final medicine = medicinesList[index];

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                      medicine['medicineName'],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text(
                        'Start Date: ${medicine['startDate']}\nEnd Date: ${medicine['endDate']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MedicineFormScreen(
                                  existingData: medicine,
                                ),
                              ),
                            ).then((_) {
                              setState(() {
                                medicines = FirebaseServices()
                                    .fetchMedicinesForUser(); // Refresh the list
                              });
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteMedicine(medicine['id']);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
              const MedicineFormScreen(), // For adding new medicine
            ),
          ).then((_) {
            setState(() {
              medicines = FirebaseServices().fetchMedicinesForUser();
// Refresh the list after adding a new medicine
            });
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
