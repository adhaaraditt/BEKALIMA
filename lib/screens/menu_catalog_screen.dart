import 'package:flutter/material.dart';
import '../services/catering_service.dart';
import '../theme/theme.dart';
import '../widgets/catering_menu_card.dart';
import 'cart_screen.dart';
import 'menu_detail_screen.dart';

class MenuCatalogScreen extends StatefulWidget {
  const MenuCatalogScreen({super.key});

  @override
  State<MenuCatalogScreen> createState() => _MenuCatalogScreenState();
}

class _MenuCatalogScreenState extends State<MenuCatalogScreen> {
  final CateringService _cateringService = CateringService();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = _cateringService.searchQuery;
    _cateringService.addListener(_onServiceChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cateringService.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final menus = _cateringService.filteredMenus;
    final categories = _cateringService.categories;
    final selectedCat = _cateringService.selectedCategoryId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Menu Katering'),
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
      body: Column(
        children: [
          // Bar Pencarian
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => _cateringService.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Cari menu (misal: Ayam Bakar, Liwet, Prasmanan)...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _cateringService.setSearchQuery('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Filter Kategori (Horizontal Chips)
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final cat = categories[i];
                final isSelected = cat.id == selectedCat;

                return ChoiceChip(
                  label: Text(cat.name),
                  selected: isSelected,
                  selectedColor: AppColors.crispCarrot,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                  backgroundColor: AppColors.cardSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSelected ? AppColors.crispCarrot : AppColors.border,
                    ),
                  ),
                  showCheckmark: false,
                  onSelected: (_) {
                    _cateringService.selectCategory(cat.id);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Daftar Menu Katering
          Expanded(
            child: menus.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textDisabled),
                          const SizedBox(height: 12),
                          Text(
                            'Menu Tidak Ditemukan',
                            style: theme.textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Coba kata kunci lain atau pilih kategori "Semua Menu" untuk melihat seluruh sajian.',
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    itemCount: menus.length,
                    itemBuilder: (ctx, index) {
                      final item = menus[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CateringMenuCard(
                          menu: item,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => MenuDetailScreen(menu: item)),
                            );
                          },
                          onAddToCart: () {
                            _cateringService.addToCart(item, 1);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: AppColors.forestGreen,
                                content: Text('Ditambahkan 1 porsi ${item.name}'),
                                action: SnackBarAction(
                                  label: 'Lihat Keranjang',
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
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
