import 'package:flutter/material.dart';
import 'screens/main_navigation_screen.dart';
import 'theme/theme.dart';

void main() {
  runApp(const BekalimaApp());
}

class BekalimaApp extends StatelessWidget {
  const BekalimaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BEKALIMA - Katering Online',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationScreen(),
    );
  }
}
