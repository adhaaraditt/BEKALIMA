import 'package:flutter/material.dart';
import '../services/catering_service.dart';
import '../theme/theme.dart';
import '../widgets/liquid_glass_app_bar_components.dart';
import 'welcome_screen.dart';

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
              decoration: const InputDecoration(
                labelText: 'Nomor Telepon / WA',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.lock_outline_rounded, size: 18),
                label: const Text('Ubah Password'),
                onPressed: _showChangePasswordDialog,
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

  void _showChangePasswordDialog() {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    String? error;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Ubah Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password Lama'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password Baru'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Ulangi Password Baru',
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(
                  error!,
                  style: TextStyle(
                    color: Theme.of(ctx).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newCtrl.text != confirmCtrl.text) {
                  setDialogState(
                    () => error = 'Ulangi password baru belum sama.',
                  );
                  return;
                }
                final serviceError = _cateringService.changePassword(
                  currentPassword: currentCtrl.text,
                  newPassword: newCtrl.text,
                );
                if (serviceError != null) {
                  setDialogState(() => error = serviceError);
                  return;
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AppColors.forestGreen,
                    content: Text('Password berhasil diubah.'),
                  ),
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddressDialog({int? index}) {
    final isEdit = index != null;
    final addressCtrl = TextEditingController(
      text: isEdit ? _cateringService.savedAddresses[index] : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isEdit ? 'Edit Alamat Pengiriman' : 'Tambah Alamat Pengiriman',
        ),
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
              final address = addressCtrl.text.trim();
              if (address.isEmpty) return;
              if (isEdit) {
                _cateringService.updateAddress(index, address);
              } else {
                _cateringService.addAddress(address);
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.forestGreen,
                  content: Text(
                    isEdit
                        ? 'Alamat berhasil diperbarui.'
                        : 'Alamat baru berhasil ditambahkan.',
                  ),
                ),
              );
            },
            child: Text(isEdit ? 'Simpan' : 'Tambah'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAddress(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Alamat'),
        content: Text(
          'Hapus alamat "${_cateringService.savedAddresses[index]}" dari daftar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tomatoBurst,
            ),
            onPressed: () {
              _cateringService.removeAddress(index);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Alamat berhasil dihapus.')),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            LiquidGlassHeader(
              leading: const LiquidGlassCircle(
                child: Icon(
                  Icons.person_rounded,
                  color: AppColors.crispCarrot,
                  size: 22,
                ),
              ),
              title: Text(
                'Profil Saya',
                style: theme.textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
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
                            child: const Icon(
                              Icons.person,
                              size: 36,
                              color: AppColors.forestGreen,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _cateringService.userName,
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _cateringService.userPhone,
                                  style: theme.textTheme.bodyMedium,
                                ),
                                Text(
                                  _cateringService.userEmail,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: AppColors.crispCarrot,
                            ),
                            onPressed: _showEditProfileDialog,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Alamat Pengantaran',
                        style: theme.textTheme.titleMedium,
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Tambah'),
                        onPressed: () => _showAddressDialog(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(_cateringService.savedAddresses.length, (
                    index,
                  ) {
                    final isSelected =
                        index == _cateringService.selectedAddressIndex;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isSelected
                              ? AppColors.forestGreen
                              : AppColors.textDisabled,
                        ),
                        title: Text(
                          _cateringService.savedAddresses[index],
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.cream,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Utama',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.forestGreen,
                                  ),
                                ),
                              ),
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: AppColors.crispCarrot,
                              ),
                              tooltip: 'Edit alamat',
                              visualDensity: VisualDensity.compact,
                              onPressed: () => _showAddressDialog(index: index),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.tomatoBurst,
                              ),
                              tooltip: 'Hapus alamat',
                              visualDensity: VisualDensity.compact,
                              onPressed: () => _confirmDeleteAddress(index),
                            ),
                          ],
                        ),
                        onTap: () {
                          _cateringService.selectAddress(index);
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  Text(
                    'Informasi Layanan BEKALIMA',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.verified,
                            color: theme.colorScheme.secondary,
                          ),
                          title: const Text('100% Halal & Higienis'),
                          subtitle: const Text(
                            'Dipersiapkan dengan standar dapur bersih profesional.',
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(
                            Icons.schedule,
                            color: AppColors.crispCarrot,
                          ),
                          title: const Text('Waktu Pemesanan (Lead Time)'),
                          subtitle: const Text(
                            'Pemesanan minimal H-1 sebelum jam 17:00 WIB.',
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          leading: Icon(
                            Icons.support_agent,
                            color: theme.colorScheme.secondary,
                          ),
                          title: const Text('Bantuan & Customer Service'),
                          subtitle: const Text(
                            'WhatsApp: +62 812-9988-7766 (08:00 - 20:00 WIB)',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Card(
                    child: ListTile(
                      key: const ValueKey('logout_button'),
                      leading: const Icon(
                        Icons.logout_rounded,
                        color: AppColors.tomatoBurst,
                      ),
                      title: const Text('Keluar'),
                      subtitle: const Text(
                        'Kembali ke halaman selamat datang.',
                      ),
                      onTap: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute<void>(
                            builder: (_) => const WelcomeScreen(),
                          ),
                          (route) => false,
                        );
                      },
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
            ),
          ],
        ),
      ),
    );
  }
}