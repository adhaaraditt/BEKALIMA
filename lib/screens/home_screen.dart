import 'package:flutter/material.dart';
import '../services/catering_service.dart';
import '../theme/theme.dart';
import '../widgets/add_to_cart_dialog.dart';
import '../widgets/catering_menu_card.dart';
import '../widgets/liquid_glass_app_bar_components.dart';
import '../widgets/promo_carousel_banner.dart';
import 'menu_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int tabIndex)? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CateringService _cateringService = CateringService();

  static const _homeCategories = [
    (id: 'nasi_kotak', title: 'Nasi Kotak', emoji: '🍱'),
    (id: 'prasmanan', title: 'Prasmanan', emoji: '🍲'),
    (id: 'snack_box', title: 'Snack Box', emoji: '🧁'),
    (id: 'tumpeng', title: 'Tumpeng', emoji: '🍚'),
  ];

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

  List<PromoItemData> _buildPromoItems() {
    final menusById = {for (final m in _cateringService.menus) m.id: m};
    final ayamBakar = menusById['m1'];
    final liwet = menusById['m2'];
    final rendang = menusById['m3'];
    final nasiKuning = menusById['m6'];

    return [
      if (ayamBakar != null)
        PromoItemData(
          menu: ayamBakar,
          headline: 'Promo Spesial Bulan Ini',
          highlight: 'Ayam Bakar Madu',
          subtitle: 'Ayam bumbu madu legit dengan tahu tempe & urap',
          termsText: '*Min. order 10 box. Berlaku selama persediaan ada.',
        ),
      if (liwet != null)
        PromoItemData(
          menu: liwet,
          headline: 'Khas Nusantara',
          highlight: 'Nasi Liwet Solo',
          subtitle: 'Suwiran ayam opor lembut & areh santan kental',
          termsText: '*Tersedia setiap hari. Diskon 10% paket kantor.',
        ),
      if (rendang != null)
        PromoItemData(
          menu: rendang,
          headline: 'Resep Asli Minang',
          highlight: 'Nasi Box Rendang',
          subtitle: 'Daging sapi rempah Minang empuk dengan gulai daun singkong',
          termsText: '*Paling disukai untuk rapat dinas & makan siang.',
        ),
      if (nasiKuning != null)
        PromoItemData(
          menu: nasiKuning,
          headline: 'Paket Tumpeng Mini',
          highlight: 'Nasi Kuning Syukuran',
          subtitle: '6 macam lauk pauk khas syukuran kemasan mika tebal',
          termsText: '*Pilihan utama syukuran & perayaan keluarga.',
        ),
    ];
  }

  void _showAddressPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 12, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Pilih Alamat Pengiriman',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111111),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showAddAddressDialog();
                    },
                    icon: const Icon(Icons.add_circle, size: 28),
                    color: AppColors.crispCarrot,
                    tooltip: 'Tambah alamat',
                  ),
                ],
              ),
            ),
            ...List.generate(_cateringService.savedAddresses.length, (index) {
              final isSelected =
                  index == _cateringService.selectedAddressIndex;
              return ListTile(
                leading: Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected
                      ? AppColors.forestGreen
                      : AppColors.textDisabled,
                ),
                title: Text(
                  _cateringService.savedAddresses[index],
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                onTap: () {
                  _cateringService.selectAddress(index);
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showAddAddressDialog() {
    final addressCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Alamat Pengiriman'),
        content: TextField(
          controller: addressCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Nama gedung / jalan, nomor, lantai, patokan...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final address = addressCtrl.text.trim();
              if (address.isEmpty) return;
              final newIndex = _cateringService.savedAddresses.length;
              _cateringService.addAddress(address);
              _cateringService.selectAddress(newIndex);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.forestGreen,
                  content: Text('Alamat baru berhasil ditambahkan.'),
                ),
              );
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
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
                      GestureDetector(
                        onTap: _showAddressPicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
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
                                      'Alamatmu',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
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
                      ),
                      const SizedBox(height: 16),

                      PromoCarouselBanner(promoItems: _buildPromoItems()),
                      const SizedBox(height: 24),

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
                          for (final (i, category) in _homeCategories.indexed) ...[
                            if (i > 0) const SizedBox(width: 8),
                            _buildCategoryTile(
                              context,
                              title: category.title,
                              emoji: category.emoji,
                              onTap: () {
                                _cateringService.selectCategory(category.id);
                                widget.onNavigateTab?.call(1);
                              },
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),

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
            color: theme.brightness == Brightness.dark
                ? theme.colorScheme.surface
                : Colors.white,
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