import 'package:flutter/material.dart';
import '../services/catering_service.dart';
import '../theme/theme.dart';
import '../widgets/catering_menu_card.dart';
import 'cart_screen.dart';
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
    final popularMenus = _cateringService.menus.take(4).toList();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 38,
              height: 38,
              errorBuilder: (context, error, stackTrace) => const Text('🍱', style: TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BEKALIMA',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.crispCarrot,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Katering Online Indonesia',
                  style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Keranjang',
            icon: Badge(
              isLabelVisible: _cateringService.cartItemCount > 0,
              label: Text('${_cateringService.cartItemCount}'),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          // Lokasi Pengiriman Pengguna
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.crispCarrot, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Kirim Katering ke:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      Text(
                        _cateringService.currentAddress,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, size: 20, color: AppColors.textSecondary),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              Text('Kategori Katering', style: theme.textTheme.titleMedium),
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
              Text('Menu Unggulan & Favorit', style: theme.textTheme.titleMedium),
              TextButton(
                onPressed: () {
                  widget.onNavigateTab?.call(1);
                },
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...popularMenus.map((menu) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CateringMenuCard(
                menu: menu,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MenuDetailScreen(menu: menu)),
                  );
                },
                onAddToCart: () {
                  _cateringService.addToCart(menu, 1);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.forestGreen,
                      content: Text('Ditambahkan 1 porsi ${menu.name}'),
                      action: SnackBarAction(
                        label: 'Keranjang',
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CartScreen()),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(
    BuildContext context, {
    required String title,
    required String emoji,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
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
