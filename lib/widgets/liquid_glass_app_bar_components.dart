import 'dart:ui';
import 'package:flutter/material.dart';
import '../screens/cart_screen.dart';
import '../services/catering_service.dart';
import '../theme/app_colors.dart';

/// Gradien kaca cair yang dipakai bersama oleh elemen header.
/// Warna dibuat lebih pekat agar bulatan ikon/judul/keranjang lebih tegas.
LinearGradient _glassGradient() {
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withValues(alpha: 0.96),
      AppColors.cream.withValues(alpha: 0.88),
    ],
  );
}

/// Bayangan halus agar elemen kaca tetap terpisah dari background.
List<BoxShadow> _glassShadows() {
  return [
    BoxShadow(
      color: AppColors.textPrimary.withValues(alpha: 0.06),
      blurRadius: 14,
      offset: const Offset(0, 4),
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.5),
      blurRadius: 4,
      offset: const Offset(0, -1),
    ),
  ];
}

/// Wadah liquid glass berbentuk kapsul (kotak membulat) untuk judul header.
class LiquidGlassCapsule extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const LiquidGlassCapsule({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    this.borderRadius = 22,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: _glassGradient(),
            borderRadius: radius,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.85),
              width: 1.2,
            ),
            boxShadow: _glassShadows(),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Wadah liquid glass berbentuk lingkaran untuk ikon header.
class LiquidGlassCircle extends StatelessWidget {
  final Widget child;
  final double size;

  const LiquidGlassCircle({super.key, required this.child, this.size = 42});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: _glassGradient(),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.85),
              width: 1.2,
            ),
            boxShadow: _glassShadows(),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Tombol keranjang belanja dengan gaya liquid glass dan badge jumlah item
class LiquidGlassCartButton extends StatelessWidget {
  const LiquidGlassCartButton({super.key});

  @override
  Widget build(BuildContext context) {
    final cateringService = CateringService();

    return ListenableBuilder(
      listenable: cateringService,
      builder: (context, _) {
        final count = cateringService.cartItemCount;

        return ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
                child: Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: _glassGradient(),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.85),
                      width: 1.2,
                    ),
                    boxShadow: _glassShadows(),
                  ),
                  child: Badge(
                    isLabelVisible: count > 0,
                    label: Text(
                      '$count',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    backgroundColor: AppColors.crispCarrot,
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
