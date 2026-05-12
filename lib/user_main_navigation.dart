import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'app_theme.dart';
import 'sahabat_satwa_list_screen.dart';
import 'search_screen.dart';
import 'favourites_screen.dart';
import 'profile_screen.dart';

class UserNavigation extends StatefulWidget {
  const UserNavigation({super.key});

  @override
  State<UserNavigation> createState() => _UserNavigationState();
}

class _UserNavigationState extends State<UserNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    SahabatSatwaListScreen(),
    SearchScreen(),
    FavouritesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 12, offset: Offset(0, -2)),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedHome01,
                  color: Colors.grey,
                  size: 24),
              activeIcon: HugeIcon(
                  icon: HugeIcons.strokeRoundedHome01,
                  color: AppTheme.primary,
                  size: 24),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedSearch01,
                  color: Colors.grey,
                  size: 24),
              activeIcon: HugeIcon(
                  icon: HugeIcons.strokeRoundedSearch01,
                  color: AppTheme.primary,
                  size: 24),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedBookmark01,
                  color: Colors.grey,
                  size: 24),
              activeIcon: HugeIcon(
                  icon: HugeIcons.strokeRoundedBookmark02,
                  color: AppTheme.primary,
                  size: 24),
              label: 'Favorit',
            ),
            BottomNavigationBarItem(
              icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedUser,
                  color: Colors.grey,
                  size: 24),
              activeIcon: HugeIcon(
                  icon: HugeIcons.strokeRoundedUser,
                  color: AppTheme.primary,
                  size: 24),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}