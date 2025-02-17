import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../helpers/functions/save_user_info.dart';
import '../../../helpers/validators.dart';
import '../../../helpers/date_helper.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_fonts.dart';
import '../../../widgets/my_elevated_button.dart';
import '../../../widgets/my_snack_bar.dart';
import '../../../widgets/my_text_field.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _selectedGender = "";

  void _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateHelper.formatDate(picked);
      });
    }
  }

  void _onGenderSelected(String gender) {
    setState(() {
      _selectedGender = gender;
    });
  }

  void _onNextPressed() async {
    if (_formKey.currentState!.validate() && _selectedGender.isNotEmpty) {
      try {
        await saveUserInfo(
          name: _nameController.text.trim(),
          birthDate: _dobController.text.trim(),
          gender: _selectedGender,
          phoneNumber: _phoneController.text.trim(),
        );

        mySnackBar(context, "Details saved successfully!",
            isError: false, icon: Icons.check_circle);

        // Navigate to the next screen
        Navigator.pushNamed(context, "/profilePicture");
      } catch (e) {
        mySnackBar(context, "Failed to save details. Try again!",
            isError: true, icon: Icons.error);
      }
    } else {
      mySnackBar(context, "Please fill all details correctly!",
          isError: true, icon: Icons.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text("Let's Get to Know You!", style: AppFonts.headline),
        backgroundColor: AppColors.darkBackground,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyTextField(
                  controller: _nameController,
                  hintText: "Enter your name",
                  icon: Icons.person,
                  validator: Validators.validateName,
                  fillColor: AppColors.cardBackground,
                  borderRadius: 50,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _selectDate,
                  child: AbsorbPointer(
                    child: MyTextField(
                      controller: _dobController,
                      hintText: "Select your date of birth",
                      icon: Icons.calendar_today,
                      validator: Validators.validateDOB,
                      fillColor: AppColors.cardBackground,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _genderButton("Male"),
                    _genderButton("Female"),
                    _genderButton("Other"),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity, // Ensures it takes up available space
                  child: IntlPhoneField(
                    controller: _phoneController,
                    initialCountryCode: 'IN',
                    decoration: InputDecoration(
                      hintText: "Enter your phone number",
                      hintStyle: AppFonts.caption,
                      filled: true,
                      fillColor: AppColors.cardBackground,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50)),
                    ),
                    validator: (phone) =>
                        Validators.validatePhone(phone?.completeNumber),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: MyElevatedButton(
                    text: "Next",
                    onPressed: _onNextPressed,
                    backgroundColor: AppColors.buttonColor,
                    textColor: Colors.white,
                    borderRadius: 50,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _genderButton(String gender) {
    return MyElevatedButton(
      text: gender,
      onPressed: () => _onGenderSelected(gender),
      backgroundColor: _selectedGender == gender
          ? AppColors.buttonColor
          : AppColors.darkBackground,
      textColor: _selectedGender == gender
          ? AppColors.buttonText
          : AppColors.textPrimary,
      borderRadius: 50,
    );
  }
}
