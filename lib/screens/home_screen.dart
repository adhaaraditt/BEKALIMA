import 'package:flutter/material.dart';
import '../services/catering_service.dart';
import '../theme/theme.dart';
import '../widgets/add_to_cart_dialog.dart';
import '../widgets/catering_menu_card.dart';
import '../widgets/liquid_glass_app_bar_components.dart';
import 'menu_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int tabIndex)? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CateringService _cateringService = CateringService();

  @override
  void initState() {
    super.initState();
    _cateringService.addListener(_onServiceChanged);
  }

  @override
  void dispose() {
    _cateringService.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logoCacheSize = (26 * MediaQuery.devicePixelRatioOf(context)).round();
    final popularMenus = _cateringService.menus.take(4).toList();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  LiquidGlassCircle(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 26,
                      height: 26,
                      cacheWidth: logoCacheSize,
                      cacheHeight: logoCacheSize,
                      gaplessPlayback: true,
                      errorBuilder: (context, error, stackTrace) =>
                          const Text('🍱', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: LiquidGlassCapsule(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text( 
                              'BEKALIMA',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.crispCarrot,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              'Katering Online Indonesia',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 9,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const LiquidGlassThemeToggleButton(),
                  const SizedBox(width: 8),
                  const LiquidGlassNotificationButton(),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: popularMenus.length + 1,
                itemBuilder: (context, index) {
                  if (index > 0) {
                    final menu = popularMenus[index - 1];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CateringMenuCard(
                        menu: menu,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MenuDetailScreen(menu: menu),
                            ),
                          );
                        },
                        onAddToCart: () {
                          _cateringService.addToCart(menu, 1);
                          AddToCartSuccessDialog.show(
                            context,
                            menuName: menu.name,
                            quantity: 1,
                          );
                        },
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Lokasi Pengiriman Pengguna
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: AppColors.crispCarrot,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Kirim Katering ke:',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    _cateringService.currentAddress,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 20,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Banner Promosi (BRD-3)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.forestGreen, Color(0xFF246C3B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.sunshine,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'PROMO BULAN INI',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Diskon 10% Paket Nasi Kotak',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Untuk pemesanan gathering kantor & syukuran mulai dari 30 box.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.crispCarrot,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                minimumSize: const Size(0, 36),
                              ),
                              onPressed: () {
                                widget.onNavigateTab?.call(1); // Go to menu tab
                              },
                              child: const Text('Lihat Menu Sekarang'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Pilihan Kategori Katering (BRD-2)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Kategori Katering',
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              widget.onNavigateTab?.call(1);
                            },
                            child: const Text('Semua Menu'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildCategoryTile(
                            context,
                            title: 'Nasi Kotak',
                            emoji: '🍱',
                            onTap: () {
                              _cateringService.selectCategory('nasi_kotak');
                              widget.onNavigateTab?.call(1);
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildCategoryTile(
                            context,
                            title: 'Prasmanan',
                            emoji: '🍲',
                            onTap: () {
                              _cateringService.selectCategory('prasmanan');
                              widget.onNavigateTab?.call(1);
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildCategoryTile(
                            context,
                            title: 'Snack Box',
                            emoji: '🧁',
                            onTap: () {
                              _cateringService.selectCategory('snack_box');
                              widget.onNavigateTab?.call(1);
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildCategoryTile(
                            context,
                            title: 'Tumpeng',
                            emoji: '🍚',
                            onTap: () {
                              _cateringService.selectCategory('tumpeng');
                              widget.onNavigateTab?.call(1);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Menu Unggulan & Rekomendasi (BRD-1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Menu Unggulan & Favorit',
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              widget.onNavigateTab?.call(1);
                            },
                            child: const Text('Lihat Semua'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTile(
    BuildContext context, {
    required String title,
    required String emoji,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}