import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  ThemeController._();

  static final ThemeController instance = ThemeController._();

  ThemeMode _themeMode = ThemeMode.light;

  Offset? _toggleOrigin;

  ThemeMode get themeMode => _themeMode;

  Offset? get toggleOrigin => _toggleOrigin;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleDarkMode({Offset? origin}) {
    _toggleOrigin = origin;
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}