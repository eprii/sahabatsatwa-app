import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'app_theme.dart';
import 'package:hugeicons/hugeicons.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  final Color warnaBackground = AppTheme.background;
  final Color warnaHeader = const Color(0xFF74855A);
  final Color warnaMerah = const Color(0xFFD93A1E);
  final Color warnaText = const Color(0xFF333333);

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  String _namaTampilan(
    String namaDepan,
    String namaBelakang,
    String username,
    String role,
  ) {
    String namaLengkap = '$namaDepan $namaBelakang'.trim();

    if (role == 'admin') {
      return 'Admin';
    } else if (namaLengkap.isNotEmpty) {
      return namaLengkap;
    } else if (username.isNotEmpty && username != '-') {
      return username;
    } else {
      return 'Pengguna';
    }
  }

  Widget _infoItem(String title, String value, List<List<dynamic>> icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        HugeIcon(
          icon: icon,
          size: 20,
          color: warnaHeader,
        ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: warnaText,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileCard({
    required String nama,
    required String namaDepan,
    required String username,
    required String email,
    required String noTelepon,
    required String alamat,
    required String role,
  }) {
    String hurufAvatar = namaDepan.isNotEmpty
        ? namaDepan[0].toUpperCase()
        : nama[0].toUpperCase();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: warnaHeader,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 41,
                  backgroundColor: Colors.white,
                  child: Text(
                    hurufAvatar,
                    style: TextStyle(
                      fontSize: 32,
                      color: warnaText,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  nama,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 14),

                _infoItem('Username', username, HugeIcons.strokeRoundedUser),
                _infoItem('Email', email, HugeIcons.strokeRoundedMail01),
                _infoItem('No. Telepon', noTelepon, HugeIcons.strokeRoundedCall),
                _infoItem('Alamat', alamat, HugeIcons.strokeRoundedLocation01),
                _infoItem(
                  'Status Akun',
                  role == 'admin' ? 'Admin' : 'Pengguna',
                  HugeIcons.strokeRoundedUserCheck01,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
                'Profil',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.normal,
                ),
              ),
        backgroundColor: warnaBackground,
        elevation: 0,
      ),
      body: SafeArea(
        child: uid == null
            ? const Center(
                child: Text(
                  'Tidak ada user login',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              )
            : StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    );
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(
                      child: Text(
                        'Data profil tidak ditemukan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    );
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;

                  final namaDepan = data['nama_depan'] ?? '';
                  final namaBelakang = data['nama_belakang'] ?? '';
                  final username = data['username'] ?? '-';
                  final email = data['email'] ?? user?.email ?? '-';
                  final noTelepon = data['no_telepon'] ?? '-';
                  final alamat = data['alamat'] ?? '-';
                  final role = data['role'] ?? 'user';

                  final nama = _namaTampilan(
                    namaDepan.toString(),
                    namaBelakang.toString(),
                    username.toString(),
                    role.toString(),
                  );

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
                    children: [
                      _profileCard(
                        nama: nama,
                        namaDepan: namaDepan.toString(),
                        username: username.toString(),
                        email: email.toString(),
                        noTelepon: noTelepon.toString(),
                        alamat: alamat.toString(),
                        role: role.toString(),
                      ),

                      const SizedBox(height: 14),

                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () {
                            _logout(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: warnaMerah,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Log Out',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}