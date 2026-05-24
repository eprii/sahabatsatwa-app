import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hugeicons/hugeicons.dart';

import 'register_screen.dart';
import 'main.dart';

// Halaman login digunakan untuk masuk ke aplikasi
// menggunakan email dan password dari Firebase Authentication.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  // FirebaseAuth digunakan untuk proses login.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Controller digunakan untuk mengambil isi input email.
  final TextEditingController _emailController = TextEditingController();

  // Controller digunakan untuk mengambil isi input password.
  final TextEditingController _passwordController = TextEditingController();

  // Variabel ini digunakan untuk menyimpan pesan error login.
  String _errorMessage = '';

  // Variabel ini digunakan untuk menyembunyikan atau menampilkan password.
  bool _hidePassword = true;

  // Variabel ini digunakan untuk menampilkan loading pada tombol login.
  bool _isLoading = false;

  // Warna utama halaman login.
  static const Color _kPanel = Color(0xFF7B8860);
  static const Color _kButton = Color(0xFF1E5A27);

  // Ukuran logo dan lengkungan panel.
  static const double _kLogo = 62;
  static const double _kCurve = 35;

  @override
  void dispose() {
    // Controller harus di-dispose agar tidak membuang memory.
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  // Fungsi ini dijalankan saat tombol login ditekan.
  void _login() async {
    // Ambil isi email dari TextField dan hapus spasi depan/belakang.
    String email = _emailController.text.trim();

    // Ambil isi password dari TextField dan hapus spasi depan/belakang.
    String password = _passwordController.text.trim();

    // Validasi sederhana: email tidak boleh kosong.
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Email tidak boleh kosong';
      });

      return;
    }

    // Validasi sederhana: password tidak boleh kosong.
    if (password.isEmpty) {
      setState(() {
        _errorMessage = 'Password tidak boleh kosong';
      });

      return;
    }

    // Loading dinyalakan agar user tahu proses login sedang berjalan.
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Proses login menggunakan Firebase Authentication.
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Jika login berhasil dan user tidak null,
      // maka user diarahkan ke AuthWrapper.
      if (userCredential.user != null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const AuthWrapper();
              },
            ),
          );
        }

        // Function dihentikan supaya setState loading tidak jalan
        // setelah halaman login diganti.
        return;
      }
    } catch (e) {
      // Jika login gagal, pesan error disimpan ke _errorMessage.
      if (mounted) {
        setState(() {
          _errorMessage = 'Email atau password salah';
        });
      }
    }

    // Loading dimatikan jika halaman masih aktif.
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: _kPanel,

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

            // Panel form login.
            Transform.translate(
              offset: const Offset(0, -40),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: _kPanel,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(_kCurve),
                  ),
                ),

                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul login.
                      const Text(
                        'Silakan masuk',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        'Gunakan email dan password yang sudah terdaftar.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Input email.
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Masukkan Email',
                          hintStyle: const TextStyle(
                            color: Color(0xFFAAAAAA),
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 13),
                          child: Center(
                            widthFactor: 1,
                            heightFactor: 1,
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedUser,
                              color: const Color.fromARGB(255, 148, 147, 147),
                              size: 22,
                            ),
                          ),
                        ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Input password.
                      TextField(
                        controller: _passwordController,
                        obscureText: _hidePassword,
                        decoration: InputDecoration(
                          hintText: 'Masukkan Password',
                          hintStyle: const TextStyle(
                            color: Color(0xFFAAAAAA),
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 1.3),
                            child: Container(
                              margin: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: _hidePassword
                                    ? const Color(0xFFF0F0F0)
                                    : _kButton.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: IconButton(
                                tooltip: _hidePassword
                                    ? 'Tampilkan password'
                                    : 'Sembunyikan password',
                                onPressed: () {
                                  setState(() {
                                    _hidePassword = !_hidePassword;
                                  });
                                },
                                icon: HugeIcon(
                                  icon: _hidePassword
                                      ? HugeIcons.strokeRoundedView
                                      : HugeIcons.strokeRoundedViewOff,
                                  color: _hidePassword
                                      ? const Color.fromARGB(255, 120, 120, 120)
                                      : _kButton,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Pesan error login.
                      // Jika _errorMessage kosong, widget tidak ditampilkan.
                      if (_errorMessage.isNotEmpty)
                        Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                          ),
                        ),

                      const SizedBox(height: 28),

                      // Tombol login.
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kButton,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),

                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Tombol menuju halaman register.
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Tidak punya akun? ',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),

                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return const RegisterScreen();
                                    },
                                  ),
                                );
                              },
                              child: const Text(
                                'Daftar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
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