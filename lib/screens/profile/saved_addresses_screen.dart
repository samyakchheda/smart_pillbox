import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:home/theme/app_colors.dart';
import 'package:home/widgets/common/my_text_field.dart';
import 'package:home/widgets/common/my_elevated_button.dart';

class SavedAddressesScreen extends StatefulWidget {
  final VoidCallback onBack;

  const SavedAddressesScreen({required this.onBack, super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;
  List<String> tags = ["Home", "Work", "Other"];

  CollectionReference get _addressesRef =>
      _firestore.collection('users').doc(_user!.uid).collection('addresses');

  void _showEditAddressDialog({String? docId, Map<String, dynamic>? address}) {
    final buildingController = TextEditingController();
    final address1Controller = TextEditingController();
    final address2Controller = TextEditingController();
    final newTagController = TextEditingController();
    String selectedTag = "Home";

    if (address != null) {
      buildingController.text = address["building"] ?? '';
      address1Controller.text = address["address1"] ?? '';
      address2Controller.text = address["address2"] ?? '';
      selectedTag = address["tag"] ?? 'Home';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(docId == null ? "Add New Address" : "Edit Address",
                            style: GoogleFonts.poppins(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    MyTextField(
                      controller: buildingController,
                      hintText: "Building Name & Room Number",
                      borderRadius: 8.0,
                    ),
                    const SizedBox(height: 10),
                    MyTextField(
                      controller: address1Controller,
                      hintText: "Address Line 1",
                      borderRadius: 8.0,
                    ),
                    const SizedBox(height: 10),
                    MyTextField(
                      controller: address2Controller,
                      hintText: "Address Line 2",
                      borderRadius: 8.0,
                    ),
                    const SizedBox(height: 15),
                    Wrap(
                      spacing: 10,
                      children: tags.map((tag) {
                        return ChoiceChip(
                          label: Text(tag,
                              style: GoogleFonts.poppins(fontSize: 14)),
                          selected: selectedTag == tag,
                          selectedColor: AppColors.buttonColor,
                          backgroundColor: Colors.grey[300],
                          onSelected: (bool selected) {
                            setModalState(() {
                              selectedTag = selected ? tag : selectedTag;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 15),
                    MyTextField(
                      controller: newTagController,
                      hintText: "New Tag (Optional)",
                      borderRadius: 8.0,
                      icon: Icons.add,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          setState(() {
                            tags.add(value);
                            selectedTag = value;
                            newTagController.clear();
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    MyElevatedButton(
                      text: docId == null ? "Add Address" : "Save Changes",
                      backgroundColor: AppColors.buttonColor,
                      onPressed: () async {
                        if (buildingController.text.isNotEmpty &&
                            address1Controller.text.isNotEmpty) {
                          Map<String, String> newAddress = {
                            "building": buildingController.text,
                            "address1": address1Controller.text,
                            "address2": address2Controller.text,
                            "tag": selectedTag,
                          };

                          try {
                            if (docId == null) {
                              await _addressesRef.add(newAddress);
                            } else {
                              await _addressesRef.doc(docId).update(newAddress);
                            }
                            Navigator.pop(context);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')));
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Center(child: Text('Please sign in to view addresses'));
    }

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: widget.onBack,
              ),
              Text("Saved Addresses",
                  style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          Flexible(
            child: StreamBuilder<QuerySnapshot>(
              stream: _addressesRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final addresses = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    final address =
                        addresses[index].data() as Map<String, dynamic>;
                    final docId = addresses[index].id;

                    return Dismissible(
                      key: Key(docId),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) async {
                        try {
                          await _addressesRef.doc(docId).delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Address deleted successfully')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Error deleting address: $e')),
                          );
                        }
                      },
                      child: Card(
                        color: Colors.white,
                        child: ListTile(
                          title: Text("${address["building"]}"),
                          subtitle: Text(
                              "${address["address1"]}, ${address["address2"]}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit,
                                color: AppColors.buttonColor),
                            onPressed: () => _showEditAddressDialog(
                              docId: docId,
                              address: address,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MyElevatedButton(
              borderRadius: 50,
              text: "Add Address",
              height: 50,
              backgroundColor: AppColors.buttonColor,
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () => _showEditAddressDialog(),
            ),
          ),
        ],
      ),
    );
  }
}
