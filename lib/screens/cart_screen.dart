import 'package:flutter/material.dart';
import '../services/catering_service.dart';
import '../theme/theme.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
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

  String _formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = _cateringService.cartItems;
    final subtotal = _cateringService.cartTotalPrice;
    const packagingFee = 5000;
    final grandTotal = subtotal > 0 ? subtotal + packagingFee : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Katering'),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () {
                _cateringService.clearCart();
              },
              child: const Text('Kosongkan', style: TextStyle(color: AppColors.tomatoBurst)),
            ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: AppColors.cream,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.shopping_basket_outlined,
                        size: 40,
                        color: AppColors.forestGreen,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Keranjang Anda Masih Kosong',
                      style: theme.textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pilih paket nasi kotak, prasmanan, atau tumpeng lezat dari BEKALIMA untuk melengkapi acara Anda.',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.restaurant_menu),
                      label: const Text('Cari Menu Katering'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              children: [
                Text(
                  'Daftar Menu yang Dipesan (${_cateringService.cartItemCount} Porsi)',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                ...items.map((cartItem) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.creamTint,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.border),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  cartItem.menu.imageEmoji,
                                  style: const TextStyle(fontSize: 26),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cartItem.menu.name,
                                      style: theme.textTheme.titleSmall,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${_formatCurrency(cartItem.menu.price)} / porsi',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                    if (cartItem.specialNote != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          'Catatan: "${cartItem.specialNote}"',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            fontStyle: FontStyle.italic,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.tomatoBurst, size: 20),
                                onPressed: () {
                                  _cateringService.removeFromCart(cartItem.menu.id);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Divider(),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Subtotal: ${_formatCurrency(cartItem.subtotal)}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: AppColors.crispCarrot,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.creamTint,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, size: 16),
                                      onPressed: () {
                                        _cateringService.updateQuantity(
                                          cartItem.menu.id,
                                          cartItem.quantity - 1,
                                        );
                                      },
                                    ),
                                    Text(
                                      '${cartItem.quantity}',
                                      style: theme.textTheme.titleSmall,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 16),
                                      onPressed: () {
                                        _cateringService.updateQuantity(
                                          cartItem.menu.id,
                                          cartItem.quantity + 1,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),

                // Ringkasan Pembayaran
                Text('Rincian Pembayaran', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Subtotal Menu Katering', style: theme.textTheme.bodyMedium),
                            Text(_formatCurrency(subtotal), style: theme.textTheme.titleSmall),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Kemasan Higienis & Peralatan', style: theme.textTheme.bodyMedium),
                            Text(_formatCurrency(packagingFee), style: theme.textTheme.titleSmall),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Biaya',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              _formatCurrency(grandTotal),
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: AppColors.crispCarrot,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomSheet: items.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2)),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Estimasi', style: theme.textTheme.bodySmall),
                          Text(
                            _formatCurrency(grandTotal),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppColors.crispCarrot,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                        );
                      },
                      child: const Text('Lanjut Pemesanan'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
