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
  late TextEditingController _dateController;
  late TextEditingController _timeController;
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
    _dateController = TextEditingController();
    _timeController = TextEditingController(text: '11:00 WIB');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Pilih Tanggal Kirim',
    );
    if (picked == null) return;
    _dateController.text =
        '${picked.day} ${_monthNames[picked.month - 1]} ${picked.year}';
  }

  void _submitOrder() {
    if (!_formKey.currentState!.validate()) return;

    final newOrder = _cateringService.createOrder(
      recipientName: _nameController.text.trim(),
      recipientPhone: _phoneController.text.trim(),
      deliveryAddress: _addressController.text.trim(),
      eventDate: _dateController.text.trim(),
      eventTime: _timeController.text.trim(),
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
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close checkout
              Navigator.pop(context); // Close cart, back to home or orders
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
            // Peringatan Waktu Pemesanan (Lead Time)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.secondary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Pemesanan katering disarankan H-1 sebelum jam 17:00 WIB agar bahan segar dapat disiapkan maksimal.',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Kontak Penerima
            Text('Penerima & Kontak Acara', style: theme.textTheme.titleMedium),
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

            // Waktu Pengiriman Acara
            Text('Jadwal Acara & Pengiriman', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: _pickDate,
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Kirim',
                      hintText: 'Pilih tanggal',
                      prefixIcon: Icon(Icons.calendar_today, size: 18),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _timeController,
                    decoration: const InputDecoration(
                      labelText: 'Jam Tiba',
                      prefixIcon: Icon(Icons.access_time, size: 18),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Alamat Pengiriman
            Text('Alamat Lokasi Acara', style: theme.textTheme.titleMedium),
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

            // Metode Pembayaran
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