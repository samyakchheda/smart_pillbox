import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home/screens/onboarding/onboarding_screen.dart';
import 'package:home/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageSelectionScreen extends StatefulWidget {
  @override
  _LanguageSelectionScreenState createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? _selectedLanguage;

  // List of available languages with codes and names
  final List<Map<String, String>> _languages = [
    {'code': 'en', 'country': 'US', 'name': 'English'},
    {'code': 'hi', 'country': 'IN', 'name': 'हिंदी'},
    {'code': 'mr', 'country': 'IN', 'name': 'मराठी'},
    {'code': 'gu', 'country': 'IN', 'name': 'ગુજરાતી'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Choose Your Language'),
          backgroundColor: Color(0xFFE0E0E0) // Set your desired color here
          ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _languages.length,
              itemBuilder: (context, index) {
                final language = _languages[index];
                final isSelected = _selectedLanguage == language['code'];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedLanguage = language['code'];
                    });

                    // Set locale based on selected language
                    final locale =
                        Locale(language['code']!, language['country']!);
                    context.setLocale(locale);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? AppColors.buttonColor : Colors.grey,
                        width: 5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: isSelected ? AppColors.kWhiteColor : Colors.white,
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            language['name']!,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonColor, // Blue background
              padding: EdgeInsets.symmetric(
                  horizontal: 32, vertical: 16), // Bigger button
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _selectedLanguage != null
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OnboardingScreen(),
                      ),
                    );
                  }
                : null,
            child: Text(
              'Proceed',
              style: GoogleFonts.poppins(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
