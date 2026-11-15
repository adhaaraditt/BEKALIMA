import 'package:flutter/material.dart';
import '../models/order_item.dart';
import '../services/catering_service.dart';
import '../theme/theme.dart';
import '../utils/currency.dart';
import '../widgets/review_dialog.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderItem order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final CateringService _cateringService = CateringService();

  Future<void> _showReviewDialog() async {
    final result = await ReviewDialog.show(context);
    if (result == null || !mounted) return;

    final firstMenuId = widget.order.items.isNotEmpty ? widget.order.items.first.menu.id : 'm1';
    _cateringService.addReview(
      orderId: widget.order.id,
      menuId: firstMenuId,
      rating: result.rating,
      comment: result.comment,
      userName: widget.order.recipientName,
    );
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Terima kasih! Ulasan Anda telah berhasil disimpan.'),
      ),
    );
  }

  Future<void> _simulatePaymentSuccess() async {
    _cateringService.confirmPayment(widget.order.id);
    setState(() {});

    final wantsReview = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PaymentSuccessDialog(orderId: widget.order.id),
    );
    if (wantsReview == true && mounted) {
      await _showReviewDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = orderStatusColor(context, widget.order.status);

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
                  widget.order.status == OrderStatus.completed ||
                  widget.order.status == OrderStatus.paid
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
                    onPressed: _simulatePaymentSuccess,
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
                      Icon(Icons.person_outline, size: 20, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text(widget.order.recipientName, style: theme.textTheme.titleSmall),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.phone_outlined, size: 20, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text(widget.order.recipientPhone, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on_outlined, size: 20, color: theme.colorScheme.onSurfaceVariant),
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
                  leading: item.menu.imageAsset != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset(
                            item.menu.imageAsset!,
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Text(item.menu.imageEmoji, style: const TextStyle(fontSize: 24)),
                          ),
                        )
                      : Text(item.menu.imageEmoji, style: const TextStyle(fontSize: 24)),
                  title: Text(item.menu.name, style: theme.textTheme.titleSmall),
                  subtitle: Text('${item.quantity} porsi x ${formatRupiah(item.menu.price)}'),
                  trailing: Text(
                    formatRupiah(item.subtotal),
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
                        formatRupiah(widget.order.totalPrice),
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

/// Pop-up terpusat setelah simulasi pembayaran berhasil.
class _PaymentSuccessDialog extends StatelessWidget {
  final String orderId;

  const _PaymentSuccessDialog({required this.orderId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final green = theme.colorScheme.secondary;

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: green.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: green,
                  size: 38,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pembayaran Berhasil!',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pesanan $orderId sudah selesai. Bagikan ulasan Anda untuk membantu pelanggan lain.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Beri Ulasan Sekarang'),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurfaceVariant,
                ),
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Nanti Saja'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}