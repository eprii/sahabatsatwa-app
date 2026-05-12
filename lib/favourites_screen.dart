import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sahabat_satwa_model.dart';
import 'detail_sahabat_satwa_screen.dart';
import 'app_theme.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text(
                'Favoritmu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Expanded(
              child: uid == null
                  ? const Center(
                      child: Text('Login dulu untuk melihat favorit!',
                          style: TextStyle(color: Colors.white70)))
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('favourites')
                          .where('id_user', isEqualTo: uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white));
                        }

                        if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.bookmark_border,
                                    color: Colors.white38, size: 64),
                                SizedBox(height: 12),
                                Text('Belum ada favorit',
                                    style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16)),
                                SizedBox(height: 4),
                                Text(
                                    'Simpan destinasi favoritmu\ndari halaman detail!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white38,
                                        fontSize: 13)),
                              ],
                            ),
                          );
                        }

                        final favDocs = snapshot.data!.docs;

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: favDocs.length,
                          itemBuilder: (context, index) {
                            final idZoo = favDocs[index]['id_zoo'];
                            final idFavourit = favDocs[index].id;

                            return FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('destination')
                                  .doc(idZoo)
                                  .get(),
                              builder: (context, zooSnap) {
                                if (!zooSnap.hasData) {
                                  return const SizedBox(height: 80);
                                }

                                if (!zooSnap.data!.exists) {
                                  return const SizedBox();
                                }

                                final zoo = SahabatSatwa.fromDocument(
                                    zooSnap.data!);

                                return _FavouriteCard(
                                  zoo: zoo,
                                  idFavourit: idFavourit,
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavouriteCard extends StatelessWidget {
  final SahabatSatwa zoo;
  final String idFavourit;
  const _FavouriteCard({required this.zoo, required this.idFavourit});

  Future<void> _removeFavourite(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('favourites')
        .doc(idFavourit)
        .delete();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dihapus dari favorit')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => DetailSahabatSatwaScreen(data: zoo)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08), blurRadius: 8),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: zoo.foto_url.isNotEmpty
                  ? Image.network(
                      zoo.foto_url,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    zoo.nama_zoo,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 12, color: AppTheme.textMuted),
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
                ],
              ),
            ),

            // Hapus dari favorit
            IconButton(
              icon: const Icon(Icons.bookmark,
                  color: AppTheme.primary, size: 22),
              onPressed: () => _removeFavourite(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 70,
        height: 70,
        color: Colors.grey[300],
        child: const Icon(Icons.photo, color: Colors.grey),
      );
}