import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

      // 3. User harus login manual
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
      appBar: AppBar(title: const Text('Daftar Akun')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Nama Depan
            TextFormField(
              controller: _namaDepanController,
              decoration: const InputDecoration(
                labelText: 'Nama Depan',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Nama depan tidak boleh kosong' : null,
            ),
            const SizedBox(height: 12),

            // Nama Belakang
            TextFormField(
              controller: _namaBelakangController,
              decoration: const InputDecoration(
                labelText: 'Nama Belakang (opsional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Username
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
                hintText: 'cth: johndoe123',
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Username tidak boleh kosong' : null,
            ),
            const SizedBox(height: 12),

            // No Telepon
            TextFormField(
              controller: _noTeleponController,
              decoration: const InputDecoration(
                labelText: 'Nomor Telepon',
                border: OutlineInputBorder(),
                hintText: '08xxxxxxxxxx',
              ),
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Nomor telepon tidak boleh kosong' : null,
            ),
            const SizedBox(height: 12),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email tidak boleh kosong';
                if (!v.contains('@')) return 'Format email tidak valid';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Alamat
            TextFormField(
              controller: _alamatController,
              decoration: const InputDecoration(
                labelText: 'Alamat',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),

            // Password
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              obscureText: _obscurePassword,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password tidak boleh kosong';
                if (v.length < 6) return 'Password minimal 6 karakter';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Konfirmasi Password
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Konfirmasi Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              obscureText: _obscureConfirm,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Konfirmasi password tidak boleh kosong';
                if (v != _passwordController.text) return 'Password tidak cocok';
                return null;
              },
            ),
            const SizedBox(height: 8),

            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Daftar'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}