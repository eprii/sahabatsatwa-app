import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hugeicons/hugeicons.dart';

import 'login_screen.dart';
import 'app_notification.dart';

// Halaman register digunakan untuk membuat akun user baru.
// Akun dibuat di Firebase Authentication, lalu data profil disimpan ke Firestore.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() {
    return _RegisterScreenState();
  }
}

class _RegisterScreenState extends State<RegisterScreen> {
  // FirebaseAuth digunakan untuk membuat akun baru.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Controller digunakan untuk mengambil isi input dari TextField.
  final TextEditingController _namaDepanController = TextEditingController();
  final TextEditingController _namaBelakangController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _noTeleponController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Variabel untuk menampilkan loading pada tombol daftar.
  bool _isLoading = false;

  // Variabel untuk menyembunyikan / menampilkan password.
  bool _obscurePassword = true;
  bool _obscureConfirm = true;



  // Warna utama halaman register, disamakan dengan halaman login.
  static const Color _kBg = Color(0xFF7B8860);
  static const Color _kButton = Color(0xFF1E5A27);

  // Ukuran logo.
  static const double _kLogo = 62;

  @override
  void dispose() {
    // Semua controller harus di-dispose agar tidak membuang memory.
    _namaDepanController.dispose();
    _namaBelakangController.dispose();
    _usernameController.dispose();
    _noTeleponController.dispose();
    _emailController.dispose();
    _alamatController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  // Fungsi ini dijalankan saat tombol daftar ditekan.
  void _register() async {
    // Mengambil isi input dan menghapus spasi di awal/akhir.
    String namaDepan = _namaDepanController.text.trim();
    String namaBelakang = _namaBelakangController.text.trim();
    String username = _usernameController.text.trim();
    String noTelepon = _noTeleponController.text.trim();
    String email = _emailController.text.trim();
    String alamat = _alamatController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    // Validasi nama depan.
    if (namaDepan.isEmpty) {
      AppNotification.showError(
        context,
        'Nama depan tidak boleh kosong',
      );
      return;
    }

    // Validasi username.
    if (username.isEmpty) {
      AppNotification.showError(
        context,
        'Username tidak boleh kosong',
      );
      return;
    }

    // Validasi nomor telepon.
    if (noTelepon.isEmpty) {
      AppNotification.showError(
        context,
        'Nomor telepon tidak boleh kosong',
      );
      return;
    }

    // Validasi email.
    if (email.isEmpty) {
      AppNotification.showError(
        context,
        'Email tidak boleh kosong',
      );
      return;
    }

    // Validasi sederhana format email.
    if (!email.contains('@')) {
      AppNotification.showError(
        context,
        'Format email tidak valid',
      );
      return;
    }

    // Validasi alamat.
    if (alamat.isEmpty) {
      AppNotification.showError(
        context,
        'Alamat tidak boleh kosong',
      );
      return;
    }

    // Validasi password.
    if (password.isEmpty) {
      AppNotification.showError(
        context,
        'Password tidak boleh kosong',
      );
      return;
    }

    // Firebase Authentication minimal password adalah 6 karakter.
    if (password.length < 6) {
      AppNotification.showError(
        context,
        'Password minimal 6 karakter',
      );
      return;
    }

    // Validasi konfirmasi password.
    if (confirmPassword.isEmpty) {
      AppNotification.showError(
        context,
        'Konfirmasi password tidak boleh kosong',
      );
      return;
    }

    // Mengecek apakah password dan konfirmasi password sama.
    if (confirmPassword != password) {
      AppNotification.showError(
        context,
        'Password tidak cocok',
      );
      return;
    }

    // Jika semua validasi lolos, loading dinyalakan.
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Membuat akun baru di Firebase Authentication.
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // UID digunakan sebagai id dokumen user di Firestore.
      String uid = credential.user!.uid;

      // 2. Menyimpan data profil user ke collection users.
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'nama_depan': namaDepan,
        'nama_belakang': namaBelakang,
        'username': username,
        'no_telepon': noTelepon,
        'email': email,
        'alamat': alamat,
        'role': 'user',
        'created_at': FieldValue.serverTimestamp(),
      });

      // 3. Setelah register, user dibuat logout.
      // Jadi user harus login manual di halaman login.
      await _auth.signOut();

      if (mounted) {
        // Notifikasi sukses muncul dengan background hijau.
        // Karena AppNotification memakai rootOverlay,
        // popup tetap muncul walaupun halaman langsung pindah.
        AppNotification.showSuccess(
          context,
          'Akun berhasil dibuat! Silakan login.',
        );

        // Setelah berhasil daftar, pindah ke halaman login.
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

      // Function dihentikan agar tidak menjalankan setState setelah pindah halaman.
      return;
    } on FirebaseAuthException catch (e) {
      // Error khusus dari Firebase Authentication.
      if (mounted) {
        if (e.code == 'email-already-in-use') {
          AppNotification.showError(
            context,
            'Email sudah digunakan. Coba email lain.',
          );
        } else if (e.code == 'weak-password') {
          AppNotification.showError(
            context,
            'Password terlalu lemah. Minimal 6 karakter.',
          );
        } else if (e.code == 'invalid-email') {
          AppNotification.showError(
            context,
            'Format email tidak valid.',
          );
        } else {
          AppNotification.showError(
            context,
            'Registrasi gagal. Coba lagi.',
          );
        }
      }
    } catch (e) {
      // Error umum selain FirebaseAuthException.
      if (mounted) {
        AppNotification.showError(
          context,
          'Terjadi kesalahan. Coba lagi.',
        );
      }
    }

    // Loading dimatikan jika halaman masih aktif.
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  // Widget ini digunakan untuk icon biasa di kanan input.
  // Padding kanan dibuat mirip dengan halaman login.
  Widget _buildSuffixIcon(List<List<dynamic>> icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 13),
      child: Center(
        widthFactor: 1,
        heightFactor: 1,
        child: HugeIcon(
          icon: icon,
          color: const Color.fromARGB(255, 148, 147, 147),
          size: 22,
        ),
      ),
    );
  }

  // Widget ini digunakan untuk tombol show/hide password.
  // Bentuknya disamakan dengan halaman login agar terlihat seperti tombol toggle.
  Widget _buildPasswordToggle({
    required bool obscure,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 1.3),
      child: Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: obscure
              ? const Color(0xFFF0F0F0)
              : _kButton.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          tooltip: obscure ? 'Tampilkan password' : 'Sembunyikan password',
          onPressed: onPressed,
          icon: HugeIcon(
            icon: obscure
                ? HugeIcons.strokeRoundedView
                : HugeIcons.strokeRoundedViewOff,
            color: obscure
                ? const Color.fromARGB(255, 120, 120, 120)
                : _kButton,
            size: 22,
          ),
        ),
      ),
    );
  }

  // Widget reusable untuk membuat TextField.
  // Ini dibuat agar kode input tidak ditulis berulang terlalu banyak.
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required Widget suffixIcon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFFAAAAAA),
          fontSize: 14,
        ),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: _kBg,

      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gambar background bagian atas.
            SizedBox(
              height: 230,
              width: double.infinity,
              child: Image.asset(
                'assets/img/fix_login_bg.jpg',
                fit: BoxFit.cover,
              ),
            ),

            // Logo dan nama aplikasi.
            Transform.translate(
              offset: const Offset(0, -_kLogo / 2),
              child: Column(
                children: [
                  // Logo aplikasi berbentuk lingkaran.
                  Container(
                    width: _kLogo * 2,
                    height: _kLogo * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/icon/sahabatsatwa_logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'SahabatSatwa',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          blurRadius: 6,
                          color: Colors.black45,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Panel form register.
            Transform.translate(
              offset: const Offset(0, -40),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: _kBg,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(35),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul halaman register.
                      const Text(
                        'Daftar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        'Masukkan data akun untuk mendaftar.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Input nama depan.
                      _buildTextField(
                        controller: _namaDepanController,
                        hint: 'Nama Depan',
                        keyboardType: TextInputType.name,
                        suffixIcon: _buildSuffixIcon(
                          HugeIcons.strokeRoundedUser,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Input nama belakang. Field ini opsional.
                      _buildTextField(
                        controller: _namaBelakangController,
                        hint: 'Nama Belakang (opsional)',
                        keyboardType: TextInputType.name,
                        suffixIcon: _buildSuffixIcon(
                          HugeIcons.strokeRoundedUser,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Input username.
                      _buildTextField(
                        controller: _usernameController,
                        hint: 'Username',
                        suffixIcon: _buildSuffixIcon(
                          HugeIcons.strokeRoundedUser,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Input nomor telepon.
                      _buildTextField(
                        controller: _noTeleponController,
                        hint: 'Nomor Telepon',
                        keyboardType: TextInputType.phone,
                        suffixIcon: _buildSuffixIcon(
                          HugeIcons.strokeRoundedSmartPhone01,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Input email.
                      _buildTextField(
                        controller: _emailController,
                        hint: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        suffixIcon: _buildSuffixIcon(
                          HugeIcons.strokeRoundedMail01,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Input alamat.
                      _buildTextField(
                        controller: _alamatController,
                        hint: 'Alamat',
                        suffixIcon: _buildSuffixIcon(
                          HugeIcons.strokeRoundedLocation01,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Input password.
                      _buildTextField(
                        controller: _passwordController,
                        hint: 'Password',
                        obscureText: _obscurePassword,
                        suffixIcon: _buildPasswordToggle(
                          obscure: _obscurePassword,
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Input konfirmasi password.
                      _buildTextField(
                        controller: _confirmPasswordController,
                        hint: 'Konfirmasi Password',
                        obscureText: _obscureConfirm,
                        suffixIcon: _buildPasswordToggle(
                          obscure: _obscureConfirm,
                          onPressed: () {
                            setState(() {
                              _obscureConfirm = !_obscureConfirm;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 12),



                      const SizedBox(height: 28),

                      // Tombol daftar.
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kButton,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Daftar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Tombol kembali ke halaman login.
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Sudah punya akun? ',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),

                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Masuk',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}