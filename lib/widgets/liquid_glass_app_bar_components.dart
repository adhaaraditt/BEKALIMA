import 'dart:ui';
import 'package:flutter/material.dart';
import '../screens/cart_screen.dart';
import '../services/catering_service.dart';
import '../services/theme_controller.dart';
import '../theme/app_colors.dart';
import '../theme/glass_palette.dart';

/// Gradien kaca cair yang dipakai bersama oleh elemen header.
/// Warna dibuat lebih pekat agar bulatan ikon/judul/keranjang lebih tegas.
LinearGradient _glassGradient(BuildContext context) {
  final palette = glassPaletteOf(context);

  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [palette.gradientStart, palette.gradientEnd],
  );
}

/// Bayangan halus agar elemen kaca tetap terpisah dari background.
List<BoxShadow> _glassShadows(BuildContext context) {
  final palette = glassPaletteOf(context);

  return [
    BoxShadow(
      color: palette.shadow,
      blurRadius: 14,
      offset: const Offset(0, 4),
      spreadRadius: -2,
    ),
    BoxShadow(
      color: palette.highlight,
      blurRadius: 4,
      offset: const Offset(0, -1),
    ),
  ];
}

Color _glassBorder(BuildContext context) => glassPaletteOf(context).border;

/// Baris header standar: ikon, judul, tombol tema, dan notifikasi.
class LiquidGlassHeader extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final EdgeInsetsGeometry titlePadding;

  const LiquidGlassHeader({
    super.key,
    required this.leading,
    required this.title,
    this.titlePadding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 8),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: LiquidGlassCapsule(padding: titlePadding, child: title),
            ),
          ),
          const SizedBox(width: 8),
          const LiquidGlassThemeToggleButton(),
          const SizedBox(width: 8),
          const LiquidGlassNotificationButton(),
        ],
      ),
    );
  }
}

/// Tombol ikon dengan wadah kaca yang sama untuk tema dan notifikasi.
class GlassIconButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final String? tooltip;

  const GlassIconButton({
    super.key,
    required this.child,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onTap,
            child: Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: _glassGradient(context),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: _glassBorder(context), width: 1.2),
                boxShadow: _glassShadows(context),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );

    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
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
            gradient: _glassGradient(context),
            borderRadius: radius,
            border: Border.all(color: _glassBorder(context), width: 1.2),
            boxShadow: _glassShadows(context),
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
            gradient: _glassGradient(context),
            border: Border.all(color: _glassBorder(context), width: 1.2),
            boxShadow: _glassShadows(context),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Tombol notifikasi bergaya liquid glass untuk header.
class LiquidGlassNotificationButton extends StatelessWidget {
  const LiquidGlassNotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassIconButton(
      onTap: () {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Belum ada notifikasi baru.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
      },
      child: Icon(
        Icons.notifications_none_rounded,
        color: Theme.of(context).colorScheme.onSurface,
        size: 22,
      ),
    );
  }
}

/// Tombol sekali ketuk untuk berpindah antara mode terang dan mode gelap.
class LiquidGlassThemeToggleButton extends StatelessWidget {
  const LiquidGlassThemeToggleButton({super.key});

  void _toggleTheme(BuildContext context) {
    final renderObject = context.findRenderObject();
    final origin = renderObject is RenderBox
        ? renderObject.localToGlobal(renderObject.size.center(Offset.zero))
        : null;
    ThemeController.instance.toggleDarkMode(origin: origin);
  }

  @override
  Widget build(BuildContext context) {
    final controller = ThemeController.instance;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final isDark = controller.isDarkMode;

        return GlassIconButton(
          tooltip: isDark ? 'Mode terang' : 'Mode gelap',
          onTap: () => _toggleTheme(context),
          child: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: isDark ? AppColors.sunshine : AppColors.textPrimary,
            size: 22,
          ),
        );
      },
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
                    gradient: _glassGradient(context),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: _glassBorder(context),
                      width: 1.2,
                    ),
                    boxShadow: _glassShadows(context),
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
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: Theme.of(context).colorScheme.onSurface,
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
