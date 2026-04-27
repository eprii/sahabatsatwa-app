import 'package:flutter/material.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Controller untuk setiap animasi
  late AnimationController _blobController;
  late AnimationController _textController;

  // Animasi blob hijau expand
  late Animation<double> _blobScale;
  late Animation<double> _blobOpacity;

  // Animasi teks fly-up
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  static const Color _green = Color(0xFF5C7A4E);

  @override
  void initState() {
    super.initState();

    // ── BLOB CONTROLLER ──
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _blobScale = Tween<double>(begin: 0.0, end: 30.0).animate(
      CurvedAnimation(parent: _blobController, curve: Curves.easeInOut),
    );

    _blobOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _blobController,
        curve: const Interval(0.0, 0.2, curve: Curves.easeIn),
      ),
    );

    // ── TEXT CONTROLLER ──
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    // ── URUTAN ANIMASI ──
    _runAnimation();
  }

  Future<void> _runAnimation() async {
    // 1. Diam 2 detik — logo di tengah, bg putih
    await Future.delayed(const Duration(milliseconds: 2400));

    // 2. Blob hijau expand memenuhi layar
    await _blobController.forward();

    // 3. Teks "Selamat Datang" fly-up
    await Future.delayed(const Duration(milliseconds: 300));
    await _textController.forward();

    // 4. Tahan sebentar lalu transisi ke beranda
    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainNavigation(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  void dispose() {
    _blobController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // ── BLOB HIJAU yang expand ──
          AnimatedBuilder(
            animation: _blobController,
            builder: (context, child) {
              return Opacity(
                opacity: _blobOpacity.value,
                child: Transform.scale(
                  scale: _blobScale.value,
                  child: Container(
                    width: size.width * 0.5,
                    height: size.width * 0.5,
                    decoration: const BoxDecoration(
                      color: _green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),

          // ── LOGO + TEKS di tengah ──
          SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              // Logo
              Image.asset(
                'assets/icon/sahabatsatwa_logo.png',
                width: 160,
                height: 160,
              ),

              const SizedBox(height: 24),

              // Teks "Selamat Datang" fly-up
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _textOpacity,
                    child: SlideTransition(
                      position: _textSlide,
                      child: child,
                    ),
                  );
                },
                child: const Text(
                  'Selamat Datang',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
            ),
          ),
        ],
      ),
    );
  }
}
