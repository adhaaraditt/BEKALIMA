import 'package:flutter/material.dart';
import '../models/order_item.dart';
import '../services/catering_service.dart';
import '../theme/theme.dart';
import 'order_detail_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> with SingleTickerProviderStateMixin {
  final CateringService _cateringService = CateringService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _cateringService.addListener(_onServiceChanged);
  }

  @override
  void dispose() {
    _cateringService.removeListener(_onServiceChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
  }

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

  List<OrderItem> _filterOrders(int tabIndex) {
    final all = _cateringService.orders;
    if (tabIndex == 1) {
      // Aktif
      return all.where((o) => o.status == OrderStatus.waitingPayment || o.status == OrderStatus.processing || o.status == OrderStatus.shipped).toList();
    } else if (tabIndex == 2) {
      // Selesai / Dibatalkan
      return all.where((o) => o.status == OrderStatus.completed || o.status == OrderStatus.cancelled).toList();
    }
    return all;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Katering Saya'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.crispCarrot,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.crispCarrot,
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Sedang Berjalan'),
            Tab(text: 'Riwayat Selesai'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(3, (index) {
          final list = _filterOrders(index);

          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.receipt_long_outlined, size: 54, color: AppColors.textDisabled),
                    const SizedBox(height: 12),
                    Text(
                      'Belum Ada Pesanan',
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Seluruh riwayat transaksi katering Anda akan tercatat rapi di sini.',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: list.length,
            itemBuilder: (ctx, i) {
              final order = list[i];
              final statusColor = _getStatusColor(order.status);

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)),
                    ).then((_) => setState(() {}));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Baris: ID & Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(order.id, style: theme.textTheme.titleSmall),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                order.status.label,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Jadwal Acara: ${order.eventDate} (${order.eventTime})',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 10),
                        const Divider(),
                        const SizedBox(height: 10),

                        // Item menu pertama & ringkasan
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.creamTint,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                order.items.isNotEmpty ? order.items.first.menu.imageEmoji : '🍱',
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.items.isNotEmpty ? order.items.first.menu.name : 'Paket Katering',
                                    style: theme.textTheme.titleSmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (order.items.length > 1)
                                    Text(
                                      '+ ${order.items.length - 1} menu lainnya',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Total Biaya', style: theme.textTheme.bodySmall),
                                Text(
                                  _formatCurrency(order.totalPrice),
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: AppColors.crispCarrot,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Tombol Cepat Bawah
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Lihat Detail & Lacak Status >',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.forestGreen,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}