import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hugeicons/hugeicons.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _namaDepanController = TextEditingController();
  final _namaBelakangController = TextEditingController();
  final _usernameController = TextEditingController();
  final _noTeleponController = TextEditingController();
  final _emailController = TextEditingController();
  final _alamatController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String _errorMessage = '';

  static const Color _kBg     = Color(0xFF7B8860);
  static const Color _kButton = Color(0xFF1E5A27);
    static const double _kLogo = 62;

  

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 1. Buat akun di Firebase Auth
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = credential.user!.uid;

      // 2. Simpan data profil ke Firestore collection 'users'
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'nama_depan': _namaDepanController.text.trim(),
        'nama_belakang': _namaBelakangController.text.trim(),
        'username': _usernameController.text.trim(),
        'no_telepon': _noTeleponController.text.trim(),
        'email': _emailController.text.trim(),
        'alamat': _alamatController.text.trim(),
        'role': 'user', 
        'created_at': FieldValue.serverTimestamp(),
      });

      // 3. User login manual setelah register 
      await FirebaseAuth.instance.signOut();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akun berhasil dibuat! Silakan login.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'email-already-in-use') {
          _errorMessage = 'Email sudah digunakan. Coba email lain.';
        } else if (e.code == 'weak-password') {
          _errorMessage = 'Password terlalu lemah. Minimal 6 karakter.';
        } else {
          _errorMessage = 'Registrasi gagal. Coba lagi.';
        }
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
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
            /// =========================
            /// BACKGROUND IMAGE
            /// =========================

            SizedBox(
              height: 230,
              width: double.infinity,
              child: Image.asset(
                'assets/img/fix_login_bg.jpg',
                fit: BoxFit.cover,
              ),
            ),

            /// =========================
            /// LOGO + TEXT
            /// =========================

            Transform.translate(
              offset: const Offset(0, -_kLogo / 2),
              child: Column(
                children: [

                  /// LOGO

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

                  /// TEXT

                  const SizedBox(height: 10),

                  const Text(
                    "SahabatSatwa",

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

            /// PANEL

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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // Judul 

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
                          'Masukkan username, email, dan password untuk mendaftar.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Nama Depan 

                        _InputField(
                          controller: _namaDepanController,
                          hint: 'Nama Depan',
                          keyboardType: TextInputType.name,
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(14),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedUser,
                              color: const Color(0xFFAAAAAA),
                              size: 22,
                            ),
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Nama depan tidak boleh kosong' : null,
                        ),
                        const SizedBox(height: 14),

                        // Nama Belakang

                        _InputField(
                          controller: _namaBelakangController,
                          hint: 'Nama Belakang (opsional)',
                          keyboardType: TextInputType.name,
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(14),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedUser,
                              color: const Color(0xFFAAAAAA),
                              size: 22,
                            ),
                          ),
                          validator: (v) => null,
                        ),
                        const SizedBox(height: 14),

                        // Username

                        _InputField(
                          controller: _usernameController,
                          hint: 'Username',
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(14),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedUser,
                              color: const Color(0xFFAAAAAA),
                              size: 22,
                            ),
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Username tidak boleh kosong' : null,
                        ),
                        const SizedBox(height: 14),

                        // Nomor Telepon

                        _InputField(
                          controller: _noTeleponController,
                          hint: 'Nomor Telepon',
                          keyboardType: TextInputType.phone,
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(14),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedSmartPhone01,
                              color: const Color(0xFFAAAAAA),
                              size: 22,
                            ),
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Nomor telepon tidak boleh kosong' : null,
                        ),
                        const SizedBox(height: 14),

                        // Email

                        _InputField(
                          controller: _emailController,
                          hint: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(14),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedMail01,
                              color: const Color(0xFFAAAAAA),
                              size: 22,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Email tidak boleh kosong';
                            if (!v.contains('@')) return 'Format email tidak valid';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Alamat

                        _InputField(
                          controller: _alamatController,
                          hint: 'Alamat',
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(14),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedLocation01,
                              color: const Color(0xFFAAAAAA),
                              size: 22,
                            ),
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Alamat tidak boleh kosong' : null,
                        ),
                        const SizedBox(height: 14),

                        // Password

                        _InputField(
                          controller: _passwordController,
                          hint: 'Password',
                          obscure: _obscurePassword,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: HugeIcon(
                              icon: _obscurePassword
                                  ? HugeIcons.strokeRoundedView
                                  : HugeIcons.strokeRoundedViewOff,
                              color: const Color(0xFFAAAAAA),
                              size: 22,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Password tidak boleh kosong';
                            if (v.length < 6) return 'Password minimal 6 karakter';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Konfirmasi Password

                        _InputField(
                          controller: _confirmPasswordController,
                          hint: 'Konfirmasi Password',
                          obscure: _obscureConfirm,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureConfirm = !_obscureConfirm;
                              });
                            },
                            icon: HugeIcon(
                              icon: _obscureConfirm
                                  ? HugeIcons.strokeRoundedView
                                  : HugeIcons.strokeRoundedViewOff,
                              color: const Color(0xFFAAAAAA),
                              size: 22,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Konfirmasi password tidak boleh kosong';
                            if (v != _passwordController.text) return 'Password tidak cocok';
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),

                        // Pesan Error

                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, bottom: 4),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 13,
                              ),
                            ),
                          ),

                        const SizedBox(height: 20),

                        // Tombol Daftar 

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

                        // Sudah punya akun? 

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
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
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
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// REUSABLE INPUT FIELD WIDGET
// ══════════════════════════════════════════════════════════════════════════════

class _InputField extends StatelessWidget {

  const _InputField({
    required this.controller,
    required this.hint,
    required this.suffixIcon,
    required this.validator,
    this.obscure      = false,
    this.keyboardType = TextInputType.text,
  });

  final TextEditingController     controller;
  final String                    hint;
  final Widget                    suffixIcon;
  final String? Function(String?) validator;
  final bool                      obscure;
  final TextInputType             keyboardType;

  static final OutlineInputBorder _border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide:   BorderSide.none,
  );

  static final OutlineInputBorder _errorBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide:   const BorderSide(color: Colors.redAccent, width: 1.5),
  );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller:   controller,
      obscureText:  obscure,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 14,
        color:    Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color:    Color(0xFFAAAAAA),
          fontSize: 14,
        ),
        filled:    true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical:   14,
        ),
        border:             _border,
        enabledBorder:      _border,
        focusedBorder:      _border,
        errorBorder:        _errorBorder,
        focusedErrorBorder: _errorBorder,
      ),
      validator: validator,
    );
  }
}