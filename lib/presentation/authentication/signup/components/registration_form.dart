import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:home/home_page.dart';
import 'package:home/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../common/widgets/snackbar/basic_snack_bar.dart';

class RegistrationForm extends StatefulWidget {
  final String email;
  const RegistrationForm({required this.email, super.key});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedGender;
  final List<String> _genders = ['Male', 'Female', 'Other'];
  String? _profilePicture;
  final ImagePicker _picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();

  void storeUserDetails() async {
    if (_formKey.currentState?.validate() ?? false) {
      String formattedBirthDate = _selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
          : '';

      String genderString = _selectedGender ?? '';

      String res = await AuthService().storeOtherDetails(
          email: widget.email,
          name: nameController.text,
          birthDate: formattedBirthDate,
          gender: genderString,
          phoneNumber: phoneController.text,
          profilePicture: _profilePicture);

      if (res == "User details stored successfully!" ||
          res == "User details updated successfully!") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => HomePage(),
          ),
        );
      } else {
        showSnackBar(context, res);
      }
    }
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _profilePicture = base64Encode(bytes);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration Form'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                  onTap: _pickImage,
                  child: Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _profilePicture != null
                          ? MemoryImage(base64Decode(_profilePicture!))
                          : const AssetImage(
                                  'assets/icons/ic_default_avatar.jpg')
                              as ImageProvider,
                      child: _profilePicture == null
                          ? const Icon(Icons.add_a_photo,
                              size: 40, color: Colors.white)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter your phone number',
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedGender = newValue;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    hintText: 'Select your gender',
                  ),
                  items: _genders.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your gender';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Birthdate',
                    hintText: _selectedDate == null
                        ? 'Select your birthdate'
                        : '${_selectedDate!.toLocal()}'.split(' ')[0],
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  readOnly: true, // Prevent direct input
                  onTap: () => _selectBirthDate(context),
                  validator: (value) {
                    if (_selectedDate == null) {
                      return 'Please select your birthdate';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: storeUserDetails,
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
