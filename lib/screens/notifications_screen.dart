import 'package:flutter/material.dart';
import '../models/order_item.dart';
import '../services/catering_service.dart';
import '../theme/theme.dart';
import '../utils/currency.dart';
import 'order_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
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

  List<_AppNotification> get _notifications {
    final now = DateTime.now();
    final list = <_AppNotification>[
      for (final order in _cateringService.orders) ..._forOrder(order),
      _AppNotification(
        title: 'Promo Katering Kantor',
        message: 'Diskon 10% untuk pemesanan minimal 20 porsi, berlaku sampai akhir bulan.',
        time: now.subtract(const Duration(hours: 2)),
        icon: Icons.local_offer_rounded,
        color: AppColors.kiwi,
      ),
      _AppNotification(
        title: 'Menu Baru: Nasi Liwet Solo Komplit',
        message: 'Paket nasi liwet dengan ayam opor dan areh santan kini tersedia di katalog.',
        time: now.subtract(const Duration(days: 2)),
        icon: Icons.restaurant_menu_rounded,
        color: AppColors.crispCarrot,
      ),
    ];
    list.sort((a, b) => b.time.compareTo(a.time));
    return list;
  }

  List<_AppNotification> _forOrder(OrderItem order) {
    switch (order.status) {
      case OrderStatus.waitingPayment:
        return [
          _AppNotification(
            title: 'Menunggu Pembayaran',
            message:
                'Pesanan ${order.id} belum dibayar. Selesaikan pembayaran sebelum ${order.eventDate}.',
            time: order.orderDate,
            icon: Icons.access_time_filled_rounded,
            color: AppColors.tomatoBurst,
            order: order,
          ),
        ];
      case OrderStatus.paid:
        return [
          _AppNotification(
            title: 'Pembayaran Diterima',
            message:
                'Pembayaran pesanan ${order.id} sebesar ${formatRupiah(order.totalPrice)} sudah kami terima.',
            time: order.orderDate,
            icon: Icons.check_circle_rounded,
            color: AppColors.crispCarrot,
            order: order,
          ),
        ];
      case OrderStatus.shipped:
        return [
          _AppNotification(
            title: 'Pesanan Dikirim',
            message:
                'Kurir sedang mengantar pesanan ${order.id}. Pastikan penerima di lokasi.',
            time: order.orderDate,
            icon: Icons.local_shipping_rounded,
            color: AppColors.kiwi,
            order: order,
          ),
        ];
      case OrderStatus.completed:
        return [
          _AppNotification(
            title: 'Pesanan Selesai',
            message: order.review == null
                ? 'Pesanan ${order.id} sudah diterima. Bagikan ulasan Anda untuk membantu pelanggan lain.'
                : 'Pesanan ${order.id} sudah diterima dan diulas. Terima kasih!',
            time: order.orderDate,
            icon: Icons.task_alt_rounded,
            color: AppColors.forestGreen,
            order: order,
          ),
        ];
      case OrderStatus.cancelled:
        return [
          _AppNotification(
            title: 'Pesanan Dibatalkan',
            message:
                'Pesanan ${order.id} telah dibatalkan. Menu masih bisa dipesan ulang kapan saja.',
            time: order.orderDate,
            icon: Icons.cancel_rounded,
            color: AppColors.textDisabled,
            order: order,
          ),
        ];
    }
  }

  String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${time.day}/${time.month}/${time.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        itemBuilder: (ctx, i) {
          final notif = _notifications[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              leading: CircleAvatar(
                backgroundColor: notif.color.withValues(alpha: 0.12),
                child: Icon(notif.icon, color: notif.color, size: 20),
              ),
              title: Text(notif.title, style: theme.textTheme.titleSmall),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(notif.message, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    _relativeTime(notif.time),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              trailing: notif.order == null
                  ? null
                  : Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
              onTap: notif.order == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              OrderDetailScreen(order: notif.order!),
                        ),
                      ).then((_) => setState(() {}));
                    },
            ),
          );
        },
      ),
    );
  }
}

class _AppNotification {
  final String title;
  final String message;
  final DateTime time;
  final IconData icon;
  final Color color;
  final OrderItem? order;

  const _AppNotification({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.color,
    this.order,
  });
}
