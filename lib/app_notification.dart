import 'package:flutter/material.dart';


// File ini berisi helper untuk menampilkan notifikasi custom.
// Notifikasi akan muncul di tengah atas layar menggunakan OverlayEntry.
//
// OverlayEntry dipakai karena SnackBar bawaan Flutter biasanya muncul di bawah,
// sedangkan kita ingin popup muncul di bagian atas layar.
class AppNotification {
  // Variabel ini menyimpan notifikasi yang sedang tampil.
  // Tujuannya agar jika ada notifikasi baru, notifikasi lama dihapus dulu.
  static OverlayEntry? _currentEntry;

  // Function untuk menampilkan notifikasi sukses.
  // Contoh: data berhasil disimpan, alamat berhasil disalin.
  static void showSuccess(
    BuildContext context,
    String message,
  ) {
    _show(
      context: context,
      message: message,
      backgroundColor: const Color(0xFF7A873A),
      icon: Icons.check_circle_outline,
    );
  }

  // Function untuk menampilkan notifikasi error.
  // Contoh: login gagal, data gagal dikirim.
  static void showError(
    BuildContext context,
    String message,
  ) {
    _show(
      context: context,
      message: message,
      backgroundColor: Colors.redAccent,
      icon: Icons.error_outline,
    );
  }

  // Function untuk menampilkan notifikasi informasi.
  // Contoh: user harus login terlebih dahulu.
  static void showInfo(
    BuildContext context,
    String message,
  ) {
    _show(
      context: context,
      message: message,
      backgroundColor: const Color(0xFF4F6F52),
      icon: Icons.info_outline,
    );
  }

  // Function utama untuk membuat dan menampilkan popup.
  // Function ini dipakai oleh showSuccess, showError, dan showInfo.
  static void _show({
    required BuildContext context,
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    // Jika ada notifikasi lama yang masih tampil, hapus dulu.
    // Ini mencegah notifikasi menumpuk di layar.
    _currentEntry?.remove();
    _currentEntry = null;

  // Overlay.of(context, rootOverlay: true) digunakan agar notifikasi
  // tetap muncul walaupun halaman langsung berpindah.
    final overlay = Overlay.of(
      context,
      rootOverlay: true,
    );

    // MediaQuery digunakan untuk mengambil padding atas layar,
    // terutama agar popup tidak menabrak status bar.
    final topPadding = MediaQuery.of(context).padding.top;

    // OverlayEntry adalah widget yang akan dimasukkan ke atas layar.
    final entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          // Posisi popup dari atas layar.
          top: topPadding + 30,

          // Popup diberi jarak kiri dan kanan agar tidak menempel layar.
          left: 24,
          right: 24,

          child: Material(
            color: Colors.transparent,

            // SafeArea tambahan agar lebih aman di berbagai device.
            child: SafeArea(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.70),
                        blurRadius: 50,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),

                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon notifikasi.
                      Icon(
                        icon,
                        color: Colors.white,
                        size: 23,
                      ),

                      const SizedBox(width: 8),

                      // Flexible digunakan agar teks tidak overflow
                      // jika pesan notifikasi cukup panjang.
                      Flexible(
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    // Simpan entry ke _currentEntry.
    _currentEntry = entry;

    // Masukkan notifikasi ke overlay.
    overlay.insert(entry);

    // Setelah 3 detik, notifikasi akan otomatis hilang.
    Future.delayed(const Duration(seconds: 3), () {
      // Jika entry yang aktif masih sama, hapus dari layar.
      if (_currentEntry == entry) {
        entry.remove();
        _currentEntry = null;
      }
    });
  }
}