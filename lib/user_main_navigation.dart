import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import 'app_theme.dart';
import 'sahabat_satwa_list_screen.dart';
import 'search_screen.dart';
import 'favourites_screen.dart';
import 'profile_screen.dart';

// UserNavigation adalah halaman utama untuk user.
// Di sini terdapat BottomNavigationBar untuk berpindah halaman:
// Home, Search, Favorit, dan Profil.
class UserNavigation extends StatefulWidget {
  const UserNavigation({super.key});

  @override
  State<UserNavigation> createState() {
    return _UserNavigationState();
  }
}

class _UserNavigationState extends State<UserNavigation> {
  // _currentIndex digunakan untuk mengetahui tab mana yang sedang aktif.
  int _currentIndex = 0;

  // List halaman yang akan ditampilkan sesuai index BottomNavigationBar.
  final List<Widget> _pages = const [
    SahabatSatwaListScreen(),
    SearchScreen(),
    FavouritesScreen(),
    ProfileScreen(),
  ];

  // Fungsi ini dijalankan saat item navbar ditekan.
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body akan berubah sesuai index yang dipilih user.
      body: _pages[_currentIndex],

      // Container digunakan untuk memberi background putih dan shadow pada navbar.
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, -2),
            ),
          ],
        ),

        child: BottomNavigationBar(
          // Menentukan item navbar yang sedang aktif.
          currentIndex: _currentIndex,

          // Saat item ditekan, index akan berubah dan halaman ikut berubah.
          onTap: _onItemTapped,

          // fixed digunakan agar semua item memiliki posisi tetap.
          type: BottomNavigationBarType.fixed,

          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: Colors.grey,

          // Bagian ini membuat label/title di bawah icon tampil.
          showSelectedLabels: true,
          showUnselectedLabels: true,

          // Style label ketika item sedang aktif.
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),

          // Style label ketika item tidak aktif.
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.normal,
          ),

          elevation: 0,

          items: [
            BottomNavigationBarItem(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedHome01,
                color: Colors.grey,
                size: 24,
              ),
              activeIcon: HugeIcon(
                icon: HugeIcons.strokeRoundedHome01,
                color: AppTheme.primary,
                size: 24,
              ),
              label: 'Home',
            ),

            BottomNavigationBarItem(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedSearch01,
                color: Colors.grey,
                size: 24,
              ),
              activeIcon: HugeIcon(
                icon: HugeIcons.strokeRoundedSearch01,
                color: AppTheme.primary,
                size: 24,
              ),
              label: 'Cari',
            ),

            BottomNavigationBarItem(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedBookmark01,
                color: Colors.grey,
                size: 24,
              ),
              activeIcon: HugeIcon(
                icon: HugeIcons.strokeRoundedBookmark02,
                color: AppTheme.primary,
                size: 24,
              ),
              label: 'Favorit',
            ),

            BottomNavigationBarItem(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedUser,
                color: Colors.grey,
                size: 24,
              ),
              activeIcon: HugeIcon(
                icon: HugeIcons.strokeRoundedUser,
                color: AppTheme.primary,
                size: 24,
              ),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}