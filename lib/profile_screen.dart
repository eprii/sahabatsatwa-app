import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hugeicons/hugeicons.dart';

import 'login_screen.dart';
import 'app_theme.dart';
import 'app_notification.dart';

// Halaman profil digunakan untuk menampilkan data akun user/admin.
// Data profil diambil dari Firebase Auth dan Firestore collection "users".
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Warna-warna yang digunakan di halaman profil.
  final Color warnaBackground = AppTheme.background;
  final Color warnaHeader = const Color(0xFF74855A);
  final Color warnaMerah = const Color(0xFFD93A1E);
  final Color warnaText = const Color(0xFF333333);

  // Fungsi untuk logout dari Firebase Authentication.
  Future<void> _logout(BuildContext context) async {
    // Menghapus sesi login user dari Firebase.
    await FirebaseAuth.instance.signOut();

    if (context.mounted) {
      // Tampilkan notifikasi berhasil logout.
      // Karena AppNotification memakai rootOverlay,
      // popup tetap muncul walaupun halaman langsung pindah ke LoginScreen.
      AppNotification.showSuccess(
        context,
        'Logout berhasil',
      );

      // Setelah logout, pindah ke halaman login dan hapus semua halaman sebelumnya.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) {
            return const LoginScreen();
          },
        ),
        (route) {
          return false;
        },
      );
    }
  }

  // Fungsi ini menentukan nama yang akan ditampilkan di bagian atas profil.
  String _namaTampilan(
    String namaDepan,
    String namaBelakang,
    String username,
    String role,
  ) {
    // Menggabungkan nama depan dan nama belakang.
    String namaLengkap = '$namaDepan $namaBelakang'.trim();

    // Jika akun adalah admin, tampilkan "Admin".
    if (role == 'admin') {
      return 'Admin';
    }

    // Jika nama lengkap tersedia, tampilkan nama lengkap.
    else if (namaLengkap.isNotEmpty) {
      return namaLengkap;
    }

    // Jika nama kosong tapi username ada, tampilkan username.
    else if (username.isNotEmpty && username != '-') {
      return username;
    }

    // Jika semua data kosong, tampilkan teks default.
    else {
      return 'Pengguna';
    }
  }

  // Widget kecil untuk menampilkan satu baris informasi profil.
  // Contoh: Username, Email, No. Telepon, Alamat, Status Akun.
  Widget _infoItem(
    String title,
    String value,
    List<List<dynamic>> icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon di sebelah kiri informasi.
          HugeIcon(
            icon: icon,
            size: 20,
            color: warnaHeader,
          ),

          const SizedBox(width: 10),

          // Expanded digunakan agar teks tidak overflow keluar layar.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul informasi, misalnya "Email".
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                  ),
                ),

                const SizedBox(height: 2),

                // Isi informasi, misalnya email user.
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

  // Widget card utama yang berisi avatar dan data profil.
  Widget _profileCard({
    required String nama,
    required String namaDepan,
    required String username,
    required String email,
    required String noTelepon,
    required String alamat,
    required String role,
  }) {
    // Huruf avatar diambil dari huruf pertama nama depan.
    // Jika nama depan kosong, ambil dari huruf pertama nama tampilan.
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
          // Bagian header card berwarna hijau.
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
                // Avatar berbentuk lingkaran.
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

                // Nama tampilan user/admin.
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

          // Bagian isi detail profil.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),

                _infoItem(
                  'Username',
                  username,
                  HugeIcons.strokeRoundedUser,
                ),

                _infoItem(
                  'Email',
                  email,
                  HugeIcons.strokeRoundedMail01,
                ),

                _infoItem(
                  'No. Telepon',
                  noTelepon,
                  HugeIcons.strokeRoundedCall,
                ),

                _infoItem(
                  'Alamat',
                  alamat,
                  HugeIcons.strokeRoundedLocation01,
                ),

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

  // Widget tombol logout.
  Widget _logoutButton(BuildContext context) {
    return SizedBox(
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
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // currentUser mengambil user yang sedang login dari Firebase Auth.
    final user = FirebaseAuth.instance.currentUser;

    // UID digunakan untuk mencari dokumen user di Firestore.
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
        // Jika uid null, berarti tidak ada user yang sedang login.
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

            // Jika uid ada, ambil data profil dari Firestore.
            : StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .snapshots(),

                builder: (context, snapshot) {
                  // Saat data masih dimuat.
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    );
                  }

                  // Jika terjadi error saat mengambil data profil.
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Gagal memuat data profil',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    );
                  }

                  // Jika dokumen user tidak ditemukan di Firestore.
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

                  // Mengambil data dokumen user sebagai Map.
                  final data = snapshot.data!.data() as Map<String, dynamic>;

                  // Mengambil setiap field dari Firestore.
                  // Jika field kosong/null, gunakan nilai default.
                  final namaDepan = data['nama_depan'] ?? '';
                  final namaBelakang = data['nama_belakang'] ?? '';
                  final username = data['username'] ?? '-';
                  final email = data['email'] ?? user?.email ?? '-';
                  final noTelepon = data['no_telepon'] ?? '-';
                  final alamat = data['alamat'] ?? '-';
                  final role = data['role'] ?? 'user';

                  // Menentukan nama yang akan ditampilkan di header profil.
                  final nama = _namaTampilan(
                    namaDepan.toString(),
                    namaBelakang.toString(),
                    username.toString(),
                    role.toString(),
                  );

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
                    children: [
                      // Card profil utama.
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

                      // Tombol logout.
                      _logoutButton(context),
                    ],
                  );
                },
              ),
      ),
    );
  }
}