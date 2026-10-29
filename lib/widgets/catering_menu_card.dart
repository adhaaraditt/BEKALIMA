import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../theme/theme.dart';

class CateringMenuCard extends StatelessWidget {
  final MenuItem menu;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const CateringMenuCard({
    super.key,
    required this.menu,
    required this.onTap,
    required this.onAddToCart,
  });

  String _formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header kartu: Badge kategori / badge khusus & Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (menu.badgeText != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.cream,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        menu.badgeText!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.forestGreen,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 18, color: AppColors.sunshine),
                      const SizedBox(width: 4),
                      Text(
                        menu.rating.toStringAsFixed(1),
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '(${menu.reviewCount})',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Bagian konten menu
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar visual makanan
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.creamTint,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      menu.imageEmoji,
                      style: const TextStyle(fontSize: 34),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Nama & deskripsi singkat
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          menu.name,
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          menu.description,
                          style: theme.textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Porsi higienis & fresh',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.forestGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 10),

              // Footer kartu: Harga & Tombol Tambah
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Harga per porsi',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        _formatCurrency(menu.price),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.crispCarrot,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      minimumSize: const Size(0, 36),
                    ),
                    icon: const Icon(Icons.add_shopping_cart, size: 16),
                    label: const Text('Tambah'),
                    onPressed: onAddToCart,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
