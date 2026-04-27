import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF5C7A4E);
  static const Color primaryDark = Color(0xFF3D5C33);
  static const Color background = Color(0xFF6B8C5A);
  static const Color cardBg = Color(0xFFF5F2EE);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF888888);
  static const Color gold = Color(0xFFE8A020);

  static ThemeData get theme => ThemeData(
        useMaterial3: false,
        primaryColor: primary,
        scaffoldBackgroundColor: background,
        // ✅ Poppins sebagai font utama
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: const ColorScheme.light(
          primary: primary,
          secondary: primaryDark,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      );
}
