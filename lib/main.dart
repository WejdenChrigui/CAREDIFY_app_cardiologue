import 'package:flutter/material.dart';
import 'package:app_cardiologue/theme/app_theme.dart';
import 'package:app_cardiologue/screens/sign_in_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caredify Cardiologist',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light, // Specifically enforcing light theme (no black backgrounds)
      debugShowCheckedModeBanner: false,
      home: const SignInScreen(),
    );
  }
}
