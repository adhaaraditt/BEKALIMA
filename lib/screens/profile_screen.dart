import 'package:flutter/material.dart';
import '../services/catering_service.dart';
import '../theme/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: _cateringService.userName);
    final phoneCtrl = TextEditingController(text: _cateringService.userPhone);
    final emailCtrl = TextEditingController(text: _cateringService.userEmail);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nama Lengkap'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Nomor Telepon / WA'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
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
              _cateringService.updateProfile(
                name: nameCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                email: emailCtrl.text.trim(),
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.forestGreen,
                  content: Text('Profil berhasil diperbarui.'),
                ),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showAddAddressDialog() {
    final addressCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Alamat Pengiriman'),
        content: TextField(
          controller: addressCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Nama gedung / jalan, nomor, lantai, patokan...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (addressCtrl.text.trim().isNotEmpty) {
                _cateringService.addAddress(addressCtrl.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AppColors.forestGreen,
                    content: Text('Alamat baru berhasil ditambahkan.'),
                  ),
                );
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          // Kartu Informasi Akun
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: AppColors.cream,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.person, size: 36, color: AppColors.forestGreen),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_cateringService.userName, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 2),
                        Text(_cateringService.userPhone, style: theme.textTheme.bodyMedium),
                        Text(_cateringService.userEmail, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.crispCarrot),
                    onPressed: _showEditProfileDialog,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Daftar Alamat Tersimpan (PRF-3)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Alamat Pengantaran Acara', style: theme.textTheme.titleMedium),
              TextButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Tambah'),
                onPressed: _showAddAddressDialog,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(_cateringService.savedAddresses.length, (index) {
            final isSelected = index == _cateringService.selectedAddressIndex;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isSelected ? AppColors.forestGreen : AppColors.textDisabled,
                ),
                title: Text(
                  _cateringService.savedAddresses[index],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                trailing: isSelected
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.cream,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Utama',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.forestGreen),
                        ),
                      )
                    : null,
                onTap: () {
                  _cateringService.selectAddress(index);
                },
              ),
            );
          }),
          const SizedBox(height: 24),

          // Kebijakan & Informasi Katering
          Text('Informasi Layanan BEKALIMA', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.verified, color: AppColors.forestGreen),
                  title: Text('100% Halal & Higienis'),
                  subtitle: Text('Dipersiapkan dengan standar dapur bersih profesional.'),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.schedule, color: AppColors.crispCarrot),
                  title: Text('Waktu Pemesanan (Lead Time)'),
                  subtitle: Text('Pemesanan minimal H-1 sebelum jam 17:00 WIB.'),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.support_agent, color: AppColors.forestGreen),
                  title: Text('Bantuan & Customer Service'),
                  subtitle: Text('WhatsApp: +62 812-9988-7766 (08:00 - 20:00 WIB)'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Center(
            child: Text(
              'BEKALIMA v0.1 (Draft MVP)',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}