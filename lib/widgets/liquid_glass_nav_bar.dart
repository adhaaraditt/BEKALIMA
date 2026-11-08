import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

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

  const LiquidGlassNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isFloating = true,
    required this.items,
    this.onlyShowSelectedLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final content = Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.58),
            Colors.white.withValues(alpha: 0.22),
          ],
        ),
        borderRadius: BorderRadius.circular(isFloating ? 28 : 0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.85),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.07),
            blurRadius: 18,
            spreadRadius: -2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.5),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (items.isNotEmpty)
            AnimatedAlign(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              alignment: Alignment(
                items.length > 1
                    ? -1.0 +
                        (currentIndex.clamp(0, items.length - 1) /
                                (items.length - 1)) *
                            2.0
                    : 0.0,
                0.0,
              ),
              child: FractionallySizedBox(
                widthFactor: 1.0 / items.length,
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
            children: List.generate(items.length, (index) {
              final item = items[index];
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
                                  : AppColors.textSecondary,
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
                                      : AppColors.textSecondary,
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
            }),
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
          color: Colors.white.withValues(alpha: 0.85),
          border: const Border(
            top: BorderSide(color: AppColors.border, width: 1),
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
}