import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hugeicons/hugeicons.dart';

import 'register_screen.dart';
import 'main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _hidePass = true;
  bool _isLoading = false;
  bool _rememberMe = false;

  late final AnimationController _bannerCtrl;

  static const Color _kPanel = Color(0xFF7B8860);
  static const Color _kButton = Color(0xFF1E5A27);

  static const double _kLogo = 62;
  static const double _kCurve = 35;

  @override
  void initState() {
    super.initState();

    _bannerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );


  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _bannerCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );

      if (mounted) {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AuthWrapper(),
          ),
        );

      }

    } on FirebaseAuthException catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'Login gagal',
          ),
        ),
      );

    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: _kPanel,

      body: SingleChildScrollView(

        physics: const ClampingScrollPhysics(),
        keyboardDismissBehavior:
            ScrollViewKeyboardDismissBehavior.manual,

          child: Column(
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
                    color: _kPanel,

                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(_kCurve),
                    ),
                  ),

                  child: Padding(

                    padding: EdgeInsets.fromLTRB(
                      24,
                      0,
                      24,
                      MediaQuery.of(context).viewInsets.bottom + 16,
                    ),

                    child: Form(
                      key: _formKey,

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          /// TITLE

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

                          /// EMAIL

                          _InputField(
                            controller: _emailCtrl,
                            hint: 'Masukkan Email',

                            keyboardType:
                                TextInputType.emailAddress,

                            suffixIcon: Padding(
                              padding: const EdgeInsets.all(14),

                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedUser,
                                color: const Color.fromARGB(255, 148, 147, 147),
                                size: 22,
                              ),
                            ),

                            validator: (v) {

                              if (v == null || v.isEmpty) {
                                return 'Email tidak boleh kosong';
                              }

                              return null;

                            },
                          ),

                          const SizedBox(height: 14),

                          /// PASSWORD

                          _InputField(
                            controller: _passCtrl,
                            hint: 'Masukkan Password',
                            obscure: _hidePass,

                            suffixIcon: IconButton(

                              onPressed: () {

                                setState(() {
                                  _hidePass = !_hidePass;
                                });

                              },

                              icon: HugeIcon(

                                icon: _hidePass
                                    ? HugeIcons.strokeRoundedView
                                    : HugeIcons.strokeRoundedViewOff,

                                color: const Color.fromARGB(255, 148, 147, 147),
                                size: 22,
                              ),
                            ),

                            validator: (v) {

                              if (v == null || v.isEmpty) {
                                return 'Password tidak boleh kosong';
                              }

                              return null;

                            },
                          ),

                          const SizedBox(height: 12),

                          /// REMEMBER ME

                          Row(
                            children: [

                              SizedBox(
                                width: 20,
                                height: 20,

                                child: Checkbox(

                                  value: _rememberMe,

                                  onChanged: (v) {

                                    setState(() {
                                      _rememberMe = v ?? false;
                                    });

                                  },

                                  activeColor: _kButton,
                                  checkColor: Colors.white,

                                  side: const BorderSide(
                                    color: Colors.white60,
                                    width: 1.5,
                                  ),

                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(4),
                                  ),

                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),

                              const SizedBox(width: 8),

                              const Text(
                                'Remember me',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),

                            ],
                          ),

                          const SizedBox(height: 28),

                          /// LOGIN BUTTON

                          SizedBox(
                            width: double.infinity,
                            height: 54,

                            child: ElevatedButton(

                              onPressed:
                                  _isLoading ? null : _login,

                              style: ElevatedButton.styleFrom(
                                backgroundColor: _kButton,

                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),

                                elevation: 0,
                              ),

                              child: _isLoading

                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,

                                      child:
                                          CircularProgressIndicator(
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

                          /// REGISTER

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
                                        builder: (_) =>
                                            const RegisterScreen(),
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

/// ======================================================
/// INPUT FIELD
/// ======================================================

class _InputField extends StatelessWidget {

  const _InputField({
    required this.controller,
    required this.hint,
    required this.suffixIcon,
    required this.validator,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
  });

  final TextEditingController controller;
  final String hint;
  final Widget suffixIcon;
  final String? Function(String?) validator;

  final bool obscure;
  final TextInputType keyboardType;

  static final _border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide.none,
  );

  static final _errBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),

    borderSide: const BorderSide(
      color: Colors.redAccent,
      width: 1.5,
    ),
  );

  @override
  Widget build(BuildContext context) {

    return TextFormField(

      controller: controller,
      obscureText: obscure,
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

        border: _border,
        enabledBorder: _border,
        focusedBorder: _border,

        errorBorder: _errBorder,
        focusedErrorBorder: _errBorder,

      ),

      validator: validator,
    );
  }
}