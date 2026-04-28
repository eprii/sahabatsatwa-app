import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hugeicons/hugeicons.dart';
import 'app_theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: uid == null
            ? const Center(child: Text('Tidak ada user login'))
            : StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.white));
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(
                        child: Text('Data profil tidak ditemukan',
                            style: TextStyle(color: Colors.white)));
                  }

                  final data =
                      snapshot.data!.data() as Map<String, dynamic>;
                  final namaDepan = data['nama_depan'] ?? '';
                  final namaBelakang = data['nama_belakang'] ?? '';
                  final username = data['username'] ?? '-';
                  final email = data['email'] ?? '-';
                  final noTelepon = data['no_telepon'] ?? '-';
                  final alamat = data['alamat'] ?? '-';
                  final role = data['role'] ?? 'user';

                  return ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Avatar + nama
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.white24,
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedUser,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '$namaDepan $namaBelakang',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '@$username',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: role == 'admin'
                                  ? Colors.orange.withOpacity(0.8)
                                  : Colors.white24,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              role == 'admin' ? 'Admin' : 'Pengguna',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Info card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _infoRow(HugeIcons.strokeRoundedMail01,
                                'Email', email),
                            const Divider(height: 24),
                            _infoRow(HugeIcons.strokeRoundedCall,
                                'No. Telepon', noTelepon),
                            const Divider(height: 24),
                            _infoRow(HugeIcons.strokeRoundedLocation01,
                                'Alamat', alamat),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Tombol Logout
                      OutlinedButton.icon(
                        onPressed: () => _logout(context),
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedLogout01,
                          color: Colors.red,
                          size: 18,
                        ),
                        label: const Text('Logout',
                            style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _infoRow(dynamic icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HugeIcon(icon: icon, color: AppTheme.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textMuted)),
              const SizedBox(height: 2),
              Text(value.isNotEmpty ? value : '-',
                  style: const TextStyle(
                      fontSize: 14, color: AppTheme.textDark)),
            ],
          ),
        ),
      ],
    );
  }
}