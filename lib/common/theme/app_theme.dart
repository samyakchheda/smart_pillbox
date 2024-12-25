// import 'package:flutter/material.dart';
// import 'package:smart_pillbox/common/theme/app_color.dart';
//
// class AppTheme {
//   static final lightTheme = ThemeData(
//     primaryColor: AppColors.primary,
//     scaffoldBackgroundColor: AppColors.lightBackground,
//     brightness: Brightness.light,
//     fontFamily: 'Satoshi',
//     inputDecorationTheme: InputDecorationTheme(
//       filled: true,
//       fillColor: const Color(0xE6D5D8F8),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(35),
//         borderSide: BorderSide.none,
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderSide: const BorderSide(width: 2, color: Colors.blue),
//         borderRadius: BorderRadius.circular(35),
//       ),
//       hintStyle: const TextStyle(fontWeight: FontWeight.w300, fontSize: 15),
//       prefixIconColor: Colors.grey,
//     ),
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: AppColors.primary,
//         elevation: 0,
//         textStyle: const TextStyle(color: Colors.white, fontSize: 15),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(30),
//         ),
//       ),
//     ),
//   );
//
//   static final darkTheme = ThemeData(
//     primaryColor: AppColors.secondary,
//     scaffoldBackgroundColor: AppColors.darkBackground,
//     brightness: Brightness.dark,
//     fontFamily: 'Satoshi',
//     inputDecorationTheme: InputDecorationTheme(
//       filled: true,
//       fillColor: const Color(0x3DFFFFFF),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(35),
//         borderSide: BorderSide.none,
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderSide: const BorderSide(width: 2, color: Colors.blue),
//         borderRadius: BorderRadius.circular(35),
//       ),
//       hintStyle: const TextStyle(fontWeight: FontWeight.w300, fontSize: 15),
//       prefixIconColor: Colors.grey,
//     ),
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: AppColors.primary,
//         elevation: 0,
//         textStyle: const TextStyle(color: Colors.white, fontSize: 15),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(30),
//         ),
//       ),
//     ),
//   );
// }

import 'package:flutter/material.dart';
import 'package:home/common/theme/app_color.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.lightBackground,
    brightness: Brightness.light,
    fontFamily: 'Satoshi',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 2,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.sky, // Soft light tone
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(color: AppColors.kGreyColor.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(width: 2, color: AppColors.aqua),
        borderRadius: BorderRadius.circular(25),
      ),
      hintStyle: const TextStyle(fontWeight: FontWeight.w300, fontSize: 15),
      prefixIconColor: AppColors.kGreyColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        elevation: 1,
        textStyle: const TextStyle(
          color: AppColors
              .lightBackground, // Ensures visibility on light background
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        minimumSize: const Size.fromHeight(56), // Matches TextFormField height
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.sky,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
  );

  static final darkTheme = ThemeData(
    primaryColor: AppColors.secondary,
    scaffoldBackgroundColor: AppColors.darkBackground,
    brightness: Brightness.dark,
    fontFamily: 'Satoshi',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.secondary,
      foregroundColor: Colors.white,
      elevation: 2,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.kGreyColor.withOpacity(0.2), // Subtle dark fill
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(color: AppColors.kGreyColor.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(width: 2, color: AppColors.aqua),
        borderRadius: BorderRadius.circular(25),
      ),
      hintStyle: const TextStyle(fontWeight: FontWeight.w300, fontSize: 15),
      prefixIconColor: AppColors.kGreyColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        elevation: 1,
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        minimumSize: const Size.fromHeight(56), // Matches TextFormField height
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.kGreyColor.withOpacity(0.2),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
  );
}
