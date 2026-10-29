import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../services/catering_service.dart';
import '../theme/theme.dart';

class MenuDetailScreen extends StatefulWidget {
  final MenuItem menu;

  const MenuDetailScreen({super.key, required this.menu});

  @override
  State<MenuDetailScreen> createState() => _MenuDetailScreenState();
}

class _MenuDetailScreenState extends State<MenuDetailScreen> {
  final CateringService _cateringService = CateringService();
  final TextEditingController _noteController = TextEditingController();
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = 1;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  void _increment() {
    setState(() {
      _quantity += 1;
    });
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() {
        _quantity -= 1;
      });
    }
  }

  void _submitAddToCart() {
    _cateringService.addToCart(
      widget.menu,
      _quantity,
      note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.forestGreen,
        content: Text('Berhasil menambahkan $_quantity porsi ke keranjang.'),
        action: SnackBarAction(
          label: 'Lihat',
          textColor: Colors.white,
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reviews = _cateringService.getReviewsForMenu(widget.menu.id);
    final totalPrice = widget.menu.price * _quantity;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.menu.name),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          // Banner visual katering
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.menu.imageEmoji,
                  style: const TextStyle(fontSize: 72),
                ),
                const SizedBox(height: 8),
                if (widget.menu.badgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.crispCarrot,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.menu.badgeText!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Nama menu & Harga
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.menu.name,
                  style: theme.textTheme.displayMedium,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCurrency(widget.menu.price),
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: AppColors.crispCarrot,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '/ porsi',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Rating & Minimal Order
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.creamTint,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 18, color: AppColors.sunshine),
                    const SizedBox(width: 4),
                    Text(
                      widget.menu.rating.toStringAsFixed(1),
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${widget.menu.reviewCount} ulasan)',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Siap Dipesan',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.forestGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Deskripsi
          Text(
            widget.menu.description,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),

          // Komposisi Paket / Isi Lauk Pauk
          Text(
            'Komposisi Paket Katering',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: widget.menu.packageContents.map((content) {
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.check_circle_outline, size: 20, color: AppColors.forestGreen),
                    title: Text(
                      content,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Catatan khusus
          Text(
            'Catatan Khusus untuk Dapur',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Contoh: Pisahkan sambal, sambal tidak terlalu pedas...',
            ),
          ),
          const SizedBox(height: 28),

          // Ulasan Pelanggan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ulasan Pelanggan',
                style: theme.textTheme.titleMedium,
              ),
              Text(
                '${reviews.length} ulasan terverifikasi',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (reviews.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Belum ada ulasan untuk menu ini. Jadilah yang pertama menikmati dan memberi ulasan!',
                style: theme.textTheme.bodyMedium,
              ),
            )
          else
            ...reviews.map((rev) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            rev.userName,
                            style: theme.textTheme.titleSmall,
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 16, color: AppColors.sunshine),
                              const SizedBox(width: 2),
                              Text(
                                rev.rating.toStringAsFixed(1),
                                style: theme.textTheme.titleSmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        rev.comment,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Pengatur jumlah (+/-)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.creamTint,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      onPressed: _decrement,
                    ),
                    Text(
                      '$_quantity',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: _increment,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Tombol Tambah ke Keranjang
              Expanded(
                child: ElevatedButton(
                  onPressed: _submitAddToCart,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Tambah ke Keranjang',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        _formatCurrency(totalPrice),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
