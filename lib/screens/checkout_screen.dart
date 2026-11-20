import 'package:flutter/material.dart';
import '../services/catering_service.dart';
import '../theme/theme.dart';
import '../utils/currency.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CateringService _cateringService = CateringService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  final TextEditingController _notesController = TextEditingController();

  static const _monthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  String _selectedPayment = 'Transfer Virtual Account BCA';
  final List<String> _paymentMethods = [
    'Transfer Virtual Account BCA',
    'Transfer Bank Mandiri',
    'QRIS (GoPay, OVO, ShopeePay)',
    'Bayar di Tempat / COD (Sesuai Konfirmasi)',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _cateringService.userName);
    _phoneController = TextEditingController(text: _cateringService.userPhone);
    _addressController = TextEditingController(text: _cateringService.currentAddress);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitOrder() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final eta = now.add(const Duration(hours: 1));
    final etaStr =
        '${eta.hour.toString().padLeft(2, '0')}:${eta.minute.toString().padLeft(2, '0')} WIB';
    final todayStr =
        'Hari ini, ${now.day} ${_monthNames[now.month - 1]} ${now.year}';

    final newOrder = _cateringService.createOrder(
      recipientName: _nameController.text.trim(),
      recipientPhone: _phoneController.text.trim(),
      deliveryAddress: _addressController.text.trim(),
      eventDate: todayStr,
      eventTime: '1 Jam (estimasi tiba ~$etaStr)',
      paymentMethod: _selectedPayment,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.secondary,
              size: 28,
            ),
            const SizedBox(width: 8),
            const Text('Pesanan Berhasil!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nomor Pesanan: ${newOrder.id}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Pesanan katering Anda telah dicatat dengan status "${newOrder.status.label}". Mohon selesaikan pembayaran agar dapur dapat memproses sajian Anda.',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Metode Pembayaran:', style: TextStyle(fontSize: 12)),
                  Text(newOrder.paymentMethod, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Total: ${formatRupiah(newOrder.totalPrice)}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.crispCarrot)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); 
              Navigator.pop(context); 
            },
            child: const Text('Lihat Pesanan Saya'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalAmount = _cateringService.cartTotalPrice + 5000;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengiriman Katering'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.crispCarrot.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.crispCarrot.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.bolt_rounded,
                    color: AppColors.crispCarrot,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pengiriman Instan (Hari Ini)',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Pesanan dikirim hari ini juga dengan estimasi tiba dalam 1 jam.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text('Penerima & Kontak', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Lengkap Penerima'),
              validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Nomor WhatsApp / Telepon Aktif'),
              validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 20),

            Text('Alamat Pengantaran', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Alamat Lengkap (Gedung/Rumah, No, RT/RW, Patokan)',
              ),
              validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Catatan Pengantaran (Opsional, misal: Masuk lewat lift barang)',
              ),
            ),
            const SizedBox(height: 20),

            Text('Pilihan Pembayaran', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: _paymentMethods.map((method) {
                  final isSelected = method == _selectedPayment;
                  return ListTile(
                    leading: Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: isSelected
                          ? AppColors.crispCarrot
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    title: Text(
                      method,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      setState(() => _selectedPayment = method);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          boxShadow: const [
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
                    Text('Total Tagihan', style: theme.textTheme.bodySmall),
                    Text(
                      formatRupiah(totalAmount),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.crispCarrot,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _submitOrder,
                child: const Text('Konfirmasi & Buat Pesanan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}