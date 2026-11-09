import 'package:flutter/material.dart';

/// Menyimpan pilihan tema aplikasi dan memberi tahu MaterialApp saat berubah,
/// sehingga mode gelap langsung aktif tanpa perlu restart.
class ThemeController extends ChangeNotifier {
  ThemeController._();

  static final ThemeController instance = ThemeController._();

  ThemeMode _themeMode = ThemeMode.light;

  /// Titik asal animasi reveal, diambil dari posisi tombol tema saat ditekan.
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