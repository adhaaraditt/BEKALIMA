import 'dart:async';
import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../screens/menu_detail_screen.dart';
import '../theme/app_colors.dart';

class PromoItemData {
  final MenuItem menu;
  final String headline;
  final String highlight;
  final String subtitle;
  final String termsText;
  final String ctaText;

  const PromoItemData({
    required this.menu,
    required this.headline,
    required this.highlight,
    required this.subtitle,
    required this.termsText,
    this.ctaText = 'Shop Now',
  });
}

class PromoCarouselBanner extends StatefulWidget {
  final List<PromoItemData> promoItems;

  const PromoCarouselBanner({
    super.key,
    required this.promoItems,
  });

  @override
  State<PromoCarouselBanner> createState() => _PromoCarouselBannerState();
}

class _PromoCarouselBannerState extends State<PromoCarouselBanner> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.promoItems.length > 1) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final nextPage = (_currentPage + 1) % widget.promoItems.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.promoItems.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? theme.colorScheme.surface : Colors.white;

    return Container(
      height: 380,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? theme.colorScheme.outlineVariant
              : const Color(0xFFEBE3D0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : AppColors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.promoItems.length,
            itemBuilder: (context, index) {
              final promo = widget.promoItems[index];
              return _buildSlide(context, promo, cardBg, isDark);
            },
          ),

          if (widget.promoItems.length > 1) ...[
            Positioned(
              left: 10,
              top: 150,
              child: _buildArrow(
                icon: Icons.chevron_left_rounded,
                isDark: isDark,
                onTap: () => _pageController.animateToPage(
                  _currentPage == 0
                      ? widget.promoItems.length - 1
                      : _currentPage - 1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
              ),
            ),
            Positioned(
              right: 10,
              top: 150,
              child: _buildArrow(
                icon: Icons.chevron_right_rounded,
                isDark: isDark,
                onTap: () => _pageController.animateToPage(
                  (_currentPage + 1) % widget.promoItems.length,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
              ),
            ),
          ],

          if (widget.promoItems.length > 1)
            Positioned(
              bottom: 14,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.promoItems.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == i ? 10 : 8,
                    height: _currentPage == i ? 10 : 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == i
                          ? (isDark ? Colors.white : AppColors.forestGreen)
                          : Colors.transparent,
                      border: Border.all(
                        color: _currentPage == i
                            ? (isDark ? Colors.white : AppColors.forestGreen)
                            : (isDark ? Colors.white38 : AppColors.border),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildArrow({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.05),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: isDark ? Colors.white : AppColors.textPrimary,
            size: 26,
          ),
        ),
      ),
    );
  }

  Widget _buildSlide(
    BuildContext context,
    PromoItemData promo,
    Color cardBg,
    bool isDark,
  ) {
    final imagePath = promo.menu.imageAsset;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (imagePath != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 250,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              alignment: Alignment.topCenter,
              errorBuilder: (_, _, _) => Center(
                child: Text(
                  promo.menu.imageEmoji,
                  style: const TextStyle(fontSize: 80),
                ),
              ),
            ),
          )
        else
          Center(
            child: Text(
              promo.menu.imageEmoji,
              style: const TextStyle(fontSize: 80),
            ),
          ),

        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.35, 0.65, 1.0],
              colors: [
                cardBg.withValues(alpha: 0.0),
                cardBg.withValues(alpha: 0.45),
                cardBg.withValues(alpha: 0.92),
                cardBg,
              ],
            ),
          ),
        ),

        Positioned(
          left: 20,
          right: 20,
          bottom: 34,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Headline atas
              Text(
                promo.headline.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.crispCarrot,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),

              Text(
                promo.highlight.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  letterSpacing: -0.2,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 5),

              Text(
                promo.subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 5),

              Text(
                promo.termsText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 10,
                  color: isDark ? Colors.white54 : AppColors.textDisabled,
                ),
              ),
              const SizedBox(height: 14),

              ElevatedButton(
                key: ValueKey('promo_cta_button_${promo.menu.id}'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MenuDetailScreen(menu: promo.menu),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : AppColors.forestGreen,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 36,
                    vertical: 12,
                  ),
                  minimumSize: const Size(140, 42),
                ),
                child: Text(
                  promo.ctaText,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}