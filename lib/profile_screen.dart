import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
                        child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(
                        child: Text('Data profil tidak ditemukan'));
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
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Avatar + nama
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 48,
                              child: Text(
                                '$namaDepan'[0].toUpperCase(),
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '$namaDepan $namaBelakang',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '@$username',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Chip(
                              label: Text(role == 'admin' ? 'Admin' : 'Pengguna'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Info rows
                      ListTile(
                        title: const Text('Email'),
                        subtitle: Text(email),
                      ),
                      ListTile(
                        title: const Text('No. Telepon'),
                        subtitle: Text(noTelepon),
                      ),
                      ListTile(
                        title: const Text('Alamat'),
                        subtitle: Text(alamat),
                      ),
                      const SizedBox(height: 24),

                      // Logout button
                      ElevatedButton(
                        onPressed: () => _logout(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}