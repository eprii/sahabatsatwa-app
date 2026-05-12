import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hugeicons/hugeicons.dart';
import 'sahabat_satwa_model.dart';
import 'detail_sahabat_satwa_screen.dart';
import 'app_theme.dart';

class SahabatSatwaListScreen extends StatelessWidget {
  const SahabatSatwaListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('destination')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.white));
            }

            final docs = snapshot.data?.docs ?? [];
            final zoos = docs.map((d) => SahabatSatwa.fromDocument(d)).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/icon/sahabatsatwa_logo.png',
                            width: 36,
                            height: 36,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'SahabatSatwa',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${zoos.length} destinasi',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

                // GREETING CARD 
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF3D5C33),
                          Color(0xFF6B8C5A),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Temukan Kebun\nBinatang Favoritmu!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 10),
                        
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: zoos.length,
                    itemBuilder: (context, index) {
                      final zoo = zoos[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        color: AppTheme.cardBg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16)),
                                  child: zoo.foto_url.isNotEmpty
                                      ? Image.network(
                                          zoo.foto_url,
                                          height: 160,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => _placeholder(),
                                        )
                                      : _placeholder(),
                                ),
                                if (zoo.provinsi.isNotEmpty)
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryDark.withOpacity(0.85),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        zoo.provinsi,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            ListTile(
                              title: Text(
                                zoo.nama_zoo,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              subtitle: Row(
                                children: [
                                  HugeIcon(
                                    icon: HugeIcons.strokeRoundedLocation01,
                                    color: AppTheme.textMuted,
                                    size: 13,
                                  ),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      zoo.alamat.isNotEmpty ? zoo.alamat : '-',
                                      style: const TextStyle(
                                          fontSize: 12, color: AppTheme.textMuted),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(FirebaseAuth.instance.currentUser?.uid)
                                    .get(),
                                builder: (context, userSnap) {
                                  final role = userSnap.data?.exists == true
                                      ? (userSnap.data!.data()
                                              as Map<String, dynamic>)['role'] ??
                                          'user'
                                      : 'user';

                                  // Jika admin, tidak tampilkan tombol favorit
                                  if (role == 'admin') {
                                    return const SizedBox();
                                  }

                                  return StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('favourites')
                                        .where('id_user',
                                            isEqualTo: FirebaseAuth
                                                .instance.currentUser?.uid)
                                        .where('id_zoo', isEqualTo: zoo.id_zoo)
                                        .snapshots(),
                                    builder: (context, favSnap) {
                                      final isFav = favSnap.hasData &&
                                          favSnap.data!.docs.isNotEmpty;
                                      return GestureDetector(
                                        onTap: () async {
                                          final uid = FirebaseAuth
                                              .instance.currentUser?.uid;
                                          if (uid == null) return;
                                          final favRef = FirebaseFirestore
                                              .instance
                                              .collection('favourites');
                                          final existing = await favRef
                                              .where('id_user', isEqualTo: uid)
                                              .where('id_zoo',
                                                  isEqualTo: zoo.id_zoo)
                                              .get();
                                          if (existing.docs.isNotEmpty) {
                                            await favRef
                                                .doc(existing.docs.first.id)
                                                .delete();
                                          } else {
                                            await favRef.add({
                                              'id_user': uid,
                                              'id_zoo': zoo.id_zoo,
                                              'saved_at': FieldValue
                                                  .serverTimestamp(),
                                            });
                                          }
                                        },
                                        child: HugeIcon(
                                          icon: isFav
                                              ? HugeIcons
                                                  .strokeRoundedBookmarkCheck02
                                              : HugeIcons
                                                  .strokeRoundedBookmarkAdd01,
                                          color: isFav
                                              ? const Color.fromARGB(
                                                  255, 69, 185, 15)
                                              : AppTheme.textMuted,
                                          size: 22,
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailSahabatSatwaScreen(data: zoo),
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DetailSahabatSatwaScreen(data: zoo),
                                    ),
                                  ),
                                  child: const Text('Lihat Detail'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 160,
      width: double.infinity,
      color: Colors.grey[300],
      child: HugeIcon(
        icon: HugeIcons.strokeRoundedImage01,
        color: Colors.grey,
        size: 48,
      ),
    );
  }
}