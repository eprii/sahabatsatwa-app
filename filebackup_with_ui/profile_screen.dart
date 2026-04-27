import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 48,
              child: Icon(Icons.person, size: 48),
            ),
            SizedBox(height: 16),
            Text('Admin SahabatSatwa',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('admin@sahabatsatwa.id',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
