import 'package:flutter/material.dart';

/// Palet warna resmi BEKALIMA berdasarkan PRD Bab 5 & DESIGN.md
/// Mengikuti aturan antislop (R-29: 2-3 warna inti + aksen fungsional terarah).
abstract final class AppColors {
  // --- Warna Brand Inti (Core) ---
  /// Crisp Carrot (#F86015) - Aksi utama (CTA), checkout, highlight penting
  static const Color crispCarrot = Color(0xFFF86015);

  /// Forest Green (#19532B) - Kepercayaan, halal/higienis, status sukses/selesai
  static const Color forestGreen = Color(0xFF19532B);

  /// Cream (#F3E8CC) - Latar aksen lembut / border container
  static const Color cream = Color(0xFFF3E8CC);

  /// Cream Tint (#FAF7F0) - Kanvas latar utama aplikasi (hangat & ramah mata)
  static const Color creamTint = Color(0xFFFAF7F0);

  // --- Warna Aksen Fungsional (Functional Accents) ---
  /// Sunshine (#FFCA26) - Bintang ulasan/rating & badge menu favorit
  static const Color sunshine = Color(0xFFFFCA26);

  /// Tomato Burst (#D42518) - Peringatan, batas waktu bayar, pembatalan & promo mendesak
  static const Color tomatoBurst = Color(0xFFD42518);

  /// Kiwi (#9ABC04) - Menu sehat / vegetarian / snack box segar
  static const Color kiwi = Color(0xFF9ABC04);

  // --- Warna Netral & Teks (High Contrast & Legibility) ---
  /// Espresso Dark (#231B15) - Teks utama, rasio kontras > 7:1 di atas Cream
  static const Color textPrimary = Color(0xFF231B15);

  /// Espresso Muted (#66584F) - Teks sekunder, deskripsi menu & caption
  static const Color textSecondary = Color(0xFF66584F);

  /// Muted Grey (#9A8E85) - Placeholder & disabled state
  static const Color textDisabled = Color(0xFF9A8E85);

  /// Pure White (#FFFFFF) - Kartu menu & surface modal
  static const Color cardSurface = Color(0xFFFFFFFF);

  /// Border & Garis Pembatas (#E7DEC8)
  static const Color border = Color(0xFFE7DEC8);

  /// Subtle Fill (#F1ECE0) - Latar input field & chip unselected
  static const Color inputFill = Color(0xFFF3EEDF);
}
