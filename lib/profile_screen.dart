import 'package:flutter/material.dart';
import 'app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text('Admin SahabatSatwa',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('admin@sahabatsatwa.id',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
