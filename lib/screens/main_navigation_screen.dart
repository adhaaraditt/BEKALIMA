import 'package:flutter/material.dart';
import '../widgets/liquid_glass_nav_bar.dart';
import 'home_screen.dart';
import 'menu_catalog_screen.dart';
import 'order_history_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onNavigateTab: _onTabSelected),
      const MenuCatalogScreen(),
      const OrderHistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: LiquidGlassNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        isFloating: true,
        items: const [
          LiquidGlassNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'Beranda',
          ),
          LiquidGlassNavItem(
            icon: Icons.restaurant_menu_outlined,
            activeIcon: Icons.restaurant_menu_rounded,
            label: 'Menu',
          ),
          LiquidGlassNavItem(
            icon: Icons.receipt_long_outlined,
            activeIcon: Icons.receipt_long_rounded,
            label: 'Pesanan',
          ),
          LiquidGlassNavItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}