import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'glass_palette.dart';

abstract final class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.creamTint,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.crispCarrot,
        onPrimary: Colors.white,
        secondary: AppColors.forestGreen,
        onSecondary: Colors.white,
        surface: AppColors.cardSurface,
        onSurface: AppColors.textPrimary,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.border,
        outlineVariant: AppColors.border,
        surfaceContainerHigh: AppColors.creamTint,
        surfaceContainerHighest: AppColors.inputFill,
        error: AppColors.tomatoBurst,
        onError: Colors.white,
      ),
      extensions: [GlassPalette.light],
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.creamTint,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headlineMedium,
        iconTheme: IconThemeData(
          color: AppColors.textPrimary,
          size: 24,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        headlineMedium: AppTypography.headlineMedium,
        titleMedium: AppTypography.titleMedium,
        titleSmall: AppTypography.titleSmall,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
        labelSmall: AppTypography.labelSmall,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.crispCarrot,
          foregroundColor: Colors.white,
          elevation: 0,
          textStyle: AppTypography.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.forestGreen,
          textStyle: AppTypography.titleSmall.copyWith(color: AppColors.forestGreen),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          side: const BorderSide(
            color: AppColors.forestGreen,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textDisabled),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.crispCarrot, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.tomatoBurst, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.tomatoBurst, width: 2),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.crispCarrot,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: AppTypography.labelSmall,
        unselectedLabelStyle: AppTypography.labelSmall,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.forestGreen,
        showCloseIcon: true,
        closeIconColor: Colors.white,
        contentTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontFamily: 'Plus Jakarta Sans',
        ),
      ),
    );
  }

  /// Varian gelap dari tema BEKALIMA. Latar memakai cokelat-hitam hangat,
  /// bukan #000000, supaya foto & aksen kuliner tetap terasa natural.
  static ThemeData get darkTheme {
    final textTheme = TextTheme(
      displayLarge: AppTypography.displayLarge.copyWith(
        color: AppColors.darkTextPrimary,
      ),
      displayMedium: AppTypography.displayMedium.copyWith(
        color: AppColors.darkTextPrimary,
      ),
      headlineMedium: AppTypography.headlineMedium.copyWith(
        color: AppColors.darkTextPrimary,
      ),
      titleMedium: AppTypography.titleMedium.copyWith(
        color: AppColors.darkTextPrimary,
      ),
      titleSmall: AppTypography.titleSmall.copyWith(
        color: AppColors.darkTextPrimary,
      ),
      bodyLarge: AppTypography.bodyLarge.copyWith(
        color: AppColors.darkTextPrimary,
      ),
      bodyMedium: AppTypography.bodyMedium.copyWith(
        color: AppColors.darkTextSecondary,
      ),
      bodySmall: AppTypography.bodySmall.copyWith(
        color: AppColors.darkTextSecondary,
      ),
      labelLarge: AppTypography.labelLarge,
      labelSmall: AppTypography.labelSmall.copyWith(
        color: AppColors.darkTextSecondary,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.crispCarrot,
        onPrimary: Colors.white,
        secondary: AppColors.greenAccent,
        onSecondary: Color(0xFF0C2414),
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        onSurfaceVariant: AppColors.darkTextSecondary,
        error: Color(0xFFFF6B5E),
        onError: Colors.black,
        outlineVariant: AppColors.darkBorder,
        surfaceContainerHigh: AppColors.darkSurfaceHigh,
        surfaceContainerHighest: AppColors.darkSurfaceHigh,
      ),
      extensions: [GlassPalette.dark],
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineMedium,
        iconTheme: const IconThemeData(
          color: AppColors.darkTextPrimary,
          size: 24,
        ),
      ),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.crispCarrot,
          foregroundColor: Colors.white,
          elevation: 0,
          textStyle: AppTypography.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.greenAccent,
          textStyle: AppTypography.titleSmall.copyWith(
            color: AppColors.greenAccent,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          side: const BorderSide(color: AppColors.greenAccent, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceHigh,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.darkTextSecondary.withValues(alpha: 0.7),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.crispCarrot, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFFF6B5E), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFFF6B5E), width: 2),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.forestGreen,
        showCloseIcon: true,
        closeIconColor: Colors.white,
        contentTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontFamily: 'Plus Jakarta Sans',
        ),
      ),
    );
  }
}