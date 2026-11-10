import 'package:flutter/material.dart';
import '../models/order_item.dart';

abstract final class AppColors {
  static const Color crispCarrot = Color(0xFFF86015);
  static const Color forestGreen = Color(0xFF19532B);
  static const Color cream = Color(0xFFF3E8CC);
  static const Color creamTint = Color(0xFFFAF7F0);
  static const Color sunshine = Color(0xFFFFCA26);
  static const Color tomatoBurst = Color(0xFFD42518);
  static const Color kiwi = Color(0xFF9ABC04);
  static const Color textPrimary = Color(0xFF231B15);
  static const Color textSecondary = Color(0xFF66584F);
  static const Color textDisabled = Color(0xFF9A8E85);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE7DEC8);
  static const Color inputFill = Color(0xFFF3EEDF);

  // Palet teal untuk hero & dashboard beranda.
  static const Color deepTeal = Color(0xFF02323D);
  static const Color teal = Color(0xFF0B5B67);
  static const Color tealBright = Color(0xFF2FBCB3);

  // Palet mode gelap (hangat, bukan hitam pekat) agar nuansa kuliner tetap terjaga.
  static const Color darkBackground = Color(0xFF14110D);
  static const Color darkSurface = Color(0xFF1F1A14);
  static const Color darkSurfaceHigh = Color(0xFF2A241D);
  static const Color darkBorder = Color(0xFF3D342B);
  static const Color darkTextPrimary = Color(0xFFF5EFE5);
  static const Color darkTextSecondary = Color(0xFFC4B7A8);
  static const Color greenAccent = Color(0xFF82D79C);
}

Color orderStatusColor(BuildContext context, OrderStatus status) {
  switch (status) {
    case OrderStatus.waitingPayment:
      return AppColors.tomatoBurst;
    case OrderStatus.processing:
      return AppColors.crispCarrot;
    case OrderStatus.shipped:
      return AppColors.kiwi;
    case OrderStatus.completed:
      return Theme.of(context).colorScheme.secondary;
    case OrderStatus.cancelled:
      return AppColors.textDisabled;
  }
}