import 'dart:ui';
import 'package:flutter/material.dart';
import '../screens/cart_screen.dart';
import '../services/catering_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/glass_palette.dart';

/// Item data model untuk [LiquidGlassNavigationBar]
class LiquidGlassNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const LiquidGlassNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class LiquidGlassNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isFloating;
  final List<LiquidGlassNavItem> items;
  final bool onlyShowSelectedLabel;

  /// Aksi utama yang ditampilkan di tengah bar, di antara item navigasi.
  /// Tidak ikut terpilih sebagai tab.
  final Widget? centerAction;

  const LiquidGlassNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isFloating = true,
    required this.items,
    this.onlyShowSelectedLabel = true,
    this.centerAction,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final palette = glassPaletteOf(context);

    // Saat ada aksi tengah, bar punya satu slot ekstra di tengah.
    final centerSlot = items.length ~/ 2;
    final slotCount = items.length + (centerAction != null ? 1 : 0);
    final activeSlot = centerAction != null && currentIndex >= centerSlot
        ? currentIndex + 1
        : currentIndex;

    final content = Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.navGradientStart, palette.navGradientEnd],
        ),
        borderRadius: BorderRadius.circular(isFloating ? 28 : 0),
        border: Border.all(
          color: palette.border,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 18,
            spreadRadius: -2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: palette.highlight,
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (items.isNotEmpty && slotCount > 0)
            AnimatedAlign(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              alignment: Alignment(
                slotCount > 1
                    ? -1.0 +
                        (activeSlot.clamp(0, slotCount - 1) /
                                (slotCount - 1)) *
                            2.0
                    : 0.0,
                0.0,
              ),
              child: FractionallySizedBox(
                widthFactor: 1.0 / slotCount,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.crispCarrot.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.crispCarrot.withValues(alpha: 0.25),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.crispCarrot.withValues(alpha: 0.10),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var index = 0; index < items.length; index++) ...[
                if (centerAction != null && index == centerSlot)
                  Expanded(child: Center(child: centerAction)),
                _buildNavItem(context, items[index], index),
              ],
              if (centerAction != null && centerSlot >= items.length)
                Expanded(child: Center(child: centerAction)),
            ],
          ),
        ],
      ),
    );

    final glassPill = ClipRRect(
      borderRadius: BorderRadius.circular(isFloating ? 28 : 0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: content,
      ),
    );

    if (!isFloating) {
      return Container(
        padding: EdgeInsets.only(bottom: bottomPadding),
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: isDark ? 0.94 : 0.85),
          border: Border(
            top: BorderSide(color: scheme.outlineVariant, width: 1),
          ),
        ),
        child: glassPill,
      );
    }

    return SafeArea(
      top: false,
      maintainBottomViewPadding: true,
      child: Padding(
        padding: EdgeInsets.only(
          left: 36,
          right: 36,
          bottom: bottomPadding > 0 ? 6 : 14,
          top: 8,
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: glassPill,
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    LiquidGlassNavItem item,
    int index,
  ) {
    final isSelected = index == currentIndex;

    return Expanded(
      child: Semantics(
        selected: isSelected,
        label: item.label,
        button: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Feedback.forTap(context);
            onTap(index);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: 2),
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.08 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutBack,
                  child: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    size: isSelected ? 22 : 24,
                    color: isSelected
                        ? AppColors.crispCarrot
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  firstCurve: Curves.easeIn,
                  secondCurve: Curves.easeOut,
                  sizeCurve: Curves.easeOutCubic,
                  crossFadeState: (isSelected || !onlyShowSelectedLabel)
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? AppColors.crispCarrot
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  secondChild: const SizedBox(
                    width: double.infinity,
                    height: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tombol keranjang utama di tengah navigation bar, lengkap dengan badge
/// jumlah item.
class LiquidGlassCartNavAction extends StatelessWidget {
  const LiquidGlassCartNavAction({super.key});

  @override
  Widget build(BuildContext context) {
    final cateringService = CateringService();

    return ListenableBuilder(
      listenable: cateringService,
      builder: (context, _) {
        final count = cateringService.cartItemCount;

        return Semantics(
          button: true,
          label: 'Keranjang',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Feedback.forTap(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
            child: Badge(
              isLabelVisible: count > 0,
              backgroundColor: Colors.white,
              textColor: AppColors.crispCarrot,
              offset: const Offset(-2, -2),
              label: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.crispCarrot, Color(0xFFD94A0A)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.crispCarrot.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shopping_bag_rounded,
                  color: Colors.white,
                  size: 23,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}