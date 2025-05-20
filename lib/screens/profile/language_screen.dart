import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:home/theme/app_colors.dart';
import 'package:home/theme/app_fonts.dart';
import '../../widgets/common/my_snack_bar.dart';

class LanguageScreen extends StatefulWidget {
  final VoidCallback onBack;

  const LanguageScreen({super.key, required this.onBack});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String? _selectedLanguage;

  // Map of available languages with codes, countries, and display names
  final List<Map<String, String>> _languages = [
    {'code': 'en', 'country': 'US', 'name': 'English'},
    {'code': 'gu', 'country': 'IN', 'name': 'Gujarati'},
    {'code': 'hi', 'country': 'IN', 'name': 'हिंदी'},
    {'code': 'mr', 'country': 'IN', 'name': 'मराठी'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new,
                    color: AppColors.buttonColor),
                onPressed: widget.onBack,
              ),
              Expanded(
                child: Text(
                  'Select Language',
                  textAlign: TextAlign.center,
                  style:
                      AppFonts.headline.copyWith(color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: _languages.map((lang) {
              final code = lang['code']!;
              final country = lang['country']!;
              final name = lang['name']!;
              final isSelected = _selectedLanguage == code;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedLanguage = code;
                  });
                  // Apply locale
                  context.setLocale(Locale(code, country));
                  mySnackBar(context, 'Language set to $name');
                },
                child: Card(
                  color: AppColors.cardBackground,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: isSelected
                        ? BorderSide(color: AppColors.buttonColor, width: 2)
                        : BorderSide.none,
                  ),
                  child: Center(
                    child: Text(
                      name,
                      style: AppFonts.subHeadline.copyWith(
                        color: isSelected
                            ? AppColors.buttonColor
                            : AppColors.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
