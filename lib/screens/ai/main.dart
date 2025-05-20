import 'chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

void main() {
  const apiKey =
      'AIzaSyD3psw8M8hiX2mnwGoXxc-0-ZvBxPa0IYY'; // Replace with your actual API key
  Gemini.init(apiKey: apiKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Pillbox Chatbot',
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.grey,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.grey,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      home: const ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
