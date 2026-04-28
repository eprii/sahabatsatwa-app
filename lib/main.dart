import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hugeicons/hugeicons.dart';
import 'firebase_options.dart';
import 'app_theme.dart';
import 'sahabat_satwa_list_screen.dart';
import 'search_screen.dart';
import 'admin_list_screen.dart';
import 'profile_screen.dart';
import 'splash_screen.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterNativeSplash.remove();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SahabatSatwa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const SplashScreen(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    SahabatSatwaListScreen(),
    SearchScreen(),
    AdminListScreen(),
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
            BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -2)),
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
              icon: HugeIcon(icon: HugeIcons.strokeRoundedHome01, color: Colors.grey, size: 24),
              activeIcon: HugeIcon(icon: HugeIcons.strokeRoundedHome01, color: AppTheme.primary, size: 24),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: HugeIcon(icon: HugeIcons.strokeRoundedSearch01, color: Colors.grey, size: 24),
              activeIcon: HugeIcon(icon: HugeIcons.strokeRoundedSearch01, color: AppTheme.primary, size: 24),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: HugeIcon(icon: HugeIcons.strokeRoundedPlusSign, color: Colors.grey, size: 29),
              activeIcon: HugeIcon(icon: HugeIcons.strokeRoundedPlusSign, color: AppTheme.primary, size: 29),
              label: 'Add',
            ),
            BottomNavigationBarItem(
              icon: HugeIcon(icon: HugeIcons.strokeRoundedUser, color: Colors.grey, size: 26),
              activeIcon: HugeIcon(icon: HugeIcons.strokeRoundedUser, color: AppTheme.primary, size: 26),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
