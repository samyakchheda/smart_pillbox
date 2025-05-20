import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home/screens/onboarding/onboarding_screen.dart';
import 'package:home/theme/app_colors.dart';
import 'package:home/theme/theme_provider.dart';
import 'package:home/widgets/common/my_elevated_button.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  _LanguageSelectionScreenState createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? _selectedLanguage;

  // List of available languages with codes and names
  final List<Map<String, String>> _languages = [
    {'code': 'en', 'country': 'US', 'name': 'English'},
    {'code': 'hi', 'country': 'IN', 'name': 'हिन्दी'},
    {'code': 'mr', 'country': 'IN', 'name': 'मराठी'},
    {'code': 'gu', 'country': 'IN', 'name': 'ગુજરાતી'},
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeProvider.themeNotifier,
      builder: (context, themeMode, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header with logo and SmartDose text
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/splash_logo.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'SmartDose',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Choose Your Language text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Choose Your Language'.tr(),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Language selection grid
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.69,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                              color: isSelected
                                  ? AppColors.buttonColor
                                  : AppColors.borderColor,
                              width: isSelected ? 5 : 1.5,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            color: isSelected
                                ? AppColors.cardBackground
                                : AppColors.listItemBackground,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.borderColor.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Text(
                                  language['name']!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Icon(
                                    Icons.check_circle,
                                    color: AppColors.buttonColor,
                                    size: 24,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: MyElevatedButton(
                    text: 'Proceed'.tr(),
                    onPressed: _selectedLanguage != null
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OnboardingScreen(),
                              ),
                            );
                          }
                        : null,
                    backgroundColor: AppColors.buttonColor,
                    textColor: AppColors.textOnPrimary,
                    borderRadius: 10,
                    height: 50,
                    width: double.infinity,
                    textStyle: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                    ),
                    disabled: _selectedLanguage == null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
