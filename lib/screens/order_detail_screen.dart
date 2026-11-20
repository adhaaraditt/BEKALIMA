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

  @override
  void initState() {
    super.initState();
    _cateringService.addListener(_onServiceChanged);
    _cateringService.syncOrderStatuses();
  }

  @override
  void dispose() {
    _cateringService.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _showReviewDialog() async {
    final result = await ReviewDialog.show(context);
    if (result == null || !mounted) return;

    final firstMenuId = widget.order.items.isNotEmpty
        ? widget.order.items.first.menu.id
        : 'm1';
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

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pembayaran Diterima'),
        content: const Text(
          'Status pesanan sekarang Terbayar. Ulasan bisa diberikan setelah pesanan selesai.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Oke'),
          ),
        ],
      ),
    );
  }

  void _changeQuantity(int currentQuantity, String menuId, int delta) {
    final next = currentQuantity + delta;
    if (next <= 0 && widget.order.items.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimal 1 menu dalam pesanan.')),
      );
      return;
    }
    _cateringService.updateOrderItemQuantity(widget.order.id, menuId, next);
  }

  Future<void> _showAddMenuSheet() async {
    final existingIds = widget.order.items.map((item) => item.menu.id).toSet();
    final menus = _cateringService.menus
        .where((menu) => !existingIds.contains(menu.id))
        .toList();
    if (menus.isEmpty) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(ctx).height * 0.6,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: menus.length,
            itemBuilder: (_, index) {
              final menu = menus[index];
              return ListTile(
                title: Text(menu.name),
                subtitle: Text(formatRupiah(menu.price)),
                trailing: Icon(
                  Icons.add_circle,
                  color: Theme.of(ctx).colorScheme.secondary,
                ),
                onTap: () {
                  _cateringService.addOrderItem(widget.order.id, menu);
                  Navigator.pop(ctx);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = orderStatusColor(context, widget.order.status);

    return Scaffold(
      appBar: AppBar(title: Text('Rincian ${widget.order.id}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
                        'Pengiriman: ${widget.order.eventDate} • ${widget.order.eventTime}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (widget.order.canBeCancelled) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.forestGreen,
                    ),
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
                        const SnackBar(
                          content: Text('Pesanan telah dibatalkan.'),
                        ),
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
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.forestGreen,
                        ),
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
                          content: Text(
                            'Menu ditambahkan kembali ke keranjang!',
                          ),
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
                      Icon(
                        Icons.person_outline,
                        size: 20,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.order.recipientName,
                        style: theme.textTheme.titleSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 20,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.order.recipientPhone,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 20,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.order.deliveryAddress,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  if (widget.order.notes != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Catatan: "${widget.order.notes}"',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: Text(
                  'Daftar Menu Katering',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              if (widget.order.canBeEdited)
                TextButton.icon(
                  onPressed: _showAddMenuSheet,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Tambah Menu'),
                ),
            ],
          ),
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
                            errorBuilder: (_, _, _) => Text(
                              item.menu.imageEmoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        )
                      : Text(
                          item.menu.imageEmoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                  title: Text(
                    item.menu.name,
                    style: theme.textTheme.titleSmall,
                  ),
                  subtitle: Text(
                    '${formatRupiah(item.menu.price)} / porsi • ${formatRupiah(item.subtotal)}',
                  ),
                  trailing: widget.order.canBeEdited
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                size: 20,
                              ),
                              onPressed: () => _changeQuantity(
                                item.quantity,
                                item.menu.id,
                                -1,
                              ),
                            ),
                            Text(
                              '${item.quantity}',
                              style: theme.textTheme.titleSmall,
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(
                                Icons.add_circle_outline,
                                size: 20,
                              ),
                              onPressed: () => _changeQuantity(
                                item.quantity,
                                item.menu.id,
                                1,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          formatRupiah(item.subtotal),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
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
                      Text(
                        widget.order.paymentMethod,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Keseluruhan',
                        style: theme.textTheme.titleMedium,
                      ),
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
