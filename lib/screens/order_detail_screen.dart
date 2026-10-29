import 'package:flutter/material.dart';
import '../models/order_item.dart';
import '../services/catering_service.dart';
import '../theme/theme.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderItem order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final CateringService _cateringService = CateringService();

  String _formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.waitingPayment:
        return AppColors.tomatoBurst;
      case OrderStatus.processing:
        return AppColors.crispCarrot;
      case OrderStatus.shipped:
        return AppColors.kiwi;
      case OrderStatus.completed:
        return AppColors.forestGreen;
      case OrderStatus.cancelled:
        return AppColors.textDisabled;
    }
  }

  void _showReviewDialog() {
    double selectedRating = 5.0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Beri Ulasan & Rating'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bagaimana cita rasa dan layanan katering BEKALIMA?'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  return IconButton(
                    icon: Icon(
                      starIndex <= selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                      color: AppColors.sunshine,
                      size: 32,
                    ),
                    onPressed: () {
                      setDialogState(() {
                        selectedRating = starIndex.toDouble();
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Tuliskan ulasan Anda mengenai rasa lauk, ketepatan waktu, dan kemasan...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (commentController.text.trim().isNotEmpty) {
                  final firstMenuId = widget.order.items.isNotEmpty ? widget.order.items.first.menu.id : 'm1';
                  _cateringService.addReview(
                    orderId: widget.order.id,
                    menuId: firstMenuId,
                    rating: selectedRating,
                    comment: commentController.text.trim(),
                    userName: widget.order.recipientName,
                  );
                  Navigator.pop(ctx);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.forestGreen,
                      content: Text('Terima kasih! Ulasan Anda telah berhasil disimpan.'),
                    ),
                  );
                }
              },
              child: const Text('Kirim Ulasan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(widget.order.status);

    return Scaffold(
      appBar: AppBar(
        title: Text('Rincian ${widget.order.id}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner Status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  widget.order.status == OrderStatus.completed
                      ? Icons.check_circle
                      : widget.order.status == OrderStatus.cancelled
                          ? Icons.cancel
                          : Icons.access_time_filled,
                  color: statusColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status: ${widget.order.status.label}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Jadwal Kirim: ${widget.order.eventDate} pukul ${widget.order.eventTime}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tombol Aksi Cepat berdasarkan status
          if (widget.order.canBeCancelled) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.forestGreen),
                    onPressed: () {
                      _cateringService.confirmPayment(widget.order.id);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppColors.forestGreen,
                          content: Text('Pembayaran berhasil dikonfirmasi! Dapur mulai memproses pesanan.'),
                        ),
                      );
                    },
                    child: const Text('Simulasi Bayar Berhasil'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.tomatoBurst,
                      side: const BorderSide(color: AppColors.tomatoBurst),
                    ),
                    onPressed: () {
                      _cateringService.cancelOrder(widget.order.id);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pesanan telah dibatalkan.')),
                      );
                    },
                    child: const Text('Batalkan Pesanan'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],

          if (widget.order.status == OrderStatus.completed) ...[
            Row(
              children: [
                if (widget.order.canBeReviewed)
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.rate_review, size: 18),
                      label: const Text('Beri Ulasan'),
                      onPressed: _showReviewDialog,
                    ),
                  )
                else
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.cream,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Sudah Diulas ⭐',
                        style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.forestGreen),
                      ),
                    ),
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.replay, size: 18),
                    label: const Text('Pesan Ulang'),
                    onPressed: () {
                      _cateringService.reorder(widget.order);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppColors.forestGreen,
                          content: Text('Menu ditambahkan kembali ke keranjang!'),
                        ),
                      );
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],

          // Informasi Pengantaran
          Text('Informasi Pengantaran', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 20, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(widget.order.recipientName, style: theme.textTheme.titleSmall),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 20, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(widget.order.recipientPhone, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 20, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(widget.order.deliveryAddress, style: theme.textTheme.bodyMedium),
                      ),
                    ],
                  ),
                  if (widget.order.notes != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Catatan: "${widget.order.notes}"',
                      style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Daftar Item Menu
          Text('Daftar Menu Katering', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: widget.order.items.map((item) {
                return ListTile(
                  leading: Text(item.menu.imageEmoji, style: const TextStyle(fontSize: 24)),
                  title: Text(item.menu.name, style: theme.textTheme.titleSmall),
                  subtitle: Text('${item.quantity} porsi x ${_formatCurrency(item.menu.price)}'),
                  trailing: Text(
                    _formatCurrency(item.subtotal),
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Rincian Pembayaran
          Text('Rincian Biaya & Metode', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Metode Pembayaran'),
                      Text(widget.order.paymentMethod, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Keseluruhan', style: theme.textTheme.titleMedium),
                      Text(
                        _formatCurrency(widget.order.totalPrice),
                        style: theme.textTheme.titleMedium?.copyWith(
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
    );
  }
}
